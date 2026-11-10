-- replays a recorded game to frame F0, then plays it out twice: as recorded, and pressing RIGHT from F0 for N frames.
-- Prints the given barrel slot's x over the next frames for both.
local mac = manager.machine
local h = io.open(os.getenv("REPLAY")); h:read("l"); local start = tonumber(h:read("l")); local inp = h:read("l"); h:close()
local F0, N, SLOT = tonumber(os.getenv("F0")), tonumber(os.getenv("NPRESS")), tonumber(os.getenv("SLOT"))
local sp, F, f, stage, out = nil, {}, 0, "replay", {}
local NAMES = {"P1 Left", "P1 Right", "P1 Up", "P1 Down", "P1 Button 1"}
local function apply(m) for i = 1, 5 do F[i]:set_value((m >> (i - 1)) & 1) end end
local variant = 0
emu.register_frame_done(function()
  if not sp then
    sp = mac.devices[":maincpu"].spaces["program"]
    local port = mac.ioport.ports[":IN0"]
    for i, n in ipairs(NAMES) do F[i] = port.fields[n] end
    apply(0); mac:load(string.format("%s%03d", os.getenv("START_PREFIX"), start)); return
  end
  f = f + 1
  local m = (inp:byte(f) or 48) - 48
  if f >= F0 and variant == 1 and f < F0 + N then m = tonumber(os.getenv("ALT") or 2) end
  apply(m)
  if f >= F0 + 34 and f <= F0 + 80 and (f - F0) % 6 == 0 then
    local a = 0x6700 + 0x20 * SLOT
    out[#out + 1] = string.format("%d:%d,%d M%d", f - F0, sp:readv_u8(a + 3), sp:readv_u8(a + 5), sp:readv_u8(0x6203))
  end
  if f == F0 + 80 then
    print((variant == 0 and "as recorded  " or "changed      ") .. table.concat(out, " "))
    if variant == 1 then mac:exit(); return end
    variant = 1; out = {}; f = 0; apply(0); mac:load(string.format("%s%03d", os.getenv("START_PREFIX"), start))
  end
end)
