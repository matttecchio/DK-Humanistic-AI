-- Replays a recorded game and writes the real screen, from frame FROM until a little after the inputs end, to OUT_RAW.
local mac = manager.machine
local h = io.open(os.getenv("REPLAY")); h:read("l"); local start = tonumber(h:read("l")); local inp = h:read("l"); h:close()
local FROM, AFTER = tonumber(os.getenv("FROM")), tonumber(os.getenv("AFTER"))
local out = io.open(os.getenv("OUT_RAW"), "wb")
local NAMES = {"P1 Left", "P1 Right", "P1 Up", "P1 Down", "P1 Button 1"}
local F, ready, f = {}, false, 0
emu.register_frame_done(function()
  if not ready then
    if not mac.devices[":maincpu"] then return end
    local port = mac.ioport.ports[":IN0"]
    for i, n in ipairs(NAMES) do F[i] = port.fields[n] end
    for i = 1, 5 do F[i]:set_value(0) end
    mac:load(string.format("%s%03d", os.getenv("START_PREFIX") or "s", start))
    ready = true
    return
  end
  f = f + 1
  local m = f <= #inp and inp:byte(f) - 48 or 0
  for i = 1, 5 do F[i]:set_value((m >> (i - 1)) & 1) end
  if f >= FROM then out:write((mac.screens[":screen"]:pixels())) end
  if f > #inp + AFTER then out:close(); mac:exit() end
end)
