-- Plays barrel boards under the human limits and records every game.
-- MODE=batch  plays games START_ID, START_ID+STEP... at full speed, appending to OUT
-- MODE=live   plays endlessly for the website
-- MODE=replay feeds a recorded game's inputs back for the website, or VERIFY's output
local HOME = os.getenv("DKH")
local MODE = os.getenv("MODE") or "batch"
local P = dofile(HOME .. "/lua/policy.lua")
local params = dofile(os.getenv("PARAMS") or (HOME .. "/lua/params.lua"))
for k, v in pairs(params.levels and params.levels[tonumber(os.getenv("LEVEL") or 1)] or {}) do params[k] = v end   -- what suits this level only
local NSTARTS = tonumber(os.getenv("NSTARTS") or 64)
local ID, STEP, LAST = tonumber(os.getenv("START_ID") or 0), tonumber(os.getenv("STEP") or 1), tonumber(os.getenv("LAST") or 0)
local OUT = os.getenv("OUT")
local LIVE = os.getenv("LIVE")
local GRID = os.getenv("GRID")     -- when set, publish positions about 10 times a second for the website
local WORKER = os.getenv("WORKER") or "0"
local GRID_EVERY = tonumber(os.getenv("GRID_EVERY") or 0.016)   -- seconds of CPU time between position updates

-- Human limits: what's seen is 8-9 frames (133-150 ms) old, and inputs land 0-1 frames late.
-- react = {min, max} frames (params, per level): Matt allowed 30 ms (2 frames) on the barrel boards (2026-11-08); otherwise 8-9
local DELAY_MIN, DELAY_MAX = tonumber(os.getenv("DELAY_MIN") or (params.react and params.react[1]) or 8), tonumber(os.getenv("DELAY_MAX") or (params.react and params.react[2]) or 9)   -- (DELAY_MIN / DELAY_MAX: only to measure what a quicker reaction would be worth)
local MAX_FRAMES = 11000

local mac = manager.machine
local sp, F = nil, {}
local NAMES = {"P1 Left", "P1 Right", "P1 Up", "P1 Down", "P1 Button 1"}
local function r(a) return sp:readv_u8(a) end
local function bcd(v) return (v >> 4) * 10 + (v & 15) end
-- points earned on this board: skipping to a later level leaves points behind, and changing them in memory would change the game
local score_base = 0
local function score() return bcd(r(0x60B4)) * 10000 + bcd(r(0x60B3)) * 100 + bcd(r(0x60B2)) - score_base end
local function apply(m) for i = 1, 5 do F[i]:set_value((m >> (i - 1)) & 1) end end

