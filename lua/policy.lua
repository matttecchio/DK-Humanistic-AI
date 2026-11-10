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
local DOWN_SPEED = 0.5      -- pixels per frame coming down a ladder (measured)
-- Under dkh (the native emulator) the plan check runs compiled: the same logic, giving identical results, only faster.
local NATIVE = rawget(_G, "dkh_native")
if NATIVE then NATIVE.set_arc(ARC) end
local LAND_STALL = 8       -- frames before he's walking again after landing
local PLAN_STEPS = 80      -- plans look this many steps ahead
local WAITS = {0, 6, 12, 20, 30, 44}   -- frames before a plan's jump
local WAITS_FINE = {0, 2, 4, 6, 8, 10, 12, 16, 20, 25, 30, 37, 44}   -- (fine_waits) so a jump planned for 6 frames' time can still be 4 a moment later

local PREDLOG = os.getenv("PREDLOG") and io.open(os.getenv("PREDLOG"), "a")
function P.new(params)
  for fl = 1, 6 do
    if params["arrive" .. fl] then P.ROUTE[fl].arrive = params["arrive" .. fl] end
  end
  if params.ladder3 then P.ROUTE[3].x = params.ladder3 end
  if params.ladder4 then P.ROUTE[4].x = params.ladder4; P.ROUTE[4].top = params.ladder4_top end
  local c = {plan = 0, next_decide = 0, air_dir = 0, jump_until = 0, prev = {}, live = {}, moved = {}, why = ""}
  local HORIZON = params.horizon
  local NSTEP = HORIZON // STEP
  local NATIVE_ROLL = NATIVE and not params.sure_ladders
  if NATIVE_ROLL then NATIVE.set_world(LEVEL, DROPS, NSTEP, params) end

  -- Every path this barrel could take over the horizon, as flat {x1,y1,x2,y2,...} lists.
  local function barrel_paths(b, vx, vy, age)
    local out = {}
    local f_now = c.f_now
    local function roll(x, y, t, lvl, into)
      if NATIVE_ROLL then NATIVE.roll(x, y, t, lvl, into, out, c.mario_floor); return end
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
              alt.lad = d
              if params.sure_ladders and params.sure_ladders[lvl] and params.sure_ladders[lvl][d] then alt.commit = true end   -- likely enough to plan around
              out[#out + 1] = alt
              local ax, ay, at = d, L.a + L.s * d, t + 1
              local nl = LEVEL[lvl - 1]
              if nl then
                local land = nl.a + nl.s * d
                while at <= NSTEP and ay < land do
                  ay = ay + (params.drop_rate or DROP_RATE) * STEP
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
            local ay, land, at = L.a + L.s * d + (params.drop_rate or DROP_RATE) * math.abs(x0 - d), nl.a + nl.s * d, 0
            while at <= NSTEP and ay < land do
              alt[#alt + 1] = d; alt[#alt + 1] = ay
              ay = ay + (params.drop_rate or DROP_RATE) * STEP; at = at + 1
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
        -- wild_toward: each time it lands, a wild barrel heads for Mario (measured: 384 of 385 landings on 3-1), so one path does
        if params.wild_toward and not certain then sides = {1} end
        if params.wild_sides and not certain then sides = params.wild_sides end   -- e.g. {1, -1}: on 3-1 it almost never stays put
        local function toward(px) return (c.mario_x or px) >= px and 1 or -1 end
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
        -- wild_dynamic (native only): on level 3 a wild barrel heads for Mario each time it lands, so where it goes depends on
        -- the plan being weighed. Its state is handed to the compiled plan check, which moves it in step with each plan.
        if params.wild_dynamic and NATIVE and not certain then
          local px, py, pv, fall, rest = x0, y0, vx, math.max(vy, 0), 0
          local lvl = girder_below(px, py, 5)
          local spd, pend = speed, false
          local wt = params.wild_smooth and c.wt and c.wt[b.k]
          if wt then
            local since = (f_now - age) - wt.fb
            local r = wt.first and 15 or WILD_REST
            lvl = wt.lvl
            if since < r then rest = r - since; fall = 0 else rest = 0; fall = 0.5 + WILD_GRAVITY * (since - r) end
            if wt.vx then pv = wt.vx; spd = math.max(math.abs(wt.vx), 0.5) else pend = true end
          end
          local sp = math.max(spd, params.wild_spd or 0)
          -- wild_pre (0x22E1): until the oil drum is lit every landing sends it right at a fixed speed (0xE9/256 from level 3)
          local pre_v = params.wild_pre and c.oil == 0 and params.wild_pre or nil
          for fr = -age + (params.wild_catch1 and 1 or 0) - (params.wild_lead or 0), -1 do   -- catch up to now, with Mario where he is (wild_catch1: measured, one frame less lines it up)
            if pend then pv = pre_v or (params.wild_aim and ((c.mario_x or px) - px) / 64) or toward(px) * sp; pend = false end
            px = px + pv
            if rest > 0 then
              rest = rest - 1
              if rest == 0 then fall = 0.5 end
            else
              fall = fall + WILD_GRAVITY
              py = py + fall
              local land = lvl > 0 and LEVEL[lvl].a + LEVEL[lvl].s * px or 999
              if py >= land then py, rest, fall = land, WILD_REST, 0; lvl = lvl - 1; pv = pre_v or (params.wild_aim and ((c.mario_x or px) - px) / 64) or toward(px) * sp end
            end
          end
          c.wild_dyn[#c.wild_dyn + 1] = {px, py, pv, fall, rest, lvl, sp, pend and 1 or 0}
        end
        local function wild_sides_paths(sides, use_new, tag)
          local wt_spd, wt_toward = params.wild_spd, params.wild_toward
          if not use_new then params.wild_spd, params.wild_toward = nil, nil end
          local first_new = #out + 1
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
                pv = (params.wild_toward and toward(px) or side) * math.max(spd, params.wild_spd or 0)
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
                  if params.wild_toward then pv = toward(px) * math.max(spd, params.wild_spd or 0); bounced = true; path.commit = path.commit or (fr > 0 and fr or 0)
                  elseif not bounced then pv = side * math.max(spd, params.wild_spd or 0); bounced = true; path.commit = (fr > 0 and fr or 0) end
                  if certain then pv = 0 end
                end
              end
            end
          end
          for i = first_new, #out do if tag then out[i][tag] = true end end
          params.wild_spd, params.wild_toward = wt_spd, wt_toward
        end
        -- wild_split: the measured model guides jumps and walking, the old one decides on ladders, where changes have only made him dither
        if params.wild_dynamic and NATIVE and not certain then
          wild_sides_paths({1, 0, -1}, false, "climb_only")   -- ladders keep the old model
        elseif params.wild_split and not certain then
          wild_sides_paths(params.wild_sides or {1, 0, -1}, true, "jump_only")
          wild_sides_paths({1, 0, -1}, false, "climb_only")
        else
          wild_sides_paths(sides, true, nil)
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
      if params.ladder_fix then vx, vy = 0, params.drop_rate or DROP_RATE end   -- (drop_rate: measured 1.0 px a frame, 2,303 of 2,330 descents)
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
      local y = y0 + (plan.speed or CLIMB) * t
      if y > plan.bottom then y = plan.bottom end
      return x0, y
    end
    return x0, y0
  end

  -- Frames until this plan first touches a hazard, or nil if it stays clear.
  local function first_hit(plan, paths, fires, x0, y0, floor, frames)
    local xm, ym = plan.xm or params.clear_x, plan.ym or params.clear_y
    local rays_hit, seen_ray = 0, nil
    for s = 0, (frames or HORIZON) // STEP do
      local t = s * STEP
      local mx, my = mario_at(plan, t, x0, y0, floor)
      if mx < 30 or mx > 222 then return t end   -- he'd walk off the end of the girder
      local i = s * 2 + 1
      for p = 1, #paths do
        local path = paths[p]
        local bx = path[i]
        if bx and not (plan.certain and path.maybe) and not (params.ladder_sure and path.wild and path.maybe) and not (plan.real and path.imagined and not path.real_next) and not path.jump_only then
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

  -- Steering (Matt): which way to press so a barrel above that's about to cross a ladder takes it, when that ladder is on
  -- the side barrels on his own girder roll away to. nil if there's nothing to steer.
  local function pull_dir(o, age, at_x)
    local mx = at_x or o.x   -- where he'll be: in a jump, where he lands
    local here = P.floor(o.y)
    local L = LEVEL[here]
    if not L or (params.pull_floors and not params.pull_floors[here]) then return nil end
    for _, b in ipairs(o.b) do
      -- pull_up: barrels on girders further up count too (the game only checks that Mario is below the barrel)
      local lb = level_of(b.y)
      if b.c == 0 and (b.d == 2 or b.d == 4) and lb > here and lb <= here + (params.pull_up or 1) then
        local side = b.d == 2 and 1 or -1
        local bx = b.x + side * ROLL * age
        for _, d in ipairs(DROPS[lb] or {}) do
          local ahead = (d - bx) * side
          -- pull_gap: not a ladder that drops it on to his own girder just ahead of him: it rolls straight back at him
          local near = params.pull_gap and lb == here + 1 and math.abs(d - mx) < params.pull_gap and (not params.steer_here or params.steer_here[here])
          if (d - mx) * L.dir > 0 and ahead >= -1 and ahead <= (params.steer_pull or 3) and not near then return L.dir > 0 and RIGHT or LEFT end
        end
      end
    end
    return nil
  end

  -- age = how many frames old this observation is; f = the frame number.
  local function decide(o, f, age)
    if PREDLOG then   -- where each barrel really was (what he sees is age frames old)
      local t = {"O", f - age, "M" .. o.x .. ":" .. (o.oil or 0)}
      for _, b in ipairs(o.b) do t[#t + 1] = b.k .. "," .. b.x .. "," .. b.y .. "," .. b.d .. "," .. b.c end
      PREDLOG:write(table.concat(t, " "), "\n")
    end
    -- keep track of each barrel's movement, and when Kong last threw one
    local vel, seen_now = c.prev, {}
    for _, b in ipairs(o.b) do
      seen_now[b.k] = true
      if not c.live[b.k] and b.y < 85 and b.x >= 80 and b.x <= 100 then c.last_throw = f - age; c.next_wild = f - age + (params.wild_after or 80) end
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
    -- air_plan {floor, x from, x to, frames} (from grinding deaths off ladder 91's top): that many frames into a jump there, he
    -- stops coasting and plans again, so his next move is ready the moment he lands. A floor of 0 means anywhere.
    for _, ap in ipairs({params.air_plan or false, params.air_plan2 or false}) do   -- air_plan2: a second setup
      if ap and c.air_until and f < c.air_until and f >= c.jump_f + ap[4] and (ap[1] == 0 or (c.ground_floor == ap[1] and c.jump_x and c.jump_x >= ap[2] and c.jump_x <= ap[3])) then
        c.air_until = nil; c.replanned = f
      end
    end
    if c.air_until and f < c.air_until then
      if f > c.jump_f + age + (params.double_tap and 9 or 4) and o.jmp == 0 and o.lad == 0 then
        c.air_until = nil
      else
        -- A press too soon after landing is ignored, so tap twice: a tap during the jump does nothing.
        if params.double_tap and f >= c.press_until + 2 and f < c.press_until + 5 then return c.plan end
        -- The stick does nothing in the air, but it still draws barrels down ladders, so he lets go until just before landing.
        if params.air_steer and params.air_steer[c.ground_floor] and f > c.jump_f + 8 and f < c.jump_f + JUMP_LEN - 4 then return params.air_steer[c.ground_floor] end   -- draws barrels down ladders that way while it costs him nothing
        if params.air_free and (params.air_free == true or params.air_free[c.ground_floor]) and f > c.jump_f + 8 and f < c.jump_f + JUMP_LEN - 4 then return 0 end
        -- steer_air: in a straight jump the stick can't move him, but it still steers barrels at the ladders above
        -- (any jump: the stick can't change his path once he's in the air, so he can steer either way)
        if params.steer_air and (params.steer_air ~= "straight" or c.air_dir == 0) and f >= c.press_until and f > c.jump_f + 8 and f < c.jump_f + JUMP_LEN - 4 then
          local land_x = c.jump_x and c.jump_x + ((c.air_dir == RIGHT and 1) or (c.air_dir == LEFT and -1) or 0) * JUMP_X * JUMP_LEN
          local pd = pull_dir(o, age, land_x)
          if pd then c.why = c.why .. " steer"; return pd end
        end
        -- air_tap {floor, x from, x to, nearest, furthest, from frame, to frame, dir}: in a straight jump there, with a barrel on
        -- that girder rolling at him this close, hold dir for those frames of the jump (it can't change the jump, only which
        -- ladders barrels take). Found by grinding deaths just off ladder 91's top: a 4-frame left press, 4-6 frames into the jump.
        local at = params.air_tap
        if at and c.air_dir == 0 and c.ground_floor == at[1] and c.jump_x and c.jump_x >= at[2] and c.jump_x <= at[3] then
          local since = f - c.jump_f
          if since >= at[6] and since <= at[7] then
            for _, b in ipairs(o.b) do
              if b.c == 0 and (b.d == 2 or b.d == 4) and level_of(b.y) == at[1] then
                local side = b.d == 2 and 1 or -1
                local gap = (c.jump_x - (b.x + side * ROLL * age)) * side
                if gap >= at[4] and gap <= at[5] then c.why = c.why .. " air tap"; return at[8] end
              end
            end
          end
        end
        if f >= c.press_until then
          -- air_off: the stick can't change his jump, but held towards a ladder a barrel above is crossing, it draws the barrel down on him
          if params.air_off and c.air_dir ~= 0 and (not params.steer_here or params.steer_here[c.ground_floor]) then
            for _, b in ipairs(o.b) do
              if b.c == 0 and (b.d == 2 or b.d == 4) and P.floor(b.y) == c.ground_floor + 1 then
                local side = b.d == 2 and 1 or -1
                for _, d in ipairs(DROPS[P.floor(b.y)] or {}) do
                  local ahead = (d - (b.x + side * ROLL * age)) * side
                  local towards = (c.air_dir == LEFT and d < o.x) or (c.air_dir == RIGHT and d > o.x)
                  if towards and ahead >= -1 and ahead <= params.air_off then c.why = c.why .. " lets go"; return 0 end
                end
              end
            end
          end
          return c.air_dir
        end
        return c.plan
      end
    end
    if f < (c.up_until or 0) and o.lad == 0 then return UP end   -- he's on the ladder, just not seen to be yet
    if f < c.next_decide then return c.plan end
    c.next_decide = f + params.decide_every

    c.f_now = f
    c.mario_x = o.x
    c.oil = o.oil
    c.wild_dyn = {}
    local paths = {}
    local floor = P.floor(o.y)
    if o.jmp ~= 0 and c.ground_floor then floor = c.ground_floor end   -- what he sees is still mid-air
    c.mario_floor = floor
    for _, b in ipairs(o.b) do
      if b.y - o.y < 48 and o.y - b.y < 90 then   -- anything further can't matter within the horizon
        local ps = barrel_paths(b, b.vx, b.vy, age)
        for i = 1, #ps do paths[#paths + 1] = ps[i] end
        if PREDLOG and f % 8 == 0 then   -- (PREDLOG) what he predicts for each barrel, to measure against what happens
          for i = 1, #ps do
            local t = {"P", f, b.k, b.c, b.d, ps[i].maybe and 1 or 0, ps[i].lad or 0}
            for _, st in ipairs({0, 4, 8, 16, 24}) do t[#t + 1] = ps[i][st * 2 + 1] and string.format("%.1f,%.1f", ps[i][st * 2 + 1], ps[i][st * 2 + 2]) or "-" end
            PREDLOG:write(table.concat(t, " "), "\n")
          end
        end
      end
    end
    -- Kong's next barrel isn't on screen yet but its timing is known: treat it as already on its way.
    -- Kong's pose gives away exactly when he'll let go: 73 frames after he turns to the barrels, 25 after he brings one round.
    if params.kong_pose then
      if o.kong ~= c.kong_seen then
        c.kong_seen = o.kong
        if o.kong == 44 then c.next_throw = f - age + 73 elseif o.kong == 172 then c.next_throw = f - age + 25 end
      end
      if c.next_throw and f - c.next_throw > 12 then c.next_throw = nil end
    end
    if c.last_throw and o.y < 125 then
      local x = THROW_X + (f - c.last_throw) - params.throw_every
      if c.next_throw then x = THROW_X + f - c.next_throw end
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
    -- Kong's next barrel will probably roll to the broken ladder and come down it. He can't see it yet, but he knows when it's due,
    -- so he doesn't choose to land beside the foot of that ladder just then. It only weighs on jumps, never on a climb.
    -- On the ladder (next_drop_climb) the same barrel is what decides whether to keep climbing: it rolls from that ladder's foot to the top of his.
    local near_climb = o.lad ~= 0 or (params.next_drop_approach and floor == 4 and math.abs(o.x - 91) <= 14)   -- (also while deciding whether to start up)
    local drops_next = params.next_drop_climb and near_climb and params.next_drop_climb or (floor == 5 and params.next_drop)
    if drops_next and c.last_throw then
      for _, late in ipairs(drops_next) do
        local x = math.min(THROW_X + (f - c.last_throw) - params.throw_every - late, THROW_X)
        -- next_drop_pose: only when Kong's pose shows the throw is coming, timed from that, as a player watching him does
        if params.next_drop_pose then x = c.next_throw and math.min(THROW_X + f - c.next_throw - late, THROW_X) or -999 end
        if x < BROKEN and x > BROKEN - HORIZON then
          for _, path in ipairs(barrel_paths({x = x, y = 79, d = 2, c = 0}, 0, 0, 0)) do
            if path.lad == BROKEN then
              path.commit = true; path.imagined = true
              if near_climb and params.next_drop_climb then path.climb_only = true; path.real_next = true else path.jump_only = true end
              paths[#paths + 1] = path
            end
          end
        end
      end
    end

    -- Kong can only let go of a wild barrel at one moment in his rhythm: 80 frames after a normal throw,
    -- 64 after a wild one (measured). A person watching him feels that coming, and so doesn't start a jump
    -- that would have them in the air beneath him when it drops. It's only a small chance, so it's weighed.
    if params.kong_watch and c.next_wild and o.y < params.kong_y then
      local t0 = c.next_wild - f
      if t0 >= -age and t0 < HORIZON then
        -- kong_aim (difficulty 5): Kong's wild barrel leaves aimed at Mario, at (his x - 59) / 64 px a frame
        local aim = params.kong_aim and (params.kong_aim_top and floor >= 5 and params.kong_aim_top or params.kong_aim)   -- kong_aim_top: on the top two girders
        local rays = aim and {{((c.mario_x or 120) - 59) / 64, aim}} or params.kong_rays or KONG_RAYS
        for _, ray in ipairs(rays) do   -- (kong_rays: how they leave Kong on this level, measured)
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
    -- know_self (Matt): he knows where he is from his own presses, not from what he saw a moment ago
    if params.know_self and o.now and o.lad == 0 and o.now.lad == 0 and o.now.jmp == 0 and o.jmp == 0 then x0, y0 = o.now.x, o.now.y end

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
        c.past_top = params.guard_free and o.y - CLIMB * age <= r.top - params.guard_free and f or nil
      end
      -- Likewise backing down: he knows when his feet are on the girder, and mustn't climb back into what he's backing away from.
      if on_ladder and (params.ladder_commit or params.ladder_true) and c.plan == DOWN then
        local fl = P.floor(r.top) - 1
        local bottom = mario_y(fl, r.x)
        if o.y + DOWN_SPEED * age >= bottom - 1 then
          on_ladder = false
          floor = fl
          c.mario_floor = floor
          x0, y0 = r.x, bottom
        end
      end
    end
    if not on_ladder then c.lad_down = nil end
    c.on_ladder = on_ladder
    -- ladder_steer {ladder x, girder above, {ladder xs up there}, window} (Matt): climbing that ladder, as a barrel on the girder
    -- above reaches one of those ladders, let go of up and tap towards it: it takes that ladder and rolls off away from him
    local ls = params.ladder_steer
    local wait_for = false
    if ls and on_ladder and math.abs(o.x - ls[1]) <= 2 then
      for _, b in ipairs(o.b) do
        if b.c == 0 and (b.d == 2 or b.d == 4) and level_of(b.y) == ls[2] and b.y < o.y then
          local side = b.d == 2 and 1 or -1
          for _, d in ipairs(ls[3]) do
            local ahead = (d - (b.x + side * ROLL * age)) * side
            if ahead >= -1 and ahead <= ls[4] then
              if PREDLOG then PREDLOG:write(string.format("S %d %d %d\n", f, b.k, d)) end
              c.why = "steer from the ladder"; c.plan = d > o.x and RIGHT or LEFT; return c.plan
            end
            -- ls[5]: it gets there within this many frames: wait on the ladder for it, unless a barrel on the girder just
            -- above is heading for the ladder he's on (it could come down on him)
            if ls[5] and ahead > ls[4] and ahead <= ls[5] then wait_for = true end
          end
        end
      end
      -- and barrels still on the girder above that, rolling to its end: they drop on to this girder's end and roll back
      -- to the ladder (measured: 228 − x to the edge, 26 to land and turn, then roll from x=237)
      if ls[5] and not wait_for then
        for _, b in ipairs(o.b) do
          if b.c == 0 and b.d == 2 and level_of(b.y) == ls[2] + 1 and b.x < RIGHT_END + 1 then
            for _, d in ipairs(ls[3]) do
              local eta = (RIGHT_END + 1 - (b.x + ROLL * age)) + 26 + (237 - d)
              if eta > ls[4] and eta <= ls[5] then wait_for = true end
            end
          end
        end
      end
      if wait_for then
        local safe = true
        for _, b in ipairs(o.b) do
          if b.c == 0 and (b.d == 2 or b.d == 4) and level_of(b.y) == ls[2] - 1 and b.y < o.y then
            local side = b.d == 2 and 1 or -1
            local ahead = (ls[1] - (b.x + side * ROLL * age)) * side
            if ahead >= -4 and ahead <= ls[5] + 20 then safe = false end
          elseif b.c == 0 and b.d ~= 2 and b.d ~= 4 and math.abs(b.x - ls[1]) <= 4 and b.y < o.y then safe = false end
        end
        if safe then c.why = "waits on the ladder to steer"; c.plan = 0; return 0 end
      end
    end
    if on_ladder then
      local r = P.ROUTE[floor]
      for fl = 1, 6 do
        local R = P.ROUTE[fl]
        if math.abs(R.x - o.x) <= 2 and o.y >= R.top - 4 and o.y <= R.top + 44 then r = R end
      end
      local climb = {kind = "climb", top = r.top - 4, real = params.ladder_real}   -- (ladder_real: a barrel Kong hasn't thrown yet doesn't turn him back)
      local down = {kind = "down", bottom = o.y + 40}
      -- once on the ladder only the climb itself matters: at the top he can step off and jump
      local left = math.floor((o.y - r.top) / CLIMB) + 4
      local dleft = left
      if params.ladder_true then
        -- Backing down he goes at his real speed and only has to reach the girder: there he can step aside.
        local bottom = mario_y(P.floor(r.top) - 1, r.x)
        down = {kind = "down", bottom = bottom, speed = DOWN_SPEED}
        dleft = math.max(0, math.floor((bottom - o.y) / DOWN_SPEED)) + params.ladder_true
      end
      local cpaths = paths
      if params.climb_nowild then   -- (Matt) at difficulty 5 a wild barrel can't hurt him once he's going up
        cpaths = {}
        for _, p in ipairs(paths) do if not p.wild then cpaths[#cpaths + 1] = p end end
      end
      local hu = first_hit(climb, cpaths, fires, x0, y0, floor, left)
      -- Heading back up from near the bottom he knows he's on the ladder, even while what he sees still shows him on the girder.
      if (params.ladder_true or params.ladder_known) and o.y > r.top + 16 then c.up_until = f + 12 end
      if c.lad_down then
        local hd = first_hit(down, paths, fires, x0, y0, floor, dleft)
        if not hd or (hu and hd > hu) then c.up_until = nil; c.plan = DOWN; c.why = "ladder retreat"; return DOWN end   -- having decided, he doesn't dither
        c.lad_down = nil
      end
      if not hu then c.plan = UP; c.why = "climb"; return UP end
      -- Near the top he can stop just below the girder and let a barrel roll over him. Only a very close barrel can't come down at him.
      local ys = o.y - (c.plan == UP and CLIMB * age or 0)
      if params.ladder_hold and ys - r.top <= params.ladder_hold then
        if not first_hit({kind = "stop", certain = true, ym = params.hold_y}, paths, fires, x0, ys, floor, params.hold_for) then
          c.plan = 0; c.why = "hold"; return 0
        end
      end
      if params.retreat_top and o.y - r.top <= params.retreat_top then c.plan = UP; c.why = "climb on"; return UP end   -- nearly there: climb and jump it
      local hd = first_hit(down, paths, fires, x0, y0, floor, dleft)
      if not hd or hd > hu then
        c.lad_down = params.ladder_commit or nil
        if params.ladder_true or params.ladder_known then c.up_until = nil end
        c.plan = DOWN; c.why = "ladder retreat"; return DOWN
      end
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
      local climb_frames = math.floor(dist / WALK + (mario_y(floor, r.x) - r.top) / CLIMB) + (params["after_climb" .. floor] or params.after_climb)
      can_climb = not first_hit({kind = "approach", lx = r.x, top = r.top, ym = params.climb_ym, xm = params.climb_xm}, paths, fires, x0, y0, floor, climb_frames)
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
    -- A barrel rolling at him from close by (with_x): jumping the way it rolls keeps him in the air longest above it, so that's the jump to take.
    local close_dir
    if params.w_with and (not params.with_floors or params.with_floors[floor]) then
      for _, b in ipairs(o.b) do
        if b.c == 0 and (b.d == 2 or b.d == 4) and level_of(b.y) == floor then
          local bd = b.d == 2 and 1 or -1
          local gap = (x0 - (b.x + bd * age)) * bd
          if gap > 0 and gap <= params.with_x then close_dir = bd end
        elseif params.with_drop and b.c == 0 and b.d ~= 2 and b.d ~= 4 and b.y < floor_y and b.y > floor_y - (params.with_drop_h or 34) and LEVEL[floor] then   -- (with_drop_h: only once it's nearly down)
          -- Coming down a ladder beside him: it'll roll his way as soon as it lands.
          local bd = LEVEL[floor].dir
          local gap = (x0 - b.x) * bd
          if gap > 0 and gap <= params.with_x then close_dir = bd end
        end
      end
    end
    -- chase_zone {floor, from x, to x}: a barrel close behind him rolling his way (chase_x px); chase_w rewards jumping back over it
    -- now (chase_dir "back"), or any jump now ("any"). Grinding: on the 4th girder's right, the jump back over it is what still works.
    local chase_bd
    local cz = params.chase_zone
    if cz and floor == cz[1] and x0 >= cz[2] and x0 <= cz[3] then
      for _, b in ipairs(o.b) do
        if b.c == 0 and (b.d == 2 or b.d == 4) and level_of(b.y) == floor then
          local bd = b.d == 2 and 1 or -1
          local gap = (x0 - (b.x + bd * ROLL * age)) * bd
          if gap > 0 and gap <= params.chase_x then chase_bd = bd end
        end
      end
    end
    c.train = nil
    local tz = params.train_zone
    if tz and floor == tz[1] and x0 >= tz[2] and x0 <= tz[3] then
      local gaps = {}
      for _, b in ipairs(o.b) do
        if b.c == 0 and (b.d == 2 or b.d == 4) and level_of(b.y) == floor then
          local bd = b.d == 2 and 1 or -1
          local gap = (x0 - (b.x + bd * ROLL * age)) * bd   -- how far it has to roll to reach him
          if gap > 0 then gaps[#gaps + 1] = gap end
        end
      end
      table.sort(gaps)
      if #gaps >= 2 and gaps[1] >= tz[4] and gaps[1] <= tz[5] and gaps[2] - gaps[1] <= tz[6] then c.train = true end
    end
    local trail
    if params.trail_w then
      local list = {}
      for _, b in ipairs(o.b) do
        if b.c == 0 and (b.d == 2 or b.d == 4) and level_of(b.y) == floor then
          local side = b.d == 2 and 1 or -1
          local gap = (x0 - (b.x + side * ROLL * age)) * side
          if gap > 0 then list[#list + 1] = {gap = gap, x = b.x, side = side} end
        end
      end
      table.sort(list, function(a, b) return a.gap < b.gap end)
      if params.trail_group then
        -- (Matt) the case is a group (2+ barrels close enough to clear in one jump) with a third coming behind it: the jump over the
        -- group is chosen by the time it leaves before that third one arrives
        local n = 1
        while list[n + 1] and list[n + 1].side == list[1].side and list[n + 1].gap - list[n].gap <= params.trail_group do n = n + 1 end
        local tr = list[n + 1]
        if n >= 2 and tr and tr.side == list[1].side and list[1].gap <= params.trail_near and tr.gap - list[n].gap <= params.trail_gap then trail = tr end
      elseif #list >= 2 and list[1].side == list[2].side and list[2].gap - list[1].gap <= params.trail_gap and list[1].gap <= params.trail_near then trail = list[2] end
    end
    local hz
    local memo   -- plans already tried against this set of hazards (deciding asks about the same plan more than once)
    local function fill_hz(paths)
      memo = {}
      if params.dbghz and params.dbg and params.dbg(c.f_now) then   -- (why_plan) what's predicted near him
        for pi, path in ipairs(paths) do
          for st = params.dbghz[1], params.dbghz[2], 2 do
            local bx, by = path[st * 2 + 1], path[st * 2 + 2]
            if bx and math.abs(bx - x0) <= params.dbghz[3] and by > floor_y - 34 and by < floor_y + 16 then
              print(string.format("    hz path %d t=%d (%.1f,%.1f) maybe=%s lad=%s wild=%s", pi, st * 2, bx, by, tostring(path.maybe), tostring(path.lad), tostring(path.wild)))
            end
          end
        end
      end
      if NATIVE and not params.stick_odds then
        if params.dbgnative_at then params.dbgnative = (params.dbg and params.dbg(c.f_now)) and params.dbgnative_at or nil end   -- (why_plan) only at the frames asked about
        NATIVE.fill(paths, floor_y); NATIVE.set_ctx(params, x0, y0, floor, dirn, target, o.ham, age, fires)
        NATIVE.set_wild(params.wild_dynamic and c.wild_dyn or {}, floor_y, params.wild_pre and c.oil == 0 and params.wild_pre or nil)
        return
      end
      hz = {}
      for s = 0, PLAN_STEPS do hz[s] = {} end
      for _, path in ipairs(paths) do
        if path.climb_only then goto skip end
        local m, w = path.maybe and (path.commit or true), path.wild
        local ray = path.ray and path or false
        for s = 0, PLAN_STEPS do
          local bx = path[s * 2 + 1]
          if not bx then break end
          local by = path[s * 2 + 2]
          if by > floor_y - 34 and by < floor_y + 16 then
            local h = hz[s]
            h[#h + 1] = bx; h[#h + 1] = by; h[#h + 1] = m or false; h[#h + 1] = w or false; h[#h + 1] = ray; h[#h + 1] = path.lad or false
          end
        end
        ::skip::
      end
    end
    fill_hz(paths)
    -- which ladders above him a barrel could come down: one of its predicted paths takes it, or it's on it now
    local under_lads = {}
    if params.under_live then
      for _, path in ipairs(paths) do if path.lad then under_lads[path.lad] = true end end
      -- under_live = "rolling": any barrel on the girder above rolling towards the ladder, however far, or Kong about to throw
      if params.under_live == "rolling" then
        for _, b in ipairs(o.b) do
          if b.c == 0 and (b.d == 2 or b.d == 4) and level_of(b.y) == floor + 1 then
            local side = b.d == 2 and 1 or -1
            for _, d in ipairs(DROPS[floor + 1] or {}) do if (d - b.x) * side >= -1 then under_lads[d] = true end end
          end
        end
        if floor + 1 == 6 and c.next_throw and c.next_throw - f < 90 then for _, d in ipairs(DROPS[6]) do under_lads[d] = true end end
      end
      for _, b in ipairs(o.b) do
        if b.c == 0 and b.d ~= 2 and b.d ~= 4 and b.y < y0 then
          for _, d in ipairs(DROPS[floor + 1] or {}) do if math.abs(b.x - d) <= 3 then under_lads[d] = true end end
        end
      end
    end
    local stand_ok   -- with_needed: is standing where he is safe enough that a back jump isn't called for?

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
    -- Would this plan have him pressing towards ladder d at moment t, or be right under it?
    local function pressed_at(t, d, act, w1, j1, w2, j2, stay, mx)
      if math.abs(d - mx) < 1 then return true end
      local press = dirn
      if t < w1 then press = act
      elseif j1 then
        local tj = t - w1
        if tj < JUMP_LEN then
          local free = params.air_free and (params.air_free == true or params.air_free[floor])
          press = (free and tj > 8 and tj < JUMP_LEN - 4) and 0 or j1
        elseif stay then press = 0 end
      end
      return press ~= 0 and (d - mx) * press > 0
    end
    -- With stay, he stands where he lands rather than walking on, to see what the barrels do.
    local function try_plan_now(act, w1, j1, w2, j2, stay)
      local last = j1 and (w1 + JUMP_LEN + (j2 and (w2 + JUMP_LEN) or 0) + (c.extra_tail or params.plan_tail)) or (w1 + tail)
      local steps = math.min(last // 2, PLAN_STEPS)
      local xw = along(x0, act, w1)
      -- wall_jump: a jump that reaches the left wall (x=22) bounces off it and carries on the other way (measured)
      local function wall(x)
        if params.wall_jump then
          if x < 22 then return 44 - x end
          if params.wall_right and params.wall_right[floor] and x > 233 then return 466 - x end   -- the right wall, at x=233 (measured), on girders that reach it
        end
        return x
      end
      local xl = j1 and wall(xw + j1 * JUMP_X * JUMP_LEN) or xw
      local xs2 = j2 and along(xl, dirn, params.land_stall2 and math.max(0, w2 - LAND_STALL) or w2)
      local xl2 = j2 and wall(xs2 + j2 * JUMP_X * JUMP_LEN) or xl
      local best_c, risk, mx, my = 99, false, x0, y0
      local chance, soft = 0, 0
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
            mx = wall(xw + j1 * JUMP_X * tj); my = mario_y(floor, mx) + ARC[tj + 1]
          else
            local tw = tj - JUMP_LEN
            if j2 and tw >= w2 then
              local tk = tw - w2
              if tk < JUMP_LEN then
                mx = wall(xs2 + j2 * JUMP_X * tk); my = mario_y(floor, mx) + ARC[tk + 1]
              else
                mx = stay and xl2 or along(xl2, dirn, math.max(0, tk - JUMP_LEN - LAND_STALL)); my = mario_y(floor, mx)
              end
            else
              mx = (stay or j2) and xl or along(xl, dirn, math.max(0, tw - LAND_STALL)); my = mario_y(floor, mx)
            end
          end
        end
        -- with the right wall: in the air he can go up to it, but where he stands has to be on the girder, which ends at 224
        local airborne = j1 and ((t >= w1 and t - w1 < JUMP_LEN) or (j2 and t - w1 - JUMP_LEN >= w2 and t - w1 - JUMP_LEN - w2 < JUMP_LEN))
        local right_end = (params.wall_jump and params.wall_right and params.wall_right[floor]) and (airborne and 234 or (params.right_stand or 224)) or 222
        if mx < (params.wall_jump and 22 or 30) or mx > right_end then return nil, t, risk, mx end
        if params.ham_avoid and floor == 5 and mx < (params.ham_avoid_x or 40) and x0 >= (params.ham_avoid_x or 40) and o.ham == 0 then return nil, t, risk, mx end   -- the hammer's there
        if params.ham_avoid2 and floor == 2 and o.ham == 0 and j1 and t >= w1 and t - w1 < JUMP_LEN and mx >= params.ham_avoid2[1] and mx <= params.ham_avoid2[2] then return nil, t, risk, mx end   -- jumping here grabs the lower hammer
        local h = hz[s]
        for i = 1, #h, 6 do
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
                if t - free < params.respond then
                  if params.stick_odds and h[i + 5] and not pressed_at(cm, h[i + 5], act, w1, j1, w2, j2, stay, mx) then
                    soft = params.stick_odds   -- the game lets it come down far less often unless he's pressing towards the ladder
                  else
                    risk = true
                  end
                end
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
      return best_c, last, risk, mx, chance + soft
    end
    local function try_plan(act, w1, j1, w2, j2, stay, juke)
      if NATIVE and not params.stick_odds then   -- compiled, a repeat costs less than looking it up
        local last = j1 and (w1 + JUMP_LEN + (j2 and (w2 + JUMP_LEN) or 0) + (c.extra_tail or params.plan_tail)) or (w1 + tail)
        return NATIVE.try(act, w1, j1, w2, j2, stay, last, j1 and last or (w1 + params.plan_tail), math.min(last // 2, PLAN_STEPS), juke)
      end
      local key = act .. " " .. w1 .. " " .. tostring(j1) .. " " .. tostring(w2) .. " " .. tostring(j2) .. " " .. tostring(stay) .. " " .. tostring(c.extra_tail)
      local r = memo[key]
      if not r then
        r = table.pack(try_plan_now(act, w1, j1, w2, j2, stay))
        memo[key] = r
      end
      return table.unpack(r, 1, r.n)
    end

    local function score(cl, risk, xe, last, jumps)
      local prog = (xe - x0) * dirn / last
      return (cl > params.clear_cap and params.clear_cap or cl) * params.w_clear + prog * params.w_prog
        - jumps * params.w_jump - (risk and params.w_risk or 0)
    end

    local best, best_s, fallback, fallback_t
    local pref_fb, pref_t
    -- A jump is only any good if he can deal with what comes after it, like a person watching the next barrel
    -- before he leaves the ground: either he can stand where he lands, or there's a second jump that works.
    local function next_ok(act, w1, j1)
      c.extra_tail = params.next_tail
      local a, _, rk = try_plan(act, w1, j1, nil, nil, true)
      c.extra_tail = nil
      if a and a >= 1 and not (params.next_risk and rk) then return true end
      for _, w2 in ipairs(params.next_waits) do
        for _, j2 in ipairs({0, -dirn}) do
          local cl2, _, rk2 = try_plan(act, w1, j1, w2, j2, true)
          if cl2 and cl2 >= 1 and not (params.next_risk and rk2) then return true end
        end
      end
      return false
    end
    local function consider(act, w1, j1, w2, j2, stay, juke)
      -- Just landed: the game ignores a press for a few frames, so the soonest this jump can really start is then.
      if params.jump_ready and j1 and c.jump_ready and f + w1 < c.jump_ready then w1 = c.jump_ready - f end
      -- A press takes a frame or two to become a jump, and he allows for it.
      local cl, t, risk, xe, chance, follow = try_plan(act, j1 and params.press_lag and w1 + params.press_lag or w1, j1, w2, j2, stay, juke)
      if cl then
        local v = score(cl, risk, xe, t, (j1 and 1 or 0) + (j2 and 1 or 0)) + w1 * params.w_later - chance * params.w_ray
        if params.w_no_follow and follow == false then v = v - params.w_no_follow end   -- (follow_check) it leaves him with no way on
        -- With nothing comfortable left, getting away matters and progress doesn't.
        if params.thin_safe and cl < params.min_clear then v = v - (xe - x0) * dirn / t * params.w_prog + cl * params.thin_safe end
        if j1 and j1 ~= 0 then v = v - (params["w_sideways" .. floor] or params.w_sideways) end   -- a straight jump is calmer
        -- train_zone {floor, from x, to x, nearest, furthest, gap, bonus} (Matt: anticipate): two barrels rolling at him close
        -- together; jump the first early, straight, while it's still nearest..furthest px away, so he's down in time for the second
        if c.train and j1 == 0 and w1 <= 2 then v = v + params.train_zone[7] end
        -- trail (Matt: "how close the 2nd barrel will be to me, how much time I'll have to react to the trailing barrels"): two
        -- barrels rolling at him on his girder, the second within trail_gap of the first: for a jump over the first, how many
        -- frames after landing before the second reaches where he lands. Below trail_need, each frame short costs trail_w;
        -- so with a close second barrel he picks the jump (a back jump with it, usually) that leaves him time for it.
        if params.trail_w and j1 and trail then
          local xl = along(x0, act, w1) + j1 * JUMP_X * JUMP_LEN
          local tl = w1 + JUMP_LEN
          local b2x = trail.x + trail.side * ROLL * (age + tl)   -- where the second barrel is when he lands
          local left = (xl - b2x) * trail.side                 -- how far it still has to roll to reach him
          local short = params.trail_need - left / ROLL
          if short > 0 then v = v - short * params.trail_w end
        end
        -- left_zone {floor, from x, to x, cost} (Matt: at ladder 91's foot a left jump is the worst option, into what's coming)
        local lz = params.left_zone
        if lz and j1 == -1 and floor == lz[1] and x0 >= lz[2] and x0 <= lz[3] then v = v - lz[4] end
        if cl < params.min_clear then v = v - params.w_thin end
        if params.w_no_next and j1 and not j2 and not next_ok(act, w1, j1) then v = v - params.w_no_next end
        if params.w_under and j1 then
          -- Leaving the ground or landing right under a ladder: he can't react if a barrel comes down it, and being there draws them.
          local xa = along(x0, act, w1)
          local xb = xa + j1 * JUMP_X * JUMP_LEN
          local ladders = DROPS[floor + 1]
          for i = 1, ladders and #ladders or 0 do
            local here = not params.under_zones
            if params.under_live and not under_lads[ladders[i]] then goto next_ladder end   -- under_live: only if a barrel could come down it
            for _, z in ipairs(params.under_zones or {}) do if z[1] == floor and ladders[i] >= z[2] and ladders[i] <= z[3] then here = true end end   -- under_zones: only these ladders
            if here and (math.abs(ladders[i] - xa) <= params.under_x or math.abs(ladders[i] - xb) <= params.under_x) then v = v - params.w_under; break end
            ::next_ladder::
          end
        end
        if close_dir and j1 == close_dir and not (params.with_needed and stand_ok) and (w1 <= 6 or (c.jump_ready and f + w1 <= c.jump_ready + 2)) and (not params.with_next or j2 or next_ok(act, w1, j1)) and cl >= (params.with_cl or 0) and not (params.with_min_x and along(x0, act, w1) + j1 * JUMP_X * JUMP_LEN < params.with_min_x) then v = v + params.w_with end   -- (with_min_x: not when it lands him near the left corner)   -- now, or as soon as he can after landing
        if wild_about and w1 > 0 and c.last_act and c.last_act ~= 0 and act == -c.last_act then v = v - params.w_commit end   -- turning back under a barrel costs ground
        if chase_bd and j1 and w1 <= (params.chase_now or 6) and (params.chase_dir == "any" or j1 == -chase_bd) then v = v + params.chase_w end
        -- jitter: his press can land a frame or two late; a jump that only works if pressed exactly on time is marked down
        if params.jitter and j1 then
          local cj = try_plan(act, (params.press_lag and w1 + params.press_lag or w1) + params.jitter, j1, w2, j2, stay, juke)
          if not cj then v = v - params.w_jitter end
        end
        if c.keeping and params.w_keep and w1 == c.keeping then v = v + params.w_keep end   -- (keep_jump) the jump he already planned
        if not best_s or v > best_s then best_s = v; best = {act = act, w1 = w1, j1 = j1, cl = cl, juke = juke} end
      elseif not fallback_t or t > fallback_t then
        fallback_t = t; fallback = {act = act, w1 = w1, j1 = j1}
      end
      -- fallback_pref: with nothing safe, the jump that grinding found usually works in this spot, if it lasts nearly as long
      if not cl and params.fallback_pref and j1 and (not pref_t or t > pref_t) then
        for _, r in ipairs(params.fallback_pref) do   -- {floor, from x, to x, jump direction}: only in the spot grinding covered
          if r[1] == floor and x0 >= r[2] and x0 <= r[3] and j1 == r[4] then pref_t = t; pref_fb = {act = act, w1 = w1, j1 = j1} end
        end
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
    -- ham_ladder: with the hammer, a barrel coming down a ladder close beside him lands where the hammer can't reach: step away from it
    if params.ham_ladder and o.ham ~= 0 then
      for _, b in ipairs(o.b) do
        if b.c == 0 and b.d ~= 2 and b.d ~= 4 and b.y < y0 and y0 - b.y < 34 and math.abs(b.x - x0) <= params.ham_ladder then
          c.why = "hammer: step away from the ladder"; c.last_act = 0
          c.plan = b.x > x0 and LEFT or RIGHT
          return c.plan
        end
      end
    end
    -- ham_stop (Matt's pro tip): with the hammer, stop just before a barrel rolling at him, so it can't go under the hammer
    if params.ham_stop and o.ham ~= 0 then
      for _, b in ipairs(o.b) do
        if b.c == 0 and (b.d == 2 or b.d == 4) and level_of(b.y) == floor then
          local side = b.d == 2 and 1 or -1
          local gap = (x0 - (b.x + side * ROLL * age)) * side
          if gap > 0 and gap <= params.ham_stop then
            c.why = "hammer: wait for it"; c.last_act = 0
            c.plan = side > 0 and LEFT or RIGHT   -- face it (one frame's press turns him), then stand
            if params.face_known then
              -- face_known: he can see which way Mario faces; with the hammer one press doesn't always turn him, so press till he does
              local face = (o.now and o.now.face) or o.face
              if face == (side > 0 and -1 or 1) then c.plan = 0 end
            elseif c.ham_faced == b.k then c.plan = 0 end
            c.ham_faced = b.k
            return c.plan
          end
        end
      end
      c.ham_faced = nil
    end
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
        -- ham_tap (Matt's hammer tip, for any barrel, wild ones too): one press turns him to face it, then he stands and
        -- lets it come to the hammer, instead of walking into it
        if params.ham_tap and params.face_known then
          local face = (o.now and o.now.face) or o.face
          if face == (near_dx > 0 and 1 or -1) then c.plan = 0; c.why = "face it, wait" end
        elseif params.ham_tap then
          if c.ham_dir == c.plan then c.plan = 0; c.why = "face it, wait" else c.ham_dir = c.plan end
        end
        return c.plan
      end
      c.ham_dir = nil
    end

    -- Nothing near: no need to weigh anything up.
    do
      local cl, _, risk, _, chance = try_plan(at_ladder and 0 or dirn, 0, nil)
      local think = false
      for _, z in ipairs(params.think_zones or {}) do if z[1] == floor and x0 >= z[2] and x0 <= z[3] then think = true end end
      if cl and cl >= params.walk_clear and not risk and (chance or 0) < params.ray_ok and not think then
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
        for _, w1 in ipairs(params.fine_waits and WAITS_FINE or WAITS) do
          consider(act, w1, nil)
          -- Matt's juke: stand still, and tap right just as a wild barrel lands, which flings it right
          if params.juke and NATIVE and act == 0 and #c.wild_dyn > 0 then
            consider(0, w1, nil, nil, nil, nil, true)
            for _, j1 in ipairs(need_jump and {dirn, 0, -dirn} or {}) do consider(0, w1, j1, nil, nil, nil, true) end
          end
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
    if params.with_needed then local cs = try_plan(0, 0, nil); stand_ok = cs and cs >= params.min_clear end
    weigh()
    -- keep_jump: the jump he planned a moment ago, at the same moment (his list of waits is coarse, and with a slight
    -- preference for later, re-planning every two frames lets a planned jump keep slipping). w_keep: some loyalty to it.
    local kept = c.kept
    if params.keep_jump and kept and kept.floor == floor and kept.at > f and kept.at - f <= 44 then
      c.keeping = kept.at - f
      consider(kept.act, kept.at - f, kept.j1)
      c.keeping = nil
    end
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
    if not best and pref_fb and fallback_t and pref_t >= fallback_t - (params.fallback_slack or 6) then fallback = pref_fb end
    local p = best or fallback
    c.why = best and "plan" or "no safe plan"
    c.chosen = best   -- (chase_stop) what he settled on: act, w1, j1
    if params.keep_jump then c.kept = (best and best.j1 and best.w1 > 0) and {act = best.act, at = f + best.w1, j1 = best.j1, floor = floor} or nil end
    if params.top_guard and p.j1 and p.w1 == 0 and o.lad ~= 0 and c.past_top ~= f then
      -- Still on the last rungs: the game ignores a jump here, and he'd stand there thinking he was in the air.
      c.plan = UP; c.why = "climb"; return UP
    end
    if p.j1 and p.w1 == 0 then
      local d = p.j1
      local mask = JUMP | (d > 0 and RIGHT or (d < 0 and LEFT or 0))
      c.press_until = f + 3
      c.jump_f = f
      c.jump_x = x0
      c.jump_ready = params.jump_ready and f + params.jump_ready or nil
      c.air_until = f + JUMP_LEN + params.land_wait   -- a press before his feet are down is ignored by the game
      c.ground_floor = floor
      c.air_dir = d > 0 and RIGHT or (d < 0 and LEFT or 0)
      c.why = c.why .. " jump"
      c.last_act = nil
      c.plan = mask
      return mask
    end
    if p.juke and NATIVE.juke_now(params.juke_lead or 3) then c.why = c.why .. " juke"; c.last_act = 0; c.plan = RIGHT; return RIGHT end
    local d = p.act
    if at_ladder and d == dirn then d = 0 end
    -- for steer_pull: would a few steps the way he'd tap be safe?
    c.pull_ok = nil; c.pull_jump_ok = nil
    if params.steer_pull and (d == 0 or params.pull_moving) and not p.j1 and LEVEL[floor] then
      local cl = try_plan(LEVEL[floor].dir, params.pull_walk or 6, nil)
      c.pull_ok = cl and cl >= params.min_clear
      -- pull_jump: if a few steps aren't safe, would a straight jump now be? (then he steers from the air)
      if params.pull_jump and not c.pull_ok then
        local cj = try_plan(0, 0, 0)
        c.pull_jump_ok = cj and cj >= params.min_clear
      end
    end
    if d ~= 0 then c.cur_dir = d end
    c.last_act = d
    best = {mask = d > 0 and RIGHT or (d < 0 and LEFT or 0)}
    c.plan = best.mask
    return c.plan
  end

  -- Remember how far each frame's input moves him, to work out where he is now from what he last saw.
  -- cases (tools/solve.py): situations from past deaths, each with the move that got through when it was played back.
  -- When what he sees matches one closely (his girder, his x within case_x, the same barrels near him each within case_b
  -- px and going the same way), he makes that move, as a player who has been here before.
  local CASES = params.cases and dofile(params.cases) or nil
  -- (Matt) solutions found closer to the death count for more: when several match, the one found closest to its death is used
  if CASES then table.sort(CASES, function(p, q) return (p.early or 999) < (q.early or 999) end) end
  local function case_stick(p, t)
    if t < p.w then return p.a end
    if not p.j1 then return nil end
    local u = t - p.w
    if u < 3 then return JUMP | p.j1 end
    if u < 44 then return (p.h and u < 40) and p.h or p.j1 end
    if not p.j2 then return nil end
    if u < 50 then return 0 end
    u = u - 50
    if u < 3 then return JUMP | p.j2 end
    if u < 44 then return p.j2 end
    return nil
  end
  local function match_case(o, f)
    local me = (params.case_now and o.now) or o   -- case_now: his real position (he knows where he is), barrels as he sees them
    if me.jmp ~= 0 or me.lad ~= 0 then return nil end
    local fl, ham = P.floor(me.y), o.ham ~= 0 and 1 or 0
    local near = {}
    for _, b in ipairs(o.b) do
      local dx, dy = b.x - me.x, b.y - me.y
      if params.case_above and dy > params.case_above then
        -- (Matt) barrels below his girder don't matter: not compared
      elseif params.case_all or (math.abs(dx) <= 64 and dy >= -50 and dy <= 16) then near[#near + 1] = {dx, dy, (b.d == 2 or b.d == 4) and b.d or 0, b.c ~= 0 and 1 or 0} end
    end
    local tx, tb = params.case_x or 3, params.case_b or 6
    local best_cs, best_err
    for _, cs in ipairs(CASES) do
      local cb_list = cs.b
      if params.case_above then
        cb_list = cs.above
        if not cb_list then cb_list = {}; for _, cb in ipairs(cs.b) do if cb[2] <= params.case_above then cb_list[#cb_list + 1] = cb end end; cs.above = cb_list end
      end
      -- case_kong / case_walk: the hidden state a player can see too: Kong's pose and how long he has held it (frames, within
      -- case_kong), and Mario's walk rhythm (the frame counter's low bits)
      local hidden = true
      if params.case_kong and cs.kong then hidden = cs.kong == o.kong and math.abs(cs.kage - (f - (c.kp_f or f))) <= params.case_kong end
      if hidden and params.case_walk and cs.fc and me.fc then hidden = (cs.fc % 4) == (me.fc % 4) end
      if hidden and cs.fl == fl and cs.ham == ham and #cb_list > 0 and #cb_list == #near and math.abs(cs.x - me.x) <= tx then
        local used, all = {}, true
        for _, cb in ipairs(cb_list) do
          local hit = false
          -- case_far: more slack for barrels further from him ("roughly those positions")
          local tol = tb + (params.case_far or 0) * (math.abs(cb[1]) + math.abs(cb[2]))
          for i, nb in ipairs(near) do
            if not used[i] and nb[3] == cb[3] and nb[4] == cb[4] and math.abs(nb[1] - cb[1]) <= tol and math.abs(nb[2] - cb[2]) <= tol then used[i] = true; hit = true; break end
          end
          if not hit then all = false; break end
        end
        if all then
          if not params.case_best then return cs end
          -- case_best: of all the solutions that match, the closest match (smallest total barrel offset, then nearest his spot)
          local err = math.abs(cs.x - me.x) * 2
          for _, cb in ipairs(cb_list) do
            local bestd = 1e9
            for _, nb in ipairs(near) do if nb[3] == cb[3] and nb[4] == cb[4] then local d = math.abs(nb[1] - cb[1]) + math.abs(nb[2] - cb[2]); if d < bestd then bestd = d end end end
            err = err + bestd
          end
          if not best_cs or err < best_err then best_cs, best_err = cs, err end
        end
      end
    end
    return best_cs
  end

  -- ham_top {hammer x, gap from, gap to, most frames to wait} (Matt, 2026-11-10: "a good Kong player will always grab the hammer up
  -- there and jump vertically, then land with the hammer just as the barrel is in the perfect spot to be hit"): on the 5th girder
  -- with the top hammer still there, he heads for it instead of the ladder up; under it he turns to face the barrels coming from the
  -- right and waits, then jumps straight up when the nearest one rolling at him is `gap` px away, so he lands swinging as it
  -- arrives. If the planner wants to jump to dodge, that jump grabs it too. Once he has it, the hammer rules take over.
  local ROUTE5 = P.ROUTE[5]
  local function ham_top_route(o)
    local ht = params.ham_top
    local me = (params.know_self and o.now) or o
    if o.ham ~= 0 then c.ham_used = true; end   -- one hammer a board (the game shows it again once it wears off)
    -- ham_hold {x, frames} (Matt): with the top hammer he stands just left of ladder 91 smashing what comes, and only heads right
    -- for the far ladder once he's held it that long (it lasts about 800-1,000 frames)
    local hh = params.ham_hold
    if hh and o.ham ~= 0 and c.ham_held_from and P.floor(me.y) == 5 and c.now_f - c.ham_held_from < hh[2] then
      P.ROUTE[5] = {x = hh[1], top = -999, arrive = 1}
      return false, ht, me
    end
    local on = ht and not c.ham_used and o.hamtop == 1 and o.ham == 0 and o.lad == 0 and P.floor(me.y) == 5
    P.ROUTE[5] = on and {x = ht[5] or 48, top = -999, arrive = 1} or ROUTE5
    return on, ht, me
  end
  local function ham_top_move(o, f, age, m, ht, me)
    -- Matt's way (2026-11-10): from the wait spot (ht[5], outside the hammer's reach) he goes left to the girder's edge (ht[1]),
    -- turns to face right, and jumps straight up for the hammer as a barrel crosses the foot of the broken ladder in front of Kong
    -- (nearest barrel coming at him ht[2]-ht[3] px away), so landing smashes it. He waits at most ht[4] frames at the edge.
    local wx = ht[5] or 48
    local function nearest()
      local gap
      for _, b in ipairs(o.b) do
        if b.c == 0 and level_of(b.y) == 5 and b.d ~= 2 then
          local g = b.x - ROLL * age - me.x
          if g > -6 and (not gap or g < gap) then gap = g end
        end
      end
      return gap
    end
    if c.ham_jump and f < c.ham_jump then c.why = "hammer: jump for it"; c.plan = 0; return JUMP end   -- held 3 frames, so it lands
    if c.ham_jump2 and f < c.ham_jump2 then c.why = "hammer: jump it first"; c.plan = 0; return JUMP | RIGHT end
    c.ham_jump = nil
    if me.jmp ~= 0 then c.ham_go = nil; return m end
    if c.ham_go then
      if me.x > ht[1] + 1 and f - c.ham_go < 60 then c.why = "hammer: to the edge"; c.plan = LEFT; return LEFT end
      c.ham_go = nil; c.ham_edge = f
    end
    if c.ham_edge and me.x <= ht[1] + 4 then
      local face = (o.now and o.now.face) or o.face
      if face ~= 1 then c.why = "hammer: turn round"; c.plan = 0; return RIGHT end
      local gap = nearest()
      -- a barrel already too close for that: let it come right up and jump as it gets there, so it passes under on the way up,
      -- before the grab slows his fall, and rolls off the end (ht[6], px)
      if (gap and gap >= ht[2] and gap <= ht[3]) or (gap and gap < ht[2] and gap <= (ht[6] or 14)) or f - c.ham_edge >= ht[4] then
        c.why = "hammer: jump for it"; c.ham_jump = f + 3; c.ham_edge = nil; c.plan = 0; return JUMP
      end
      c.why = "hammer: wait at the edge"; c.plan = 0
      -- if the planner wants to dodge here, it's a straight jump: that takes the hammer and lands him facing the barrels
      -- (a jump left misses it and bounces him off the wall)
      -- but with a barrel already too close for the grab (it'd reach him before the hammer can swing), he jumps right over it
      -- instead, away from the hammer, and comes back for it after (ht[8]: how far short of the window that is)
      if m & JUMP ~= 0 then
        if gap and gap < ht[2] - (ht[8] or 99) then c.why = "hammer: jump it first"; c.ham_edge = nil; c.ham_jump2 = f + 3; return JUMP | RIGHT end
        c.why = "hammer: jump for it"; c.ham_jump = f + 3; c.ham_edge = nil; return JUMP
      end
      return 0
    end
    c.ham_edge = nil
    if math.abs(me.x - wx) > 3 then return m end
    if m & JUMP ~= 0 then return m end   -- dodging something first
    local gap = nearest()
    -- go only if the next barrel won't reach the jump spot before he's ready there (about 30 frames to walk in and turn)
    -- (barra, 2026-11-10: he steps onto the spot only with the next barrel still back at the broken ladder or further: ht[7] is
    -- the margin in px beyond the jump window it must still have to come, allowing for the walk in)
    if params.ham_straight or not gap or gap - (wx - ht[1]) >= ht[2] + (ht[7] or 30) then c.ham_go = f; c.why = "hammer: to the edge"; c.plan = LEFT; return LEFT end
    c.why = "hammer: wait for the gap"; c.plan = 0
    return m & ~(LEFT | RIGHT) == 0 and 0 or m
  end
  function c.decide(o, f, age)
    if o.kong ~= c.kp then c.kp = o.kong; c.kp_f = f end   -- when Kong took his current pose (as he sees it)
    c.now_f = f
    if o.ham ~= 0 and not c.ham_held_from then c.ham_held_from = f end
    local hon, ht, hme = ham_top_route(o)
    local m = decide(o, f, age)
    P.ROUTE[5] = ROUTE5
    if hon then m = ham_top_move(o, f, age, m & ~UP, ht, hme) elseif o.ham ~= 0 then c.ham_turned = nil end
    -- step_with {floor, from x, to x, nearest, furthest, frames}: a barrel on his girder rolling at him this close: a short
    -- step its way first, once per barrel (solved deaths: 14 of 17 near ladder 91's top on 5-1 were a 4-20 frame step left)
    local sw = params.step_with
    if sw and not c.script and o.jmp == 0 and o.lad == 0 and P.floor(o.y) == sw[1] and o.x >= sw[2] and o.x <= sw[3] then
      for _, b in ipairs(o.b) do
        if b.c == 0 and (b.d == 2 or b.d == 4) and level_of(b.y) == sw[1] and c.stepped ~= b.k then
          local side = b.d == 2 and 1 or -1
          local gap = (o.x - (b.x + side * ROLL * age)) * side
          if gap >= sw[4] and gap <= sw[5] then
            c.stepped = b.k
            c.script = {p = {a = side > 0 and RIGHT or LEFT, w = sw[6]}, f0 = f, src = "step with it"}
            break
          end
        end
      end
    end
    if CASES or c.script then
      if CASES and not c.script and f >= (c.case_cool or 0) then
        local cs = match_case(o, f)
        if cs then
          c.script = {p = cs.plan, f0 = f, src = cs.src}
          if os.getenv("CASELOG") then local h = io.open(os.getenv("CASELOG"), "a"); h:write(cs.src, " ", f, " ", o.x, " ", o.y, "\n"); h:close() end
        end
      end
      if c.script then
        local cm = case_stick(c.script.p, f - c.script.f0)
        if cm then c.why = "remembers " .. c.script.src; c.plan = cm; return cm end
        c.script = nil; c.case_cool = f + 30; c.plan = 0; c.air_until = nil
      end
    end
    c.steering = (c.why or ""):find("steer", 1, true) ~= nil   -- a steer from the air mustn't be undone below
    -- lad_hyst: on a ladder, once he changes direction he keeps going that way for a moment, instead of flipping back
    if params.lad_hyst then
      if o.lad ~= 0 and (m == UP or m == DOWN) then
        if c.lad_dir and m ~= c.lad_dir and f < (c.lad_until or 0) then m = c.lad_dir; c.plan = m; c.why = c.why .. " (keeps going)"
        elseif m ~= c.lad_dir then c.lad_dir = m; c.lad_until = f + params.lad_hyst end
      elseif o.lad == 0 then c.lad_dir = nil end
    end
    -- Matt's steering: standing still, tap towards a ladder the barrel above is about to cross, when the ladder is on the side
    -- barrels on his own girder roll away to. It then takes the ladder far more often (the game takes it if the stick points
    -- at it, after a difficulty check) and rolls off away from him; and it skips the ladders on the other side, which feed him.
    local wild_near = false   -- pull_nowild: not with a wild barrel above him and this close sideways (Matt's death 1)
    if params.pull_nowild then
      for _, b in ipairs(o.b) do if b.c ~= 0 and b.y < o.y and math.abs(b.x - o.x) <= params.pull_nowild then wild_near = true end end
    end
    -- pull_moving (2026-11-10, the experts pull barrels down a downstream ladder 17-48 px away 81-85% of the time, he 8%): also
    -- while walking, not only when standing with nothing to do
    local pull_ok_m = m == 0 or (params.pull_moving and m & (JUMP | UP | DOWN) == 0)
    if params.steer_pull and pull_ok_m and o.lad == 0 and o.jmp == 0 and not wild_near then
      local pd = (not params.pull_safe or c.pull_ok or c.pull_jump_ok) and pull_dir(o, age)
      if pd and (not params.pull_safe or c.pull_ok) then c.why = c.why .. " steer"; m = pd; c.steering = true
      elseif pd and c.pull_jump_ok and params.steer_air then
        -- jump straight to steer from the air, set up as any other straight jump
        c.press_until = f + 3; c.jump_f = f; c.jump_x = o.x
        c.jump_ready = params.jump_ready and f + params.jump_ready or nil
        c.air_until = f + JUMP_LEN + params.land_wait
        c.ground_floor = P.floor(o.y); c.air_dir = 0
        c.why = c.why .. " steer jump"; c.plan = JUMP
        m = JUMP; c.steering = true
      end
    end
    local me = (params.know_self and o.now) or o   -- he knows where he is (know_self); barrels are as he sees them
    -- chase_stop {floor, from x, to x, nearest, furthest} (grinding 4th-girder deaths): walking away from a barrel rolling after
    -- him this close behind only puts off the jump (his planned jump keeps slipping); he stops and lets it come, then jumps it
    local cs = params.chase_stop
    if cs and me.lad == 0 and me.jmp == 0 and P.floor(me.y) == cs[1] and me.x >= cs[2] and me.x <= cs[3] and m & JUMP == 0 and m & (LEFT | RIGHT) ~= 0 then
      for _, b in ipairs(o.b) do
        if b.c == 0 and (b.d == 2 or b.d == 4) and level_of(b.y) == cs[1] then
          local side = b.d == 2 and 1 or -1
          local gap = (me.x - (b.x + side * ROLL * age)) * side
          local away = (side > 0 and m & RIGHT ~= 0) or (side < 0 and m & LEFT ~= 0)
          -- cs[6]: only when his plan is the slipping kind, "walk on for 6+ frames, then jump"
          local ch = (c.why or ""):sub(1, 4) == "plan" and c.chosen
          local slipping = ch and ch.j1 and ch.w1 >= 6 and ch.act == side
          if away and gap >= cs[4] and gap <= cs[5] and (not cs[6] or slipping) then m = 0; c.plan = 0; c.why = c.why .. " stops for the chaser" end
        end
      end
    end
    -- setups (Matt: only in the relevant situations, "when barrels are in similar places, Mario is in the similar place"): each
    -- {floor, x from, x to, needs = {...}, move = {a, w, j1, h}}. Mario standing or walking on that girder in that x range, and
    -- every need met by some barrel: {girder up from his (0 his own, 1 the one above), dx from, dx to (barrel x - Mario x),
    -- dir ("L", "R", "e" on a ladder or going over an end, "any"), ladder x and how far short of it from/to (optional)}.
    -- Then he makes that move, once per setup per barrel in the first need.
    for si, st in ipairs(params.setups or {}) do
      if not c.script and me.lad == 0 and me.jmp == 0 and P.floor(me.y) == st[1] and me.x >= st[2] and me.x <= st[3] then
        local all, key = true, nil
        for ni, nd in ipairs(st.needs) do
          local hit = nil
          for _, b in ipairs(o.b) do
            if b.c == 0 and level_of(b.y) == st[1] + nd[1] then
              local bx = b.x + ((b.d == 2 and 1) or (b.d == 4 and -1) or 0) * ROLL * age
              local dx = bx - me.x
              local dir = (b.d == 2 and "R") or (b.d == 4 and "L") or "e"
              local ok = dx >= nd[2] and dx <= nd[3] and (nd[4] == "any" or nd[4] == dir)
              if ok and nd[5] then local short = (nd[5] - bx) * (dir == "L" and -1 or 1); ok = short >= nd[6] and short <= nd[7] end
              if ok then hit = b.k; break end
            end
          end
          if not hit then all = false; break end
          if ni == 1 then key = hit end
        end
        c.setup_done = c.setup_done or {}
        if all and c.setup_done[si] ~= key and st.detect then
          -- detect: only note that the setup came up (game, frame), changing nothing
          c.setup_done[si] = key
          c.fired[#c.fired + 1] = string.format("seen %s@%d:%d", st.name or si, f, me.x)
        elseif all and c.setup_done[si] ~= key then
          c.setup_done[si] = key
          c.script = {p = st.move, f0 = f, src = st.name or ("setup " .. si)}
          if PREDLOG then PREDLOG:write(string.format("U %d %d\n", f, si)) end
        end
      end
    end
    -- hold_ground {floor, from x, to x, range} (Matt, review 4 #2): just up the middle ladder, with barrels rolling at him within range,
    -- he doesn't walk towards them; he stands and jumps them straight as they come
    local hg = params.hold_ground
    if hg and me.lad == 0 and me.jmp == 0 and P.floor(me.y) == hg[1] and me.x >= hg[2] and me.x <= hg[3] and m & JUMP == 0 and m & (LEFT | RIGHT) ~= 0 then
      for _, b in ipairs(o.b) do
        if b.c == 0 and (b.d == 2 or b.d == 4) and level_of(b.y) == hg[1] then
          local side = b.d == 2 and 1 or -1
          local gap = (me.x - (b.x + side * ROLL * age)) * side
          local towards = (side > 0 and m & LEFT ~= 0) or (side < 0 and m & RIGHT ~= 0)
          if towards and gap > 0 and gap <= hg[4] then m = 0; c.plan = 0; c.why = c.why .. " holds his ground" end
        end
      end
    end
    -- back_jump {floor, from x, to x, nearest, furthest, step} (Matt, review 4 #1): a barrel rolling at him this close: step towards it
    -- for `step` frames, then jump the way it's going (over it, landing behind it), which leaves time for the ones after it
    local bj = params.back_jump
    if bj and not c.script and me.lad == 0 and me.jmp == 0 and P.floor(me.y) == bj[1] and me.x >= bj[2] and me.x <= bj[3] and not (c.air_until and f < c.air_until) then
      for _, b in ipairs(o.b) do
        if b.c == 0 and (b.d == 2 or b.d == 4) and level_of(b.y) == bj[1] and c.backjumped ~= b.k then
          local side = b.d == 2 and 1 or -1
          local gap = (me.x - (b.x + side * ROLL * age)) * side
          if gap >= bj[4] and gap <= bj[5] then
            c.backjumped = b.k
            c.script = {p = {a = side > 0 and LEFT or RIGHT, w = bj[6], j1 = side > 0 and RIGHT or LEFT, h = side > 0 and RIGHT or LEFT}, f0 = f, src = "back jump"}
            break
          end
        end
      end
    end
    -- low_roof {floor, from x, to x, nearest, furthest, overhead, frames} (grinding 5-1 deaths under Kong's girder; Matt's review 2
    -- #10): standing where the girder above is close, with a barrel rolling at him this close and one on the girder above within
    -- overhead px sideways, he walks left that many frames first, so he jumps it where there's more headroom
    local lr = params.low_roof
    if lr and not c.script and me.lad == 0 and me.jmp == 0 and P.floor(me.y) == lr[1] and me.x >= lr[2] and me.x <= lr[3] and m & JUMP == 0 then
      local coming, above
      for _, b in ipairs(o.b) do
        if b.c == 0 and (b.d == 2 or b.d == 4) then
          if level_of(b.y) == lr[1] then
            local side = b.d == 2 and 1 or -1
            local gap = (me.x - (b.x + side * ROLL * age)) * side
            if gap >= lr[4] and gap <= lr[5] then coming = b.k end
          elseif level_of(b.y) == lr[1] + 1 and math.abs(b.x - me.x) <= lr[6] then above = true end
        end
      end
      if coming and above and c.roofed ~= coming then
        c.roofed = coming
        c.script = {p = {a = LEFT, w = lr[7]}, f0 = f, src = "more headroom"}
      end
    end
    -- foot_dodge {floor, from x, to x, dx from, dx to, frames} (grinding deaths at ladder 91's foot): waiting there, with a barrel
    -- coming down a ladder up to his right that close, he steps left that many frames, once per barrel
    local fd = params.foot_dodge
    if fd and not c.script and me.lad == 0 and me.jmp == 0 and P.floor(me.y) == fd[1] and me.x >= fd[2] and me.x <= fd[3] and m & JUMP == 0 then
      for _, b in ipairs(o.b) do
        local dx, dy = b.x - me.x, b.y - me.y
        if b.c == 0 and b.d ~= 2 and b.d ~= 4 and dx >= fd[4] and dx <= fd[5] and dy >= -45 and dy <= -15 and c.dodged ~= b.k then
          c.dodged = b.k
          c.script = {p = {a = LEFT, w = fd[6]}, f0 = f, src = "steps away from the ladder"}
          break
        end
      end
    end
    -- chase_jump {floor, from x, to x, nearest, furthest} (grinding 4th-girder-right deaths; Matt's "anticipate"): a barrel
    -- rolling after him this close behind: jump it straight now, once, rather than run on ahead of it
    local cj = params.chase_jump
    if cj and o.lad == 0 and o.jmp == 0 and not (c.air_until and f < c.air_until) and P.floor(o.y) == cj[1] and me.x >= cj[2] and me.x <= cj[3] and m & JUMP == 0 then
      for _, b in ipairs(o.b) do
        if b.c == 0 and (b.d == 2 or b.d == 4) and level_of(b.y) == cj[1] and c.chase_jumped ~= b.k then
          local side = b.d == 2 and 1 or -1
          local gap = (me.x - (b.x + side * ROLL * age)) * side
          if gap >= cj[4] and gap <= cj[5] then
            c.chase_jumped = b.k
            c.press_until = f + 3; c.jump_f = f; c.jump_x = me.x
            c.jump_ready = params.jump_ready and f + params.jump_ready or nil
            c.air_until = f + JUMP_LEN + params.land_wait
            c.ground_floor = P.floor(me.y); c.air_dir = 0
            c.why = "jumps the chaser early"; c.plan = JUMP
            return JUMP
          end
        end
      end
    end
    -- steer_zone {floor, from x, to x, girder above, ladder x, window} (Matt): on that stretch of his girder, as a barrel on
    -- the girder above reaches that ladder, a tap towards it sends it down there, away from where he's going
    local sz = params.steer_zone
    if sz and o.lad == 0 and o.jmp == 0 and P.floor(o.y) == sz[1] and o.x >= sz[2] and o.x <= sz[3] and m & JUMP == 0 and (not sz[7] or m == 0) then   -- sz[7]: only when he'd be standing anyway (as validated: his delayed view)
      for _, b in ipairs(o.b) do
        if b.c == 0 and (b.d == 2 or b.d == 4) and level_of(b.y) == sz[4] then
          local side = b.d == 2 and 1 or -1
          local ahead = (sz[5] - (b.x + side * ROLL * age)) * side
          if ahead >= -1 and ahead <= sz[6] then
            if PREDLOG then PREDLOG:write(string.format("S %d %d %d\n", f, b.k, sz[5])) end
            m = sz[5] > o.x and RIGHT or LEFT; c.why = c.why .. " steer it down"; c.steering = true
          end
        end
      end
    end
    -- Pressing towards a ladder makes a barrel crossing it above far likelier to come down (tested from identical moments), so he lets go as one crosses.
    if params.steer_off and not c.steering and m & JUMP == 0 and m & (LEFT | RIGHT) ~= 0 and (not params.steer_here or params.steer_here[P.floor(o.y)]) and not (params.steer_calm and c.why ~= "walk") then
      local here = P.floor(o.y)
      for _, b in ipairs(o.b) do
        if b.c == 0 and (b.d == 2 or b.d == 4) then
          local up = P.floor(b.y) - here
          if up >= 1 and up <= params.steer_floors then
            local side = b.d == 2 and 1 or -1
            local drops = DROPS[P.floor(b.y)]
            for i = 1, drops and #drops or 0 do
              local ahead = (drops[i] - (b.x + side * age)) * side
              local towards = (m & LEFT ~= 0 and drops[i] < o.x) or (m & RIGHT ~= 0 and drops[i] > o.x)
              if towards and ahead >= -1 and ahead <= params.steer_off and not (params.steer_far and c.why ~= "walk" and math.abs(drops[i] - o.x) >= params.steer_far) then m = 0 end
            end
          end
        end
      end
    end
    -- climb_gate {ladder x, window, room, pose ok, pass broken, threat px} (Matt, 2026-11-10): he starts up ladder 91 only after Kong has
    -- let a barrel go (within `window` frames) or has it in front of him (pose 172, so it isn't a wild), and only with room to get
    -- up before a barrel reaches the top: none on the 5th girder within `room` px to the ladder's right (rolling at it or coming
    -- down Kong's short ladder); with `pass broken`, also not while a barrel on Kong's girder still hasn't passed that short ladder
    local cg = params.climb_gate
    if cg and m & UP ~= 0 and o.lad == 0 then
      local me = (params.know_self and o.now) or o
      if P.floor(me.y) == 4 and math.abs(me.x - cg[1]) <= 4 then
        local kong_ok = (c.last_throw and f - c.last_throw <= cg[2]) or (cg[4] and o.kong == 172)
        local room = true
        for _, b in ipairs(o.b) do
          local lv = level_of(b.y)
          if b.c == 0 and lv == 5 and b.d ~= 2 and b.x > cg[1] and b.x - cg[1] <= cg[3] then room = false end
          if b.c == 0 and cg[5] and lv == 6 and b.d == 2 and b.x < BROKEN + 2 then room = false end
        end
        -- cg[6]: only while his own girder is quiet: a barrel on the 4th girder rolling at him within that many px, or coming down
        -- a ladder onto it that close, and he climbs as before (waiting there is what got him killed)
        local threat = false
        if cg[6] then
          for _, b in ipairs(o.b) do
            local lv = level_of(b.y)
            if b.c == 0 and lv == 4 and b.d == 2 and me.x - b.x > -4 and me.x - b.x <= cg[6] then threat = true end
            if b.c == 0 and lv == 5 and b.d ~= 2 and b.d ~= 4 and math.abs(b.x - me.x) <= cg[6] then threat = true end
            if b.c ~= 0 and math.abs(b.x - me.x) <= cg[6] and b.y < me.y then threat = true end
          end
        end
        if not (kong_ok and room) and not threat then m = m & ~UP; c.plan = 0; c.why = c.why .. " waits to climb" end
      end
    end
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

  -- Which rules acted, for testing (Matt: if a rule from his answer lowers the numbers, see where it fired). Read from c.why,
  -- so it changes nothing about play. c.fired: "rule@frame:x" per firing, a rule counted again only after 30 frames.
  local RULES = {"holds his ground", "back jump", "steer from the ladder", "steer it down", "jumps the chaser early",
    "stops for the chaser", "more headroom", "steps away from the ladder", "air tap", "lets go", "face it, wait",
    "hammer: step away", "hammer: wait", "waits on the ladder", "replans in the air", "remembers", "waits to climb", "hammer: jump for it", "hammer: to the edge"}
  local inner = c.decide
  c.fired, c.fired_at = {}, {}
  function c.decide(o, f, age)
    local m = inner(o, f, age)
    local why = c.why or ""
    for _, r in ipairs(RULES) do
      if why:find(r, 1, true) and f - (c.fired_at[r] or -99) > 30 then
        c.fired[#c.fired + 1] = string.format("%s@%d:%d", r == "remembers" and why:match("remembers %S+") or r, f, o.x)
      end
      if why:find(r, 1, true) then c.fired_at[r] = f end
    end
    if c.replanned and c.replanned ~= c.replan_logged then
      c.replan_logged = c.replanned
      c.fired[#c.fired + 1] = string.format("replans in the air@%d:%d", c.replanned, o.x)
    end
    return m
  end
  return c
end

return P
