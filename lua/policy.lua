-- The player. It only ever receives what agent.lua lets it see (old observations) and decides
-- every few frames, like a person would. It predicts where hazards are going, including any
-- ladder a barrel might take, and only commits to a move that stays clear of all of them.
local P = {}
local LEFT, RIGHT, UP, DOWN, JUMP = 1, 2, 4, 8, 16

-- Measured from traced games.
local WALK = 0.67          -- Mario pixels per frame
local CLIMB = 0.36
local ROLL = 1.0           -- barrel pixels per frame
local ARC = {0,-2,-3,-4,-5,-6,-7,-8,-9,-9,-10,-11,-11,-12,-12,-13,-13,-13,-13,-14,-14,-14,-14,-13,-13,-13,-13,-12,-12,-11,-11,-10,-9,-9,-8,-7,-6,-5,-4,-3,-2}
local JUMP_X = 0.5
local JUMP_LEN = #ARC

-- floor -> the ladder Mario takes: x, height to climb to, direction to walk on that floor
-- arrive = the side of the ladder to wait on. Near a girder end he waits on the open side, because
-- barrels landing from the end leave no time to react; otherwise past the ladder, so one coming
-- down it rolls away from him.
P.ROUTE = {
  [1] = {x = 203, top = 213, arrive = -1},
  [2] = {x = 115, top = 175, arrive = -1},
  [3] = {x = 203, top = 143, arrive = -1},
  [4] = {x = 51,  top = 114, arrive = 1},
  [5] = {x = 203, top = 81,  arrive = -1},   -- the ladder at x=107 is broken and stops at y=97
  [6] = {x = 147, top = 50,  arrive = -1},   -- up to Pauline, which clears the board
}

-- Girder heights for barrels (y = a + s*x) and the way they roll on each level.
local LEVEL = {
  [6] = {a = 74.6,  s = 0.036,   dir = 1},
  [5] = {a = 118.5, s = -0.0626, dir = -1},
  [4] = {a = 135.5, s = 0.0626,  dir = 1},
  [3] = {a = 184.5, s = -0.0626, dir = -1},
  [2] = {a = 201.5, s = 0.0626,  dir = 1},
  [1] = {a = 246.3, s = -0.0433, dir = -1},
}
local function level_of(y)
  if y < 95 then return 6 elseif y < 125 then return 5 elseif y < 160 then return 4
  elseif y < 195 then return 3 elseif y < 225 then return 2 else return 1 end
end
-- Ladders a barrel can drop down, by the level it starts from.
local DROPS = {
  [6] = {106, 202}, [5] = {52, 92, 188}, [4] = {82, 130, 202}, [3] = {52, 116}, [2] = {99, 203},
}
local LEFT_END, RIGHT_END = 27, 227
local DROP_RATE = 0.95
local END_DROP = 19.2
local END_FRAMES, END_OUT = 24, 9   -- a barrel leaving a girder end takes this long, and travels this far out

-- Mario's walking height on each floor.
local function mario_y(floor, x)
  if floor == 1 then return 243.4 - 0.038 * x
  elseif floor == 2 then return 198.8 + 0.0607 * x
  elseif floor == 3 then return 181.2 - 0.0611 * x
  elseif floor == 4 then return 132.7 + 0.0615 * x
  elseif floor == 5 then return 115.3 - 0.0616 * x
  else return 68.7 + 0.05 * x end
end

function P.floor(y)
  if y >= 220 then return 1 elseif y >= 190 then return 2 elseif y >= 155 then return 3
  elseif y >= 120 then return 4 elseif y >= 101 then return 5 else return 6 end
end

local STEP = 2             -- prediction resolution in frames
local THROW_X = 88         -- where a thrown barrel first appears
local LAND_STALL = 8       -- frames before he's walking again after landing
local PLAN_STEPS = 80      -- plans look this many steps ahead
local WAITS = {0, 6, 12, 20, 30, 44}   -- frames before a plan's jump
local SECONDS = {16, 30}   -- frames after landing before a second jump