local function observe()
  local o = {x = r(0x6203), y = r(0x6205), lad = r(0x6215), jmp = r(0x6216), ham = r(0x6217), kong = r(0x690D), t = r(0x62B1), oil = r(0x6348), fc = r(0x601A), hamtop = (r(0x6680) == 1 and r(0x6681) == 0) and 1 or 0, face = (r(0x6207) >= 0x80) and 1 or -1, b = {}, f = {}}   -- oil: the drum is alight (its flames are on screen)
  for k = 0, 9 do
    local a = 0x6700 + 0x20 * k
    if r(a) & 1 == 1 then o.b[#o.b + 1] = {k = k, x = r(a + 3), y = r(a + 5), d = r(a + 2), c = r(a + 1), blue = r(a + 21)} end
  end
  for k = 0, 4 do
    local a = 0x6400 + 0x20 * k
    if r(a) & 1 == 1 then o.f[#o.f + 1] = {k = k, x = r(a + 3), y = r(a + 5)} end
  end
  return o
end

local function cause_of_death(o)
  -- Whatever is actually touching him: inside the measured collision box, nearest first.
  local best, kind = 1e9, "none"
  local function check(list, name, bx, by)
    for _, h in ipairs(list) do
      local dx, dy = math.abs(h.x - o.x), math.abs(h.y - o.y)
      if dx <= bx and dy <= by and dx + dy < best then
        best, kind = dx + dy, h.c == 1 and "wild barrel" or name
      end
    end
  end
  check(o.b, "barrel", 7, 9)
  check(o.f, "fireball", 9, 11)
  if kind == "none" then kind = "fall_or_unknown" end
  local doing = o.lad ~= 0 and "ladder" or (o.jmp ~= 0 and "jumping" or "walking")
  if o.ham ~= 0 then doing = doing .. " with hammer" end
  return kind, doing, best
end

local g        -- the current game
local function new_game(id)
  math.randomseed(id * 7919 + 13)
  g = {id = id, start = id % NSTARTS, f = 0, hist = {}, seen = 0, delay = DELAY_MIN, delay_for = 0,
       cur = 0, pending = nil, pending_at = 0, inp = {}, floors = {}, top = 1, at = 1, hash = 5381, lastobs = nil,
       c = P.new(params), maxgap = 0}
  apply(0)
  mac:load(string.format("%s%03d", os.getenv("START_PREFIX") or "s", g.start))
end

local SCEN
local function new_scen(i)   -- row i (from 0) of SCEN: g.id becomes the row
  local r = SCEN[i + 1]
  new_game(r[1])
  g.force, g.force_until, g.reseed, g.id = r[4], r[2], r[1] * 131 + r[3] * 7919 + r[2], i
  g.force_plan = r[5]
end

local function finish(outcome, fields)
  local o = g.lastobs or {x = 0, y = 0, lad = 0, jmp = 0, ham = 0, t = 0, b = {}, f = {}}
  local kind, doing, near = cause_of_death(o)
  if outcome == "clear" then kind, doing = "", "" end
  local fl = {}; for i = 1, 6 do fl[i] = tostring(g.floors[i] or -1) end
  local line = string.format('{"id":%d,"start":%d,"outcome":"%s","score":%d,"play":%d,"timer":%d,"frames":%d,"floor":%d,"cause":"%s","doing":"%s","near":%d,"x":%d,"y":%d,"bars":%d,"fires":%d,"hash":%d,"floors":[%s],"at":%d,"inp":"%s","rules":"%s"}\n',
    g.id, g.start, outcome, fields.score, fields.play, fields.t, g.f, g.top, kind, doing, near == 1e9 and -1 or near, o.x, o.y, #o.b, #o.f, g.hash, table.concat(fl, ","), g.at, os.getenv("NO_INPUTS") and "" or table.concat(g.inp), table.concat(g.c.fired or {}, ";"))
  if OUT then local f = io.open(OUT, "a"); f:write(line); f:close() end
  return line
end

local rep, frame_no = nil, 0
local function write_frame(label)
  frame_no = frame_no + 1
  if frame_no % 2 ~= 0 then return end
  local px = mac.screens[":screen"]:pixels()
  local h = io.open(LIVE .. "/frame.tmp", "wb"); h:write(px); h:close(); os.rename(LIVE .. "/frame.tmp", LIVE .. "/frame.raw")
  local o = g.lastobs
  if o then
    local s = io.open(LIVE .. "/state.tmp", "w")
    s:write(string.format('{"mode":"%s","id":%d,"frame":%d,"score":%d,"timer":%d,"floor":%d,"x":%d,"y":%d,"delay":%d,"bars":%d,"fires":%d,"label":"%s"}',
      MODE, g.id, g.f, score(), o.t * 100, P.floor(o.y), o.x, o.y, (g.delay or 0) * 1000 // 60, #o.b, #o.f, label or ""))
    s:close(); os.rename(LIVE .. "/state.tmp", LIVE .. "/state.json")
  end
end

local grid_t, played, cleared, last_out = 0, 0, 0, ""
local function publish(o)
  local now = os.clock()
  if now - grid_t < GRID_EVERY then return end
  grid_t = now
  local bs, fs = {}, {}
  for i, b in ipairs(o.b) do bs[i] = "[" .. b.x .. "," .. b.y .. "," .. b.blue .. "," .. b.c .. "]" end
  for i, f in ipairs(o.f) do fs[i] = "[" .. f.x .. "," .. f.y .. "]" end
  local h = io.open(GRID .. "/" .. WORKER .. ".tmp", "w")
  if not h then return end   -- the website missing an update must never stop a game
  h:write(string.format('{"w":%s,"id":%d,"frame":%d,"score":%d,"timer":%d,"level":%d,"floor":%d,"x":%d,"y":%d,"ham":%d,"played":%d,"cleared":%d,"last":"%s","b":[%s],"f":[%s]}',
    WORKER, g.id, g.f, score(), o.t * 100, r(0x6229), P.floor(o.y), o.x, o.y, o.ham, played, cleared, last_out, table.concat(bs, ","), table.concat(fs, ",")))
  h:close(); os.rename(GRID .. "/" .. WORKER .. ".tmp", GRID .. "/" .. WORKER .. ".json")
end

local function play_frame()
  g.f = g.f + 1
  local mode = r(0x600A)
  local o = observe()
  if mode == 0x0C and r(0x6200) ~= 0 then g.lastobs = o end
  if LIVE then write_frame() end
  if GRID then publish(o) end
  local gone = mode ~= 0x0C or r(0x6200) == 0 or r(0x639D) ~= 0 or r(0x6228) < 3
  if mode == 0x16 then return "clear" end
  if gone then return o.t == 0 and "timeout" or "died" end
  if g.f > MAX_FRAMES then return "stuck" end

  local fl = P.floor(o.y)
  if o.jmp == 0 then    -- a jump can rise past the line between floors without reaching the one above
    g.at = fl
    if fl > g.top then g.top = fl end
    if not g.floors[fl] then g.floors[fl] = g.f end
  end
  if g.f <= 1500 then for _, b in ipairs(o.b) do g.hash = (g.hash * 33 + b.x * 256 + b.y) % 2147483647 end end

  -- what the player gets to see: an older frame, and never going backwards in time
  g.hist[g.f] = o; g.hist[g.f - 40] = nil
  g.delay_for = g.delay_for - 1
  if g.delay_for <= 0 then g.delay = math.random(DELAY_MIN, DELAY_MAX); g.delay_for = math.random(15, 45) end
  g.seen = math.max(g.seen, g.f - g.delay)
  local want = 0
  local seen = g.hist[g.seen]
  if seen then seen.now = {x = o.x, y = o.y, lad = o.lad, jmp = o.jmp, fc = o.fc, face = o.face}; want = g.c.decide(seen, g.f, g.f - g.seen) end   -- now: where Mario really is (only used with know_self)

  -- what they want lands 0-1 frames late
  if want ~= g.cur and want ~= g.pending then g.pending = want; g.pending_at = g.f + math.random(0, 1) end
  if g.pending and g.f >= g.pending_at then g.cur = g.pending; g.pending = nil end
  -- MODE=scenario: the recorded game's own inputs up to the takeover, his decisions after (he has watched it all, so he's warmed up)
  if g.force then
    if g.f < g.force_until then g.cur = g.force:byte(g.f) - 48; g.pending = nil
    elseif g.f == g.force_until then
      math.randomseed(g.reseed)
      if g.force_plan then g.c.script = {p = g.force_plan, f0 = g.f + 1, src = "tried"} end
    end
  end
  apply(g.cur)
  g.inp[g.f] = string.char(48 + g.cur)
  return nil
end

local function replay_frame()
  g.f = g.f + 1
  local mode = r(0x600A)
  local o = observe()
  if mode == 0x0C and r(0x6200) ~= 0 then g.lastobs = o end
  if LIVE then write_frame("replay of game " .. rep.id) end
  if mode == 0x16 then return "clear" end
  if mode ~= 0x0C or r(0x6200) == 0 or r(0x639D) ~= 0 or r(0x6228) < 3 then return o.t == 0 and "timeout" or "died" end
  if g.f > #rep.inp then return "stuck" end
  apply(rep.inp:byte(g.f) - 48)
  return nil
end

local tail = 0
emu.register_frame_done(function()
  if not sp then
    local c = mac.devices[":maincpu"]; if not c then return end
    sp = c.spaces["program"]
    local port = mac.ioport.ports[":IN0"]
    for i, n in ipairs(NAMES) do F[i] = port.fields[n] end
    if MODE == "scenario" then
      -- SCEN: one "game_id takeover_frame trial inputs" per line; rows START_ID, START_ID+STEP, ... up to LAST
      SCEN = {}
      for l in io.lines(os.getenv("SCEN")) do
        local a, b, c, d, rest = l:match("(%d+) (%d+) (%d+) (%S+)(.*)")
        -- optional "a w j1 j2 h": a move he makes at the takeover (then plays on himself)
        local pa, pw, pj1, pj2, ph = rest:match("(%d+) (%d+) (%S+) (%S+) (%S+)")
        local plan = pa and {a = tonumber(pa), w = tonumber(pw), j1 = tonumber(pj1), j2 = tonumber(pj2), h = tonumber(ph)} or nil
        SCEN[#SCEN + 1] = {tonumber(a), tonumber(b), tonumber(c), d, plan}
      end
      new_scen(ID)
      return
    end
    if MODE == "replay" then
      local h = io.open(os.getenv("REPLAY")); rep = {id = tonumber(h:read("l")), start = tonumber(h:read("l")), inp = h:read("l")}; h:close()
      new_game(rep.id)
    else
      new_game(ID)
    end
    return
  end
  if tail > 0 then   -- let the end of a watched game play out
    tail = tail - 1
    if LIVE then write_frame("game over") end
    if tail == 0 then
      if MODE == "replay" then mac:exit(); return end
      ID = ID + 1; new_game(ID)
    end
    return
  end
  local out
  if g.f == 0 then score_base = 0; score_base = score() end
  if MODE == "replay" then out = replay_frame() else out = play_frame() end
  if not out then return end
  local s = score()
  local t = g.lastobs and g.lastobs.t or 0
  local fields = {score = out == "clear" and s + 100 * r(0x62B1) or s, play = s, t = out == "clear" and r(0x62B1) or t}
  finish(out, fields)
  played = played + 1; if out == "clear" then cleared = cleared + 1 end; last_out = out
  if MODE == "batch" then
    ID = ID + STEP
    if ID > LAST then mac:exit(); return end
    new_game(ID)
  elseif MODE == "scenario" then
    ID = ID + STEP
    if ID > LAST then mac:exit(); return end
    new_scen(ID)
  else
    apply(0); tail = 120
  end
end)
