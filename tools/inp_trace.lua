-- inp_trace.lua: passive logger for -playback of a player's .inp (Matt, 2026-11-10: learn from top players' recordings, every
-- barrel board from level 5 on). Changes nothing. On barrel boards (0x6227 = 1) at level >= MINLEVEL (env, default 5), one line
-- per frame in the same layout as tools/autopsy.py's traces, plus the joystick and button and Mario's facing:
--   board-id frame x y lad jmp ham face in0 | B k x y d c | ... | F k x y 0 0 | ... | K pose held fc | H top taken
-- "start level L board B lives N score S frame F" each time play starts on any board (so whether a barrel board ended in a
-- death shows from the next start's lives), "board <id> ..." when a traced barrel board starts, "end <id> score <s>" when play stops.
local mac = manager.machine
local OUT = io.open(os.getenv("TRACE"), "w")
local MINLEVEL = tonumber(os.getenv("MINLEVEL") or 5)
local sp, n, pm, id, on, kp, kpf = nil, 0, nil, 0, false, nil, 0
local function r(a) return sp:readv_u8(a) end
local function bcd(v) return (v >> 4) * 10 + (v & 15) end
local function score() return bcd(r(0x60B4)) * 10000 + bcd(r(0x60B3)) * 100 + bcd(r(0x60B2)) end
local in0
emu.register_frame_done(function()
  if not sp then
    local c = mac.devices[":maincpu"]; if not c then return end
    sp = c.spaces["program"]; in0 = mac.ioport.ports[":IN0"]
  end
  n = n + 1
  local m = r(0x600A)
  if m == 0x0C and pm ~= 0x0C then
    OUT:write(string.format("start level %d board %d lives %d score %d frame %d\n", r(0x6229), r(0x6227), r(0x6228), score(), n))
    on = r(0x6227) == 1 and r(0x6229) >= MINLEVEL
    if on then id = id + 1; OUT:write(string.format("board %d level %d score %d frame %d\n", id, r(0x6229), score(), n)) end
  end
  if on and m ~= 0x0C then
    OUT:write(string.format("end %d score %d frame %d\n", id, score(), n))
    on = false
  end
  pm = m
  if not on then return end
  local kong = r(0x690D)
  if kong ~= kp then kp = kong; kpf = n end
  local p = {string.format("%d %d %d %d %d %d %d %d %d", id, n, r(0x6203), r(0x6205), r(0x6215), r(0x6216), r(0x6217),
    r(0x6207) >= 0x80 and 1 or -1, in0 and in0:read() or 0)}
  for k = 0, 9 do
    local a = 0x6700 + 0x20 * k
    if r(a) & 1 == 1 then p[#p + 1] = string.format("B%d %d %d %d %d", k, r(a + 3), r(a + 5), r(a + 2), r(a + 1)) end
  end
  for k = 0, 4 do
    local a = 0x6400 + 0x20 * k
    if r(a) & 1 == 1 then p[#p + 1] = string.format("F%d %d %d 0 0", k, r(a + 3), r(a + 5)) end
  end
  p[#p + 1] = string.format("K %d %d %d", kong, n - kpf, r(0x601A))
  p[#p + 1] = string.format("H %d %d", r(0x6680), r(0x6681))
  OUT:write(table.concat(p, "|"), "\n")
end)
emu.add_machine_stop_notifier(function() if on then OUT:write(string.format("end %d score %d frame %d\n", id, score(), n)) end; OUT:close() end)
