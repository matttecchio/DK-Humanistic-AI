-- Plays barrel boards under the human limits and records every game.
-- MODE=batch  plays games START_ID, START_ID+STEP... at full speed, appending to OUT
-- MODE=live   plays endlessly for the website
-- MODE=replay feeds a recorded game's inputs back for the website, or VERIFY's output
local HOME = os.getenv("DKH")
local MODE = os.getenv("MODE") or "batch"
RIV = nil   -- set below, once HOME is known
local P = dofile(HOME .. "/lua/policy.lua")
RIV = dofile(HOME .. "/lua/rivets.lua")   -- the rivet board's player
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

FIREF = os.getenv("FIRELOG") and io.open(os.getenv("FIRELOG") .. "/fl_" .. (os.getenv("WORKER") or "0") .. ".txt", "a")
RNGF = os.getenv("RNGLOG") and io.open(os.getenv("RNGLOG") .. "/r_" .. (os.getenv("WORKER") or "0") .. ".txt", "a")
HAMF = os.getenv("HAMLOG") and io.open(os.getenv("HAMLOG") .. "/h_" .. (os.getenv("WORKER") or "0") .. ".txt", "a")
FEATF = os.getenv("FEATLOG") and io.open(os.getenv("FEATLOG") .. "/f_" .. (os.getenv("WORKER") or "0") .. ".txt", "a")
local function observe()
  local o = {x = r(0x6203), y = r(0x6205), lad = r(0x6215), jmp = r(0x6216), ham = r(0x6217), kong = r(0x690D), t = r(0x62B1), oil = r(0x6348), fc = r(0x601A), hamtop = (r(0x6680) == 1 and r(0x6681) == 0) and 1 or 0, face = (r(0x6207) >= 0x80) and 1 or -1, hcnt = r(0x6394), hleft = (2 - r(0x6395)) * 256 - r(0x6394), board = r(0x6227), rivets_left = r(0x6290), ham_mid = (r(0x6690) == 1 and r(0x6691) == 0) and 1 or 0, ham_left = (r(0x6680) == 1 and r(0x6681) == 0) and 1 or 0, b = {}, f = {}}   -- oil: the drum is alight (its flames are on screen)
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
       c = P.new(params), rc = RIV.new(params), maxgap = 0}
  apply(0)
  mac:load(string.format("%s%03d", os.getenv("START_PREFIX") or "s", g.start))
  if SEARCH then
    mac:search_on(true, tonumber(os.getenv("SEARCH_H") or 120), tonumber(os.getenv("SEARCH_BUDGET") or 600))
    local rx = {}; for fl = 1, 6 do rx[fl] = P.ROUTE[fl].x end; mac:search_route(rx)
  end
end

local SCEN
local function new_scen(i)   -- row i (from 0) of SCEN: g.id becomes the row
  local r = SCEN[i + 1]
  new_game(r[1])
  g.force, g.force_until, g.reseed, g.id = r[4], r[2], r[1] * 131 + r[3] * 7919 + r[2], i
  g.trial = r[3]
  g.force_plan = r[5]
  g.rforce = r[6]
end

