-- For probe_escape.py and autopsy.py: replays a recorded game to frame F0 and saves there, then tries each move at each later frame.
-- First comes a check: with the recorded inputs he has to die on the recorded frame, or nothing here can be trusted.
local F0, DEATH = tonumber(os.getenv("F0")), tonumber(os.getenv("DEATH"))
local STEP = tonumber(os.getenv("PSTEP") or 2)
local AFTER = 30                 -- he has to still be alive this long after the original death
local NAMES = {"P1 Left", "P1 Right", "P1 Up", "P1 Down", "P1 Button 1"}
local mac = manager.machine
local h = io.open(os.getenv("REPLAY")); local id, start, inp = h:read("l"), tonumber(h:read("l")), h:read("l"); h:close()
local out = io.open(os.getenv("OUT"), "w")
local sp, F = nil, {}
local function r(a) return sp:readv_u8(a) end
local function apply(m) for i = 1, 5 do F[i]:set_value((m >> (i - 1)) & 1) end end
local ACTS = {0, 1, 2, 16, 17, 18}
local stage, f, a_i, at = "replay", 0, 0, 0
local PRESS = 3
local prints = {}
local function dead() return r(0x600A) ~= 0x0C or r(0x6200) == 0 or r(0x639D) ~= 0 or r(0x6228) < 3 end
-- What the machine looks like this frame, to recognise which recorded frame a loaded state has reached.
local function print_now()
  local t = {r(0x601A), r(0x6203), r(0x6205)}
  for k = 0, 9 do local a = 0x6700 + 0x20 * k; t[#t + 1] = r(a); t[#t + 1] = r(a + 3); t[#t + 1] = r(a + 5) end
  return table.concat(t, ",")
end
-- The frame that runs straight after a load uses whatever is held at the time, so that has to be the recorded input.
local load_k
local function restart() apply(load_k and inp:byte(load_k - 1) - 48 or inp:byte(F0) - 48); mac:load("probe" .. id); stage = "loaded" end
emu.register_frame_done(function()
  if not sp then
    local c = mac.devices[":maincpu"]; if not c then return end
    sp = c.spaces["program"]
    local port = mac.ioport.ports[":IN0"]
    for i, n in ipairs(NAMES) do F[i] = port.fields[n] end
    apply(0); mac:load(string.format("s%03d", start))
    return
  end
  if stage == "replay" then
    f = f + 1
    if f >= F0 - 6 then prints[print_now()] = f end
    if f >= F0 then mac:save("probe" .. id); stage = "saved"; apply(inp:byte(f) - 48); return end
    apply(inp:byte(f) - 48)
  elseif stage == "saved" then
    if f <= F0 + 6 then f = f + 1; prints[print_now()] = f; apply(inp:byte(f) - 48) end
    if f >= F0 + 6 then restart() end
  elseif stage == "loaded" then
    if not load_k then
      -- First load: find out which recorded frame a load lands on, then load again holding the right input.
      load_k = prints[print_now()] or F0 + 1
      restart()
      return
    end
    f = load_k; apply(inp:byte(f) - 48); base_f = load_k; stage = "try"
  elseif stage == "try" then
    f = f + 1
    local act, m = ACTS[a_i], 0
    if a_i == 0 or f < base_f + at then m = inp:byte(f) or 48; m = m - 48
    elseif act >= 16 then
      if f < base_f + at + PRESS then m = act else m = act & 3 end     -- press, then hold the direction through the jump
      if f > base_f + at + 41 then m = 0 end
    else m = act end
    apply(m)
    local gone = dead()
    if gone or f >= DEATH + AFTER then
      if a_i == 0 then out:write(string.format("check %d %d\n", f, base_f))
      else out:write(string.format("%d %d %s %d %d %d %d\n", act, base_f + at, gone and "dead" or "ok", f, r(0x6203), r(0x6205), r(0x600A))) end
      out:flush()
      a_i = a_i + 1
      if a_i > #ACTS then a_i = 1; at = at + STEP end
      if base_f + at >= DEATH then out:close(); mac:exit(); return end
      restart()
    end
  end
end)
