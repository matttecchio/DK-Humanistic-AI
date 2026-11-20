-- The 1-2 rivet board (Matt, 2026-11-15: "start learning how to complete the 1-2 rivets"; human-limited: he can't know what the
-- fireballs will do, only see where they've been; no fireball jumps unless it's life or death; the star pattern).
-- Layout from the board's tile map (video RAM, mirrored: game x = (31 - column) * 8 + 3) and the ROM's ladder check (Mario's x is
-- rounded to his 8 px column, so a ladder can be taken anywhere across it). Mario's y on each girder:
local R = {}
local FLOOR_Y = {240, 200, 160, 120, 80}
-- ladders up from each girder (x of their 8 px column: x .. x+7 counts, centre x+4)
local LADDERS = {{24, 120, 224}, {32, 88, 160, 216}, {40, 120, 208}, {48, 80, 168, 200}}
-- how far Mario can walk on each girder (measured: the bottom stops him at 234; the others from the tile map, kept 3 px in)
local ENDS = {{19, 234}, {27, 229}, {28, 221}, {43, 213}, {51, 205}}   -- (3rd girder: he walks to x 27, measured)
-- rivets: girder, x range (the 8 px column a rivet sits in), name
local RIVETS = {
  {2, 72, 79, "2L"}, {2, 176, 183, "2R"}, {3, 72, 79, "3L"}, {3, 176, 183, "3R"},
  {4, 72, 79, "4L"}, {4, 176, 183, "4R"}, {5, 72, 79, "5L"}, {5, 176, 183, "5R"},
}
-- Matt's star pattern (his later rivet boards, 15 of 21)
local STAR = {"2L", "4L", "5L", "LHAM", "3L", "3R", "2R", "HAM", "4R", "5R"}
-- which way each rivet is pulled (Matt's game, frame by frame): the left side is one sweep: 2L walking left, up the left ladders,
-- 4L walking right, up to the 5th girder, 5L walking left, down the left ladders to the bottom hammer, then right with it along
-- the 3rd girder through 3L (the gap opens behind him, so it's never in his way) to 3R
local CROSS = {["2L"] = -1, ["4L"] = 1, ["5L"] = -1, ["3L"] = 1, ["3R"] = 1}
-- (Matt) "LHAM": the bottom hammer (27, 140; a straight jump from the 3rd girder's left end, x 28-33) takes him from left to right
-- along the 3rd girder (3L, 3R), cleaning up fireballs if he's lucky
-- (Matt, 2026-11-15) "HAM": with the left side pulled, take the middle hammer (124, 100: a straight jump from the 4th girder at x
-- 118-130 takes it, measured) and work the right half with it: fireballs smashed there come back on the left, where they're
-- trapped behind the pulled rivets. Holding it he can't climb, so it covers the 4th girder (4R)
local HAM_X, HAM_LO, HAM_HI = 124, 119, 129
local HAMS = {HAM = {fl = 4, lo = 119, hi = 129, x = 124, avail = "ham_mid"}, LHAM = {fl = 3, lo = 28, hi = 33, x = 30, avail = "ham_left"}}
local LEFT, RIGHT, UP, DOWN, JUMP = 1, 2, 4, 8, 16
local WALK = 0.67

local function floor_of(y) local b, bd = 1, 999 for i, fy in ipairs(FLOOR_Y) do if math.abs(fy - y) < bd then b, bd = i, math.abs(fy - y) end end return b end
local function riv(name) local h = HAMS[name]; if h then return {h.fl, h.lo, h.hi, name} end for _, r in ipairs(RIVETS) do if r[4] == name then return r end end end

function R.new(params)
  local c = {gone = {}, fire = {}, why = "", plan = 0, jump_until = -1, ham_tried = {}}
  params = params or {}
  local SAFE = params.riv_safe or 14        -- px a fireball must stay away from him, beyond its growing allowance
  local SPREAD = params.riv_spread or 0.45  -- px a frame a fireball might come his way (they move about 1 px in 3; allowance for speeding up / turning)
  local LOOK = params.riv_look or 40        -- frames ahead he checks a move for
  local JUMP_AT = params.riv_jump or 10     -- px: a fireball this close on his girder, with nowhere to go, he jumps (life or death)

  -- fireballs as he saw them: position now (age frames old, so moved on by their seen speed) and how fast they were going
  local function fires_now(o, f, age)
    local out = {}
    for _, fb in ipairs(o.f) do
      local h = c.fire[fb.k]
      if not h or f - h.f > 20 or math.abs(fb.x - h.x) > 12 or math.abs(fb.y - h.y) > 12 then c.spawn_f = f end   -- (the spawn clock)
      if not h or f - h.f > 20 then h = {f = f, x = fb.x, y = fb.y, vx = 0, vy = 0}
      else
        local dt = math.max(1, f - h.f)
        h.vx = 0.8 * h.vx + 0.2 * (fb.x - h.x) / dt; h.vy = 0.8 * h.vy + 0.2 * (fb.y - h.y) / dt
        h.f, h.x, h.y = f, fb.x, fb.y
      end
      -- (Matt: know which way every fireball is going) its drift over the last 20 frames, as he saw it: measured, a fireball
      -- that drifted 3+ px one way keeps going that way over the next 40 frames 77-80% of the time
      h.trail = h.trail or {}
      h.trail[#h.trail + 1] = {f = f, x = fb.x, y = fb.y}
      while #h.trail > 1 and f - h.trail[1].f > 20 do table.remove(h.trail, 1) end
      local drift = (#h.trail > 1 and math.abs(h.trail[1].y - fb.y) <= 1 and f - h.trail[1].f >= 14) and (fb.x - h.trail[1].x) or 0
      c.fire[fb.k] = h
      -- riv_freeze (Matt, 2026-11-19: "it's a possibility that the 2nd and 4th will freeze occasionally ... it freezes for two
      -- different lengths of time ... it's okay for him to know that"; measured in 3,000 games: every fireball pauses on a girder
      -- for 60-80 frames; the 2nd and 4th (slots 1 and 3) also freeze for 320-360 frames, almost always at the top of a ladder
      -- going down, only from difficulty 3 on): a 2nd or 4th fireball standing at a ladder top longer than a normal pause is
      -- frozen, with about 336 frames from the start of the stop
      local frozen
      local onfl = false
      for i = 1, 5 do if math.abs(fb.y - FLOOR_Y[i]) <= 3 then onfl = i end end
      if onfl and h.sx == fb.x then h.sf = h.sf or f else h.sx, h.sf = fb.x, f end
      if params.riv_freeze and (fb.k == 1 or fb.k == 3) and onfl and onfl > 1 and h.sf then
        local still = f - h.sf
        local top = false
        for _, lx in ipairs(LADDERS[onfl - 1]) do if fb.x >= lx and fb.x <= lx + 7 then top = true end end
        if top and still >= params.riv_freeze and still < 336 then frozen = 336 - still end
      end
      -- riv_freeze_short (Matt: "knowing about the freeze could help with mario being able to avoid things"; the 2nd and 4th's
      -- own stops come in whole steps of ~56 frames): stopped on a girder this many frames with no hammer out (not a smash
      -- freeze): frozen at least until its next 56-frame mark
      if params.riv_freeze_short and not frozen and (fb.k == 1 or fb.k == 3) and onfl and h.sf and o.ham == 0 then
        local still = f - h.sf
        if still >= params.riv_freeze_short then frozen = 56 - (still % 56) end
      end
      out[#out + 1] = {x = fb.x + h.vx * age, y = fb.y + h.vy * age, vx = h.vx, vy = h.vy, drift = drift, frozen = frozen}
    end
    return out
  end

  -- can he be at (x on girder fl) at frame t from now, as far as fireballs he can see might reach?
  local function clear_at(fires, fl, x, t, onlad)
    local my = FLOOR_Y[fl]
    for _, fb in ipairs(fires) do
      local reach = SAFE + SPREAD * t
      local fx = fb.x + fb.vx * t
      local fy = fb.y + fb.vy * t
      local dy = math.abs(fy - my)
      -- on his girder: along it; on a ladder near him: up or down it as well
      if dy < 12 + SPREAD * t * 0.6 and math.abs(fx - x) < reach then return false end
      if onlad and math.abs(fb.x - x) < 10 and dy < 40 then return false end
    end
    return true
  end

  -- a removed rivet leaves a gap he can't walk across
  local function gap_between(fl, x0, x1)
    for _, r in ipairs(RIVETS) do
      if r[1] == fl and c.gone[r[4]] then
        local cx = (r[2] + r[3]) / 2
        -- crossing the gap's middle, or ending up in it
        if (x0 < cx) ~= (x1 < cx) or math.abs(x1 - cx) < 3 then return r end
      end
    end
  end

  -- girders 2-5 are split by their two rivets (present ones he mustn't walk over unless they're his target; gone ones he can't):
  -- section 0 left of x 76, 1 between, 2 right of x 180; the bottom girder is one piece
  -- (Matt: "you can't cross over kong at the top"; ft1/ft2's 30 "to the last rivet" deaths at x 103 on the top girder walked
  -- into him) Kong stands on the top girder's middle (feet x 115-139; touching him kills from x ~103 / ~151): it splits that
  -- girder's middle section in two, the left half reached by the ladder at 80, the right by the one at 168
  local KONG_L, KONG_R = 102, 152
  local function sec(fl, x)
    if fl == 1 then return 0 end
    if fl == 5 and x >= 76 and x < 180 then return x < 127 and 1 or 3 end
    return x < 76 and 0 or (x < 180 and 1 or 2)
  end
  -- the way to (girder tf, x tx), the target rivet's far side: the cheapest chain of ladders between sections (Dijkstra on walking
  -- distance), as steps {kind = "walk" / "up" / "down", fl, x}
  -- riv_stay_right (Matt: "part of the trick should be to prevent as much as possible from spawning on the right after having
  -- taken out the left side rivets"; measured in 400 games: a new fireball appears on the side opposite Mario, the line exactly at
  -- x 128; after the left sweep 43 still spawned on the right, nearly all with him on the middle ladder at 120 (3rd to 4th
  -- girder) going for the middle hammer): after the sweep, ladders left of the middle cost this much more in his routes, and he
  -- goes for the middle hammer from its right edge (x 128-129, still right of the line)
  local function stay_right()
    -- (Matt: "not a hard and fast rule ... sometimes you gotta take the hammer left up the top to kill something"): a cost, not a
    -- ban, and none with the board full (5 out: nothing can spawn)
    return params.riv_stay_right and c.gone["2L"] and c.gone["4L"] and c.gone["5L"] and c.gone["3L"] and c.gone["3R"] and (c.n_fires or 0) < 5
  end
  local function route(fl, x, tf, tx, target, holding)
    local function key(f, s) return f * 10 + s end
    local dist, prev, node = {}, {}, {}
    local start = key(fl, sec(fl, x))
    dist[start] = 0; node[start] = {fl = fl, x = x}
    local done = {}
    local goal
    for _ = 1, 40 do
      local u, ud
      for k, d in pairs(dist) do if not done[k] and (not ud or d < ud) then u, ud = k, d end end
      if not u then break end
      done[u] = true
      local uf, us, ux = u // 10, u % 10, node[u].x
      -- the target: on its girder, in a section beside it (he then walks across it)
      local cr = params.riv_cross ~= false and CROSS[target[4]]
      local from_left, from_right = sec(tf, target[2] - 1), sec(tf, target[3] + 1)
      if target[4] == "SAFE" then
        if uf == tf and us == sec(tf, target[2]) then goal = u; break end
      elseif uf == tf and ((cr == 1 and us == from_left) or (cr == -1 and us == from_right) or (not cr and (us == from_left or us == from_right))) then goal = u; break end
      -- (Matt: you can jump over removed rivets) a pulled rivet's gap joins the sections either side, by a jump from 6 px short
      if params.riv_gap_jump ~= false and not holding then
        for _, r in ipairs(RIVETS) do
          if r[1] == uf and c.gone[r[4]] then
            local cx = (r[2] + r[3]) / 2
            local d = (sec(uf, r[2] - 1) == us) and 1 or ((sec(uf, r[3] + 1) == us) and -1 or 0)
            if d ~= 0 then
              local launch = d == 1 and r[2] - 6 or r[3] + 6
              local landx = launch + d * 21
              local v = key(uf, sec(uf, landx))
              -- (riv_free_mid) with the free pass on, hopping over a gap costs nothing: up the right side, not the middle ladders
              local gcost = (params.riv_free_mid and c.free_right) and 0 or (params.riv_gapjump_cost or 120)
              -- riv_gap_dyn (Matt, 2026-11-20: "why is hopping a gap with nothing on the other side of it costly?"): the fixed cost
              -- stands for the risk of a 46-frame jump; with no fireball within 64 px of the landing on that girder, or on a ladder
              -- near it, the hop costs only this much
              if params.riv_gap_dyn and c.fires_seen then
                local clear = true
                for _, fb in ipairs(c.fires_seen) do
                  local onlad = true
                  for i = 1, 5 do if math.abs(fb.y - FLOOR_Y[i]) <= 3 then onlad = false end end
                  if math.abs(fb.y - FLOOR_Y[uf]) <= 4 and math.abs(fb.x - landx) < 64 then clear = false end
                  if onlad and math.abs(fb.x - landx) < 40 and math.abs(fb.y - FLOOR_Y[uf]) < 44 then clear = false end
                end
                if clear then gcost = params.riv_gap_dyn end
              end
              local nd = ud + math.abs(launch - ux) + gcost
              if not dist[v] or nd < dist[v] then dist[v] = nd; prev[v] = {u = u, x = launch, kind = "jump", d = d}; node[v] = {fl = uf, x = landx} end
            end
          end
        end
      end
      for lf = math.max(1, uf - 1), math.min(4, uf) do
        local other = (lf == uf) and uf + 1 or uf - 1
        for _, lx in ipairs(LADDERS[lf]) do
          local lc = lx + 4
          if sec(uf, lc) == us then
            local v = key(other, sec(other, lc))
            local nd = ud + math.abs(lc - ux) + 40 + ((lc < 128 and stay_right()) and params.riv_stay_right or 0)
            if not dist[v] or nd < dist[v] then dist[v] = nd; prev[v] = {u = u, x = lc, kind = other > uf and "up" or "down"}; node[v] = {fl = other, x = lc} end
          end
        end
      end
    end
    if not goal then return nil end
    local passes = {}
    do local v = goal; while v do passes[#passes + 1] = v; v = prev[v] and prev[v].u end end
    local chain = {}
    local v = goal
    while prev[v] do table.insert(chain, 1, prev[v]); v = prev[v].u end
    local steps = {}
    for _, e in ipairs(chain) do
      steps[#steps + 1] = {kind = "walk", fl = e.u // 10, x = e.x}
      if e.kind == "jump" then steps[#steps + 1] = {kind = "jump", fl = e.u // 10, x = e.x, d = e.d}
      else steps[#steps + 1] = {kind = e.kind, fl = e.kind == "up" and e.u // 10 + 1 or e.u // 10 - 1, x = e.x} end
    end
    if HAMS[target[4]] then steps[#steps + 1] = {kind = "walk", fl = tf, x = (target[4] == "HAM" and stay_right()) and 129 or HAMS[target[4]].x}; return steps, dist[goal], passes end
    if target[4] == "SAFE" then steps[#steps + 1] = {kind = "walk", fl = tf, x = target[2]}; return steps, dist[goal], passes end
    -- across the target rivet to its far side from where he arrives (once he's on its girder, the way he set off across it)
    local ax = (#chain > 0) and node[goal].x or x
    local key2 = target[4]
    -- (fs1's 59 timeouts: he set off for 2R from the right, left the girder, came back at it from the left, and the old memory
    -- put the "far side" on his near side: he stood there "arrived" until the timer ran out) forget it off the girder, and
    -- whenever it would put the far side on the side he's on
    if c.cross and (c.cross.fl ~= tf or (lad or 0) ~= 0 or (#chain > 0)) then c.cross = nil end
    if c.cross and c.cross.name == key2 then
      local cx = (target[2] + target[3]) / 2
      local far0 = (c.cross.from < target[2]) and target[3] + 3 or target[2] - 3
      if math.abs(x - far0) <= 2 or (x < cx) == (far0 < cx) and math.abs(x - cx) > 6 then c.cross = nil end
    end
    if #chain == 0 and c.cross and c.cross.name == key2 then ax = c.cross.from
    elseif #chain == 0 then c.cross = {fl = tf, name = key2, from = x < (target[2] + target[3]) / 2 and target[2] - 1 or target[3] + 1}; ax = c.cross.from end
    local cr = params.riv_cross ~= false and CROSS[key2]
    if cr then ax = (cr == 1) and target[2] - 1 or target[3] + 1 end
    local far = (ax < target[2]) and target[3] + 3 or target[2] - 3
    -- the last rivet: the board ends the moment it comes out (measured: at the rivet's middle, x 76 walking right over 72-79,
    -- 74 walking left), so he only needs to get there, whatever is beyond it
    local last = c.left_seen == 1 and not HAMS[target[4]]
    if last and params.riv_last ~= false then far = (ax < target[2]) and target[2] + 5 or target[2] + 1 end
    steps[#steps + 1] = {kind = "walk", fl = tf, x = far, last = last}
    return steps, dist[goal], passes
  end

  -- ---- the whole-board safety map (Matt, 2026-11-15: "think about the whole board and what paths are opened up") ----
  -- how soon a fireball could be at (girder tf, x tx), over the maze: it walks only within its own stretch (pulled rivets' gaps
  -- stop it), climbs up ladders slowly, and comes down a ladder only towards a spot below it (fireballs go down only when Mario
  -- is below them); speeds as measured (x 1.12, the planner's)
  local function fsec(fl, x) local k = 0; for _, r in ipairs(RIVETS) do if r[1] == fl and c.gone[r[4]] and x > (r[2] + r[3]) / 2 then k = k + 1 end end; return k end
  local function fb_time(fb, tf, tx, VR, VL, VD, VU)
    local ff = floor_of(fb.y)
    local best = math.huge
    local seen = {}
    local queue
    if math.abs(fb.y - FLOOR_Y[ff]) <= 3 then queue = {{fl = ff, x = fb.x, t = 0}}
    else
      -- mid-ladder (the first version snapped it to the nearest girder): on up, slowly, or down if the spot is below
      local above = 1
      for i = 1, 5 do if FLOOR_Y[i] < fb.y then above = i; break end end
      queue = {{fl = above, x = fb.x, t = (fb.y - FLOOR_Y[above]) / VU}}
      if above > 1 then queue[2] = {fl = above - 1, x = fb.x, t = (FLOOR_Y[above - 1] - fb.y) / VD} end
    end
    while #queue > 0 do
      table.sort(queue, function(a, b) return a.t < b.t end)
      local q = table.remove(queue, 1)
      local key = q.fl * 10 + fsec(q.fl, q.x)
      if not seen[key] and q.t < best then
        seen[key] = true
        if q.fl == tf and fsec(tf, tx) == fsec(q.fl, q.x) then
          local d = tx - q.x
          best = math.min(best, q.t + math.abs(d) / (d > 0 and VR or VL))
        end
        for lf = math.max(1, q.fl - 1), math.min(4, q.fl) do
          local up = lf == q.fl
          if up or tf < q.fl then
            for _, lx in ipairs(LADDERS[lf]) do
              local lc = lx + 4
              if fsec(q.fl, lc) == fsec(q.fl, q.x) then
                local d = lc - q.x
                local t = q.t + math.abs(d) / (d > 0 and VR or VL) + 40 / (up and VU or VD)
                queue[#queue + 1] = {fl = up and q.fl + 1 or q.fl - 1, x = lc, t = t}
              end
            end
          end
        end
      end
    end
    return best
  end
  -- how long his route takes, in frames
  local function steps_time(steps, x)
    local t, px = 0, x
    for _, st in ipairs(steps) do
      if st.kind == "walk" then t = t + math.abs(st.x - px) / WALK; px = st.x
      elseif st.kind == "jump" then t = t + 46; px = st.x + st.d * 21
      else t = t + 40 / 0.4 end
    end
    return t
  end

  local decide_inner
  -- riv_jump_hold (2026-11-15): every jump was pressed for one frame, and the game often missed it: of mr5's 198 deaths "in the
  -- air", 129 were standing on the girder, frozen for the jump's length; the barrel player holds jump 3 frames. Held 3 frames
  -- now, and if he's still on the girder 6 frames after the press, he knows it didn't happen and decides again
  -- (RSEARCH, the all-knowing rivet teacher) progress at a spot the search reached: minus his route's cost from there to his
  -- current target (rivets pulled are scored by the search itself)
  function c.progress(px, py, plad, left)
    local tg = c.cur_target
    if os.getenv("RSDBG2") then io.stderr:write(string.format("PROG %d,%d target %s\n", px, py, tg and tg[4] or "none")) end
    if not tg then return 0 end
    local save_cross = c.cross
    -- on a ladder (between girders): the better of going on up or back down, counting the climb left
    local best
    local on = nil
    for i = 1, 5 do if math.abs(py - FLOOR_Y[i]) <= 3 then on = i end end
    for i = 1, 5 do
      if (on and i == on) or (not on and math.abs(py - FLOOR_Y[i]) < 40) then
        local st = route(i, px, tg[1], (tg[2] + tg[3]) // 2, tg, false)
        if st then
          -- the whole way, step by step (the route's own cost leaves out the last walk, across the rivet)
          local len, cx = 0, px
          for _, sp in ipairs(st) do
            if sp.kind == "walk" then len = len + math.abs(sp.x - cx); cx = sp.x
            elseif sp.kind == "jump" then len = len + 60; cx = sp.x + sp.d * 21
            else len = len + 40 end
          end
          local v = len + math.abs(py - FLOOR_Y[i])
          if not best or v < best then best = v end
        end
      end
    end
    c.cross = save_cross
    if not best then return -5000 end
    return -best
  end
  function c.decide(o, f, age)
    if params.riv_jump_hold then
      if c.press_until and f < c.press_until then return c.press end
      local w = decide_inner(o, f, age)
      if w & JUMP ~= 0 then c.press, c.press_until, c.press_f = w, f + 3, f end
      return w
    end
    return decide_inner(o, f, age)
  end
  function decide_inner(o, f, age)
    local me = o.now or o
    local x, y, lad, jmp = me.x, me.y, me.lad, me.jmp
    -- which rivets are gone: 0x6290 counts them down; the one he was walking over when it dropped is the one gone
    if o.rivets_left and c.left_seen and o.rivets_left < c.left_seen then
      local fl = floor_of(y)
      for _, r in ipairs(RIVETS) do if r[1] == fl and x >= r[2] - 6 and x <= r[3] + 6 then c.gone[r[4]] = true; c.pulled = (c.pulled or "") .. string.format("%s@%d ", r[4], f) end end
    end
    c.left_seen = o.rivets_left
    local fires = fires_now(o, f, age)
    c.fires_seen = fires   -- (riv_gap_dyn: the route search looks at them)
    -- a route (list of targets) played out in the imagined futures from where he is: the share of futures touched (nil: no route)
    local function route_p(goals, TT, seed)
      if not (dkh_native and dkh_native.rivsim) then return nil end
      local pts, t, px, py, pf = {}, 0, x, y, floor_of(y)
      local save_cross = c.cross
      local function emit() if t % 4 == 0 then pts[#pts + 1] = t; pts[#pts + 1] = px; pts[#pts + 1] = py end end
      for _, gl in ipairs(goals) do
        local st = route(pf, px, gl[1], (gl[2] + gl[3]) // 2, gl, o.ham ~= 0)
        if not st then c.cross = save_cross; return nil end
        for _, sp in ipairs(st) do
          if sp.kind == "walk" then
            while math.abs(px - sp.x) > WALK and t < TT do px = px + (sp.x > px and WALK or -WALK); t = t + 1; emit() end
            px = sp.x
          elseif sp.kind == "jump" then
            for i = 1, 46 do if t >= TT then break end; if i <= 42 then px = px + sp.d * 0.5 end; t = t + 1; emit() end
          else
            local ty = FLOOR_Y[sp.fl]; px = sp.x
            while math.abs(py - ty) > 0.4 and t < TT do py = py + (ty > py and 0.4 or -0.4); t = t + 1; emit() end
            py, pf = ty, sp.fl
          end
          if t >= TT then break end
        end
        if t >= TT then break end
        pf = gl[1]
      end
      c.cross = save_cross
      while t < TT do t = t + 1; emit() end
      local d2 = math.min(5, 1 + (f - (c.f0 or f)) // 2040)
      local DV2 = ({{0.43, 0.36, 0.53 * 0.5}, {0.53, 0.46, 0.53}, {0.58, 0.48, 0.53 * 1.6}, {0.62, 0.52, 0.53 * 1.8}, {0.66, 0.55, 0.53 * 2}})[d2]
      local mf = {}
      for _, fb in ipairs(fires) do mf[#mf + 1] = {fb.x, fb.y, fb.vx or 0, fb.vy or 0, fb.frozen or 0} end
      local mg = 0
      for i, nm in ipairs({"2L", "2R", "3L", "3R", "4L", "4R", "5L", "5R"}) do if c.gone[nm] then mg = mg | (1 << (i - 1)) end end
      return dkh_native.rivsim(mf, mg, pts, {n = params.riv_mc_n or 48, T = TT, seed = seed, vr = DV2[1], vl = DV2[2], vd = DV2[3], vu = 0.20,
        rx = params.riv_sim_rx, ry = params.riv_sim_ry, turn = params.riv_sim_turn})
    end
    c.n_fires = #o.f
    if params.riv_jump_hold and jmp == 0 and f < c.jump_until and c.press_f and f > c.press_f + 6 and lad == 0 and FLOOR_Y[floor_of(y)] == y then
      c.jump_until = 0; c.pull = nil
    end
    if jmp ~= 0 or f < c.jump_until then
      c.why = "in the air after " .. (c.jump_kind or "a jump")
      if c.kw_air and f < c.kw_air - 6 and jmp ~= 0 then return LEFT end   -- (by Kong: held sideways in the air)
      return 0
    end
    -- the next rivet in the star pattern still there
    local target
    for _, n in ipairs(STAR) do
      local h = HAMS[n]
      local skip = h and (params.riv_no_ham or o.ham ~= 0 or o[h.avail] == 0 or c.ham_tried[n])
      -- riv_2r_later (traces: after 3R he went down to 2R into fireballs penned in its section and was chased up the right side
      -- for ~1,000 frames; the WR player took 4R before 2R on 3 of 21 boards): with a fireball in 2R's section (the right of the
      -- 2nd girder) or on the ladder down to it, the rest of the right side first, 2R after
      if n == "2R" and params.riv_2r_later and not c.gone["2R"] then
        local busy = false
        for _, fb in ipairs(o.f) do if (math.abs(fb.y - 200) < 12 and fb.x >= 184) or (fb.x >= 214 and fb.y > 160 and fb.y < 200) then busy = true end end
        local others = false
        for _, m in ipairs({"4R", "5R"}) do if not c.gone[m] then others = true end end
        if busy and others then skip = true end
      end
      -- (Matt) the middle hammer cleans up more fireballs, but it can cost a lot of time: with a clear, safe way to finish (no
      -- fireball in the upper right, where 4R and 5R are), he takes those instead (decided once, when he gets to it)
      -- riv_free_right (Matt's review 3, 2026-11-15: "he seems to have a free pass to go up the right hand side and take out the two
      -- rivets, but instead he keeps moving back towards the middle ... if he's got a free pass up the right, he should take it"):
      -- every moment the middle hammer is next, check the whole way to 4R and on to 5R by the safety map; if no fireball could
      -- be at any point of it before him (with this many frames to spare), commit to the rivets
      if n == "HAM" and not skip and params.riv_free_right and not c.free_right and not c.gone["4R"] and not c.gone["5R"] then
        local VR0, VL0, VD0, VU0 = params.riv_vr or 0.7, params.riv_vl or 0.56, params.riv_vd or 0.7, params.riv_vu or 0.35
        local save_cross = c.cross
        local free = true
        local fl0, x0, t0 = floor_of(y), x, 0
        for _, nm in ipairs({"4R", "5R"}) do
          local tr = riv(nm)
          local st = route(fl0, x0, tr[1], (tr[2] + tr[3]) // 2, tr, false)
          if not st then free = false; break end
          local px = x0
          for _, stp in ipairs(st) do
            t0 = t0 + steps_time({stp}, px)
            px = stp.x or px
            local sf = stp.fl or fl0
            if FLOOR_Y[sf] then
              for _, fb in ipairs(o.f) do
                if fb_time(fb, sf, px, VR0, VL0, VD0, VU0) < t0 + params.riv_free_right then free = false end
              end
            end
          end
          fl0, x0 = tr[1], px
          if not free then break end
        end
        c.cross = save_cross
        if free then c.free_right = true end
      end
      -- riv_free_zone (Matt: "if there are fireballs in the middle sections and the right is free, he should try the right
      -- side"; the map version above never fired: over an ~8 s route any fireball connected through the maze could get
      -- somewhere on it): where the fireballs are now: none on the right sections of girders 2-5, none on the right-hand
      -- ladders, none in the middle of girder 4 / 5 within this many px of 4R / 5R while it's still in (they'd walk through)
      -- (xa1: it fired in 808 of 3,000 games, saved 55 / lost 157: most losses were on the left of girder 4, his way to 4R going up
      -- the middle, not the right) riv_free_where: only with him on the right (right of the 2R / 3R gaps, girder 2 or 3), and
      -- kept checking until 4R is out: a fireball coming into the right side puts the middle hammer back in his plan
      local fw = params.riv_free_where
      local onright = lad == 0 and x >= 184 and (floor_of(y) == 2 or floor_of(y) == 3)
      -- riv_free_mid (Matt: "I also see him tend to get stuck in the middle part when he could go up the right side"; his #8):
      -- in the middle of girder 2 or 3 with that girder's right rivet out, one hop over its gap puts him on the right: counts too
      if params.riv_free_mid and lad == 0 and x >= 76 and x < 180 and ((floor_of(y) == 2 and c.gone["2R"]) or (floor_of(y) == 3 and c.gone["3R"])) then onright = true end
      if n == "HAM" and fw and c.free_right and not c.gone["4R"] then c.free_right = nil; c.free_recheck = true end
      -- riv_choice_mc (Matt: "go ahead", the imagined futures for the big choices): while the middle hammer is next, his actual
      -- route to it and his actual route up to 4R (then 5R), each played out in the imagined futures over riv_choice_t frames; the
      -- rivets if he survives them more often by this margin (share of futures)
      if n == "HAM" and not skip and params.riv_choice_mc and not c.free_right and not c.gone["4R"] and not c.gone["5R"] and lad == 0
         and dkh_native and dkh_native.rivsim and o.ham == 0 then
        local TT = params.riv_choice_t or 240
        local save_cross = c.cross
        local function plan_pts(targets)
          local pts, t, px, py, pf = {}, 0, x, y, floor_of(y)
          local function emit() if t % 4 == 0 and t <= TT then pts[#pts + 1] = t; pts[#pts + 1] = px; pts[#pts + 1] = py end end
          for _, nm in ipairs(targets) do
            local tr = type(nm) == "table" and nm or riv(nm)
            local st = route(pf, px, tr[1], (tr[2] + tr[3]) // 2, tr, false)
            if not st then return nil end
            for _, sp in ipairs(st) do
              if sp.kind == "walk" then
                while math.abs(px - sp.x) > WALK and t < TT do px = px + (sp.x > px and WALK or -WALK); t = t + 1; emit() end
                px = sp.x
              elseif sp.kind == "jump" then
                for _ = 1, 46 do if t >= TT then break end; px = px + sp.d * 0.5 * ((_ <= 42) and 1 or 0); t = t + 1; emit() end
              else
                local ty = FLOOR_Y[sp.fl]
                px = sp.x
                while math.abs(py - ty) > 0.4 and t < TT do py = py + (ty > py and 0.4 or -0.4); t = t + 1; emit() end
                py, pf = ty, sp.fl
              end
              if t >= TT then return pts end
            end
            pf = tr[1]
          end
          while t < TT do t = t + 1; emit() end
          return pts
        end
        local d2 = math.min(5, 1 + (f - (c.f0 or f)) // 2040)
        local DV2 = ({{0.43, 0.36, 0.53 * 0.5}, {0.53, 0.46, 0.53}, {0.58, 0.48, 0.53 * 1.6}, {0.62, 0.52, 0.53 * 1.8}, {0.66, 0.55, 0.53 * 2}})[d2]
        local mf = {}
        for _, fb in ipairs(fires) do mf[#mf + 1] = {fb.x, fb.y, fb.vx or 0, fb.vy or 0, fb.frozen or 0} end
        local mg = 0
        for i, nm in ipairs({"2L", "2R", "3L", "3R", "4L", "4R", "5L", "5R"}) do if c.gone[nm] then mg = mg | (1 << (i - 1)) end end
        local a, b = plan_pts({"HAM"}), plan_pts({"4R", "5R"})
        c.cross = save_cross
        if a and b then
          local opt = {n = params.riv_mc_n or 48, T = TT, seed = f * 41 + 3, vr = DV2[1], vl = DV2[2], vd = DV2[3], vu = 0.20, rx = params.riv_sim_rx, ry = params.riv_sim_ry, turn = params.riv_sim_turn, bias = params.riv_bias and 1 or 0}
          local pa, pb = dkh_native.rivsim(mf, mg, a, opt), dkh_native.rivsim(mf, mg, b, opt)
          c.choice = string.format("hammer %.2f / rivets %.2f", pa, pb)
          -- riv_choice_via (2026-11-19): two more ways to the rivets, through girder 3's middle or up its right stretch; the
          -- safest of all four (a way through: a waypoint he goes to first)
          local bestp, via = pb, nil
          if params.riv_choice_via then
            -- (cv1: 8,419 vs 8,626; the right-stretch way sent him into girder 3's cut-off right end: "mid" = the middle only)
            local wps = params.riv_choice_via == "mid" and {{3, 128, 128, "SAFE"}} or {{3, 128, 128, "SAFE"}, {3, 200, 200, "SAFE"}}
            -- riv_choice_hop (Matt, 2026-11-20: "mario sat in the middle area on the 2nd girder and refused to take a free right hand
            -- side path"): in girder 2's middle with 2R out, also "hop right over 2R's gap onto girder 2's right, then up the right"
            if params.riv_choice_hop and floor_of(y) == 2 and x >= 76 and x < 180 and c.gone["2R"] then wps[#wps + 1] = {2, 205, 205, "SAFE"} end
            for _, wp in ipairs(wps) do
              if not (floor_of(y) == 3 and math.abs(x - wp[2]) < 30) then
                local cpts = plan_pts({wp, "4R", "5R"})
                c.cross = save_cross
                if cpts then
                  local pc = dkh_native.rivsim(mf, mg, cpts, opt)
                  if pc < bestp - 0.02 then bestp, via = pc, wp end
                end
              end
            end
          end
          if bestp < pa - params.riv_choice_mc then
            c.free_right = true; skip = true
            if via then c.via = {fl = via[1], x = via[2], till = f + 600} end
          end
        end
      end
      if n == "HAM" and not skip and params.riv_free_zone and not c.free_right and not c.gone["4R"] and not c.gone["5R"]
         and (not fw or onright or c.free_recheck) then
        local free = true
        for _, fb in ipairs(o.f) do
          local on = nil
          for k = 2, 5 do if math.abs(fb.y - FLOOR_Y[k]) <= 4 then on = k end end
          if on and fb.x >= 184 then free = false end
          if not on and fb.y < FLOOR_Y[2] + 4 and fb.x >= 196 then free = false end
          if (on == 4 or on == 5) and fb.x >= 176 - params.riv_free_zone and fb.x < 184 then free = false end
        end
        if free then c.free_right = true end
      end
      c.free_recheck = nil
      if n == "HAM" and c.free_right and not c.force_ham then skip = true end
      if n == "HAM" and c.force_ham and not (params.riv_no_ham or o.ham ~= 0 or o[h.avail] == 0 or c.ham_tried[n]) then skip = false end
      if n == "HAM" and not skip and params.riv_skip_ham then
        if c.ham_skip == nil then
          c.ham_skip = true
          for _, fb in ipairs(o.f) do if fb.y <= 170 and fb.x >= params.riv_skip_ham then c.ham_skip = false end end
        end
        skip = c.ham_skip and not c.force_ham
      end
      if not c.gone[n] and not skip then target = riv(n); break end
    end
    if o.ham ~= 0 and c.grabbing then
      if not c.ham_tried[c.grabbing] then c.ham_at = (c.ham_at or "") .. string.format("%s@%d ", c.grabbing, f) end
      c.ham_tried[c.grabbing] = true
    end
    if not target then c.why = "done"; return 0 end
    c.cur_target = target   -- (RSEARCH; set again below once any detour is chosen)
    -- riv_order_mc (Matt: option 4, the rivet order chosen by the maze): after the left sweep, with two or more of 2R / 4R / 5R left
    -- and a rivet next, each remaining rivet as the next target is played out in the imagined futures (they know the maze: no
    -- fireball crosses a pulled gap) over riv_order_t frames; another if it's safer by the margin; kept until it's out
    if params.riv_order_mc and c.gone["2L"] and c.gone["4L"] and c.gone["5L"] and c.gone["3L"] and c.gone["3R"] and lad == 0 then
      if c.order_pick and c.gone[c.order_pick] then c.order_pick = nil end
      if not c.order_pick and not HAMS[target[4]] and not c.order_tried then
        local left = {}
        for _, nm in ipairs({"2R", "4R", "5R"}) do if not c.gone[nm] then left[#left + 1] = nm end end
        if #left >= 2 then
          c.order_tried = true
          local TT = params.riv_order_t or 300
          local p0 = route_p({target}, TT, f * 61 + 1)
          local best, bp = nil, p0
          for _, nm in ipairs(left) do
            if nm ~= target[4] then
              local p = route_p({riv(nm)}, TT, f * 61 + 1)
              if p and bp and p < bp then best, bp = nm, p end
            end
          end
          if best and p0 and bp < p0 - params.riv_order_mc then c.order_pick = best end
        end
      end
      if c.order_pick and not c.gone[c.order_pick] then target = riv(c.order_pick) end
    end
    if c.order_tried and c.last_left ~= o.rivets_left then c.order_tried = nil end
    c.last_left = o.rivets_left
    -- (Matt's review, 2026-11-15) once the left sweep is done (through 3R), the right side isn't a fixed order: the rivet (or the
    -- middle hammer) with the cheapest way there, counting each fireball in a section the way passes through as a big cost
    local sweep_done = c.gone["2L"] and c.gone["4L"] and c.gone["5L"] and c.gone["3L"] and c.gone["3R"]
    -- chosen once and kept until it's done or out of reach (re-choosing every frame made him dither as fireballs moved: rv14)
    local keep = params.riv_dynamic and c.dyn and not c.gone[c.dyn] and not (HAMS[c.dyn] and (o.ham ~= 0 or c.ham_tried[c.dyn])) and riv(c.dyn)
    if keep then
      local st = route(floor_of(y), x, keep[1], (keep[2] + keep[3]) // 2, keep, o.ham ~= 0)
      if st then target = keep else c.dyn = nil end
    end
    if params.riv_dynamic and sweep_done and lad == 0 and not (keep and c.dyn) then   -- (off by default: rv15-17 lost ~80 of 1,000)
      local fl0 = floor_of(y)
      local best, bc
      for _, n in ipairs({"2R", "4R", "5R", "HAM"}) do
        local h = HAMS[n]
        local ok = not c.gone[n]
        if h then ok = ok and o.ham == 0 and o[h.avail] == 1 and not c.ham_tried[n] end
        if n == "HAM" and ok then   -- the hammer only with fireballs up there to clean up (Matt: it can cost a lot of time)
          local any = false
          for _, fb in ipairs(o.f) do if fb.y <= 170 and fb.x >= (params.riv_skip_ham or 100) then any = true end end
          ok = any
        end
        if ok and not (o.ham ~= 0 and n ~= "4R" and floor_of(y) == 4 and false) then
          local tr = riv(n)
          local st, cost, passes = route(fl0, x, tr[1], (tr[2] + tr[3]) // 2, tr, o.ham ~= 0)
          if st then
            for _, fb in ipairs(o.f) do
              local ff = floor_of(fb.y)
              if math.abs(fb.y - FLOOR_Y[ff]) < 10 then
                for _, k in ipairs(passes) do if k == ff * 10 + sec(ff, fb.x) then cost = cost + (params.riv_fire_cost or 150) end end
              end
            end
            if n == "HAM" then cost = cost + (params.riv_ham_cost or 60) end
            if not bc or cost < bc then best, bc = tr, cost end
          end
        end
      end
      if best then target = best; c.dyn = best[4] end
    end
    local fl = floor_of(y)
    -- escaping to a safe spot (the safety map): until he's there, or it's been 3 s
    if c.escape and (f > c.escape.till or (lad == 0 and fl == c.escape.fl and math.abs(x - c.escape.x) <= 2)) then c.escape = nil end
    if c.escape then target = {c.escape.fl, c.escape.x, c.escape.x, "SAFE"} end
    -- riv_kong_wait (Matt, 2026-11-18: "When he finishes taking out the bottom left rivet and the 2nd one from the top on the
    -- left, maybe he could stand next to kong, and do vertical jumps ... until a fireball either starts to come up on the left
    -- hand side, or the fireballs are all in a better position on the right to grab the hammer and he can run over and smash
    -- them"): after 2L and 4L (5L still in), wait on the top girder just short of Kong (x riv_kong_x) at most riv_kong_wait
    -- frames; he leaves when a fireball on the left half is climbing a ladder, or none is left on the left half
    -- riv_farm (the second world-class video, 2026-11-18: every board, he takes the middle hammer, leaves 4R in and stands on
    -- girder 4 just left of it facing right, smashing what comes up the right-hand ladders and through the 4R spot; each one
    -- respawns on the left, trapped by the pulled left rivets; only as the hammer runs out does he pull 4R and go up to 5R;
    -- Matt's tip from the start: "use the hammer in the middle to hit things while on the right half of the board"): holding
    -- the middle hammer with 4R in, stand at x riv_farm_x on girder 4 until it has riv_farm frames left
    if params.riv_farm and o.ham ~= 0 and c.ham_tried["HAM"] and not c.gone["4R"] and (o.hleft or 0) > params.riv_farm then
      target = {4, params.riv_farm_x or 164, params.riv_farm_x or 164, "SAFE"}
      c.farming = true
    else c.farming = false end
    -- riv_down_mc (2026-11-18, Matt asleep: "do you have other ideas"; 5% of boards die from 3R to 2R): on girder 3's right
    -- stretch after 3R with 2R next, two ways down: his route (the 216 ladder) or back over 3R's gap into the middle and down the
    -- 160 ladder (the expert went down the middle at times); both played out in the imagined futures; the middle if it's safer
    -- by the margin (decided once per visit to the stretch)
    if params.riv_down_mc and target[4] == "2R" and c.gone["3R"] and lad == 0 and fl == 3 and x >= 184 and o.ham == 0 and dkh_native and dkh_native.rivsim then
      if c.down_choice == nil then
        local TT = params.riv_down_t or 240
        local function pts_for(goals)
          local pts, t, px, py, pf = {}, 0, x, y, fl
          local save_cross = c.cross
          for _, gl in ipairs(goals) do
            local st = route(pf, px, gl[1], (gl[2] + gl[3]) // 2, gl, false)
            if not st then c.cross = save_cross; return nil end
            for _, sp in ipairs(st) do
              if sp.kind == "walk" then
                while math.abs(px - sp.x) > WALK and t < TT do px = px + (sp.x > px and WALK or -WALK); t = t + 1; if t % 4 == 0 then pts[#pts + 1] = t; pts[#pts + 1] = px; pts[#pts + 1] = py end end
                px = sp.x
              elseif sp.kind == "jump" then
                for i = 1, 46 do if t >= TT then break end; if i <= 42 then px = px + sp.d * 0.5 end; t = t + 1; if t % 4 == 0 then pts[#pts + 1] = t; pts[#pts + 1] = px; pts[#pts + 1] = py end end
              else
                local ty = FLOOR_Y[sp.fl]; px = sp.x
                while math.abs(py - ty) > 0.4 and t < TT do py = py + (ty > py and 0.4 or -0.4); t = t + 1; if t % 4 == 0 then pts[#pts + 1] = t; pts[#pts + 1] = px; pts[#pts + 1] = py end end
                py, pf = ty, sp.fl
              end
              if t >= TT then c.cross = save_cross; return pts end
            end
            pf = gl[1]
          end
          c.cross = save_cross
          while t < TT do t = t + 1; if t % 4 == 0 then pts[#pts + 1] = t; pts[#pts + 1] = px; pts[#pts + 1] = py end end
          return pts
        end
        local d2 = math.min(5, 1 + (f - (c.f0 or f)) // 2040)
        local DV2 = ({{0.43, 0.36, 0.53 * 0.5}, {0.53, 0.46, 0.53}, {0.58, 0.48, 0.53 * 1.6}, {0.62, 0.52, 0.53 * 1.8}, {0.66, 0.55, 0.53 * 2}})[d2]
        local mf = {}
        for _, fb in ipairs(fires) do mf[#mf + 1] = {fb.x, fb.y, fb.vx or 0, fb.vy or 0, fb.frozen or 0} end
        local mg = 0
        for i, nm in ipairs({"2L", "2R", "3L", "3R", "4L", "4R", "5L", "5R"}) do if c.gone[nm] then mg = mg | (1 << (i - 1)) end end
        local a = pts_for({riv("2R")})
        local b = pts_for({{3, 164, 164, "SAFE"}, riv("2R")})
        c.down_choice = false
        if a and b then
          local opt = {n = params.riv_mc_n or 48, T = TT, seed = f * 43 + 5, vr = DV2[1], vl = DV2[2], vd = DV2[3], vu = 0.20, rx = params.riv_sim_rx, ry = params.riv_sim_ry, turn = params.riv_sim_turn}
          local pa, pb = dkh_native.rivsim(mf, mg, a, opt), dkh_native.rivsim(mf, mg, b, opt)
          if pb < pa - params.riv_down_mc then c.down_choice = true end
          if os.getenv("DOWNDBG") then io.stderr:write(string.format("DOWN f=%d x=%d right %.2f middle %.2f -> %s\n", f, x, pa, pb, tostring(c.down_choice))) end
        end
      end
    elseif fl ~= 3 or lad ~= 0 or x < 184 then
      if not (c.down_choice and fl == 3 and lad == 0 and x >= 76 and x < 180) then c.down_choice = nil end
    end
    -- riv_route_mc (2026-11-19, Matt: "Are you working on something?"; the general form of the choices that won: the hammer
    -- choice, the way down to 2R, the middle way up): after the left sweep, heading for a rivet, about once a second his route is
    -- weighed against going first through each other section of girders 2-5 (left / middle / right; the top girder's middle in
    -- two either side of Kong), each played out in the imagined futures over 240 frames; a way through that's safer by the margin
    -- is a waypoint he goes to first
    if params.riv_route_mc and lad == 0 and o.ham == 0 and target[4] and RIVETS and not HAMS[target[4]] and target[4] ~= "SAFE"
       and c.gone["2L"] and c.gone["4L"] and c.gone["5L"] and c.gone["3L"] and c.gone["3R"] and not c.via2
       and f >= (c.rc_next or 0) and dkh_native and dkh_native.rivsim
       -- (second try: 8 / 16, mostly the timer: detours chained, one after another) one per rivet, none with the timer low
       and not (c.rc_done or {})[target[4]] and (o.t or 99) * 137 > 1500 then
      c.rc_next = f + 60
      local TT = 240
      local function pts_for(goals)
        local pts, t, px, py, pf = {}, 0, x, y, fl
        local save_cross = c.cross
        local function emit() if t % 4 == 0 then pts[#pts + 1] = t; pts[#pts + 1] = px; pts[#pts + 1] = py end end
        for _, gl in ipairs(goals) do
          local st = route(pf, px, gl[1], (gl[2] + gl[3]) // 2, gl, false)
          if not st then c.cross = save_cross; return nil end
          for _, sp in ipairs(st) do
            if sp.kind == "walk" then
              while math.abs(px - sp.x) > WALK and t < TT do px = px + (sp.x > px and WALK or -WALK); t = t + 1; emit() end
              px = sp.x
            elseif sp.kind == "jump" then
              for i = 1, 46 do if t >= TT then break end; if i <= 42 then px = px + sp.d * 0.5 end; t = t + 1; emit() end
            else
              local ty = FLOOR_Y[sp.fl]; px = sp.x
              while math.abs(py - ty) > 0.4 and t < TT do py = py + (ty > py and 0.4 or -0.4); t = t + 1; emit() end
              py, pf = ty, sp.fl
            end
            if t >= TT then c.cross = save_cross; return pts end
          end
          pf = gl[1]
        end
        c.cross = save_cross
        while t < TT do t = t + 1; emit() end
        return pts
      end
      local d2 = math.min(5, 1 + (f - (c.f0 or f)) // 2040)
      local DV2 = ({{0.43, 0.36, 0.53 * 0.5}, {0.53, 0.46, 0.53}, {0.58, 0.48, 0.53 * 1.6}, {0.62, 0.52, 0.53 * 1.8}, {0.66, 0.55, 0.53 * 2}})[d2]
      local mf = {}
      for _, fb in ipairs(fires) do mf[#mf + 1] = {fb.x, fb.y, fb.vx or 0, fb.vy or 0, fb.frozen or 0} end
      local mg = 0
      for i, nm in ipairs({"2L", "2R", "3L", "3R", "4L", "4R", "5L", "5R"}) do if c.gone[nm] then mg = mg | (1 << (i - 1)) end end
      local opt = {n = params.riv_mc_n or 48, T = TT, seed = f * 47 + 9, vr = DV2[1], vl = DV2[2], vd = DV2[3], vu = 0.20, rx = params.riv_sim_rx, ry = params.riv_sim_ry, turn = params.riv_sim_turn}
      local base = pts_for({target})
      if base then
        local p0 = dkh_native.rivsim(mf, mg, base, opt)
        local bestp, bestw, bestpts = p0, nil, nil
        -- (first try: the safest of 13 noisy estimates nearly always beat his route by luck, 9 / 16, detours everywhere): only
        -- with his route clearly dangerous, and a winner re-checked on new futures
        local go = p0 >= (params.riv_route_min or 0.3)
        local WPS = {{2, 44}, {2, 128}, {2, 205}, {3, 44}, {3, 128}, {3, 202}, {4, 56}, {4, 128}, {4, 196}, {5, 62}, {5, 90}, {5, 166}, {5, 192}}
        for _, w in ipairs(WPS) do
          if go and not (w[1] == fl and sec(fl, w[2]) == sec(fl, x)) and not (w[1] == target[1] and sec(w[1], w[2]) == sec(target[1], (target[2] + target[3]) / 2)) then
            local pp = pts_for({{w[1], w[2], w[2], "SAFE"}, target})
            if pp then
              local pw = dkh_native.rivsim(mf, mg, pp, opt)
              if pw < bestp then bestp, bestw, bestpts = pw, w, pp end
            end
          end
        end
        if go and bestw and bestp < p0 - params.riv_route_mc then
          local opt2 = {n = 96, T = TT, seed = f * 53 + 11, vr = DV2[1], vl = DV2[2], vd = DV2[3], vu = 0.20, rx = params.riv_sim_rx, ry = params.riv_sim_ry, turn = params.riv_sim_turn}
          local q0, qw = dkh_native.rivsim(mf, mg, base, opt2), dkh_native.rivsim(mf, mg, bestpts, opt2)
          if qw < q0 - params.riv_route_mc then
            c.via2 = {fl = bestw[1], x = bestw[2], till = f + 360, for_target = target[4]}
            c.rc_done = c.rc_done or {}; c.rc_done[target[4]] = true
          end
        end
      end
    end
    if c.via2 and (f > c.via2.till or (lad == 0 and fl == c.via2.fl and math.abs(x - c.via2.x) <= 3) or target[4] ~= c.via2.for_target) then c.via2 = nil end
    if c.via2 then target = {c.via2.fl, c.via2.x, c.via2.x, "SAFE"} end
    if c.via and (f > c.via.till or (lad == 0 and fl == c.via.fl and math.abs(x - c.via.x) <= 3) or not c.free_right) then c.via = nil end
    if c.via and (target[4] == "4R" or target[4] == "5R") then target = {c.via.fl, c.via.x, c.via.x, "SAFE"} end
    if c.down_choice and target[4] == "2R" then
      if fl == 3 and lad == 0 and x >= 76 and x < 180 then c.down_choice = nil   -- (in the middle now: his route goes down from here)
      else target = {3, 164, 164, "SAFE"} end
    end
    -- riv_last_mc (2026-11-19, Matt: Mario on girder 4's right, a fireball frozen at the top of that ladder, "He could jump
    -- across, go up and complete that level, but he just sits there"): heading for 4R or 5R on a girder, his route against going
    -- round the other side (5R: through the top girder's middle-right, x 166, or its right, x 192; 4R: girder 4's middle, x 128,
    -- or right, x 196), each played out in the imagined futures over 240 frames; the safest if better by the margin (once per
    -- rivet per girder he's on)
    if params.riv_last_mc and (target[4] == "4R" or target[4] == "5R") and lad == 0 and o.ham == 0 and not c.via3
       and dkh_native and dkh_native.rivsim and (o.t or 99) * 137 > 1200 then
      local key = target[4] .. fl
      c.lm_done = c.lm_done or {}
      if not c.lm_done[key] then
        c.lm_done[key] = true
        local TT = 240
        local function pts_for(goals)
          local pts, t, px, py, pf = {}, 0, x, y, fl
          local save_cross = c.cross
          local function emit() if t % 4 == 0 then pts[#pts + 1] = t; pts[#pts + 1] = px; pts[#pts + 1] = py end end
          for _, gl in ipairs(goals) do
            local st = route(pf, px, gl[1], (gl[2] + gl[3]) // 2, gl, false)
            if not st then c.cross = save_cross; return nil end
            for _, sp in ipairs(st) do
              if sp.kind == "walk" then
                while math.abs(px - sp.x) > WALK and t < TT do px = px + (sp.x > px and WALK or -WALK); t = t + 1; emit() end
                px = sp.x
              elseif sp.kind == "jump" then
                for i = 1, 46 do if t >= TT then break end; if i <= 42 then px = px + sp.d * 0.5 end; t = t + 1; emit() end
              else
                local ty = FLOOR_Y[sp.fl]; px = sp.x
                while math.abs(py - ty) > 0.4 and t < TT do py = py + (ty > py and 0.4 or -0.4); t = t + 1; emit() end
                py, pf = ty, sp.fl
              end
              if t >= TT then c.cross = save_cross; return pts end
            end
            pf = gl[1]
          end
          c.cross = save_cross
          while t < TT do t = t + 1; emit() end
          return pts
        end
        local d2 = math.min(5, 1 + (f - (c.f0 or f)) // 2040)
        local DV2 = ({{0.43, 0.36, 0.53 * 0.5}, {0.53, 0.46, 0.53}, {0.58, 0.48, 0.53 * 1.6}, {0.62, 0.52, 0.53 * 1.8}, {0.66, 0.55, 0.53 * 2}})[d2]
        local mf = {}
        for _, fb in ipairs(fires) do mf[#mf + 1] = {fb.x, fb.y, fb.vx or 0, fb.vy or 0, fb.frozen or 0} end
        local mg = 0
        for i, nm in ipairs({"2L", "2R", "3L", "3R", "4L", "4R", "5L", "5R"}) do if c.gone[nm] then mg = mg | (1 << (i - 1)) end end
        local opt = {n = params.riv_mc_n or 48, T = TT, seed = f * 59 + 13, vr = DV2[1], vl = DV2[2], vd = DV2[3], vu = 0.20, rx = params.riv_sim_rx, ry = params.riv_sim_ry, turn = params.riv_sim_turn}
        local base = pts_for({target})
        if base then
          local p0 = dkh_native.rivsim(mf, mg, base, opt)
          local bestp, bestw = p0, nil
          local wps = target[4] == "5R" and {{5, 166}, {5, 192}} or {{4, 128}, {4, 196}}
          for _, w in ipairs(wps) do
            if not (fl == w[1] and sec(fl, x) == sec(fl, w[2])) then
              local pp = pts_for({{w[1], w[2], w[2], "SAFE"}, target})
              if pp then local pw = dkh_native.rivsim(mf, mg, pp, opt); if pw < bestp then bestp, bestw = pw, w end end
            end
          end
          if bestw and bestp < p0 - params.riv_last_mc then c.via3 = {fl = bestw[1], x = bestw[2], till = f + 420, for_target = target[4]} end
        end
      end
    end
    if c.via3 and (f > c.via3.till or (lad == 0 and fl == c.via3.fl and math.abs(x - c.via3.x) <= 3) or target[4] ~= c.via3.for_target) then c.via3 = nil end
    if c.via3 then target = {c.via3.fl, c.via3.x, c.via3.x, "SAFE"} end
    c.kw_at = false
    if params.riv_kong_wait and not c.kw_done and c.gone["2L"] and c.gone["4L"] and not c.gone["5L"] and o.ham == 0 then
      local KX = params.riv_kong_x or 94
      local leave = false
      if c.kw_from then
        if f - c.kw_from > params.riv_kong_wait then leave = true end
        local left_any = false
        for _, fb in ipairs(fires) do
          if fb.x < 128 then left_any = true end
          local onlad = true
          for i = 1, 5 do if math.abs(fb.y - FLOOR_Y[i]) <= 3 then onlad = false end end
          if onlad and fb.x < 128 and (fb.vy or 0) < -0.05 then leave = true end
        end
        if not left_any then leave = true end
      end
      if leave then c.kw_done = true
      else
        target = {5, KX, KX, "SAFE"}
        if lad == 0 and fl == 5 and math.abs(x - KX) <= 2 then c.kw_from = c.kw_from or f; c.kw_at = true end
      end
    end
    if c.pull and (f > c.pull.till or lad ~= 0 or fl ~= c.pull.fl) then c.pull = nil end
    if c.pull then
      if (c.pull.launch - x) * c.pull.d <= 1 then
        local p = c.pull; c.pull = nil
        c.jump_until = f + 46; c.why = "jump back over the gap"; c.jump_kind = "jumping back over the gap"
        return JUMP | (p.d > 0 and LEFT or RIGHT)
      end
      c.why = "pull and jump back"; return c.pull.d > 0 and RIGHT or LEFT
    end
    local tx = (target[2] + target[3]) // 2
    if lad == 0 then c.climb_dir = nil end
    -- on a ladder he's between two girders: the girder he's heading for counts as his (for routing)
    if lad ~= 0 then
      local lo = 1
      for i = 1, 4 do if y <= FLOOR_Y[i] and y >= FLOOR_Y[i + 1] then lo = i end end
      fl = (target[1] > lo) and lo + 1 or lo
    end
    -- standing in a rivet's column the moment it comes out: carry straight on the way he was going (deciding from there could
    -- stop him over the new gap: rp02 fell through it 980 times in 1,000)
    if lad == 0 then
      for _, r in ipairs(RIVETS) do
        -- any rivet's column, gone or not yet known to be gone (he sees a few frames late: rp02 / rp03 turned back into the new gap)
        if r[1] == fl and x >= r[2] - 1 and x <= r[3] + 1 and c.walk_dir and me.jmp == 0 then
          c.why = "across the gap"; return c.walk_dir
        end
      end
    end
    c.cur_target = target   -- (RSEARCH: progress is measured towards this)
    local steps = route(fl, x, target[1], tx, target, o.ham ~= 0)
    if not steps then c.why = "no route to " .. target[4]; return 0 end
    local s = steps[1]
    if s.kind == "walk" and math.abs(s.x - x) <= 1 and steps[2] then s = steps[2] end
    c.step_x = s.x   -- (SEARCH on the rivet board: the all-knowing search's "his way" follows this)
    c.step_v = (s.kind == "up" and 1) or (s.kind == "down" and -1) or 0
    -- his options: each a short course over the next H frames, judged against every fireball's reach (it can be anywhere within
    -- REACH + V * t of where he last saw it: measured, 99% of the time a fireball moves less than 0.65 px a frame along a girder)
    -- (2026-11-15 sweep, two checks: reach 10 / look 48 -> 4 / 36: 420 -> 593 of 1,000, then 418 -> 577 on fresh games; he was too cautious)
    local REACH, H, CLIMB = params.riv_reach or 4, params.riv_h or 36, 0.4
    -- riv_right (per-stage settings, 2026-11-15): after the left sweep (where nearly all deaths now are), these override the
    -- caution settings: {reach =, h =, safe_w =}
    local RT = params.riv_right and c.gone["2L"] and c.gone["4L"] and c.gone["5L"] and c.gone["3L"] and c.gone["3R"] and params.riv_right
    if RT then REACH, H = RT.reach or REACH, RT.h or H end
    -- a jump is checked through its landing and a little after (42 frames in the air), whatever the look-ahead (with H 36 the
    -- landing went unchecked: mr3's escape jumps all died to fireballs just after landing)
    local JH = params.riv_jump_h or 56
    -- riv_jump_safe: in a jump he can't react for ~46 frames, so the allowance tuned for walking (REACH 4, the drift discount) is
    -- too thin there: this much extra, and no discount for a fireball drifting away
    local JS = params.riv_jump_safe or 0
    -- (sweep 2026-11-15: the measured 90th percentiles x 1.12 did better, 593 -> 625 with the gap-jump cost; second check 577 -> 615)
    local VR, VL, VD, VU = params.riv_vr or 0.7, params.riv_vl or 0.56, params.riv_vd or 0.7, params.riv_vu or 0.35
    -- (Matt: "the difficulty will increase throughout this level ... the fireballs may get faster") measured: the game's
    -- difficulty (0x6380) goes up one every 2,040 frames on the board (34 s, about 13 ticks of the bonus timer, which he can
    -- see); fireballs on girders ~0.9x / 1.1x / 1.2x the average speed at difficulty 1 / 2 / 3, down ladders ~3x faster by 3
    local DIFF = math.min(5, 1 + (f - (c.f0 or f)) // 2040)
    c.f0 = c.f0 or f
    local DS = ({0.9, 1.1, 1.2, 1.3, 1.4})[DIFF]
    if params.riv_diff then VR, VL, VD, VU = VR * DS, VL * DS, VD * DS, VU * DS end
    local at_lad = {}
    for lf = math.max(1, fl - 1), math.min(4, fl) do
      for _, lx in ipairs(LADDERS[lf]) do if x >= lx and x <= lx + 7 then at_lad[#at_lad + 1] = {dir = lf == fl and UP or DOWN, x = lx + 4} end end
    end
    local function course(kind, arg)
      -- positions every 4 frames from where he is: walking (stops at arg), standing, or climbing (up to the next girder / down to the last)
      local pts = {}
      local ytop, ybot = y, y
      if kind == "climb" then
        for i = 1, 5 do if FLOOR_Y[i] < y - 1 and (ytop == y or FLOOR_Y[i] > ytop) then ytop = FLOOR_Y[i] end end
        for i = 5, 1, -1 do if FLOOR_Y[i] > y + 1 and (ybot == y or FLOOR_Y[i] < ybot) then ybot = FLOOR_Y[i] end end
      end
      for t = 0, math.max(H, params.riv_far_h or 0), 4 do
        local px, py = x, y
        local face
        if kind == "walk" then
          local d = arg > x and 1 or (arg < x and -1 or 0)
          px = x + d * math.min(WALK * t, math.abs(arg - x))
          if d ~= 0 then face = d end
        elseif kind == "climb" then
          py = (arg == UP) and math.max(ytop, y - CLIMB * t) or math.min(ybot, y + CLIMB * t)
        end
        pts[#pts + 1] = {t = t, x = px, y = py, face = face, far = t > H or nil}
      end
      return pts
    end
    local function contact(pts, upto)
      -- first frame a fireball could be touching him on this course (nil: never within H); upto: only up to that frame
      local last_near
      for _, q in ipairs(pts) do if not q.far and q.t <= H then last_near = q end end
      for _, pnt in ipairs(pts) do
        if upto and pnt.t > upto then break end
        -- (walls: Kong, a girder's end, a gap; marked on the course, so accepted risk (time running out) never covers them)
        if params.riv_kong ~= false and math.abs(pnt.y - FLOOR_Y[5]) <= 4 and pnt.x > KONG_L and pnt.x < KONG_R then pts.wall = true; return pnt.t end
        -- riv_far_h (Matt: "perhaps he is not looking far enough ahead?"; looking further the worst-case way froze him: 44 frames
        -- 718 vs 841): beyond H, each fireball where it's actually heading (its smoothed motion), a ladder ending at the girder
        -- it reaches, a girder at its ends, with a little spread
        if pnt.far then
          for _, fb in ipairs(fires) do
            local px, py = fb.x + fb.vx * pnt.t, fb.y + fb.vy * pnt.t
            local f0 = floor_of(fb.y)
            if math.abs(fb.y - FLOOR_Y[f0]) > 3 then   -- on a ladder: as far as the girder it's going to
              local lo, hi = 0, 255
              for i = 1, 5 do if FLOOR_Y[i] < fb.y then lo = math.max(lo, FLOOR_Y[i]) else hi = math.min(hi, FLOOR_Y[i]) end end
              py = math.max(lo, math.min(hi, py)); px = fb.x
            else
              py = FLOOR_Y[f0]; px = math.max(ENDS[f0][1], math.min(ENDS[f0][2], px))
            end
            if math.abs(px - pnt.x) < REACH + (params.riv_far_spread or 0.15) * (pnt.t - H) and math.abs(py - pnt.y) < 10 then return pnt.t end
          end
          goto next_point
        end
        -- riv_under_ladder (Matt's review 4 #5: "he just let the fireball come down on top of him"; the play-out: he waited at
        -- the foot of the 200 ladder while a fireball sat at its top, which it then came down): at the foot of a ladder going
        -- up from his girder with a fireball at its top (on the girder above, within this many px of the ladder), counts as contact
        -- (zr1 / zr2: 7,947 / 7,790 vs 8,325: just being near a ladder's foot, walking past included, counted at once: too wide)
        -- only where the move ends him up, and as the latest contact (the least preferred safe move, not immediate danger)
        -- (zr3 / zr4: 8,301 / 8,260 vs 8,325: the end of a walk to a ladder is its foot, so every approach was marked) only moves
        -- where he stays put (waiting there, Matt's #5)
        if params.riv_under_ladder and o.ham == 0 and pnt == last_near and pts[1].x == pnt.x and pts[1].y == pnt.y then
          local pf = floor_of(pnt.y)
          if math.abs(pnt.y - FLOOR_Y[pf]) <= 2 and pf <= 4 then
            for _, lx in ipairs(LADDERS[pf]) do
              local lc = lx + 4
              if math.abs(pnt.x - lc) <= 10 then
                for _, fb in ipairs(fires) do
                  if math.abs(fb.y - FLOOR_Y[pf + 1]) <= 4 and math.abs(fb.x - lc) <= params.riv_under_ladder then return H end
                end
              end
            end
          end
        end
        for _, fb in ipairs(fires) do
          local smashable = false
          if o.ham ~= 0 and math.abs(fb.y - FLOOR_Y[fl]) < 10 then
            local facing = pnt.face or (me.face or 1)
            smashable = (fb.x - pnt.x) * facing > 0
          end
          -- riv_smash_right (option 5, managing the fireball count; Matt from the start: smash on the right so they respawn on the
          -- left): a smashed fireball comes back on the side opposite him, and after the left sweep three of the four left girder
          -- ends are cut off: so with him left of the middle after the sweep, a fireball isn't smashable (avoid it instead)
          if smashable and params.riv_smash_right and pnt.x < 128 and c.gone["2L"] and c.gone["4L"] and c.gone["5L"] and c.gone["3L"] and c.gone["3R"] then
            smashable = false
          end
          if smashable then goto next_fire end
          -- Matt: fireballs move faster some ways than others. Measured (16-frame runs, 90th percentile): right 0.62 px a frame,
          -- left 0.50, down a ladder 0.62, up a ladder 0.31; heading towards Mario or away makes no difference
          local vx = (pnt.x > fb.x) and VR or VL
          -- drifting away from that side: it comes back at most ~0.3 px a frame (90th percentile: 12 px in 40 frames)
          if params.riv_heading ~= false and not (pnt.jump and JS > 0) and ((pnt.x > fb.x and (fb.drift or 0) <= -3) or (pnt.x < fb.x and (fb.drift or 0) >= 3)) then vx = params.riv_vaway or 0.3 end
          local vy = (pnt.y > fb.y) and VD or VU
          if fb.frozen and pnt.t < fb.frozen then vx, vy = 0, 0 end   -- (riv_freeze: frozen for now: still)
          local dx, dy = math.abs(fb.x - pnt.x), math.abs(fb.y - pnt.y)
          -- (Matt: think of the board as a maze) along a girder, but never across a pulled rivet's gap: fireballs can't cross them
          local walled = params.riv_maze ~= false and dy < 10 and gap_between(floor_of(pnt.y), fb.x, pnt.x)
          if not walled and pnt.pulled and dy < 10 and pnt.pulled[1] == floor_of(pnt.y) then
            local cx = (pnt.pulled[2] + pnt.pulled[3]) / 2
            if (fb.x < cx) ~= (pnt.x < cx) then walled = pnt.pulled end
          end
          if walled and params.riv_maze_edge == false then
            -- (the first maze rule: a fireball across a gap never counts; kept as it was for the sweep's comparisons)
          elseif walled then
            -- it can't cross the gap, but it can come right up to its edge, and from there touch him at the near edge (the
            -- first maze rule ignored this: rs11, maze off, did better)
            local edge = (fb.x > (walled[2] + walled[3]) / 2) and walled[3] + 1 or walled[2] - 1
            if math.abs(pnt.x - edge) < REACH and math.abs(fb.x - edge) <= vx * pnt.t + REACH then return pnt.t end
          elseif dy < 10 and dx < REACH + (pnt.jump and JS or 0) + vx * pnt.t then return pnt.t end   -- along a girder (fireballs change height only on ladders)
          if dx < 9 and dy < REACH + vy * pnt.t then return pnt.t end   -- on a ladder with him (or coming up / down it)
          ::next_fire::
        end
        if lad == 0 and pnt.y == FLOOR_Y[fl] and (pnt.x < ENDS[fl][1] or pnt.x > ENDS[fl][2] or (not pnt.jump and gap_between(fl, x, pnt.x))) then pts.wall = true; return pnt.t end
        ::next_point::
      end
    end
    local hm = HAMS[target[4]]
    if hm and lad == 0 and fl == hm.fl and x >= ((target[4] == "HAM" and stay_right()) and 128 or hm.lo) and x <= hm.hi then
      local save = H; H = 52
      local hit = contact(course("stand"))
      H = save
      -- riv_lham_delay (Matt, 2026-11-17: "delay grabbing the hammer on the left side just a little, to see if you can encourage
      -- the fireballs above and below to sort of move somewhat towards the middle-ish area"): at the bottom hammer's spot, wait
      -- this many frames before jumping for it, while standing there is safe
      if target[4] == "LHAM" and params.riv_lham_delay and not hit then
        c.lham_at = c.lham_at or f
        if f - c.lham_at < params.riv_lham_delay then c.why = "waiting a moment before the bottom hammer"; return 0 end
      end
      -- riv_lham_smart (Matt: "base your wait perhaps on distance / number of fireballs above / below / middle"): wait while a
      -- fireball is close above or below (the girder above or below, or a ladder between, within this many px of him), at most
      -- riv_lham_max frames; grab once they've moved off (towards the middle) or at once if none is close
      if target[4] == "LHAM" and params.riv_lham_smart and not hit then
        c.lham_at = c.lham_at or f
        local close = 0
        for _, fb in ipairs(fires) do
          local onabove = fl < 5 and math.abs(fb.y - FLOOR_Y[fl + 1]) <= 4
          local onbelow = fl > 1 and math.abs(fb.y - FLOOR_Y[fl - 1]) <= 4
          local between = fl > 1 and fl < 5 and fb.y > FLOOR_Y[fl + 1] + 4 and fb.y < FLOOR_Y[fl - 1] - 4 and math.abs(fb.y - FLOOR_Y[fl]) > 4
          -- (Matt: "I don't mean on the left side above and below, I mean anywhere above or below") any fireball not on his girder
          -- that's out on a side, i.e. not yet in the middle sections (between the rivet columns, widened by N px)
          if params.riv_lham_anywhere then
            if math.abs(fb.y - FLOOR_Y[fl]) > 4 and (fb.x < 76 - params.riv_lham_smart or fb.x > 180 + params.riv_lham_smart) then close = close + 1 end
          elseif (onabove or onbelow or between) and math.abs(fb.x - x) < params.riv_lham_smart then close = close + 1 end
        end
        if close > 0 and f - c.lham_at < (params.riv_lham_max or 180) then c.why = "waiting for the fireballs above / below to move off"; return 0 end
      end
      if not hit then c.jump_until = f + 46; c.grabbing = target[4]; c.why = "jump for the " .. (target[4] == "HAM" and "middle" or "bottom") .. " hammer"; c.jump_kind = c.why; return JUMP end
    end
    local opts = {}
    -- riv_safe_w (the whole board, all the time): how much time to spare where the move leaves him, by the safety map
    local SW = (RT and RT.safe_w) or params.riv_safe_w
    local function spare(pts)
      local e = pts[#pts]
      for i = #pts, 1, -1 do if not pts[i].far then e = pts[i]; break end end   -- (where the near look-ahead leaves him)
      local ef = floor_of(e.y)
      local m = 60
      for _, fb in ipairs(fires) do m = math.min(m, fb_time(fb, ef, e.x, VR, VL, VD, VU) - e.t) end
      return math.max(-60, m)
    end
    -- riv_mc / riv_mc_only (imagined futures, 2026-11-15): the share of futures where a fireball touches him on this course, the
    -- fireballs moved by the odds measured in his own games (native/rivsim.cpp); not while holding a hammer
    local MC = (params.riv_mc or params.riv_mc_only) and o.ham == 0 and dkh_native and dkh_native.rivsim
    local mc_fires, mc_gone
    if MC then
      mc_fires = {}
      for _, fb in ipairs(fires) do mc_fires[#mc_fires + 1] = {fb.x, fb.y, fb.vx or 0, fb.vy or 0, fb.frozen or 0} end
      mc_gone = 0
      for i, nm in ipairs({"2L", "2R", "3L", "3R", "4L", "4R", "5L", "5R"}) do if c.gone[nm] then mc_gone = mc_gone | (1 << (i - 1)) end end
    end
    -- riv_spawn_mc (Matt: "go ahead"; measured: a new fireball every 256 frames while fewer than 5 are out, at a girder end on
    -- the side opposite Mario): the next one goes into the imagined futures (the clock from the spawns he's seen)
    local SPT = -1
    if params.riv_spawn_mc and c.spawn_f and #fires < 5 then SPT = 256 - ((f - c.spawn_f) % 256) end
    local function futures(pts)
      local cr = {}
      for _, q in ipairs(pts) do if not q.far then cr[#cr + 1] = q.t; cr[#cr + 1] = q.x; cr[#cr + 1] = q.y end end
      local DV = ({{0.43, 0.36, 0.53 * 0.5}, {0.53, 0.46, 0.53}, {0.58, 0.48, 0.53 * 1.6}, {0.62, 0.52, 0.53 * 1.8}, {0.66, 0.55, 0.53 * 2}})[DIFF]
      local p = dkh_native.rivsim(mc_fires, mc_gone, cr, {n = params.riv_mc_n or 48, T = params.riv_mc_t or 90, seed = f * 31 + #opts + 1,
        vr = DV[1], vl = DV[2], vd = DV[3], vu = 0.20, rx = params.riv_sim_rx, ry = params.riv_sim_ry, turn = params.riv_sim_turn, bias = params.riv_bias and 1 or 0, spawn_t = SPT})
      return p
    end
    -- riv_danger_w (Matt: "go ahead with all 4", the learnt danger score): from his own games (tools/danger_rivets.py), how
    -- often each fireball's situation relative to him (on his girder / above / below / on a ladder, x in 8 px, heading, a gap
    -- between) led to that fireball killing him within 90 frames; a move's end spot scored by all of them together
    local function danger_at(pts)
      if not params.riv_danger_w then return nil end
      if c.dtable == nil then
        local ok, t = pcall(dofile, (os.getenv("DKH") or ".") .. "/lua/danger_rivets.lua")
        c.dtable = ok and t or false
      end
      if not c.dtable then return nil end
      local e = pts[1]
      for _, q in ipairs(pts) do if not q.far and q.t <= H then e = q end end
      local function gir(yy) for i = 1, 5 do if math.abs(yy - FLOOR_Y[i]) <= 3 then return i end end return 0 end
      local mg = gir(e.y)
      local surv = 1
      for _, fb in ipairs(fires) do
        local fg = gir(fb.y)
        local rel = (fg > 0 and mg > 0) and ("G" .. (fg - mg)) or ("Y" .. math.max(-8, math.min(8, math.floor((fb.y - e.y) / 8 + 0.5))))
        local dx = math.max(-8, math.min(8, math.floor((fb.x - e.x) / 8 + 0.5)))
        local d0 = math.abs(fb.x - e.x) + math.abs(fb.y - e.y)
        local d1 = math.abs(fb.x + 4 * (fb.vx or 0) - e.x) + math.abs(fb.y + 4 * (fb.vy or 0) - e.y)
        local head = (d1 < d0 - 0.5) and "T" or ((d1 > d0 + 0.5) and "A" or "S")
        local wall = (fg > 0 and fg == mg and gap_between(mg, e.x, fb.x)) and 1 or 0
        local key = (mg > 0 and ("g" .. mg) or "L") .. "|" .. rel .. "|" .. dx .. "|" .. head .. "|" .. wall
        surv = surv * (1 - (c.dtable[key] or 0))
      end
      return 1 - surv
    end
    local function add(name, m, pts, prog) opts[#opts + 1] = {name = name, m = m, hit = contact(pts), prog = prog, safe = SW and spare(pts), pts = pts, mc = MC and futures(pts) or nil} end
    -- riv_park (Matt: with the hammer stand left of the ladder, facing right, the hammer landing over it; barra and player 3 after
    -- 3R: at x 184-195, facing right ~88% of the time, while the bottom hammer lasts): holding a hammer with a ladder next, wait
    -- ~30 px short of it facing it, and walk over as the hammer runs out (o.hleft: frames of hammer left)
    local climb_step
    for _, st2 in ipairs(steps) do if st2.kind == "up" or st2.kind == "down" then climb_step = st2; break end; if st2.kind == "jump" then break end end
    if params.riv_park ~= false and o.ham ~= 0 and lad == 0 and climb_step and climb_step.fl ~= fl and FLOOR_Y[fl] then
      s = climb_step
      local side = (s.x - 30 >= ENDS[fl][1] and not gap_between(fl, s.x, s.x - 30)) and -1 or 1
      local park = s.x + side * 30
      local walk_t = math.abs(s.x - x) / WALK
      if (o.hleft or 0) > walk_t + 8 then
        local face_want = -side   -- facing the ladder
        if math.abs(park - x) > 2 then add("to the hammer spot", park > x and RIGHT or LEFT, course("walk", park), 2)
        elseif (me.face or 1) ~= face_want then add("turn to face the ladder", face_want > 0 and RIGHT or LEFT, course("stand"), 2)
        else add("wait with the hammer", 0, course("stand"), 2) end
        s = {kind = "parked"}
      end
    end
    -- riv_hunt (Matt, 2026-11-15: "struggling to cover the third girder with the hammer"; and earlier: smash whatever comes up
    -- into his area, take out any fireball on the right before the hammer runs out): holding a hammer, the nearest fireball he can
    -- reach in time on his stretch of girder (no gap between), or climbing a ladder up to it: go and smash it; for one on a ladder,
    -- stand ~10 px beside the ladder top facing it (not under it: they sneak through)
    if params.riv_hunt and o.ham ~= 0 and lad == 0 and FLOOR_Y[fl] then
      local HR = params.riv_hunt_reach or 80
      local best_h
      for _, fb in ipairs(fires) do
        local spot, eta = nil, 0
        if math.abs(fb.y - FLOOR_Y[fl]) <= 4 then spot = fb.x
        elseif fl > 1 and fb.y > FLOOR_Y[fl] + 4 and fb.y < FLOOR_Y[fl - 1] - 2 then
          for _, lx in ipairs(LADDERS[fl - 1]) do
            -- (it must get to the top while he still has the hammer: measured climbing 0.20 px/frame)
            if fb.x >= lx - 1 and fb.x <= lx + 8 then local lc = lx + 4; spot = lc + ((x >= lc) and 10 or -10); eta = (fb.y - FLOOR_Y[fl]) / 0.2 end
          end
        end
        if spot and spot > ENDS[fl][1] and spot < ENDS[fl][2] and not gap_between(fl, x, spot) and math.abs(spot - x) <= HR then
          local tw = math.abs(spot - x) / WALK
          -- riv_hunt_right (Matt: smash on the right side if possible, so the fireballs reappear on the left): a smash with
          -- him on the left half counts as this many frames further away
          local rank = tw + ((spot < 128) and (params.riv_hunt_right or 0) or 0)
          if (o.hleft or 0) > math.max(tw, eta) + 20 and (not best_h or rank < best_h.rank) then best_h = {spot = spot, tw = tw, rank = rank, fbx = fb.x} end
        end
      end
      if best_h then
        local fw = best_h.fbx > x and 1 or -1
        if math.abs(best_h.spot - x) > 2 then add("hunt with the hammer", best_h.spot > x and RIGHT or LEFT, course("walk", best_h.spot), 3)
        elseif (me.face or 1) ~= fw then add("turn to the fireball", fw > 0 and RIGHT or LEFT, course("stand"), 3)
        else add("cover the ladder with the hammer", 0, course("stand"), 3) end
        s = {kind = "parked"}
      end
    end
    if s.kind == "parked" then
      -- (options above)
    elseif s.kind == "jump" and lad == 0 and math.abs(s.x - x) <= 2 then
      -- his route jumps a pulled rivet's gap here: one option among the others, judged the same way (flight and landing)
      local pts = {}
      for t = 0, math.max(H, JH), 4 do pts[#pts + 1] = {t = t, x = x + s.d * 0.5 * math.min(t, 42), y = FLOOR_Y[fl], face = s.d, jump = true} end
      opts[#opts + 1] = {name = "jump the gap to " .. target[4], m = JUMP | (s.d > 0 and RIGHT or LEFT), hit = contact(pts), prog = 2, jump = true, pts = pts, mc = MC and futures(pts) or nil}
    elseif s.kind == "jump" then
      add("to the gap", s.x > x and RIGHT or LEFT, course("walk", s.x), 2)
    elseif lad ~= 0 then
      -- on a ladder: on towards the girder his route wants, back the other way, or hold
      local want_up = s.kind == "up" or (s.kind == "walk" and FLOOR_Y[s.fl] < y)
      if s.kind == "down" then want_up = false end
      add(want_up and "climb on up" or "climb on down", want_up and UP or DOWN, course("climb", want_up and UP or DOWN), 2)
      -- riv_ladder_off: when going on isn't clear, getting off the ladder (back) beats hanging on it (traces: he held for
      -- hundreds of frames between fireballs above and below until one reached him)
      local off = params.riv_ladder_off ~= false
      add(want_up and "back down" or "back up", want_up and DOWN or UP, course("climb", want_up and DOWN or UP), off and 1 or 0)
      -- riv_ladder_commit (Matt: he hesitates on ladders; better off on a floor, top or bottom): no holding mid-ladder
      if not params.riv_ladder_commit then add("hold on the ladder", 0, course("stand"), off and 0 or 1) end
    elseif s.kind == "walk" and s.last and params.riv_last ~= false then
      local pts = course("walk", s.x)
      opts[#opts + 1] = {name = "to the last rivet", m = s.x > x and RIGHT or (s.x < x and LEFT or 0), hit = contact(pts, math.abs(s.x - x) / WALK + 2), prog = 3, pts = pts, mc = MC and futures(pts) or nil}
    elseif s.kind == "walk" then add("to " .. target[4], s.x > x and RIGHT or (s.x < x and LEFT or 0), course("walk", s.x), 2)
      -- riv_pullback (Matt, 2026-11-15: he stood left of 2R "just kinda chilling instead of crossing over to remove the rivet and
      -- then having him jump back"): across the rivet, pull it, a step onto the far side, and straight back over the new gap
      if params.riv_pullback and lad == 0 and o.ham == 0 and s.fl == fl and not HAMS[target[4]] and target[1] == fl then
        local d = s.x > x and 1 or -1
        -- jumping back starts where an ordinary crossing stops (3 px past the gap; a forward gap jump needs 6 to clear it, a
        -- jump back from the edge clears it whole: the first version took him 6 px on and never won)
        local launch = d == 1 and target[3] + 3 or target[2] - 3
        local land = launch - d * 21
        local pull_x = d == 1 and target[2] + 4 or target[2] + 2   -- measured: it comes out at x 76 walking right, 74 walking left
        if math.abs(launch - x) <= 60 and (launch - x) * d > 0 and launch > ENDS[fl][1] and launch < ENDS[fl][2] and land > ENDS[fl][1] and land < ENDS[fl][2] then
          local w = math.abs(launch - x) / WALK
          local pts = {}
          for t = 0, math.max(H, JH + w), 4 do
            local px = (t < w) and (x + d * WALK * t) or (launch - d * 0.5 * math.min(t - w, 42))
            -- once it's pulled, fireballs beyond it can't cross (the maze), though it isn't in c.gone yet
            pts[#pts + 1] = {t = t, x = px, y = FLOOR_Y[fl], face = (t < w) and d or -d, jump = t >= w,
              pulled = ((t >= w) or (px - pull_x) * d >= 0) and target or nil}
          end
          opts[#opts + 1] = {name = "pull " .. target[4] .. " and jump back", m = d > 0 and RIGHT or LEFT, hit = contact(pts), prog = 2, pts = pts, mc = MC and futures(pts) or nil,
            pull = {fl = fl, launch = launch, d = d, till = f + w + 30}}
        end
      end
    elseif math.abs(s.x - x) <= 3 and o.ham == 0 then add(s.kind .. " to " .. target[4], s.kind == "up" and UP or DOWN, course("climb", s.kind == "up" and UP or DOWN), 2)
    elseif math.abs(s.x - x) <= 3 then add("wait for the hammer to run out", 0, course("stand"), 1)
    else
      add("to the ladder", s.x > x and RIGHT or LEFT, course("walk", s.x), 2)
      -- riv_ladder_busy (Matt's review 3, #4-#6: the hammer ran out and he walked under the ladder a fireball was coming down;
      -- the 36-frame look-ahead saw it a few frames too late): a fireball anywhere on that ladder counts as contact on arrival
      if params.riv_ladder_busy and FLOOR_Y[s.fl] then
        local ya, yb = math.min(FLOOR_Y[fl], FLOOR_Y[s.fl]), math.max(FLOOR_Y[fl], FLOOR_Y[s.fl])
        for _, fb in ipairs(fires) do
          if math.abs(fb.x - s.x) <= 6 and fb.y > ya + 2 and fb.y < yb - 2 then
            local o3 = opts[#opts]; local ta = math.abs(s.x - x) / WALK
            if not o3.hit or o3.hit > ta then o3.hit = math.max(0, math.floor(ta)) end
          end
        end
      end
    end
    if lad == 0 and o.ham == 0 then
      -- (Matt's review) cornered by a pulled rivet's gap: jump across it to get away
      for _, r in ipairs(RIVETS) do
        if r[1] == fl and c.gone[r[4]] then
          local d = (x < r[2]) and 1 or -1
          local launch = d == 1 and r[2] - 6 or r[3] + 6
          local GR = params.riv_gap_reach or 4
          -- riv_gap_reach_3r (the computer's review: after 3R, on girder 3's right stretch with a fireball coming at him there
          -- or up the 216 ladder, jumping back left over 3R's gap saved him; he was 10-30 px from the take-off spot, outside the
          -- 4 px he looks for it): for 3R's gap only, the whole stretch
          if r[4] == "3R" and params.riv_gap_reach_3r then GR = params.riv_gap_reach_3r end
          if c.urgent then GR = 200 end
          if math.abs(x - launch) > 4 and math.abs(x - launch) <= GR and (launch - x) * d >= 0 then
            -- (Matt: jump back over pulled rivets when it's free over there) a few px short: walk to the edge, then jump
            local w = math.abs(launch - x) / WALK
            local pts = {}
            for t = 0, math.max(H, JH + w), 4 do
              local px = (t < w) and (x + d * WALK * t) or (launch + d * 0.5 * math.min(t - w, 42))
              pts[#pts + 1] = {t = t, x = px, y = FLOOR_Y[fl], face = d, jump = t >= w}
            end
            opts[#opts + 1] = {name = "to the gap, to escape over it", m = d > 0 and RIGHT or LEFT, hit = contact(pts), prog = 0, pts = pts, mc = MC and futures(pts) or nil}
          end
          if math.abs(x - launch) <= 4 then
            local pts = {}
            for t = 0, math.max(H, JH), 4 do pts[#pts + 1] = {t = t, x = x + d * 0.5 * math.min(t, 42), y = FLOOR_Y[fl], face = d, jump = true} end
            opts[#opts + 1] = {name = "escape over the gap", m = JUMP | (d > 0 and RIGHT or LEFT), hit = contact(pts), prog = 0, jump = true, pts = pts, mc = MC and futures(pts) or nil}
          end
        end
      end
    end
    -- riv_plan_jump (Matt, 2026-11-16: "Test a limited version"; the second computer review found a jump over a fireball 2-4 s
    -- before a death saved him in 9 of its 10 biggest groups, with other moves still open; Matt's rule otherwise: no fireball
    -- jumps unless it's life or death): only after the left sweep, on a girder without a hammer, with exactly one fireball within
    -- 60 px on his stretch (no gap between) heading straight at him, a jump straight up and one over it are two more moves, judged
    -- by the same checks (in the air over the middle of the jump he's above anything on the girder)
    if params.riv_plan_jump and lad == 0 and o.ham == 0 and FLOOR_Y[fl] and c.gone["2L"] and c.gone["4L"] and c.gone["5L"] and c.gone["3L"] and c.gone["3R"] then
      local near, other = nil, false
      for _, fb in ipairs(fires) do
        if math.abs(fb.y - FLOOR_Y[fl]) <= 4 and math.abs(fb.x - x) <= 60 and not gap_between(fl, x, fb.x) then
          if near then other = true else near = fb end
        end
      end
      if near and not other then
        local toward = (near.x > x and (near.vx or 0) < -0.1) or (near.x < x and (near.vx or 0) > 0.1)
        if toward then
          for _, d in ipairs({0, near.x > x and 1 or -1}) do
            local land = x + d * 21
            if land > ENDS[fl][1] and land < ENDS[fl][2] and not gap_between(fl, x, land) then
              local pts = {}
              for t = 0, math.max(H, JH), 4 do
                local air = t >= 8 and t <= 34
                pts[#pts + 1] = {t = t, x = x + d * 0.5 * math.min(t, 42), y = air and FLOOR_Y[fl] - 16 or FLOOR_Y[fl], face = d ~= 0 and d or nil, jump = true}
              end
              opts[#opts + 1] = {name = d == 0 and "jump the fireball (planned, straight)" or "jump over the fireball (planned)", m = JUMP | (d > 0 and RIGHT or (d < 0 and LEFT or 0)),
                hit = contact(pts), prog = 1, jump = true, pts = pts, mc = MC and futures(pts) or nil}
            end
          end
        end
      end
    end
    if lad == 0 then
      add("wait", 0, course("stand"), 1)
      if o.ham == 0 then for _, l in ipairs(at_lad) do add(l.dir == UP and "escape up" or "escape down", l.dir, course("climb", l.dir), 0) end end
      add("back off left", LEFT, course("walk", ENDS[fl][1]), 0)
      add("back off right", RIGHT, course("walk", ENDS[fl][2]), 0)
    end
    -- clear for the whole look: the most progress; else the one clear longest
    local best
    -- riv_sticky (traces: he switched between down, back up and hold every 15-30 frames on a ladder for ~300 frames, getting
    -- nowhere): the move he's already making is favoured: a small bonus when all are clear, and S frames of margin when not
    -- riv_urgent (Matt's review 4, #2-#4: with the timer nearly out, "a 30% chance is better than a 0 one"): time left (the bonus
    -- timer, ~137 frames a tick) under this many frames per rivet still in: a move that might meet a fireball only after 8
    -- frames no longer counts as unsafe; progress decides
    local URG = params.riv_urgent and o.t and o.rivets_left and o.t * 137 < params.riv_urgent * o.rivets_left
    -- riv_hurry_bonus (Matt: "compare it as normal vs engaging only when 300 left on the bonus timer, regardless of rivets left"):
    -- the bonus timer (0x62B1, hundreds) at or under this: hurry (a move meeting a fireball only after 8 frames isn't unsafe);
    -- riv_hurry_pmax instead: a move with under this share of imagined futures touched isn't unsafe
    if params.riv_hurry_bonus and o.t and o.t <= params.riv_hurry_bonus and not params.riv_hurry_pmax then URG = true end
    c.urgent = URG
    -- riv_risk_curve (Matt: "as timer gets lower and lower, risk % increases"): N frames per rivet still in is what he needs;
    -- with less than twice that left, a move counts as unsafe only if it could meet a fireball within U frames, U going from H
    -- (normal) down to 4 as the time left falls to nothing
    local RU
    if params.riv_risk_curve and o.t and o.rivets_left and o.rivets_left > 0 then
      local ratio = o.t * 137 / (params.riv_risk_curve * o.rivets_left)
      if ratio < 2 then RU = 4 + (H - 4) * ratio / 2; c.urgent = ratio < 0.5 or URG end
    end
    -- riv_risk_mc (Matt: "as timer gets lower and lower, risk % increases"; ignoring danger past 8 frames only swapped timer
    -- deaths for fireball deaths): N frames needed per rivet still in; with less than twice that left, a move whose share of
    -- imagined futures with a touch is under a limit counts as safe, the limit rising from 5% to 70% as the time left falls
    local PMAX
    if params.riv_hurry_pmax and params.riv_hurry_bonus and o.t and o.t <= params.riv_hurry_bonus then PMAX = params.riv_hurry_pmax end
    if params.riv_risk_mc and o.t and o.rivets_left and o.rivets_left > 0 then
      local ratio = o.t * 137 / (params.riv_risk_mc * o.rivets_left)
      if ratio < 2 then PMAX = 0.05 + 0.65 * (1 - ratio / 2) end
    end
    local S = params.riv_sticky
    local LC = params.riv_ladder_commit
    for _, o2 in ipairs(opts) do
      local k = o2.hit and o2.hit or 1000 + o2.prog
      local wall = o2.pts and o2.pts.wall
      if URG and o2.hit and o2.hit >= 8 and not wall then k = 1000 + o2.prog - 8 / o2.hit end
      if RU and o2.hit and o2.hit >= RU and not wall then k = 1000 + o2.prog - RU / o2.hit end
      if PMAX and o2.hit and o2.mc and o2.mc <= PMAX and o2.hit >= 4 and not wall then k = 1000 + o2.prog - o2.mc end
      -- (the worst-case check also covers girder ends, gaps and Kong: anything it says is within riv_mc_near frames still counts)
      if params.riv_mc_only and o2.mc then k = (o2.hit and o2.hit <= (params.riv_mc_near or 8)) and o2.hit or 1000 * (1 - o2.mc) + o2.prog
      elseif params.riv_mc and o2.mc and not o2.hit then k = k - params.riv_mc * o2.mc end
      if SW and o2.safe then k = k + (o2.hit and (params.riv_safe_hit or 8) or SW) * o2.safe / 60 end
      if params.riv_danger_w and not o2.hit and o2.pts then local dg = danger_at(o2.pts); if dg then k = k - params.riv_danger_w * dg end end
      -- riv_spawn_clock (Matt: "you always try and give it a good effort to get back before a respawn"; measured: a new fireball
      -- every 256 frames while there's room, the clock steady through a game, so learnt from the spawns he's seen)
      if params.riv_spawn_clock and not o2.hit and x < 128 and stay_right() and c.spawn_f and o2.pts then
        local due = 256 - ((f - c.spawn_f) % 256)
        for _, q in ipairs(o2.pts) do if q.x >= 128 and q.t <= due then k = k + params.riv_spawn_clock; break end end
      end
      if S and o2.name == c.last_opt then k = k + (o2.hit and S or 0.5) end
      -- on a ladder, keep climbing the way he's going unless the other end is clearly safer (LC frames of margin) or it's clear
      if LC and lad ~= 0 and c.climb_dir and o2.m == c.climb_dir then k = k + (o2.hit and LC or 3) end
      if not best or k > best.k then best = {k = k, o = o2} end
    end
    local o2 = best.o
    -- riv_lad_flee_up (option 2, learnt from 18,000 replays of ordinary moments: on a ladder with the nearest fireball close below
    -- him (within 32 px across) and coming his way, climbing on up beat his own play by ~9%, 66 moments; Matt: commit to the climb):
    -- climb on, unless that meets a fireball within 8 frames
    if params.riv_lad_flee_up and lad ~= 0 and o.ham == 0 then
      local near, nd
      for _, fb in ipairs(fires) do local dd = math.abs(fb.x - x) + math.abs(fb.y - y); if not nd or dd < nd then near, nd = fb, dd end end
      if near and near.y > y + 2 and math.abs(near.x - x) < 32 and ((near.x - x) * (near.vx or 0) < 0 or (near.vy or 0) < 0) then
        for _, q in ipairs(opts) do
          if q.m == UP and not (q.hit and q.hit <= 8) then o2 = q; break end
        end
      end
    end
    -- (riv_kong_wait) waiting by Kong with nothing threatening: straight jumps holding away from Kong (riv_kong_jump; points)
    if c.kw_at and params.riv_kong_jump and not o2.hit and jmp == 0 and f >= (c.kw_next or 0) then
      -- (a jump's direction is set at take-off: straight up, then held sideways in the air, which doesn't move him; JUMP | LEFT
      -- jumped him 21 px left onto 5L and through its gap)
      c.kw_next = f + 50; c.jump_until = f + 46; c.kw_air = f + 46; c.jump_kind = "jumping by Kong"; c.why = "jump by Kong"
      return JUMP
    end
    -- riv_plan2 (2026-11-17, from the play-outs of Matt's review 4: his deaths were usually escapable by a two-step plan found
    -- seconds before, e.g. "down, then left", "up, then jump left over the gap"): when his best move is waiting or could meet a
    -- fireball, he also weighs two-step plans (first step left / right / up / down for 20 or 45 frames, then left / right / up /
    -- down / still), each judged by the imagined futures over riv_plan2_t frames (never off a girder's end, into a gap or Kong; no
    -- contact in the first 8 frames by the worst-case check); a plan clearly safer than his move (by riv_plan2 in share of futures
    -- touched) is taken, its first step now, and re-planned every frame
    -- riv_plan2_always (2026-11-20, a general lever): the planner also weighs plans against an ordinary safe move, every 4th frame
    if params.riv_plan2 and lad == 0 and o.ham == 0 and MC and (o2.hit or o2.name == "wait" or (params.riv_plan2_always and f % 4 == 0)) then
      local T2 = params.riv_plan2_t or params.riv_mc_t or 90   -- (the same span as his own move's share)
      local function plan_course(steps)
        local pts, px, py, t, mode = {}, x, FLOOR_Y[fl], 0, nil
        for si, st in ipairs(steps) do
          local dur = (si == #steps) and (T2 - t) or st.n
          local cf = floor_of(py)
          local lcol
          if st.k == "up" or st.k == "down" then
            local lf = st.k == "up" and cf or cf - 1
            if lf < 1 or lf > 4 then return nil end
            for _, lx in ipairs(LADDERS[lf]) do if px >= lx and px <= lx + 7 then lcol = lx + 4 end end
            if not lcol then return nil end
          end
          local jstart
          for _ = 1, dur do
            t = t + 1
            if st.k == "jl" or st.k == "jr" then
              -- (riv_plan_gap) a jump across a pulled rivet's gap: 0.5 px a frame for 42 frames; he counts as at girder height
              -- (fireballs still reach him in the air)
              local d = st.k == "jl" and -1 or 1
              if jstart == nil then
                local g = floor_of(py)
                if math.abs(py - FLOOR_Y[g]) > 1 then return nil end
                local land = px + d * 21
                if land < ENDS[g][1] or land > ENDS[g][2] or not gap_between(g, px, land) then return nil end
                for _, r in ipairs(RIVETS) do if r[1] == g and c.gone[r[4]] and math.abs(land - (r[2] + r[3]) / 2) < 7 then return nil end end
                jstart = t
              end
              if t - jstart <= 42 then px = px + d * 0.5 end
            elseif st.k == "left" or st.k == "right" then
              local d = st.k == "left" and -1 or 1
              local nx = px + d * WALK
              local g = floor_of(py)
              if math.abs(py - FLOOR_Y[g]) <= 1 then
                if nx < ENDS[g][1] or nx > ENDS[g][2] or gap_between(g, px, nx) then return nil end
                if g == 5 and nx > KONG_L and nx < KONG_R then return nil end
                px = nx
              end
            elseif st.k == "up" or st.k == "down" then
              local target_y = st.k == "up" and FLOOR_Y[cf + 1] or FLOOR_Y[cf - 1]
              if st.k == "up" then py = math.max(target_y, py - CLIMB) else py = math.min(target_y, py + CLIMB) end
              px = lcol
            end
            if t % 4 == 0 then pts[#pts + 1] = {t = t, x = px, y = py} end
          end
        end
        return pts
      end
      local K = {left = LEFT, right = RIGHT, up = UP, down = DOWN, still = 0, jl = JUMP | LEFT, jr = JUMP | RIGHT}
      local K1 = params.riv_plan_gap and {"left", "right", "up", "down", "jl", "jr"} or {"left", "right", "up", "down"}
      local K2 = params.riv_plan_gap and {"left", "right", "up", "down", "still", "jl", "jr"} or {"left", "right", "up", "down", "still"}
      local DV = ({{0.43, 0.36, 0.53 * 0.5}, {0.53, 0.46, 0.53}, {0.58, 0.48, 0.53 * 1.6}, {0.62, 0.52, 0.53 * 1.8}, {0.66, 0.55, 0.53 * 2}})[DIFF]
      local function score(steps)
        local pts = plan_course(steps)
        if not pts or #pts <= 2 then return nil end
        local near = {}
        for _, q in ipairs(pts) do if q.t <= 8 then near[#near + 1] = q end end
        if contact(near) then return nil end
        local cr = {}
        for _, q in ipairs(pts) do cr[#cr + 1] = q.t; cr[#cr + 1] = q.x; cr[#cr + 1] = q.y end
        return dkh_native.rivsim(mc_fires, mc_gone, cr, {n = params.riv_mc_n or 48, T = T2, seed = f * 37 + 7, vr = DV[1], vl = DV[2], vd = DV[3], vu = 0.20, rx = params.riv_sim_rx, ry = params.riv_sim_ry, turn = params.riv_sim_turn, bias = params.riv_bias and 1 or 0, spawn_t = SPT})
      end
      -- riv_plan3 (Matt: "is it worth considering a 3 step planner as well?"): the riv_plan3 best two-step plans each get a
      -- third step, everything judged over riv_plan3_t frames (his own move too, over the same span)
      local P3 = params.riv_plan3
      if P3 then T2 = params.riv_plan3_t or 150 end
      local cand = {}
      for _, k1 in ipairs(K1) do
        for _, n1 in ipairs((k1 == "jl" or k1 == "jr") and {46} or {20, 45}) do
          for _, k2 in ipairs(K2) do
            local st = {{k = k1, n = n1}, {k = k2, n = 45}}
            local p = score({{k = k1, n = n1}, {k = k2}})
            if p then cand[#cand + 1] = {p = p, steps = st, name = string.format("%s %d, then %s", k1, n1, k2)} end
          end
        end
      end
      if P3 then
        table.sort(cand, function(a, b) return a.p < b.p end)
        local ext = {}
        for i = 1, math.min(P3, #cand) do
          for _, k3 in ipairs({"left", "right", "up", "down", "still"}) do
            local st = {cand[i].steps[1], cand[i].steps[2], {k = k3}}
            local p = score(st)
            if p then ext[#ext + 1] = {p = p, steps = st, name = cand[i].name .. ", then " .. k3} end
          end
        end
        for _, e in ipairs(ext) do cand[#cand + 1] = e end
      end
      local bestc
      for _, cd in ipairs(cand) do if not bestc or cd.p < bestc.p then bestc = cd end end
      -- his own move's share over the same span
      local own = o2.pts and o2.mc
      if P3 and o2.pts then
        local cr = {}
        for _, q in ipairs(o2.pts) do if not q.far then cr[#cr + 1] = q.t; cr[#cr + 1] = q.x; cr[#cr + 1] = q.y end end
        own = dkh_native.rivsim(mc_fires, mc_gone, cr, {n = params.riv_mc_n or 48, T = T2, seed = f * 37 + 7, vr = DV[1], vl = DV[2], vd = DV[3], vu = 0.20, rx = params.riv_sim_rx, ry = params.riv_sim_ry, turn = params.riv_sim_turn, bias = params.riv_bias and 1 or 0, spawn_t = SPT})
      end
      if bestc and (not own or bestc.p < own - params.riv_plan2) then
        local k1 = bestc.steps[1].k
        o2 = {name = "plan: " .. bestc.name, m = K[k1], prog = 0, jump = (k1 == "jl" or k1 == "jr") or nil}
      end
    end
    if o2.pull then c.pull = o2.pull end
    -- riv_ham_stuck (Matt, 2026-11-17: "I just watched a game fail because mario refused to pickup the hammer at the top to
    -- destroy the fireballs"; the skip, by the free pass or the first look, was decided once): stuck this many frames in a row
    -- (waiting, or every move could meet a fireball) with the middle hammer still there: it's back in his plan
    if params.riv_ham_stuck then
      if lad == 0 and (o2.hit or o2.name == "wait") then c.stuck = (c.stuck or 0) + 1 else c.stuck = 0 end
      if c.stuck >= params.riv_ham_stuck and o.ham_mid == 1 and not c.ham_tried["HAM"] and o.ham == 0 and not c.force_ham then
        c.force_ham = true; c.free_right = nil; c.ham_skip = false
      end
    end
    if os.getenv("RIVOPTS") and o2.name == "wait" then
      local t = {}
      for _, q in ipairs(opts) do t[#t + 1] = q.name .. "=" .. tostring(q.hit) end
      io.stderr:write("OPTS f=", f, " x=", x, " fl=", fl, " step=", tostring(s.kind), "/", tostring(s.x), " target=", target[4], " | ", table.concat(t, ", "), "\n")
    end
    -- the safety map: every option could meet a fireball soon: head for the spot on the board with the most time to spare
    -- (his time to get there by his routes, gap jumps at any distance included, against the soonest a fireball could)
    local ESC = params.riv_escape
    if ESC and o2.hit and o2.hit <= ESC and not c.escape and o.ham == 0 then
      local spots = {}
      for sf = 1, 5 do
        local a, b = ENDS[sf][1] + 4, ENDS[sf][2] - 4
        local xs = {(a + 72) // 2, 128, (183 + b) // 2}
        for lf = math.max(1, sf - 1), math.min(4, sf) do for _, lx in ipairs(LADDERS[lf]) do xs[#xs + 1] = lx + 4 end end
        for _, sx in ipairs(xs) do
          local inriv = false
          for _, r in ipairs(RIVETS) do if r[1] == sf and sx >= r[2] - 3 and sx <= r[3] + 3 then inriv = true end end
          if not inriv and sx >= a and sx <= b then spots[#spots + 1] = {sf, sx} end
        end
      end
      local bestm, bspot
      for _, sp in ipairs(spots) do
        local st = route(fl, x, sp[1], sp[2], {sp[1], sp[2], sp[2], "SAFE"}, false)
        if st then
          local tm = steps_time(st, x)
          local tfb = math.huge
          for _, fb in ipairs(fires) do tfb = math.min(tfb, fb_time(fb, sp[1], sp[2], VR, VL, VD, VU)) end
          local m = tfb - tm
          if params.riv_escape_near then
            -- the nearest spot that's safe by the margin (a human goes to the closest safe place, not the far corner)
            if m > (params.riv_escape_margin or 20) and (not bspot or tm < bspot.tm) then bestm, bspot = m, {sp[1], sp[2], tm = tm} end
          elseif not bestm or m > bestm then bestm, bspot = m, sp end
        end
      end
      if bspot and bestm > (params.riv_escape_margin or 20) and not (bspot[1] == fl and math.abs(bspot[2] - x) <= 2) then
        c.escape = {fl = bspot[1], x = bspot[2], till = f + 180}
      end
    end
    -- life or death: contact within a few frames whatever he does, a fireball on his girder this close: jump
    -- (the second computer review: a jump is a real answer in 9 of its 10 groups) riv_fire_jump_at: how soon contact has to be,
    -- whatever he does, before he jumps (4 frames: maybe too late for the jump to clear)
    if o2.hit and o2.hit <= (params.riv_fire_jump_at or 4) and lad == 0 and not params.riv_no_fire_jump then
      for _, fb in ipairs(fires) do
        -- riv_lod_dy (Matt's review 4, #8: "why did he try to straight jump a fireball that was coming up under him?"): only a
        -- fireball this close to his girder's height counts (12: one on the ladder below did)
        if math.abs(fb.y - FLOOR_Y[fl]) < (params.riv_lod_dy or 12) and math.abs(fb.x - x) < JUMP_AT + 6 then
          c.jump_until = f + 44; c.why = "jump the fireball"; c.jump_kind = "jumping a fireball"
          -- which way: riv_jump_dir "toward" (over it: it passes underneath), "straight", or "away" (the first version)
          local jd = params.riv_jump_dir or "away"   -- (measured: away 207 / 500, toward 186, straight 188)
          local dir = (jd == "straight") and 0 or ((jd == "toward") == (fb.x > x) and 1 or -1)
          local land = x + dir * 21
          local side = (dir ~= 0 and land > ENDS[fl][1] and land < ENDS[fl][2] and not gap_between(fl, x, land)) and (dir > 0 and RIGHT or LEFT) or 0
          return JUMP | side
        end
      end
    end
    if o2.jump then c.jump_until = f + 46; c.jump_kind = o2.name end
    if o2.m == UP or o2.m == DOWN then c.climb_dir = o2.m; c.ladder_dir = o2.m end
    c.last_opt = o2.name
    if o2.m == LEFT or o2.m == RIGHT then c.walk_dir = o2.m end
    c.why = o2.name .. (o2.hit and (" (could meet one in " .. o2.hit .. ")") or "")
    return o2.m
  end
  return c
end

return R
