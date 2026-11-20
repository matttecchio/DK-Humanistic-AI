-- Scenario drills (Matt, 2026-11-13: "would you learn more from me playing the scenario?"). For each scenario in DRILL (lines
-- "game start_state from_frame death_frame inputs label"), the recorded game is replayed at full speed to from_frame and saved
-- there; then Matt plays from that moment at normal speed (arrows to walk and climb; Q / E / W jump left / right / straight, or Left
-- Ctrl), and every frame's joystick and button is
-- recorded. An attempt ends when he dies, or lives 2 seconds past the original death; it's written to OUT and the same moment is
-- loaded again, ATTEMPTS times; then the next scenario. A countdown shows on screen before each attempt.
local mac = manager.machine
local NAMES = {"P1 Left", "P1 Right", "P1 Up", "P1 Down", "P1 Button 1"}
local ATTEMPTS = tonumber(os.getenv("ATTEMPTS") or 20)   -- the most per scenario; N moves on sooner
local out = io.open(os.getenv("OUT"), "a")
local list = {}
for l in io.lines(os.getenv("DRILL")) do
  local id, st, from, death, inp, label = l:match("^(%d+) (%d+) (%d+) (%d+) (%S+) ?(.*)$")
  if id then list[#list + 1] = {id = id, start = tonumber(st), from = tonumber(from), death = tonumber(death), inp = inp, label = label} end
end
local sp, F, port, held = nil, {}, nil, false
local last, mark, nextsc = nil, nil, false
local k, attempt, stage, f, wait, rec = 1, 0, "boot", 0, 0, {}
local function r(a) return sp:readv_u8(a) end
-- dead: Mario's alive flag goes to 0, or play stops (the mode leaves 0x0C) for more than a few frames in a row
local notplay = 0
local function dead()
  if r(0x600A) ~= 0x0C then notplay = notplay + 1 else notplay = 0 end
  return r(0x6200) == 0 or notplay > 4
end
local function set_all(m) for i = 1, 5 do F[i]:set_value((m >> (i - 1)) & 1) end end
local function release() for i = 1, 5 do F[i]:clear_value() end end
local msg = ""
emu.register_frame_done(function()
  if stage == "boot" then
    if not mac.devices[":maincpu"] then return end
    sp = mac.devices[":maincpu"].spaces["program"]; port = mac.ioport.ports[":IN0"]
    for i, n in ipairs(NAMES) do F[i] = port.fields[n] end
    stage = "load"
  end
  local s = list[k]
  if not s then out:close(); mac:exit(); return end
  if stage == "load" then
    set_all(0); mac.video.throttled = false
    mac:load(string.format("l5_%03d", s.start)); f = 0; stage = "replay"; return
  end
  if stage == "replay" then
    f = f + 1
    set_all(f <= #s.inp and s.inp:byte(f) - 48 or 0)
    if f >= s.from then mac:save("drill_now"); stage = "count"; wait = 0; mac.video.throttled = true end
    return
  end
  if stage == "reload" then mac:load("drill_now"); f = s.from; stage = "count"; wait = 0; set_all(0); return end
  if stage == "count" then
    -- hold the game still for 1.5 s with a countdown; the frame is reloaded each time so nothing moves
    wait = wait + 1
    set_all(0)
    msg = string.format("Scenario %d of %d (%s)  -  attempt %d of %d  -  go in %.1f", k, #list, s.label, attempt + 1, ATTEMPTS, (90 - wait) / 60)
    if wait < 90 then mac:load("drill_now"); return end
    release(); stage = "play"; rec = {}; msg = ""; notplay = 0; return
  end
  if stage == "play" then
    f = f + 1
    -- single keys for the combinations (Matt plays over Jump Desktop, where pressing a second key lets go of the first):
    -- Q jump left, E jump right, W jump straight; arrows still walk and climb
    local kb = mac.input
    local function key(t) local c = kb:code_from_token(t); return c and kb:code_pressed(c) end
    local combo = (key("KEYCODE_Q") and (16 | 1)) or (key("KEYCODE_E") and (16 | 2)) or (key("KEYCODE_W") and 16) or nil
    if combo then set_all(combo); held = true elseif held then release(); held = false end
    local v = port:read()   -- the board's bits (right 1, left 2, up 4, down 8, jump 16) into his recordings' (left 1, right 2, ...)
    rec[#rec + 1] = string.char(48 + (((v & 1) ~= 0) and 2 or 0) + (((v & 2) ~= 0) and 1 or 0) + (v & 0x1C))
    local gone = dead()
    if gone or f > s.death + 120 then
      last = {s.id, s.from, attempt + 1, gone and "died" or "lived", f, table.concat(rec)}
      stage = "judge"; wait = 0; set_all(0)
    end
    return
  end
  -- judge: 2 s after each attempt (the board frozen): G marks it right (the way to play it), N moves on to the next scenario
  if stage == "judge" then
    wait = wait + 1
    local kb = mac.input
    local function key(t) local c = kb:code_from_token(t); return c and kb:code_pressed(c) end
    if key("KEYCODE_G") then mark = "RIGHT" end
    if key("KEYCODE_N") then nextsc = true end
    msg = string.format("%s  -  G: that was right   N: next scenario   %s", last[4] == "died" and "died" or "made it", mark == "RIGHT" and "(marked right)" or "")
    if wait < 120 then return end
    out:write(string.format("%s %d %d %s %s %s %s\n", last[1], last[2], last[3], last[4], last[5], last[6], mark or "-"))
    out:flush()
    mark = nil
    attempt = attempt + 1
    if nextsc or attempt >= ATTEMPTS then attempt = 0; k = k + 1; stage = "load"; nextsc = false else stage = "reload" end
  end
end)
-- the countdown / result line on screen
local scr = mac.screens[":screen"]
emu.register_frame_done(function() if msg ~= "" and scr then scr:draw_text(2, 2, msg, 0xffffff00, 0xff000000) end end)
