local mac = manager.machine
local sp, F, n, phase, jf = nil, {}, 0, "walk", 0
local NAMES = {"P1 Left", "P1 Right", "P1 Up", "P1 Down", "P1 Button 1"}
local function apply(m) for i = 1, 5 do F[i]:set_value((m >> (i - 1)) & 1) end end
local START = tonumber(os.getenv("WALL_START") or 30)
emu.register_frame_done(function()
  if not sp then
    sp = mac.devices[":maincpu"].spaces["program"]
    local port = mac.ioport.ports[":IN0"]
    for i, nm in ipairs(NAMES) do F[i] = port.fields[nm] end
    apply(0); mac:load("s000"); return
  end
  n = n + 1
  local x, y, j = sp:readv_u8(0x6203), sp:readv_u8(0x6205), sp:readv_u8(0x6216)
  if phase == "walk" then
    apply(1)
    if x <= START then phase = "jump"; jf = n end
  elseif phase == "jump" then
    apply(n - jf < 3 and 17 or 1)
    print(string.format("t=%d x=%d y=%d jumping=%d", n - jf, x, y, j))
    if n - jf > 110 then mac:exit() end
  end
  if n > 2000 then mac:exit() end
end)
