-- replays a game to F0 (= landing - 40), then holds LEFT, except RIGHT during frames [A, B) relative to F0. Prints the barrel after landing.
local mac = manager.machine
local h = io.open(os.getenv("REPLAY")); h:read("l"); local start = tonumber(h:read("l")); local inp = h:read("l"); h:close()
local F0, A, B, SLOT = tonumber(os.getenv("F0")), tonumber(os.getenv("A")), tonumber(os.getenv("B")), tonumber(os.getenv("SLOT"))
local sp, F, f, out = nil, {}, 0, {}
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
  local m = (inp:byte(f) or 48) - 48
  if f >= F0 then local r = f - F0; m = (r >= A and r < B) and 2 or tonumber(os.getenv("BASE") or 1) end
  apply(m)
  if f == F0 + 64 then local a = 0x6700 + 0x20 * SLOT; print(string.format("%d %d", sp:readv_u8(a + 3), sp:readv_u8(a + 5))); mac:exit() end
end)
