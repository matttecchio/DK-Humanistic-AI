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
local BROKEN = 106         -- where barrels enter the broken ladder in front of Kong
local LEFT_END, RIGHT_END = 27, 227
local DROP_RATE = 0.95
local END_DROP = 19.2
local WILD_GRAVITY, WILD_REST = 0.0625, 6
-- Sideways speed of a wild barrel as it leaves Kong, and how often (measured, later wild barrels only).
local KONG_RAYS = {{-1, .02}, {-.75, .065}, {-.5, .095}, {-.25, .08}, {0, .25}, {.25, .15}, {.5, .155}, {.75, .11}, {1, .075}}
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
    local f_now = c.f_now
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
              alt.commit = t * STEP     -- the moment he'd see it take the ladder
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
          if params.arc_snap then
            -- It always goes over at exactly the same spot (measured), and may already be a little past it.
            xe = side > 0 and 228 or 26
            ye = L.a + L.s * xe
            tt = math.max(0, (x - xe) * side / ROLL)
          end
          while t <= NSTEP and tt < END_FRAMES do
            into[#into + 1] = xe + side * END_OUT * tt / END_FRAMES
            into[#into + 1] = ye + tt * tt / 30
            tt = tt + STEP; t = t + 1
          end
          x = xe + side * END_OUT
          if params.arc_snap then
            -- two frames' pause, then back the other way
            local past = tt - END_FRAMES - 2
            if past > 0 then x = x - side * ROLL * past end
            lvl = lvl - 1; L = nl; drops = DROPS[lvl]
            goto rolled
          end
          if params.arc_timed and t <= NSTEP then
            into[#into + 1] = x; into[#into + 1] = ye + END_FRAMES * END_FRAMES / 30; t = t + 1
          end
          lvl = lvl - 1; L = nl; drops = DROPS[lvl]
          ::rolled::
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
            local alt = {maybe = true, commit = 0}
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
      if params.arc_timed and b.arc then
        -- Measured: from the frame it goes over the edge it moves out 9 and falls t*t/30 for 24 frames,
        -- pauses 2 frames, then rolls back the other way.
        local a = b.arc
        local tt = f_now - a.f
        local ay = a.y + END_DROP
        lvl = 1
        for l = 5, 1, -1 do
          local nl = LEVEL[l]
          if nl.a + nl.s * (a.x + side * END_OUT) >= a.y + 8 then lvl, ay = l, nl.a + nl.s * (a.x + side * END_OUT); break end
        end
        while tt < END_FRAMES + 2 and t <= NSTEP do
          local q = tt < END_FRAMES and tt or END_FRAMES
          path[#path + 1] = a.x + side * END_OUT * q / END_FRAMES
          path[#path + 1] = a.y + q * q / 30
          tt = tt + STEP; t = t + 1
        end
        if t <= NSTEP then
          local L = LEVEL[lvl]
          roll(a.x + side * END_OUT + (L and L.dir or -side) * ROLL * (tt - END_FRAMES - 2), ay, t, lvl, path)
        end
      elseif params.exact_arc and above > 1 and above < 22 then
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
      if params.wild_model then
        -- Measured: it rests about 6 frames on a girder, then falls from 0.5 pixels a frame, a little faster every frame.
        local function girder_below(x, y, from)
          for l = from, 1, -1 do
            local nl = LEVEL[l]
            local ly = nl.a + nl.s * x
            if ly >= y - 1 then return l, ly end
          end
          return 0, 999
        end
        local speed = math.max(math.abs(vx), 0.5)
        -- The first wild barrel of a board always falls straight down (181 of 181 games).
        local certain = params.first_straight and b.k == c.first_wild
        if (params.wild_rays or c.force_rays) and not certain then
          -- It's certain until its next bounce. After that it could go many ways, each with measured odds.
          local wt = c.wt and c.wt[b.k]
          local v = (wt and wt.vx) or vx
          local before = wt and wt.pvx or vx
          local hard = {wild = true}
          out[#out + 1] = hard
          local bx, by, bf, nextl
          local lvl = girder_below(x0, y0, 5)
          if wt and wt.fresh then
            bx, by, bf, nextl = x0, y0, wt.fb - (f_now - age) - age, wt.lvl or lvl
          else
            local px, py, fall = x0, y0, math.max(vy, 0)
            for fr = -age, HORIZON do
              if fr >= 0 and fr % STEP == 0 then hard[#hard + 1] = px; hard[#hard + 1] = py end
              px = px + v
              fall = fall + WILD_GRAVITY
              py = py + fall
              local land = lvl > 0 and LEVEL[lvl].a + LEVEL[lvl].s * px or 999
              if py >= land then bx, by, bf, nextl = px, land, fr, lvl - 1; break end
            end
          end
          if not bx then return out end
          local s = before and math.abs(before) >= 0.1 and (before > 0 and 1 or -1) or 0
          local rays
          if s ~= 0 then
            rays = {{s * 0.25, 0.165}, {s * 0.5, 0.165}, {s * 0.75, 0.165}, {s, 0.165}, {0, 0.08},
                    {-s * 0.25, 0.065}, {-s * 0.5, 0.065}, {-s * 0.75, 0.065}, {-s, 0.065}}
          else
            rays = {{0.25, 0.1}, {0.5, 0.1}, {0.75, 0.1}, {1, 0.1}, {0, 0.2}, {-0.25, 0.1}, {-0.5, 0.1}, {-0.75, 0.1}, {-1, 0.1}}
          end
          for _, ray in ipairs(rays) do
            local path = {wild = true, ray = true, maybe = true, prob = ray[2], commit = math.max(bf, 0) + WILD_REST}
            out[#out + 1] = path
            for fr = 0, bf - 1, STEP do path[#path + 1] = -999; path[#path + 1] = -999 end
            local px, py, fall, rest, l = bx, by, 0, math.max(WILD_REST + bf + age - (wt and wt.fresh and age or 0), 0), nextl
            rest = math.min(rest, WILD_REST)
            for fr = bf, HORIZON do
              if fr >= 0 and fr % STEP == 0 then path[#path + 1] = px; path[#path + 1] = py end
              px = px + ray[1]
              if rest > 0 then
                rest = rest - 1
                if rest == 0 then fall = 0.5 end
              else
                fall = fall + WILD_GRAVITY
                py = py + fall
                local land = l > 0 and LEVEL[l].a + LEVEL[l].s * px or 999
                if py >= land then py, rest, fall, l = land, WILD_REST, 0, l - 1 end
              end
            end
          end
          return out
        end
        local sides = certain and {0} or {1, 0, -1}
        local soft = params.wild_soft and not certain
        if soft then
          -- Where it goes until its next bounce is known; after that it's only a chance.
          local path = {wild = true}
          out[#out + 1] = path
          local px, py, fall, rest = x0, y0, math.max(vy, 0), 0
          local lvl = girder_below(px, py, 5)
          for fr = -age, HORIZON do
            if fr >= 0 and fr % STEP == 0 then path[#path + 1] = px; path[#path + 1] = py end
            px = px + vx
            fall = fall + WILD_GRAVITY
            py = py + fall
            local land = lvl > 0 and LEVEL[lvl].a + LEVEL[lvl].s * px or 999
            if py >= land then break end
          end
        end
        for _, side in ipairs(sides) do
          local path = {wild = true, maybe = soft or nil}
          out[#out + 1] = path
          local px, py, pv, fall, rest = x0, y0, certain and 0 or vx, math.max(vy, 0), 0
          local lvl, land = girder_below(px, py, 5)
          local bounced = false
          local spd = speed
          local wt = params.wild_smooth and not certain and c.wt and c.wt[b.k]
          if wt then
            -- A couple of frames' movement is too rough to judge by. Judge it the way a person does: by how
            -- it has moved since it last bounced, and how long ago that was. Just after a bounce it isn't
            -- yet clear which way it has gone.
            local since = (f_now - age) - wt.fb
            local r = wt.first and 15 or WILD_REST
            lvl = wt.lvl
            if since < r then rest = r - since; fall = 0 else rest = 0; fall = 0.5 + WILD_GRAVITY * (since - r) end
            if wt.vx then
              pv = wt.vx
              spd = math.max(math.abs(wt.vx), 0.5)
            else
              pv = side * spd
              bounced = true
              path.commit = 0
            end
          end
          for fr = -age, HORIZON do
            if fr >= 0 and fr % STEP == 0 then path[#path + 1] = px; path[#path + 1] = py end
            px = px + pv
            if rest > 0 then
              rest = rest - 1
              if rest == 0 then fall = 0.5 end
            else
              fall = fall + WILD_GRAVITY
              py = py + fall
              land = lvl > 0 and LEVEL[lvl].a + LEVEL[lvl].s * px or 999
              if py >= land then
                py, rest, fall = land, WILD_REST, 0
                lvl = lvl - 1
                if not bounced then pv = side * spd; bounced = true; path.commit = (fr > 0 and fr or 0) end
                if certain then pv = 0 end
              end
            end
          end
        end
        return out
      end
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
        local path = {wild = true}
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
      -- It's committed to the ladder, whatever it was doing a moment ago: straight down at a known speed.
      if params.ladder_fix then vx, vy = 0, DROP_RATE end
      -- the girder it lands on is the first one below where it was last seen
      local lvl, land = 1, 999
      for l = 5, 1, -1 do
        local nl = LEVEL[l]
        local ly = nl.a + nl.s * x0
        if ly >= y0 - 1 then lvl, land = l + 1, ly; break end
      end
      -- Just starting down, it's still level with the girder above: that one isn't where it lands.
      if params.ladder_top_fix then
        for l = 6, 2, -1 do
          local up, dn = LEVEL[l], LEVEL[l - 1]
          local uy, dy = up.a + up.s * x0, dn.a + dn.s * x0
          if uy <= y0 + 1 and dy >= y0 - 1 then
            for _, d in ipairs(DROPS[l]) do
              if math.abs(d - x0) <= 3 then lvl, land = l, dy end
            end
          end
        end
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
    local rays_hit, seen_ray = 0, nil
    for s = 0, (frames or HORIZON) // STEP do
      local t = s * STEP
      local mx, my = mario_at(plan, t, x0, y0, floor)
      if mx < 30 or mx > 222 then return t end   -- he'd walk off the end of the girder
      local i = s * 2 + 1
      for p = 1, #paths do
        local path = paths[p]
        local bx = path[i]
        if bx and not (plan.certain and path.maybe) and not (params.ladder_sure and path.wild and path.maybe) then
          local dx = bx - mx
          if dx < xm and dx > -xm then
            local dy = path[i + 1] - my
            if dy < ym and dy > -ym then
              if not path.ray then return t end
              -- a possible bounce only stops him if it's reasonably likely
              seen_ray = seen_ray or {}
              if not seen_ray[p] then
                seen_ray[p] = true
                rays_hit = rays_hit + path.prob
                if rays_hit >= params.ray_block then return t end
              end
            end
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
      if not c.live[b.k] and b.y < 85 and b.x >= 80 and b.x <= 100 then c.last_throw = f - age; c.next_wild = f - age + 80 end
      if not c.live[b.k] and b.y < 85 and b.c ~= 0 and b.x < 70 then c.next_wild = f - age + 64 end
      local pv = vel[b.k]
      b.vx, b.vy = 0, 0
      if pv and c.live[b.k] and f > pv.f then b.vx = (b.x - pv.x) / (f - pv.f); b.vy = (b.y - pv.y) / (f - pv.f) end
      if not pv or not c.live[b.k] or f - pv.f >= 6 then vel[b.k] = {x = b.x, y = b.y, f = f} end
    end
    c.live = seen_now
    -- For each wild barrel: when it last bounced, and how fast it has moved sideways since.
    c.wt = c.wt or {}
    do
      local now = f - age
      for _, b in ipairs(o.b) do
        if b.c ~= 0 then
          local w = c.wt[b.k]
          if not w then
            w = {fb = now, f = now, lvl = 5, x = (not params.first_drift or b.y >= 85) and b.x or nil, first = b.y < 85}
            for l = 5, 1, -1 do
              if LEVEL[l].a + LEVEL[l].s * b.x >= b.y + 3 then w.lvl = l; break end
            end
            c.wt[b.k] = w
          elseif now > w.f then
            local nl = LEVEL[w.lvl]
            if nl and b.y >= nl.a + nl.s * b.x - 1 then
              w.pvx, w.vx, w.fb, w.lvl, w.x = w.vx or w.pvx, nil, now, w.lvl - 1, nil
              w.first = false; w.xf = nil
            end
            -- As it leaves Kong it doesn't start moving sideways until about 10 frames in (measured).
            local late = params.first_drift and w.first
            local start = late and 10 or 4
            if now - w.fb == start or (late and now - w.fb > start and not w.x) then w.x = b.x; w.xf = now end
            if w.x and now - w.fb >= start + 3 then w.vx = (b.x - w.x) / (now - (w.xf or (w.fb + 4))) end
            w.f = now
          end
          w.fresh = w.vx == nil
        else
          c.wt[b.k] = nil
        end
      end
    end
    c.end_seen = c.end_seen or {}
    for _, b in ipairs(o.b) do
      if b.c == 0 and b.d == 8 then
        if not c.end_seen[b.k] then c.end_seen[b.k] = {f = f - age, x = b.x, y = b.y} end
        b.arc = c.end_seen[b.k]
      else
        c.end_seen[b.k] = nil
      end
    end
    for _, b in ipairs(o.b) do
      if b.c ~= 0 and not c.first_wild then c.first_wild = b.k end
    end
    if c.first_wild and not seen_now[c.first_wild] then c.first_wild = -1 end
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
      if f > c.jump_f + age + (params.double_tap and 9 or 4) and o.jmp == 0 and o.lad == 0 then
        c.air_until = nil
      else
        -- A press too soon after landing is ignored, so tap twice: a tap during the jump does nothing.
        if params.double_tap and f >= c.press_until + 2 and f < c.press_until + 5 then return c.plan end
        if f >= c.press_until then return c.air_dir end
        return c.plan
      end
    end
    if f < (c.up_until or 0) and o.lad == 0 then return UP end   -- he's on the ladder, just not seen to be yet
    if f < c.next_decide then return c.plan end
    c.next_decide = f + params.decide_every

    c.f_now = f
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
        -- (without c = 0 this has been predicted as if it were a wild barrel)
        local ps = barrel_paths({x = math.min(x, THROW_X + 30), y = 79, d = 2, c = params.kong_fix and 0 or nil}, 0, 0, 0)
        if x < THROW_X then
          for _, path in ipairs(ps) do
            for i = 1, #path, 2 do path[i] = path[i] + (x - THROW_X) end
          end
        end
        for i = 1, #ps do ps[i].maybe = true; ps[i].commit = nil; ps[i].ray = nil; ps[i].imagined = true; paths[#paths + 1] = ps[i] end   -- worth waiting for, never worth jumping at
      end
    end

    -- Kong can only let go of a wild barrel at one moment in his rhythm: 80 frames after a normal throw,
    -- 64 after a wild one (measured). A person watching him feels that coming, and so doesn't start a jump
    -- that would have them in the air beneath him when it drops. It's only a small chance, so it's weighed.
    if params.kong_watch and c.next_wild and o.y < params.kong_y then
      local t0 = c.next_wild - f
      if t0 >= -age and t0 < HORIZON then
        for _, ray in ipairs(KONG_RAYS) do
          local path = {wild = true, ray = true, maybe = true, imagined = true, prob = ray[2] * params.kong_chance, commit = math.max(t0, 0)}
          paths[#paths + 1] = path
          local py, y1, l, k0 = 79, 79, 5, 15
          for s = 0, NSTEP do
            local dt = s * STEP - t0
            if dt < 0 then
              path[#path + 1] = -999; path[#path + 1] = -999
            else
              local px = 59 + ray[1] * math.max(dt - 10, 0)
              if dt >= k0 then
                local k = dt - k0
                py = y1 + 0.5 * k + WILD_GRAVITY * k * k / 2
                local land = l > 0 and LEVEL[l].a + LEVEL[l].s * px or 999
                if py > land then py, y1, l, k0 = land, land, l - 1, dt + WILD_REST end
              end
              path[#path + 1] = px; path[#path + 1] = py
            end
          end
        end
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
    local hz
    local function fill_hz(paths)
      hz = {}
      for s = 0, PLAN_STEPS do hz[s] = {} end
      for _, path in ipairs(paths) do
        local m, w = path.maybe and (path.commit or true), path.wild
        local ray = path.ray and path or false
        for s = 0, PLAN_STEPS do
          local bx = path[s * 2 + 1]
          if not bx then break end
          local by = path[s * 2 + 2]
          if by > floor_y - 34 and by < floor_y + 16 then
            local h = hz[s]
            h[#h + 1] = bx; h[#h + 1] = by; h[#h + 1] = m or false; h[#h + 1] = w or false; h[#h + 1] = ray
          end
        end
      end
    end
    fill_hz(paths)

    local function along(x, d, t)      -- walking; he stops at the spot he's heading for
      local heading = d ~= 0 and d == dirn
      if heading and params.along_fix then d = target > x and 1 or -1 end   -- a jump may have carried him past it
      local nx = x + d * WALK * t
      if heading and ((d > 0 and nx > target) or (d < 0 and nx < target)) then nx = target end
      return nx
    end

    -- Returns clearance in pixels (nil on contact), frame of contact, whether a "might" barrel gets close, and final x.
    -- A wild barrel high above can reach him later than he'd normally look, and he has to move early.
    -- Everything else still only counts as far ahead as usual.
    local wild_about = false
    for _, path in ipairs(paths) do wild_about = wild_about or path.wild end
    local tail = wild_about and params.wild_tail or params.plan_tail
    -- With stay, he stands where he lands rather than walking on, to see what the barrels do.
    local function try_plan(act, w1, j1, w2, j2, stay)
      local last = j1 and (w1 + JUMP_LEN + (j2 and (w2 + JUMP_LEN) or 0) + params.plan_tail) or (w1 + tail)
      local steps = math.min(last // 2, PLAN_STEPS)
      local xw = along(x0, act, w1)
      local xl = j1 and (xw + j1 * JUMP_X * JUMP_LEN) or xw
      local xs2 = j2 and along(xl, dirn, params.land_stall2 and math.max(0, w2 - LAND_STALL) or w2)
      local xl2 = j2 and (xs2 + j2 * JUMP_X * JUMP_LEN) or xl
      local best_c, risk, mx, my = 99, false, x0, y0
      local chance = 0
      c.gen = (c.gen or 0) + 1
      local gen = c.gen
      local usual = j1 and last or (w1 + params.plan_tail)
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
                mx = xs2 + j2 * JUMP_X * tk; my = mario_y(floor, mx) + ARC[tk + 1]
              else
                mx = stay and xl2 or along(xl2, dirn, math.max(0, tk - JUMP_LEN - LAND_STALL)); my = mario_y(floor, mx)
              end
            else
              mx = (stay or j2) and xl or along(xl, dirn, math.max(0, tw - LAND_STALL)); my = mario_y(floor, mx)
            end
          end
        end
        if mx < 30 or mx > 222 then return nil, t, risk, mx end
        if params.ham_avoid and floor == 5 and mx < 40 and o.ham == 0 then return nil, t, risk, mx end   -- the hammer's there
        local h = hz[s]
        for i = 1, #h, 5 do
          if t > usual and not h[i + 3] then goto next_hazard end
          local dx, dy = h[i] - mx, h[i + 1] - my
          if dx < 0 then dx = -dx end
          if dy < 0 then dy = -dy end
          local cl = dx - 5
          if dy - 7 > cl then cl = dy - 7 end
          local ray = h[i + 4]
          if ray then
            -- A chance, not a certainty: add up how likely this plan is to meet it, less if he could still react.
            if cl <= params.ray_clear and ray.stamp ~= gen then
              ray.stamp = gen
              local free = ray.commit + params.see_lag
              if j1 and free >= w1 and free < w1 + JUMP_LEN + params.land_wait then free = w1 + JUMP_LEN + params.land_wait end
              chance = chance + ray.prob * (t - free >= params.respond and params.ray_discount or 1)
            end
          elseif h[i + 2] then
            if cl < params.need_clear then
              local cm = h[i + 2]
              if cm == true or not params.odds_risk then
                risk = true
              elseif t >= cm then
                -- If it does come, will he have time to see it and jump? Not while he's in the air.
                local free = cm + params.see_lag
                if j1 and free >= w1 then
                  local a1 = w1 + JUMP_LEN + params.land_wait
                  if free < a1 then free = a1 end
                  if j2 then
                    local a2 = a1 - params.land_wait + w2
                    if free >= a2 and free < a2 + JUMP_LEN + params.land_wait then free = a2 + JUMP_LEN + params.land_wait end
                  end
                end
                if t - free < params.respond then risk = true end
              end
            end
          else
            if cl <= 0 then return nil, t, risk, mx end
            -- Passing under a barrel rolling on the girder above isn't a near miss: the height between them doesn't change.
            local roof = params.above_ok and not h[i + 3] and h[i + 1] < my and cl == dy - 7
            if not roof and cl < best_c then best_c = cl end
          end
          ::next_hazard::
        end
        if t <= params.fire_horizon and t <= usual then
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
      return best_c, last, risk, mx, chance
    end

    local function score(cl, risk, xe, last, jumps)
      local prog = (xe - x0) * dirn / last
      return (cl > params.clear_cap and params.clear_cap or cl) * params.w_clear + prog * params.w_prog
        - jumps * params.w_jump - (risk and params.w_risk or 0)
    end

    local best, best_s, fallback, fallback_t
    local function consider(act, w1, j1, w2, j2, stay)
      local cl, t, risk, xe, chance = try_plan(act, w1, j1, w2, j2, stay)
      if cl then
        local v = score(cl, risk, xe, t, (j1 and 1 or 0) + (j2 and 1 or 0)) + w1 * params.w_later - chance * params.w_ray
        if j1 and j1 ~= 0 then v = v - (params["w_sideways" .. floor] or params.w_sideways) end   -- a straight jump is calmer
        if cl < params.min_clear then v = v - params.w_thin end
        if wild_about and w1 > 0 and c.last_act and c.last_act ~= 0 and act == -c.last_act then v = v - params.w_commit end   -- turning back under a barrel costs ground
        if not best_s or v > best_s then best_s = v; best = {act = act, w1 = w1, j1 = j1, cl = cl} end
      elseif not fallback_t or t > fallback_t then
        fallback_t = t; fallback = {act = act, w1 = w1, j1 = j1}
      end
    end

    -- Past the broken ladder on floor 5, a quick press back towards it as a barrel passes over
    -- sends more barrels down there, and fewer on to the ladder he wants.
    if params.steer_top and floor == 5 and x0 > BROKEN + 12 then
      for _, b in ipairs(o.b) do
        if b.c == 0 and b.d == 2 and b.y < 95 then
          local bx = b.x + ROLL * age
          if bx >= BROKEN - 6 and bx <= BROKEN then
            local cl = try_plan(0, 0, nil)
            if cl and cl >= params.walk_clear then
              c.why = "steer"
              c.plan = LEFT
              return LEFT
            end
          end
        end
      end
    end

    -- He can't jump with a hammer, but it smashes what's in front of him: turn to face what's coming.
    if params.ham_face and o.ham ~= 0 then
      local near_dx
      for _, b in ipairs(o.b) do
        local dx = b.x + b.vx * age - x0
        local dy = b.y - y0
        if dy > -12 and dy < 12 and dx > -30 and dx < 30 and (not near_dx or math.abs(dx) < math.abs(near_dx)) then near_dx = dx end
      end
      if near_dx then
        c.why = "face it"
        c.plan = near_dx > 0 and RIGHT or LEFT
        return c.plan
      end
    end

    -- Nothing near: no need to weigh anything up.
    do
      local cl, _, risk, _, chance = try_plan(at_ladder and 0 or dirn, 0, nil)
      if cl and cl >= params.walk_clear and not risk and (chance or 0) < params.ray_ok then
        c.why = "walk"
        c.last_act = at_ladder and 0 or dirn
        if at_ladder then c.plan = 0; return 0 end
        c.cur_dir = dirn
        c.plan = dirn > 0 and RIGHT or LEFT
        return c.plan
      end
    end

    -- Jump only for what's really coming at him. A barrel that merely might take a ladder is handled
    -- by moving or waiting, not by leaping about: wait and see what it does.
    local need_jump = true
    if params.only_needed_jumps or params["only_needed" .. floor] then
      local cw = try_plan(at_ladder and 0 or dirn, 0, nil)
      local cs = try_plan(0, 0, nil)
      need_jump = not ((cw and cw >= params.min_clear) or (cs and cs >= params.min_clear))
    end
    if params.ham_face and o.ham ~= 0 then need_jump = false end
    local acts = at_ladder and {0, -dirn} or {dirn, 0, -dirn}
    local function weigh()
      for _, act in ipairs(acts) do
        for _, w1 in ipairs(WAITS) do
          consider(act, w1, nil)
          for _, j1 in ipairs(need_jump and {dirn, 0, -dirn} or {}) do
            consider(act, w1, j1)
            if params.tail_stay then consider(act, w1, j1, nil, nil, true) end
            for _, w2 in ipairs(params.seconds) do
              consider(act, w1, j1, w2, dirn)
              if params.second_straight then consider(act, w1, j1, w2, 0, true) end
            end
          end
        end
      end
    end
    weigh()
    -- Every way of being sure of a wild barrel has run out. So stop assuming it could go anywhere
    -- and play the odds on where it's likely to go, rather than a desperate move that's bound to be close.
    if params.odds_fallback and wild_about and (not best or best.cl < params.min_clear) then
      local real = {}
      c.force_rays = true
      for _, b in ipairs(o.b) do
        if b.y - o.y < 48 and o.y - b.y < 90 then
          local ps = barrel_paths(b, b.vx, b.vy, age)
          for i = 1, #ps do real[#real + 1] = ps[i] end
        end
      end
      c.force_rays = false
      for _, path in ipairs(paths) do
        if path.imagined then real[#real + 1] = path end
      end
      fill_hz(real)
      local old, old_f, old_t = best, fallback, fallback_t
      best, best_s = nil, nil
      weigh()
      if not best then best, fallback, fallback_t = old, old_f, old_t end
    end
    local p = best or fallback
    c.why = best and "plan" or "no safe plan"
    if params.top_guard and p.j1 and p.w1 == 0 and o.lad ~= 0 then
      -- Still on the last rungs: the game ignores a jump here, and he'd stand there thinking he was in the air.
      c.plan = UP; c.why = "climb"; return UP
    end
    if p.j1 and p.w1 == 0 then
      local d = p.j1
      local mask = JUMP | (d > 0 and RIGHT or (d < 0 and LEFT or 0))
      c.press_until = f + 3
      c.jump_f = f
      c.air_until = f + JUMP_LEN + params.land_wait   -- a press before his feet are down is ignored by the game
      c.ground_floor = floor
      c.air_dir = d > 0 and RIGHT or (d < 0 and LEFT or 0)
      c.why = c.why .. " jump"
      c.last_act = nil
      c.plan = mask
      return mask
    end
    local d = p.act
    if at_ladder and d == dirn then d = 0 end
    if d ~= 0 then c.cur_dir = d end
    c.last_act = d
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