function P.new(params)
  for fl = 1, 6 do
    if params["arrive" .. fl] then P.ROUTE[fl].arrive = params["arrive" .. fl] end
  end
  if params.ladder3 then P.ROUTE[3].x = params.ladder3 end
  local c = {plan = 0, next_decide = 0, air_dir = 0, jump_until = 0, prev = {}, live = {}, moved = {}, why = ""}
  local HORIZON = params.horizon
  local NSTEP = HORIZON // STEP

  -- Every path this barrel could take over the horizon, as flat {x1,y1,x2,y2,...} lists.
  local function barrel_paths(b, vx, vy, age)
    local out = {}
    local function roll(x, y, t, lvl, into)
      local L = LEVEL[lvl]
      if not L then return end
      local drops = DROPS[lvl]
      while t <= NSTEP do
        into[#into + 1] = x; into[#into + 1] = L.a + L.s * x
        local nx = x + L.dir * ROLL * STEP
        if drops and #out < 4 and lvl > c.mario_floor then
          for i = 1, #drops do
            local d = drops[i]
            if (x <= d and nx > d) or (x >= d and nx < d) then
              -- it might take this ladder: follow that path too
              local alt = {table.unpack(into)}
              alt.maybe = true
              out[#out + 1] = alt
              local ax, ay, at = d, L.a + L.s * d, t + 1
              local nl = LEVEL[lvl - 1]
              if nl then
                local land = nl.a + nl.s * d
                while at <= NSTEP and ay < land do
                  ay = ay + DROP_RATE * STEP
                  alt[#alt + 1] = ax; alt[#alt + 1] = ay
                  at = at + 1
                end
                if at <= NSTEP then roll(ax, ay, at, lvl - 1, alt) end
              end
            end
          end
        end
        x = nx; t = t + 1
        if (L.dir > 0 and x >= RIGHT_END) or (L.dir < 0 and x <= LEFT_END) then
          -- off the end: it arcs out and down to the next girder, then rolls back (measured)
          local nl = LEVEL[lvl - 1]
          if not nl then return end
          local side, xe, ye = L.dir, x, L.a + L.s * x
          local tt = 0
          while t <= NSTEP and tt < END_FRAMES do
            into[#into + 1] = xe + side * END_OUT * tt / END_FRAMES
            into[#into + 1] = ye + tt * tt / 30
            tt = tt + STEP; t = t + 1
          end
          x = xe + side * END_OUT
          lvl = lvl - 1; L = nl; drops = DROPS[lvl]
        end
      end
    end
    local x0, y0 = b.x, b.y
    if b.c == 0 and (b.d == 2 or b.d == 4) then
      local lvl = level_of(y0)
      local dirn = b.d == 2 and 1 or -1
      x0 = x0 + dirn * ROLL * age
      local path = {}
      out[#out + 1] = path
      -- It was last seen a moment ago, so it may already have started down a ladder it was passing.
      local L, here = LEVEL[lvl], b.x
      for _, d in ipairs(lvl > c.mario_floor and DROPS[lvl] or {}) do
        if (here <= d and x0 >= d) or (here >= d and x0 <= d) then
          local nl = LEVEL[lvl - 1]
          if nl then
            local alt = {maybe = true}
            out[#out + 1] = alt
            local ay, land, at = L.a + L.s * d + DROP_RATE * math.abs(x0 - d), nl.a + nl.s * d, 0
            while at <= NSTEP and ay < land do
              alt[#alt + 1] = d; alt[#alt + 1] = ay
              ay = ay + DROP_RATE * STEP; at = at + 1
            end
            if at <= NSTEP then roll(d, ay, at, lvl - 1, alt) end
          end
        end
      end
      roll(x0, y0, 0, lvl, path)
    elseif b.c == 0 and b.d == 8 then
      -- turning round at a girder end: either still in the air, or already rolling the new way
      local path = {}
      out[#out + 1] = path
      local lvl, land = 1, 999
      for l = 5, 1, -1 do
        local nl = LEVEL[l]
        local ly = nl.a + nl.s * x0
        if ly >= y0 - 3 then lvl, land = l, ly; break end
      end
      -- Where it is on the measured arc (y grows as t*t/30 for 24 frames, x moves 9 outward), worked out
      -- from how far above the girder it is, then carried on by how old this sighting is.
      local side = x0 > 128 and 1 or -1
      local above = land - y0
      local t, frames = 0, 0
      if params.exact_arc and above > 1 and above < 22 then
        local fallen = math.max(0, END_DROP - above)
        local tnow = math.sqrt(fallen * 30)
        local xe = x0 - side * END_OUT * tnow / END_FRAMES
        local ye = land - END_DROP
        local tt = tnow + age
        while tt < END_FRAMES and t <= NSTEP do
          path[#path + 1] = xe + side * END_OUT * tt / END_FRAMES
          path[#path + 1] = ye + tt * tt / 30
          tt = tt + STEP; t = t + 1
        end
        if t <= NSTEP then
          -- back the other way along the girder, for however long it has been down
          local L = LEVEL[lvl]
          local xs = xe + side * END_OUT + (L and L.dir or -side) * ROLL * (tt - END_FRAMES)
          roll(xs, land, t, lvl, path)
        end
      elseif not params.exact_arc and y0 < land - 1 then
        local x, y, fall = x0, y0, age
        while y < land - 1 and t <= NSTEP do
          if fall <= 0 then path[#path + 1] = x; path[#path + 1] = y; t = t + 1; fall = STEP end
          x = x + side * 0.375; y = y + 0.85; fall = fall - 1
        end
        if t <= NSTEP then roll(x, land, t, lvl, path) end
      else
        local L = LEVEL[lvl]
        roll(x0 + (L and L.dir or -side) * ROLL * age, land, 0, lvl, path)
      end
    elseif b.c ~= 0 then
      -- A wild barrel bounces down through the girders and can change direction at each one,
      -- so follow every way it could go after its next bounce.
      local speed = math.max(math.abs(vx), 0.5)
      local fall = math.max(vy, 1.6)     -- they drop about twice as fast as anything else
      local x, y = x0 + vx * age, y0 + fall * age
      local land = 999
      for l = 5, 1, -1 do
        local nl = LEVEL[l]
        local ly = nl.a + nl.s * x
        if ly >= y then land = ly; break end
      end
      for _, side in ipairs({1, 0, -1}) do
        local path = {}
        out[#out + 1] = path
        local px, py, pv = x, y, vx
        for t = 0, NSTEP do
          path[#path + 1] = px; path[#path + 1] = py
          px = px + pv * STEP; py = py + fall * STEP
          if py >= land then pv = side * speed end
        end
      end
    else
      -- on a ladder: carry on the way it's going, then roll once it lands
      local path = {}
      out[#out + 1] = path
      -- the girder it lands on is the first one below where it was last seen
      local lvl, land = 1, 999
      for l = 5, 1, -1 do
        local nl = LEVEL[l]
        local ly = nl.a + nl.s * x0
        if ly >= y0 - 1 then lvl, land = l + 1, ly; break end
      end
      local x, y = x0 + vx * age, y0 + vy * age
      local t = 0
      if vy > 0 and y >= land then
        -- it will have landed by now and be rolling the new way
        local L = LEVEL[lvl - 1]
        local rolled = (y - land) / vy
        roll(x0 + (L and L.dir or 0) * ROLL * rolled, land, 0, lvl - 1, path)
      else
        while t <= NSTEP do
          path[#path + 1] = x; path[#path + 1] = y
          x = x + vx * STEP; y = y + vy * STEP; t = t + 1
          if y >= land then
            roll(x, land, t, lvl - 1, path)
            break
          end
        end
      end
    end
    return out
  end

  -- Mario's position t frames from now under a plan.
  local function mario_at(plan, t, x0, y0, floor)
    local kind = plan.kind
    if kind == "stop" then return x0, y0 end
    if kind == "walk" then
      local x = x0 + plan.dir * WALK * t
      if plan.stop_x then
        if (plan.dir > 0 and x > plan.stop_x) or (plan.dir < 0 and x < plan.stop_x) then x = plan.stop_x end
      end
      return x, mario_y(floor, x)
    end
    if kind == "jump" then
      local w = plan.wait or 0
      local xs = x0 + (plan.walk or 0) * WALK * math.min(t, w)
      if t < w then return xs, mario_y(floor, xs) end
      local tj = t - w
      if tj < JUMP_LEN then
        local x = xs + plan.dir * JUMP_X * tj
        return x, mario_y(floor, x) + ARC[tj + 1]
      end
      local x = xs + plan.dir * JUMP_X * JUMP_LEN
      return x, mario_y(floor, x)
    end
    if kind == "approach" then   -- walk to the ladder, then climb it
      local tw = math.abs(plan.lx - x0) / WALK
      if t < tw then
        local x = x0 + (plan.lx > x0 and 1 or -1) * WALK * t
        return x, mario_y(floor, x)
      end
      local y = mario_y(floor, plan.lx) - CLIMB * (t - tw)
      if y < plan.top then y = plan.top end
      return plan.lx, y
    end
    if kind == "climb" then
      local y = y0 - CLIMB * t
      if y < plan.top then y = plan.top end
      return x0, y
    end
    if kind == "down" then
      local y = y0 + CLIMB * t
      if y > plan.bottom then y = plan.bottom end
      return x0, y
    end
    return x0, y0
  end

  -- Frames until this plan first touches a hazard, or nil if it stays clear.
  local function first_hit(plan, paths, fires, x0, y0, floor, frames)
    local xm, ym = plan.xm or params.clear_x, params.clear_y
    for s = 0, (frames or HORIZON) // STEP do
      local t = s * STEP
      local mx, my = mario_at(plan, t, x0, y0, floor)
      if mx < 30 or mx > 222 then return t end   -- he'd walk off the end of the girder
      local i = s * 2 + 1
      for p = 1, #paths do
        local path = paths[p]
        local bx = path[i]
        if bx and not (plan.certain and path.maybe) then
          local dx = bx - mx
          if dx < xm and dx > -xm then
            local dy = path[i + 1] - my
            if dy < ym and dy > -ym then return t end
          end
        end
      end
      if t <= params.fire_horizon then
        local spread = params.fire_spread * t
        for f = 1, #fires do
          local fb = fires[f]
          local dx, dy = fb.x - mx, fb.y - my
          local rx, ry = params.fire_x + spread, params.fire_y + spread
          if dx < rx and dx > -rx and dy < ry and dy > -ry then return t end
        end
      end
    end
    return nil
  end

  -- age = how many frames old this observation is; f = the frame number.
  local function decide(o, f, age)
    -- keep track of each barrel's movement, and when Kong last threw one
    local vel, seen_now = c.prev, {}
    for _, b in ipairs(o.b) do
      seen_now[b.k] = true
      if not c.live[b.k] and b.y < 85 and b.x >= 80 and b.x <= 100 then c.last_throw = f - age end
      local pv = vel[b.k]
      b.vx, b.vy = 0, 0
      if pv and c.live[b.k] and f > pv.f then b.vx = (b.x - pv.x) / (f - pv.f); b.vy = (b.y - pv.y) / (f - pv.f) end
      if not pv or not c.live[b.k] or f - pv.f >= 6 then vel[b.k] = {x = b.x, y = b.y, f = f} end
    end
    c.live = seen_now
    -- fireballs drift, so judge where they're heading from the last moment or two
    c.fprev = c.fprev or {}
    for _, fb in ipairs(o.f) do
      local pv = c.fprev[fb.k]
      fb.vx = 0
      if pv and f > pv.f then fb.vx = (fb.x - pv.x) / (f - pv.f) end
      if not pv or f - pv.f >= 16 then c.fprev[fb.k] = {x = fb.x, f = f} end
    end

    -- He knows what he's pressed, so he knows he's in the air and when he'll land, before he sees it.
    -- (If a jump never happened, what he sees soon says so.)
    if c.air_until and f < c.air_until then
      if f > c.jump_f + age + 4 and o.jmp == 0 and o.lad == 0 then
        c.air_until = nil
      else
        if f >= c.press_until then return c.air_dir end
        return c.plan
      end
    end
    if f < (c.up_until or 0) and o.lad == 0 then return UP end   -- he's on the ladder, just not seen to be yet
    if f < c.next_decide then return c.plan end
    c.next_decide = f + params.decide_every

    local paths = {}
    local floor = P.floor(o.y)
    if o.jmp ~= 0 and c.ground_floor then floor = c.ground_floor end   -- what he sees is still mid-air
    c.mario_floor = floor
    for _, b in ipairs(o.b) do
      if b.y - o.y < 48 and o.y - b.y < 90 then   -- anything further can't matter within the horizon
        local ps = barrel_paths(b, b.vx, b.vy, age)
        for i = 1, #ps do paths[#paths + 1] = ps[i] end
      end
    end
    -- Kong's next barrel isn't on screen yet but its timing is known: treat it as already on its way.
    if c.last_throw and o.y < 125 then
      local x = THROW_X + (f - c.last_throw) - params.throw_every
      if x < 90 + HORIZON then
        local ps = barrel_paths({x = math.min(x, THROW_X + 30), y = 79, d = 2}, 0, 0, 0)
        if x < THROW_X then
          for _, path in ipairs(ps) do
            for i = 1, #path, 2 do path[i] = path[i] + (x - THROW_X) end
          end
        end
        for i = 1, #ps do ps[i].maybe = true; paths[#paths + 1] = ps[i] end   -- worth waiting for, never worth jumping at
      end
    end

    -- where Mario is by now, given what he's been doing
    local x0, y0 = o.x, o.y
    if o.lad == 0 then
      for i = f - age, f - 1 do x0 = x0 + (c.moved[i] or 0) end
      if o.jmp ~= 0 then y0 = mario_y(floor, x0) end
    end

    local fires = o.f
    local on_ladder = o.lad ~= 0
    if on_ladder then
      local r = P.ROUTE[floor]
      for fl = 1, 6 do
        local R = P.ROUTE[fl]
        if math.abs(R.x - o.x) <= 2 and o.y >= R.top - 4 and o.y <= R.top + 44 then r = R end
      end
      -- He knows how far he has climbed: if he has reached the top by now, he's already on the next floor.
      if params.anticipate_top and c.plan == UP and r.top > 60 and o.y - CLIMB * age <= r.top then
        on_ladder = false
        floor = P.floor(r.top)
        c.mario_floor = floor
        x0, y0 = r.x, r.top
      end
    end
    c.on_ladder = on_ladder
    if on_ladder then
      local r = P.ROUTE[floor]
      for fl = 1, 6 do
        local R = P.ROUTE[fl]
        if math.abs(R.x - o.x) <= 2 and o.y >= R.top - 4 and o.y <= R.top + 44 then r = R end
      end
      local climb = {kind = "climb", top = r.top - 4}
      local down = {kind = "down", bottom = o.y + 40}
      -- once on the ladder only the climb itself matters: at the top he can step off and jump
      local left = math.floor((o.y - r.top) / CLIMB) + 4
      local hu = first_hit(climb, paths, fires, x0, y0, floor, left)
      if not hu then c.plan = UP; c.why = "climb"; return UP end
      local hd = first_hit(down, paths, fires, x0, y0, floor, left)
      if not hd or hd > hu then c.plan = DOWN; c.why = "ladder retreat"; return DOWN end
      c.plan = UP; c.why = "climb on"; return UP
    end

    local r = P.ROUTE[floor]
    if not r then return 0 end

    -- Near the ladder: go for it only if the walk to it and the whole climb stay clear.
    -- Otherwise wait just past it, where a barrel coming down the ladder rolls away from him.
    local dist = math.abs(r.x - x0)
    local away = params["standoff" .. floor] or params.standoff
    local near = dist <= away + 4
    local can_climb = false
    if near and o.ham == 0 then
      local climb_frames = math.floor(dist / WALK + (mario_y(floor, r.x) - r.top) / CLIMB) + params.after_climb
      can_climb = not first_hit({kind = "approach", lx = r.x, top = r.top}, paths, fires, x0, y0, floor, climb_frames)
    end
    if can_climb and dist <= 2 then
      c.plan = UP; c.why = "climb"; c.up_until = f + 14; c.cur_dir = nil; return UP
    end
    local target = (near and not can_climb) and (r.x + r.arrive * away) or r.x
    local dirn = target > x0 and 1 or -1
    local at_ladder = math.abs(target - x0) <= 2
    c.cur_dir = nil

    -- Compare short plans: carry on, wait or back off for a moment, then jump, then perhaps jump again.
    -- He can't react to his own landing straight away, so a second jump comes a little after the first.
    local floor_y = mario_y(floor, x0)
    local hz = {}
    for s = 0, PLAN_STEPS do hz[s] = {} end
    for _, path in ipairs(paths) do
      local m = path.maybe
      for s = 0, PLAN_STEPS do
        local bx = path[s * 2 + 1]
        if not bx then break end
        local by = path[s * 2 + 2]
        if by > floor_y - 34 and by < floor_y + 16 then
          local h = hz[s]
          h[#h + 1] = bx; h[#h + 1] = by; h[#h + 1] = m or false
        end
      end
    end

    local function along(x, d, t)      -- walking; he stops at the spot he's heading for
      local nx = x + d * WALK * t
      if d ~= 0 and d == dirn and ((d > 0 and nx > target) or (d < 0 and nx < target)) then nx = target end
      return nx
    end

    -- Returns clearance in pixels (nil on contact), frame of contact, whether a "might" barrel gets close, and final x.
    local function try_plan(act, w1, j1, w2, j2)
      local last = j1 and (w1 + JUMP_LEN + (j2 and (w2 + JUMP_LEN) or 0) + params.plan_tail) or (w1 + params.plan_tail)
      local steps = math.min(last // 2, PLAN_STEPS)
      local xw = along(x0, act, w1)
      local xl = j1 and (xw + j1 * JUMP_X * JUMP_LEN) or xw
      local xl2 = j2 and (along(xl, dirn, w2) + j2 * JUMP_X * JUMP_LEN) or xl
      local best_c, risk, mx, my = 99, false, x0, y0
      for s = 0, steps do
        local t = s * 2
        if t < w1 then
          mx = along(x0, act, t); my = mario_y(floor, mx)
        elseif not j1 then
          mx = along(xw, dirn, t - w1); my = mario_y(floor, mx)
        else
          local tj = t - w1
          if tj < JUMP_LEN then
            mx = xw + j1 * JUMP_X * tj; my = mario_y(floor, mx) + ARC[tj + 1]
          else
            local tw = tj - JUMP_LEN
            if j2 and tw >= w2 then
              local tk = tw - w2
              if tk < JUMP_LEN then
                local xs = along(xl, dirn, w2)
                mx = xs + j2 * JUMP_X * tk; my = mario_y(floor, mx) + ARC[tk + 1]
              else
                mx = along(xl2, dirn, math.max(0, tk - JUMP_LEN - LAND_STALL)); my = mario_y(floor, mx)
              end
            else
              mx = along(xl, dirn, math.max(0, tw - LAND_STALL)); my = mario_y(floor, mx)
            end
          end
        end
        if mx < 30 or mx > 222 then return nil, t, risk, mx end
        local h = hz[s]
        for i = 1, #h, 3 do
          local dx, dy = h[i] - mx, h[i + 1] - my
          if dx < 0 then dx = -dx end
          if dy < 0 then dy = -dy end
          local cl = dx - 5
          if dy - 7 > cl then cl = dy - 7 end
          if h[i + 2] then
            if cl < params.need_clear then risk = true end
          else
            if cl <= 0 then return nil, t, risk, mx end
            if cl < best_c then best_c = cl end
          end
        end
        if t <= params.fire_horizon then
          local sp = params.fire_spread * t
          for k = 1, #fires do
            local fb = fires[k]
            local dx, dy = fb.x + fb.vx * (age + t) - mx, fb.y - my
            if dx < 0 then dx = -dx end
            if dy < 0 then dy = -dy end
            local cl = dx - params.fire_x - sp
            if dy - params.fire_y - sp > cl then cl = dy - params.fire_y - sp end
            if cl <= 0 then return nil, t, risk, mx end
            if cl < best_c then best_c = cl end
          end
        end
      end
      return best_c, last, risk, mx
    end

    local function score(cl, risk, xe, last, jumps)
      local prog = (xe - x0) * dirn / last
      return (cl > params.clear_cap and params.clear_cap or cl) * params.w_clear + prog * params.w_prog
        - jumps * params.w_jump - (risk and params.w_risk or 0)
    end

    local best, best_s, fallback, fallback_t
    local function consider(act, w1, j1, w2, j2)
      local cl, t, risk, xe = try_plan(act, w1, j1, w2, j2)
      if cl then
        local v = score(cl, risk, xe, t, (j1 and 1 or 0) + (j2 and 1 or 0)) + w1 * params.w_later
        if cl < params.min_clear then v = v - params.w_thin end
        if not best_s or v > best_s then best_s = v; best = {act = act, w1 = w1, j1 = j1} end
      elseif not fallback_t or t > fallback_t then
        fallback_t = t; fallback = {act = act, w1 = w1, j1 = j1}
      end
    end

    -- Nothing near: no need to weigh anything up.
    do
      local cl, _, risk = try_plan(at_ladder and 0 or dirn, 0, nil)
      if cl and cl >= params.walk_clear and not risk then
        c.why = "walk"
        if at_ladder then c.plan = 0; return 0 end
        c.cur_dir = dirn
        c.plan = dirn > 0 and RIGHT or LEFT
        return c.plan
      end
    end

    local acts = at_ladder and {0, -dirn} or {dirn, 0, -dirn}
    for _, act in ipairs(acts) do
      for _, w1 in ipairs(WAITS) do
        consider(act, w1, nil)
        for _, j1 in ipairs({dirn, 0, -dirn}) do
          consider(act, w1, j1)
          for _, w2 in ipairs(SECONDS) do consider(act, w1, j1, w2, dirn) end
        end
      end
    end
    local p = best or fallback
    c.why = best and "plan" or "no safe plan"
    if p.j1 and p.w1 == 0 then
      local d = p.j1
      local mask = JUMP | (d > 0 and RIGHT or (d < 0 and LEFT or 0))
      c.press_until = f + 3
      c.jump_f = f
      c.air_until = f + JUMP_LEN + params.land_wait   -- a press before his feet are down is ignored by the game
      c.ground_floor = floor
      c.air_dir = d > 0 and RIGHT or (d < 0 and LEFT or 0)
      c.why = c.why .. " jump"
      c.plan = mask
      return mask
    end
    local d = p.act
    if at_ladder and d == dirn then d = 0 end
    if d ~= 0 then c.cur_dir = d end
    best = {mask = d > 0 and RIGHT or (d < 0 and LEFT or 0)}
    c.plan = best.mask
    return c.plan
  end

  -- Remember how far each frame's input moves him, to work out where he is now from what he last saw.
  function c.decide(o, f, age)
    local m = decide(o, f, age)
    local v = 0
    if c.air_until and f < c.air_until then
      v = (c.air_dir == RIGHT and JUMP_X) or (c.air_dir == LEFT and -JUMP_X) or 0
    elseif not c.on_ladder and m & UP == 0 then
      v = (m & RIGHT ~= 0 and WALK) or (m & LEFT ~= 0 and -WALK) or 0
    end
    c.moved[f] = v
    c.moved[f - 40] = nil
    return m
  end

  return c
end

return P
