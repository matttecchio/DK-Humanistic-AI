-- For probe_plans.py: replays a recorded game to frame F0, saves there, then tries thousands of short plans from that moment.
-- A plan: follow the recording for `at` frames, hold a stick direction for w frames, jump, maybe jump again, then stand.
local F0, DEATH = tonumber(os.getenv("F0")), tonumber(os.getenv("DEATH"))
local AFTER = tonumber(os.getenv("PAFTER") or 90)     -- he has to still be alive this long after the original death
local STEP = tonumber(os.getenv("PSTEP") or 4)
local PRESS, LAND, READY = 3, 44, 50                  -- a press is held 3 frames, a jump lands after 44, the next press comes at 50
local NAMES = {"P1 Left", "P1 Right", "P1 Up", "P1 Down", "P1 Button 1"}
local mac = manager.machine
local h = io.open(os.getenv("REPLAY")); local id, start, inp = h:read("l"), tonumber(h:read("l")), h:read("l"); h:close()
local out = io.open(os.getenv("OUT"), "w")
local sp, F = nil, {}
local function r(a) return sp:readv_u8(a) end
local function apply(m) for i = 1, 5 do F[i]:set_value((m >> (i - 1)) & 1) end end
local function dead() return r(0x600A) ~= 0x0C or r(0x6200) == 0 or r(0x639D) ~= 0 or r(0x6228) < 3 end
local plans = {}
do
  local moves = {{0, 0}}
  for _, a in ipairs({0, 1, 2}) do for _, w in ipairs({8, 16, 28}) do moves[#moves + 1] = {a, w} end end
  if os.getenv("PLADDER") then for _, w in ipairs({30, 60, 90, 120}) do moves[#moves + 1] = {4, w} end end
  for _, mv in ipairs(moves) do
    plans[#plans + 1] = {a = mv[1], w = mv[2]}
    for _, j1 in ipairs({0, 1, 2}) do
      -- PSTEER: also try holding another direction during the jump (it can't change his path, but it steers barrels)
      local hs = {j1}
      if os.getenv("PSTEER") then for d = 0, 2 do if d ~= j1 then hs[#hs + 1] = d end end end
      for _, h in ipairs(hs) do
        plans[#plans + 1] = {a = mv[1], w = mv[2], j1 = j1, h = h}
        for _, j2 in ipairs({0, 1, 2}) do plans[#plans + 1] = {a = mv[1], w = mv[2], j1 = j1, j2 = j2, h = h} end
      end
    end
  end
end
local function stick(p, t)
  if t < p.w then return p.a end
  if not p.j1 then return 0 end
  local u = t - p.w
  if u < PRESS then return 16 | p.j1 end
  if u < LAND then return (p.h and u < LAND - 4) and p.h or p.j1 end   -- (h: held in the air, let go just before landing)
  if not p.j2 or u < READY then return 0 end
  u = u - READY
  if u < PRESS then return 16 | p.j2 end
  if u < LAND then return p.j2 end
  return 0
end
local stage, f, i, at = "replay", 0, 0, 0
local prints, load_k, base_f = {}, nil, nil
local function print_now()
  local t = {r(0x601A), r(0x6203), r(0x6205)}
  for k = 0, 9 do local a = 0x6700 + 0x20 * k; t[#t + 1] = r(a); t[#t + 1] = r(a + 3); t[#t + 1] = r(a + 5) end
  return table.concat(t, ",")
end
local function restart() apply(load_k and inp:byte(load_k - 1) - 48 or inp:byte(F0) - 48); mac:load("plan" .. id); stage = "loaded" end
emu.register_frame_done(function()
  if not sp then
    local c = mac.devices[":maincpu"]; if not c then return end
    sp = c.spaces["program"]
    local port = mac.ioport.ports[":IN0"]
    for k, n in ipairs(NAMES) do F[k] = port.fields[n] end
    apply(0); mac:load(string.format("%s%03d", os.getenv("START_PREFIX") or "s", start))
    return
  end
  if stage == "replay" then
    f = f + 1
    if f >= F0 - 6 then prints[print_now()] = f end
    if f >= F0 then mac:save("plan" .. id); stage = "saved"; apply(inp:byte(f) - 48); return end
    apply(inp:byte(f) - 48)
  elseif stage == "saved" then
    if f <= F0 + 6 then f = f + 1; prints[print_now()] = f; apply(inp:byte(f) - 48) end
    if f >= F0 + 6 then restart() end
  elseif stage == "loaded" then
    if not load_k then load_k = prints[print_now()] or F0 + 1; restart(); return end
    f = load_k; apply(inp:byte(f) - 48); base_f = load_k; stage = "try"
  elseif stage == "try" then
    f = f + 1
    local p, m = plans[i], 0
    if i == 0 or f < base_f + at then m = (inp:byte(f) or 48) - 48
    else m = stick(p, f - base_f - at) end
    apply(m)
    local gone = dead()
    if gone or f >= DEATH + AFTER then
      if i == 0 then out:write(string.format("check %d %d\n", f, base_f))
      else out:write(string.format("%d %d %d %s %s %s %d %d %d %s\n", base_f + at, p.a, p.w, tostring(p.j1), tostring(p.j2), gone and "dead" or "ok", f, r(0x6203), r(0x6205), tostring(p.h))) end
      out:flush()
      i = i + 1
      if i > #plans then i = 1; at = at + STEP end
      if base_f + at >= DEATH then out:close(); mac:exit(); return end
      restart()
    end
  end
end)
