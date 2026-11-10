-- replays a recorded game and prints the game mode, alive flag and Mario/Kong state over its last frames
local mac = manager.machine
local h = io.open(os.getenv("REPLAY")); h:read("l"); local start = tonumber(h:read("l")); local inp = h:read("l"); h:close()
local sp, F, f = nil, {}, 0
local NAMES = {"P1 Left", "P1 Right", "P1 Up", "P1 Down", "P1 Button 1"}
local function apply(m) for i = 1, 5 do F[i]:set_value((m >> (i - 1)) & 1) end end
emu.register_frame_done(function()
  if not sp then
    sp = mac.devices[":maincpu"].spaces["program"]
    local port = mac.ioport.ports[":IN0"]
    for i, n in ipairs(NAMES) do F[i] = port.fields[n] end
    apply(0); mac:load(string.format("%s%03d", os.getenv("START_PREFIX"), start)); return
  end
  f = f + 1
  apply((inp:byte(f) or 48) - 48)
  if f >= #inp - 6 then
    print(string.format("frame %d mode %02X alive %d 639D %d lives %d mario %d,%d timer %d", f, sp:readv_u8(0x600A), sp:readv_u8(0x6200), sp:readv_u8(0x639D), sp:readv_u8(0x6228), sp:readv_u8(0x6203), sp:readv_u8(0x6205), sp:readv_u8(0x62B1)))
  end
  if f > #inp + 3 then mac:exit() end
end)
