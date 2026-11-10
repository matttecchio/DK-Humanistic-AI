-- replays a recorded game and prints the difficulty ($6380), oil flag ($6348) and bonus timer ($62B1) as it goes
local mac = manager.machine
local h = io.open(os.getenv("REPLAY")); h:read("l"); local start = tonumber(h:read("l")); local inp = h:read("l"); h:close()
local sp, F, f, last = nil, {}, 0, ""
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
  local s = string.format("difficulty %d oil %d", sp:readv_u8(0x6380), sp:readv_u8(0x6348))
  if s ~= last then print(string.format("frame %d timer %d: %s", f, sp:readv_u8(0x62B1), s)); last = s end
  if f > #inp + 5 then mac:exit() end
end)