local function finish(outcome, fields)
  local o = g.lastobs or {x = 0, y = 0, lad = 0, jmp = 0, ham = 0, t = 0, b = {}, f = {}}
  local kind, doing, near = cause_of_death(o)
  if outcome == "clear" then kind, doing = "", "" end
  local fl = {}; for i = 1, 6 do fl[i] = tostring(g.floors[i] or -1) end
  local line = string.format('{"id":%d,"start":%d,"outcome":"%s","score":%d,"play":%d,"timer":%d,"frames":%d,"floor":%d,"cause":"%s","doing":"%s","near":%d,"x":%d,"y":%d,"bars":%d,"fires":%d,"hash":%d,"floors":[%s],"at":%d,"inp":"%s","rules":"%s"}\n',
    g.id, g.start, outcome, fields.score, fields.play, fields.t, g.f, g.top, kind, doing, near == 1e9 and -1 or near, o.x, o.y, #o.b, #o.f, g.hash, table.concat(fl, ","), g.at, os.getenv("NO_INPUTS") and "" or table.concat(g.inp), table.concat(g.c.fired or {}, ";"))
  if o.board == 4 then line = line:sub(1, -3) .. string.format(',"rivets_left":%d,"riv_why":"%s","pulled":"%s","ham_at":"%s"}\n', o.rivets_left or -1, (g.rc.why or ""):gsub('"', ""), (g.rc.pulled or ""), (g.rc.ham_at or "")) end
  if g.take then line = line:sub(1, -3) .. string.format(',"take":"%s","take_rng":%d}\n', g.take, g.take_rng) end
  if fields.search_frames then line = line:sub(1, -3) .. string.format(',"unchecked":%d,"search_dead":%d,"search_frames":%d,"backs":%d}\n', fields.unchecked, fields.search_dead, fields.search_frames, fields.backs) end
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
  -- the board (0x6227: 1 barrels, 4 rivets) and, on the rivets, which are still in (read from the tile map: 0xb7 at each rivet's
  -- tile; the map is mirrored, game column c is tile column 31 - c)
  -- the hammer he's holding, where the game has it (0x6680 / 0x6690: x, y), and whether it's down (beside him at his height)
  local hm = ""
  for _, a in ipairs({0x6680, 0x6690}) do
    if r(a) == 1 and r(a + 1) == 1 then hm = string.format("%d,%d,%d", r(a + 3), r(a + 5), (r(a + 5) >= o.y - 2) and 1 or 0) end
  end
  local rv, it = {}, {}
  if r(0x6227) == 4 then
    for _, row in ipairs({26, 21, 16, 11}) do for _, col in ipairs({9, 22}) do rv[#rv + 1] = (r(0x7400 + (31 - col) * 32 + row) == 0xb7) and 1 or 0 end end
    -- the board's items (0x6A0C: hat, handbag, umbrella, then the two hammers; x, picture, colour, y each): still there while
    -- its picture is the one it started with
    for i, code in ipairs({0x73, 0x74, 0x75}) do local a = 0x6A0C + 4 * (i - 1); it[i] = (r(a) ~= 0 and r(a + 1) == code) and 1 or 0 end
    it[4] = (r(0x6680) == 1 and r(0x6681) == 0) and 1 or 0   -- the hammers: on their stands, not held (0x6680 / 0x6690)
    it[5] = (r(0x6690) == 1 and r(0x6691) == 0) and 1 or 0
  end
  h:write(string.format('{"w":%s,"id":%d,"frame":%d,"score":%d,"timer":%d,"level":%d,"floor":%d,"x":%d,"y":%d,"ham":%d,"played":%d,"cleared":%d,"last":"%s","board":%d,"rv":[%s],"it":[%s],"hm":[%s],"b":[%s],"f":[%s]}',
    WORKER, g.id, g.f, score(), o.t * 100, r(0x6229), P.floor(o.y), o.x, o.y, o.ham, played, cleared, last_out, r(0x6227), table.concat(rv, ","), table.concat(it, ","), hm, table.concat(bs, ","), table.concat(fs, ",")))
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
  -- CHAIN (2026-11-15): a clear of the barrel board carries on into the next board as the same game (one input record from the
  -- 1-1 start, so it replays in MAME); the board between is waited out with no input
  if CHAIN and (g.transit or (mode == 0x16 and o.board == 1)) then
    if not g.transit then g.transit = true; if SEARCH then mac:search_on(false) end end
    if mode == 0x0C and r(0x6200) ~= 0 and r(0x6227) ~= 1 then g.transit = nil; g.chained = r(0x6227); g.c.f_offset = g.f
    else g.cur = 0; apply(0); g.inp[g.f] = "0"; return nil end
  end
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
  if LOOK then g.c.cands = {}; g.c.dirn_now = nil end
  -- the rivet board has its own player (lua/rivets.lua); the barrel planner everywhere else
  if seen and o.board == 4 then seen.now = {x = o.x, y = o.y, lad = o.lad, jmp = o.jmp, fc = o.fc, face = o.face}; want = g.rc.decide(seen, g.f, g.f - g.seen); g.c.why = "rivets: " .. g.rc.why
    local rf = g.rforce
    if rf and rf.from and g.f >= rf.from and g.f <= rf.till then
      local inp, from = rf.inp, rf.from
      if rf.seq then
        local t = g.f - rf.from
        for _, q in ipairs(rf.seq) do if t < q.n then inp = q.inp; break end; t = t - q.n; from = from + q.n end
      end
      want = (inp & 16 ~= 0) and ((g.f < from + 3) and inp or 0) or inp
      g.rc.why = "forced (review)"
    end
    if os.getenv("RIVDBG") and (g.f % 15 == 0 or os.getenv("RIVDBG") == "all") then local t = {}; for _, fb in ipairs(o.f) do t[#t + 1] = fb.x .. "," .. fb.y end; local gn = {}; for k in pairs(g.rc.gone) do gn[#gn + 1] = k end; table.sort(gn); io.stderr:write(string.format("RIV f=%d x=%d y=%d lad=%d left=%d gone=%s want=%d why=%s fires=%s\n", g.f, o.x, o.y, o.lad, o.rivets_left, table.concat(gn, ","), want, g.rc.why, table.concat(t, " "))) end
  elseif seen then seen.now = {x = o.x, y = o.y, lad = o.lad, jmp = o.jmp, fc = o.fc, face = o.face}; want = g.c.decide(seen, g.f, g.f - g.seen) end   -- now: where Mario really is (only used with know_self)
  if os.getenv("DBGHAM") and (o.ham ~= 0 or g.c.grab_on) then io.stderr:write(string.format("OUT f=%d x=%d want=%d why=%s\n", g.f, o.x, want, tostring(g.c.why))) end
  -- FEATLOG (dir, 2026-11-13: learning danger from his own games): every 4 frames, where Mario really is, the barrels as the game has
  -- them, and his planner's score for its best plan; one file per worker. Changes nothing about play.
  -- HAMLOG (2026-11-14, the hammer in the planner): every frame he holds a hammer, Mario (x, y, 0x6207 facing / sprite), the held
  -- hammer's object (x, y, box w, h, sprite byte) and every barrel's (x, y, box w, h, 0x6350 smash flag). Changes nothing about play.
  -- RNGLOG (2026-11-14, the all-knowing mode): every frame the game's random number (0x6018), 0x6019, the frame counter (0x601A),
  -- the stick as the game read it (0x6010), and each barrel (slot, x, y, state byte 2, 7)
  -- FIRELOG (2026-11-15, checking the rivet safety map): on the rivet board, every 4 frames: Mario and every fireball (slot, x, y),
  -- the rivets still in (tile map) and the hammer
  if os.getenv("DIFFDBG") and g.f % 120 == 0 and r(0x6227) == 4 then io.stderr:write(string.format("DIFF f=%d 6380=%d 62B1=%d\n", g.f, r(0x6380), r(0x62B1))) end
  if os.getenv("DEATHDBG") and g.f >= tonumber(os.getenv("DEATHDBG")) then
    io.stderr:write(string.format("DD f=%d mario x=%d y=%d alive=%d 6216=%d 600A=%d 6290=%d timer=%d/%d sprites:", g.f, r(0x6203), r(0x6205), r(0x6200), r(0x6216), r(0x600A), r(0x6290), r(0x62B0), r(0x62B1)))
    for a0 = 0x6900, 0x69FC, 4 do if r(a0) ~= 0 then io.stderr:write(string.format(" %02x:%d,%d,%d", a0 - 0x6900, r(a0), r(a0 + 1), r(a0 + 3))) end end
    io.stderr:write("\n")
  end
  if FIREF and r(0x6227) == 4 and g.f % 4 == 0 then
    local t = {string.format("%d %d %d %d %d %d", g.id, g.f, r(0x6203), r(0x6205), r(0x6217), r(0x6290))}
    local rv = {}
    for _, row in ipairs({26, 21, 16, 11}) do for _, col in ipairs({9, 22}) do rv[#rv + 1] = (r(0x7400 + (31 - col) * 32 + row) == 0xb7) and "1" or "0" end end
    t[#t + 1] = table.concat(rv)
    for k = 0, 4 do local a0 = 0x6400 + 0x20 * k; if r(a0) & 1 == 1 then t[#t + 1] = string.format("%d %d %d", k, r(a0 + 3), r(a0 + 5)) end end
    FIREF:write(table.concat(t, "|"), "\n")
  end
  if RNGF then
    local t = {string.format("%d %d %d %d %d %d", g.id, g.f, r(0x6018), r(0x6019), r(0x601A), r(0x6010))}
    for k = 0, 9 do
      local a0 = 0x6700 + 32 * k
      if r(a0) & 1 == 1 then t[#t + 1] = string.format("%d %d %d %d %d", k, r(a0 + 3), r(a0 + 5), r(a0 + 2), r(a0 + 7)) end
    end
    RNGF:write(table.concat(t, "|"), "\n")
  end
  if HAMF and (r(0x6217) ~= 0 or r(0x6218) ~= 0 or (r(0x6216) ~= 0 and r(0x6203) < 60 and r(0x6205) > 80 and r(0x6205) < 120)) then
    local t = {string.format("%d %d %d %d %d %d %d %d %d %d", g.id, g.f, r(0x6203), r(0x6205), r(0x6207), r(0x6217), r(0x6350), r(0x6216), r(0x6394), r(0x6395)) .. " " .. (g.cur or 0)}
    for k = 0, 1 do
      local a0 = 0x6680 + 16 * k
      t[#t + 1] = string.format("H%d %d %d %d %d %d %d %d", k, r(a0), r(a0 + 1), r(a0 + 3), r(a0 + 5), r(a0 + 9), r(a0 + 10), r(a0 + 7))
    end
    for k = 0, 9 do
      local a0 = 0x6700 + 32 * k
      if r(a0) & 1 == 1 then t[#t + 1] = string.format("B%d %d %d %d %d %d", k, r(a0 + 3), r(a0 + 5), r(a0 + 9), r(a0 + 10), r(a0 + 1)) end
    end
    HAMF:write(table.concat(t, "|"), "\n")
  end
  if FEATF and g.f % 4 == 0 then
    local sc = g.c.best_s and string.format("%d", math.floor(g.c.best_s + 0.5)) or "x"
    local t = {string.format("%d %d %d %d %d %d %d %s", g.id, g.f, o.x, o.y, o.lad, o.jmp, o.ham, sc)}
    for _, b in ipairs(o.b) do t[#t + 1] = string.format("%d %d %d %d", b.x, b.y, b.d, b.c) end
    FEATF:write(table.concat(t, "|"), "\n")
  end

  -- LOOKAHEAD (Matt, 2026-11-14: the all-knowing mode, a record of its own): he only presses input sequences he has played out on a
  -- copy of the game and seen survive. The game has no randomness of its own, so from this exact moment a given sequence always does
  -- the same; but any other press reshuffles everything (0x6019 counts the CPU's spare time), so nothing unchecked is ever pressed.
  -- SEARCH: the checked plan's press for this frame (the runner keeps it growing and checked); his own choice only if there's none
  -- (MODE=scenario) the recorded game's own presses until the takeover; the search starts afresh from there
  local forced = g.force and g.f < g.force_until
  if SEARCH and g.force and g.f == g.force_until then mac:search_on(true, tonumber(os.getenv("SEARCH_H") or 120), tonumber(os.getenv("SEARCH_BUDGET") or 600)) end
  -- (2026-11-20, Matt: "try option 3": the all-knowing mode on the rivet board as a teacher) SEARCH_RIV=1: the search also runs
  -- on the rivet board, its "his way" each frame the rivet player's current target x
  -- RSEARCH=1 (2026-11-20, option 3: the all-knowing rivet teacher): every 8 frames the native search (mac:rsearch) picks the first
  -- move of the best surviving two-move sequence by progress; held 8 frames (a jump: pressed 3 frames, then hands off till he lands)
  -- (a hammer as his target: the search can't see a grab as progress, so his own play until it's taken)
  local rs_ham = g.rc and g.rc.cur_target and (g.rc.cur_target[4] == "HAM" or g.rc.cur_target[4] == "LHAM")
  if rs_ham then g.rs = nil end
  if os.getenv("RSEARCH") and r(0x6227) == 4 and g.rc and g.f > 1 and not rs_ham and not (g.force and g.f < g.force_until) then
    if not g.rs or g.f >= g.rs.till then
      local raw, isjump = mac:rsearch(g.rc.progress)
      if raw == -2 then   -- (asked: the answer comes between frames; meanwhile the same press, or nothing)
        if g.rs then g.rs.till = g.f + 1 else g.rs = {raw = 0, from = g.f, till = g.f + 1} end
      elseif raw >= 0 then g.rs = {raw = raw, from = g.f, till = g.f + (isjump == 1 and 50 or 8), jump = isjump == 1}
      else g.rs = nil end
    end
    if g.rs then
      local v = g.rs.raw
      if g.rs.jump and g.f >= g.rs.from + 3 then v = 0; if r(0x6216) == 0 and g.f > g.rs.from + 8 then g.rs.till = g.f end end
      g.cur = (((v & 1) ~= 0) and 2 or 0) | (((v & 2) ~= 0) and 1 or 0) | (v & 0x1C); g.pending = nil
      apply(g.cur); g.inp[g.f] = string.char(48 + g.cur)
      return nil
    end
  end
  local riv_search = os.getenv("SEARCH_RIV") and r(0x6227) == 4
  if riv_search and g.rc and g.rc.step_x then local sx = g.rc.step_x; local w = want or 0; local raw = (((w & 1) ~= 0) and 2 or 0) | (((w & 2) ~= 0) and 1 or 0) | (w & 0x1C); mac:search_route({sx, sx, sx, sx, sx, sx, g.rc.step_v or 0, raw}) end
  if SEARCH and g.f > 1 and not forced and (r(0x6227) == 1 or riv_search) then
    local v, left = mac:search_press()
    if v >= 0 then
      g.cur = (((v & 1) ~= 0) and 2 or 0) | (((v & 2) ~= 0) and 1 or 0) | (v & 0x1C); g.pending = nil
      apply(g.cur); g.inp[g.f] = string.char(48 + g.cur); g.checked = (g.checked or 0) + 1
      return nil
    end
    g.unchecked = (g.unchecked or 0) + 1
  end
  if LOOK and g.f > 1 then
    local now = look_frame(want)
    if now then g.cur = now; g.pending = nil; apply(g.cur); g.inp[g.f] = string.char(48 + g.cur); return nil end
  end
  -- what they want lands 0-1 frames late
  if want ~= g.cur and want ~= g.pending then g.pending = want; g.pending_at = g.f + math.random(0, 1) end
  if g.pending and g.f >= g.pending_at then g.cur = g.pending; g.pending = nil end
  -- MODE=scenario: the recorded game's own inputs up to the takeover, his decisions after (he has watched it all, so he's warmed up)
  if g.force then
    if g.f < g.force_until then g.cur = g.force:byte(g.f) - 48; g.pending = nil
    elseif g.f == g.force_until then
      -- what the board looks like at the takeover (Mario, every barrel and fireball) and the dice (0x6018): a reshuffle of the dice
      -- must leave the first the same
      local t = {string.format("%d,%d,%d,%d", o.x, o.y, o.lad, o.jmp)}
      for _, b in ipairs(o.b) do t[#t + 1] = string.format("%d,%d,%d", b.x, b.y, b.d) end
      for _, fb in ipairs(o.f) do t[#t + 1] = string.format("f%d,%d", fb.x, fb.y) end
      table.sort(t, function(a, b) return a < b end)
      g.take, g.take_rng = table.concat(t, ";"), r(0x6018)
      -- (the rivet review) on the rivet board also each fireball's heading as he'd seen it (x and y px per frame), the rivets gone
      -- and the hammer: "rv|x,y,vx,vy;...|gone|ham"
      if o.board == 4 and g.rc and g.rc.fire then
        local hv = {}
        for _, fb in ipairs(o.f) do local h = g.rc.fire[fb.k] or {}; hv[#hv + 1] = string.format("%d,%d,%.2f,%.2f", fb.x, fb.y, h.vx or 0, h.vy or 0) end
        local gn = {}; for k in pairs(g.rc.gone or {}) do gn[#gn + 1] = k end; table.sort(gn)
        g.take = g.take .. "|rv|" .. table.concat(hv, ";") .. "|" .. table.concat(gn, ",") .. "|" .. o.ham
      end
      math.randomseed(g.reseed)
      -- DICE (the oracle review): from trial 1 on, new dice at the takeover: the board exactly as it is, the random number
      -- (0x6018, which no player can see) set to something else, so a move is judged against dice he can't know
      if os.getenv("DICE") and g.trial and g.trial > 0 then sp:write_u8(0x6018, math.random(0, 255)); g.take_rng = r(0x6018) end
      if g.force_plan then g.c.script = {p = g.force_plan, f0 = g.f + 1, src = "tried"} end
      if g.rforce then
        if g.rforce.seq then local n = 0; for _, q in ipairs(g.rforce.seq) do n = n + q.n end; g.rforce.n = n end
        g.rforce.from, g.rforce.till = g.f + 1, g.f + g.rforce.n
        if g.rforce.tgt == "noham" then g.rc.free_right = true elseif g.rforce.tgt == "ham" then g.rc.force_ham = true end
      end
    end
  end
  apply(g.cur)
  g.inp[g.f] = string.char(48 + g.cur)
  return nil
end

-- ---- LOOKAHEAD ----
LOOK = os.getenv("LOOKAHEAD") and true or false
SEARCH = os.getenv("SEARCH") and true or false
CHAIN = os.getenv("CHAIN") and true or false
local LH = tonumber(os.getenv("LOOK_H") or 50)          -- frames each check plays out
local LEVERY = tonumber(os.getenv("LOOK_EVERY") or 6)   -- frames between checks (sooner once the checked part runs short)
local LN = tonumber(os.getenv("LOOK_N") or 3)           -- how many of his planner's plans are checked each time
local function raw(m) return (((m & 2) ~= 0) and 1 or 0) | (((m & 1) ~= 0) and 2 or 0) | (m & 0x1C) end   -- his bits (left 1, right 2) -> IN0's (right 1, left 2)
local function dmask(d) return (d and d > 0 and 2) or (d and d < 0 and 1) or 0 end
-- a plan (act, w1, j1, w2, j2, stay) as one press a frame, from the next frame on
local function plan_seq(p, dirn, n)
  local q = {}
  local function push(m, k) for _ = 1, k do if #q < n then q[#q + 1] = m end end end
  push(dmask(p.act), p.w1 or 0)
  if p.j1 then
    push(16 | dmask(p.j1), 3); push(0, 46)
    if p.j2 then push(0, p.w2 or 0); push(16 | dmask(p.j2), 3); push(0, 46) end
  end
  push((p.stay or p.j2) and 0 or dmask(dirn), n)
  return q
end
local function as_str(first, q, n)
  local t = {string.char(raw(first))}
  for i = 1, n - 1 do t[#t + 1] = string.char(raw(q[i] or 0)) end
  return table.concat(t)
end
-- g.look: {f0 = frame its first press is for, s = presses (his bits), safe = last frame seen alive}, the sequence he's following
function look_frame(want)
  local L = g.look_state or {}; g.look_state = L
  local mac = manager.machine
  local res = L.asked and mac:peek_seqs_result()
  if res then
    -- the check asked for last frame: each candidate started with the press made then
    -- the best of those that live through it: cleared, then higher up, then nearer where he's heading; small tie-breaks from his planner
    local best, bi
    local tx = g.c.target_now
    for i, r in ipairs(res) do
      local cd = L.asked[i]
      local ok = r[2] == 2 or r[1] >= #cd.s - 1   -- (the first frame of a check is this one's, already under way)
      local prog = (r[2] == 2 and 1e4 or 0) - r[4] * 3 - (tx and math.abs(r[3] - tx) or 0) + (cd.v or 0) * 0.01
      local key = ok and (1e6 + prog) or r[1]
      cd.prog = prog
      if not best or key > best then best, bi = key, i end
    end
    local cd, r = L.asked[bi], res[bi]
    if os.getenv("LOOKDBG") then local t = {}; for i, rr in ipairs(res) do t[#t + 1] = string.format("%d/%d:%s", rr[1], rr[2], L.asked[i].v and string.format("%.0f", L.asked[i].v) or "-") end; io.stderr:write(string.format("LOOK f=%d x=%d checks %s -> %d (now safe to %s)\n", g.f, r and 0 or 0, table.concat(t, " "), bi, tostring(g.look and g.look.safe))) end
    local cur_safe = g.look and g.look.safe or -1
    local cd_safe = L.asked_f + ((r[2] == 2) and 1e6 or r[1])
    local full = r[2] == 2 or r[1] >= #cd.s - 1
    if (full and (not g.look or g.look.safe < cd_safe or cd.prog > (g.look.prog or -1e9) - 0.5)) or (not full and cd_safe > cur_safe) then
      g.look = {f0 = L.asked_f, s = cd.s0, safe = cd_safe, v = cd.v, prog = cd.prog}
      g.look_switch = (g.look_switch or 0) + 1
    end
    local none = not (r[2] == 2 or r[1] >= #cd.s - 1)
    if none then L.wide = not L.was_wide; g.look_short = (g.look_short or 0) + (L.was_wide and 1 or 0) else L.wide = false end   -- nothing survived: a wide search next
    L.asked = nil
  end
  -- this frame's press: the sequence he follows, else (none yet, or it has run out) what his planner wants
  local now
  if g.look and g.f >= g.look.f0 and g.f - g.look.f0 + 1 <= #g.look.s then now = g.look.s[g.f - g.look.f0 + 1] else now = want; g.look = nil end
  -- time for a check: his planner's best few plans, carrying on with what he's following, and standing still
  if not L.asked and (L.wide or not L.last or g.f - L.last >= LEVERY or not g.look or g.look.safe - g.f < 30) then
    local cs = {}
    local function add(q, v) cs[#cs + 1] = {s0 = nil, q = q, v = v} end
    local dirn = g.c.dirn_now
    L.was_wide = L.wide
    if L.wide then
      -- every simple way out: a direction (or nothing, or up / down on a ladder) for a while, then a jump (straight, left, right, or
      -- none), then standing or carrying on; scored by how well it heads his way
      local d = dmask(dirn)
      for _, a in ipairs({d, 0, d ~= 0 and (3 - d) or 1, (d == 0) and 2 or nil, 4, 8}) do
        for _, w in ipairs({0, 3, 6, 10, 15, 22, 32, 45}) do
          for _, j in ipairs({false, 0, 1, -1}) do
            if not (j and (a == 4 or a == 8)) then
              for _, stay in ipairs(j and {true, false} or {false}) do
                local q = {}
                local function push(m, k) for _ = 1, k do if #q < LH then q[#q + 1] = m end end end
                push(a, w)
                if j then push(16 | dmask(j), 3); push(0, 46) end
                push((stay or (not j and a == 0)) and 0 or (j and d or a), LH)
                add(q, -w * 0.1 + ((a == d) and 1 or 0))
              end
            end
          end
        end
      end
    end
    local plans = g.c.cands or {}
    table.sort(plans, function(a, b) return a.v > b.v end)
    for i = 1, math.min(LN, #plans) do add(plan_seq(plans[i], dirn, LH), plans[i].v) end
    if #plans == 0 then local q = {}; for i = 1, LH do q[i] = want end; add(q, 0) end
    if g.look then local q = {}; for i = 1, LH do q[i] = g.look.s[g.f - g.look.f0 + 1 + i] or 0 end; add(q, (g.look.v or 0) - 0.5) end
    do local q = {}; for i = 1, LH do q[i] = 0 end; add(q, -50) end
    local strs = {}
    for i, cd in ipairs(cs) do
      strs[i] = as_str(now, cd.q, LH)
      cd.s0 = {}; for k = 1, LH - 1 do cd.s0[k] = cd.q[k] or 0 end   -- what he'd press from next frame on
      cd.s = strs[i]
    end
    mac:peek_seqs(strs)
    L.asked, L.asked_f, L.last = cs, g.f + 1, g.f
  end
  return now
end

local function replay_frame()
  g.f = g.f + 1
  local mode = r(0x600A)
  local o = observe()
  if mode == 0x0C and r(0x6200) ~= 0 then g.lastobs = o end
  if LIVE then write_frame("replay of game " .. rep.id) end
  if CHAIN and (g.transit or (mode == 0x16 and r(0x6227) == 1)) then
    g.transit = not (mode == 0x0C and r(0x6200) ~= 0 and r(0x6227) ~= 1) or nil
    if g.transit then apply(rep.inp:byte(g.f) and rep.inp:byte(g.f) - 48 or 0); return nil end
  end
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
        -- optional "R:input:frames:target" (rivets, the computer review 2026-11-15): at the takeover hold that input (a jump: pressed
        -- 3 frames, then hands off while in the air) for that many frames, then he plays on; target "noham" / "ham": skip / take
        -- the middle hammer from then on ("-": as he would)
        local ri, rn, rt = rest:match("R:(%d+):(%d+):(%S+)")
        -- or a sequence "S:input:frames,input:frames,...:target" (Matt: "play this out"): each held in turn (a jump pressed 3 frames)
        local sq, st = rest:match("S:([%d:,]+):(%a+)")
        local seq
        if sq then seq = {}; for i, n in sq:gmatch("(%d+):(%d+)") do seq[#seq + 1] = {inp = tonumber(i), n = tonumber(n)} end end
        SCEN[#SCEN + 1] = {tonumber(a), tonumber(b), tonumber(c), d, plan, ri and {inp = tonumber(ri), n = tonumber(rn), tgt = rt} or (seq and {seq = seq, n = 0, tgt = st}) or nil}
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
  -- SAVE_NEXT=prefix (2026-11-15, starts for the rivet board): after a clear, let the game carry on to the next board and save a
  -- start the moment play begins there (mode 0x0C, Mario alive, board 0x6227 different from the one cleared)
  if g.next_after_save then
    g.next_after_save = nil; ID = ID + STEP
    if ID > LAST then mac:exit(); return end
    new_game(ID); return
  end
  if g.saving then
    apply(0); g.saving = g.saving + 1
    if r(0x600A) == 0x0C and r(0x6200) ~= 0 and r(0x6227) ~= g.save_from and g.saving > 30 then
      mac:save(string.format("%s%03d", os.getenv("SAVE_NEXT"), g.start)); print(string.format("saved %s%03d (board %d)", os.getenv("SAVE_NEXT"), g.start, r(0x6227)))
      g.saving = nil; g.next_after_save = true   -- the runner holds one save or load at a time: the next game starts next frame
    elseif g.saving > 2000 then print("no next board for start " .. g.start); g.saving = nil; ID = ID + STEP; if ID > LAST then mac:exit(); return end; new_game(ID) end
    return
  end
  local out
  if g.f == 0 then score_base = 0; score_base = score() end
  if MODE == "replay" then out = replay_frame() else out = play_frame() end
  if not out then return end
  local s = score()
  local t = g.lastobs and g.lastobs.t or 0
  local fields = {score = out == "clear" and s + 100 * r(0x62B1) or s, play = s, t = out == "clear" and r(0x62B1) or t}
  if SEARCH then local dead, frames, backs = mac:search_stats(); fields.unchecked = g.unchecked or 0; fields.search_dead = dead; fields.search_frames = frames; fields.backs = backs end
  finish(out, fields)
  if os.getenv("SAVE_NEXT") and out == "clear" then g.saving = 1; g.save_from = r(0x6227); mac:search_on(false); return end
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
