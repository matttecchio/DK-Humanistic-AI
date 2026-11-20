# Rivets (1-2): handover

Everything learned about Donkey Kong's rivet board (level 1, board 2) from 2026-11-15 to 2026-11-21, written so someone new can pick it up without the conversation. The detailed day-by-day log is in PLAYBOOK.md ("Rivets, 1-2"); the measured facts are also in FINDINGS.md ("The rivet board, 1-2").

## The goal and Matt's rules

- **Goal:** clear 1-2 rivet boards as often as possible, as a **human** could. Matt (the user, a top DK player) wants it above 90%.
- **Human-limited:** it sees the game a few frames late (reaction time), presses land 0-1 frames late, it can't read the game's random numbers or know what the fireballs will do. It may know what a skilled player knows (how fireballs tend to behave, that the 2nd and 4th freeze, the difficulty rising with time).
- **No fireball jumps unless it's life or death.** (A limited planned version was tried: -25%.)
- **Clearing, not points:** no leeching off Kong.
- **Testing:** every test on the website (`tools/run_batch.py`, never raw runs without the live boards); **10,000 games per test**, on the same games as a reference with the same defaults; a fresh 10,000-game check before anything stays on; one run at a time on the machine; plain-language updates; commit only when asked.
- **Keep small gains** built on true knowledge of the game (Matt: "don't throw away a gain if it happens").
- **One expert player is called "player 3", never by name.**

## Where it stands

**~87.2%** of 1-2 boards cleared: `hp1` 8,722 / 10,000 on games 60000-69999 with the current defaults. Earlier headlines: 84.81% on 30,000 new games (`hd7`, before the last three gains). From 0% on 2026-11-15.

Reference runs with (nearly) current defaults: `hp1` (games 60000-69999, 8,722), `cvf` (70000-79999, 8,690, before the freezes and the hop plan).

Deaths now: about 2/3 after 2R (the right half), bunched right after the difficulty steps to 2 at 34 s (17-s bins: 18, 225, 534, 260, 113, 39, 125 for the timer).

## How the player works (`lua/rivets.lua`, ~1,550 lines; `native/rivsim.cpp`)

It's classic game AI, not machine learning. Each frame (`c.decide`):

1. **Sees** Mario and every fireball (all five slots) a few frames late; tracks each fireball's heading (smoothed velocity, 20-frame drift); which rivets are gone (0x6290 and position); the bonus timer (0x62B1).
2. **Picks the target:** the star order 2L, 4L, 5L, bottom hammer (LHAM), 3L, 3R, 2R, middle hammer (HAM, unless skipped), 4R, 5R; with Matt's crossing directions (2L left, 4L right, 5L left, 3L right, 3R right).
3. **Routes** to it: a shortest-path search over girder sections split by pulled rivets' gaps (the maze) and Kong; ladders cost 40; a gap jump costs 120 (`riv_gapjump_cost`).
4. **Lists options** (walk to the next step, climb on / back, wait, back off left / right, gap escapes, jumps for hammers, ...), each a short course over the next H = 36 frames.
5. **Scores them:** a worst-case check (could any fireball reach him, allowance REACH 4 px + speed x time, never across a gap, Kong and girder ends as walls); the whole-board safety map (time to spare where the move leaves him); the imagined futures (`rivsim`: 48 futures of every fireball by measured odds; share touched) as a tie-break.
6. **Big choices by the simulator:** the middle hammer or the rivets (playing both routes forward 240 frames; also through girder 3's middle; also hopping right from girder 2's middle); after 3R, down the right ladder or back over 3R's gap and down the middle; a two-step planner when waiting or every move is risky.
7. **Life-or-death jump** only with contact within 4 frames and a fireball at his girder's height.

### What's switched on (`lua/params.lua`, `riv_*`)

| Setting | What it does | Evidence |
|---|---|---|
| `riv_jump_hold` | every jump held 3 frames; a missed one is noticed | the 1-frame bug: 129 of 198 "in the air" deaths were him standing still |
| `riv_safe_w` 1 | the whole-board safety map in every choice (Matt: "think about the whole board") | +4.5% fresh |
| `riv_ladder_busy`, `riv_ladder_commit` 8 | never walk to a ladder a fireball is on; no hesitating on ladders (Matt) | +~1% |
| `riv_free_zone` 40, `riv_free_where` | free pass up the right (skip the middle hammer) when the right is clear and he's on the right (Matt; experts skip it 6/6 then) | +~1% |
| `riv_mc` 1, `riv_right` {reach=3} | imagined futures as a tie-break; tighter allowance after the left sweep | +1.2% |
| `riv_lod_dy` 4 | life-or-death jump only for a fireball at his girder's height (Matt) | +0.2% |
| `riv_plan2` 0.1 | two-step plans by the imagined futures when stuck or in danger | +0.5% fresh |
| `riv_choice_mc` 0.1, `riv_choice_via` "mid", `riv_choice_hop` | middle hammer or rivets by playing routes forward; also via girder 3's middle; also hop right from girder 2's middle (Matt) | +0.8%, +0.4%, +0.4% |
| `riv_down_mc` 0.15 | after 3R, down the right ladder or back over 3R's gap and down the middle | +1.5% fresh |
| `riv_freeze` 120, `riv_freeze_short` 16 | the 2nd / 4th fireballs' own freezes held still (Matt) | +0.2% |
| `riv_skip_ham` 100 | skip the middle hammer when nothing is up on the right (Matt) | early |

## Measured facts (his own games unless said)

- **Layout:** Mario's girder y 240, 200, 160, 120, 80 (girders 1-5). Rivet columns x 72-79 and 176-183 on girders 2-5. A rivet comes out at its middle; walking into a pulled gap is fatal; gaps can be jumped. Ladders up from girders 1-4: {24,120,224}, {32,88,160,216}, {40,120,208}, {48,80,168,200} (left x of 8-px columns).
- **Kong** stands on the top girder's middle: touching him kills (x 103-151 there); he splits that girder.
- **Timer** 0x62B1 (hundreds), ~137 frames a tick, runs out ~6,400 frames in. **Difficulty** 0x6380 steps every 2,040 frames (34 s).
- **Mario's jump** reaches only ~9 px; fireballs still touch him in the air. Jumps must be held 3 frames.
- **Fireballs:**
  - spawn every 256 frames while fewer than 5 are out, at a girder end (girders 1-4), on the side opposite Mario (line x 128);
  - never cross a pulled gap; walk through rivets still in;
  - a ladder going up taken on 16% of visits whatever Mario does; going down 22% only with Mario below, never otherwise;
  - turn ~12% per 8 frames on a girder; **turn towards Mario's side 66% (him level) / 74% (him below) / 52% (above)** — steerable;
  - speeds (with pauses) right 0.43 / 0.53 / 0.58, left 0.36 / 0.46 / 0.48 px/frame at difficulty 1 / 2 / 3; down ladders ~3x faster by difficulty 3; up ~0.20;
  - **freezes:** smashing one freezes the whole game a moment; apart from that **only the 2nd and 4th (slots 1, 3) stop on their own**: long ~336 frames at the top of a ladder going down, only from difficulty 3; shorter stops in steps of ~56 frames elsewhere.
- **The simulator** is calibrated (predicted share of a fireball reaching a spot within 90 frames vs real: error 0.005), but **over-predicts at Mario's own spot** (says 53%, real 27%): the fireballs react to where he really goes.
- **The experts** (barra and player 3's recordings, the WR video, a second world-class video in `videos/wc2/`): the star order; same left-side pace as ours; after 2R skip the middle hammer when the right is clear; with the middle hammer they leave 4R in and smash what comes through the 4R spot from girder 4 just left of it, moving to meet each one, pulling 4R as the hammer runs out; they wait in girder 3's middle (cut off at both ends) to time moves.

## Tried and didn't help (with numbers; 10,000 games unless said)

| Idea | Result | Why, where known |
|---|---|---|
| Hammer hunting | 826 vs 841 (1k) | |
| Leaving 2R for later; committing to moves; a dynamic order (early) | -7%, -13%, -8% | |
| Pull 2R and jump back | -1% | |
| Looking further ahead (worst case, or along headings) | -3% to -50% | he hesitates on ladders |
| Three-step planner | -0.4 to -0.7% | futures too uncertain that far |
| Hurry modes with the timer low (4 versions) | even | late timer games are stuck behind a fireball; risk swaps timer deaths for fireball deaths |
| Under-the-ladder rule (3 versions) | -0.4 to -4% | waiting at a ladder's foot is often his safest spot |
| Planned fireball jumps (limited) | -25% | the jump is only 9 px high |
| Free gap jumps in routes | -5% | a jump commits ~46 frames; fireballs reach him in the air |
| Gap jumps as planner steps; free pass from the middle; hop cost by landing | about even | |
| Spawn expectation in the simulator; the pull towards Mario in it | even; calibration worse | |
| Learnt danger table | -1 to -2% | "danger given how he then played it" doesn't transfer |
| General route choice (13 detours) | -8% | the best of many noisy estimates looks good by luck; detours cost time |
| Last-rivets "go round" choice | -5 to -6% | its detours need gap jumps, which the simulator underrates |
| Hammer farming at a fixed spot (5 versions) | best -0.5% | the experts move to meet each fireball |
| Waiting by Kong (Matt's points play), waiting at the left hammer | -2 to -5% | any waiting before the right half: more fireballs, harder right half |
| No hammer parking after 3R (option 1) | -3.5% | the parking does real work |
| Rivet order by the simulator (option 4) | -5% | the star order is right |
| Only smash on the right (option 5) | -0.5% | a smash now beats where its replacement appears |
| Simulator settings (touch distances, turn rate) | even or worse | already about right |
| Planner always on; longer horizon for big choices | not run (dropped) | |
| **Option 3: an all-knowing rivet search as a teacher** (`RSEARCH=1`, native `mac:rsearch`) | 23/64 vs the player's 55/64 at best | see below |

**The pattern:** changing the plan itself (order, waiting, smashing, detours) loses; the gains came from Matt's specific observations and from the simulator choosing between two ways to do the same next step at a known decision point.

### Option 3, the all-knowing search (unfinished)

`dkh.cpp`: `mac:rsearch(fn)` — request-then-answer (the main loop searches between frames; it must not run the game inside Lua's frame callback, which hung). Every 8 frames: every two-move sequence (stand, walk left / right, up, down, jump left / right / straight) on exact copies of the game, a 60-frame tail check, scored by rivets pulled and minus the route length to his target (`c.progress` in rivets.lua; the route's own cost leaves out the last walk across the rivet, so it's measured step by step). Hammers left to the normal player. Problems left: falls into gaps only kill on landing (after the search looked); counting "moving down off a ladder, not jumping" as death was too blunt (2/64: stepping off a ladder looks the same). A proper version needs an exact fall test (e.g. Mario's state byte for falling) and a better progress measure.

## How to test (and the traps)

```sh
python3 tools/run_batch.py NAME --level 1 --board 4 --games 10000 --first 60000 --native --note "…" --set key=value
```

- Compare game by game with a reference on the same games (saved / lost). About 25% of games change outcome with any change: ±30 in 10,000 is luck; a real 0.5% needs ~2 standard errors (sqrt(saved + lost)).
- Each run copies `lua/` when it starts (defaults in `runs/NAME/lua/params_base.lua`, or `params.lua` with no `--set`): later edits don't affect a running test, and a test's reference must have the same defaults.
- `--set` takes a Lua value: text needs quotes (`--set 'riv_choice_via="mid"'`).
- Check a run name is free first (`ls -d runs/NAME`): run_batch refuses a used one.
- Queue scripts: one plain list of runs; never wait with `pgrep -f "text"` that appears in the waiter's own command line.
- `--stall SECONDS` for slow players (the default kills a batch with no result for 120 s).
- Mark a batch you stop by hand as finished (`meta.json` "finished"), or the dashboard keeps showing it.
- Debugging: `RIVDBG=1` (or `all`) prints his state and reasons; `RIVOPTS=1` his options; `DOWNDBG`, `DIFFDBG`, `DEATHDBG=frame`, `FIRELOG=dir` (Mario and every fireball every 4 frames).

## Tools (rivets)

| Tool | What it does |
|---|---|
| `tools/rivet_review.py BATCH` | the computer's review of deaths: from 2 / 4 s before each, 11 choices x 2 trials (new dice) |
| `tools/rivet_review_states.py BATCH` | the board at the review's moments with a real answer |
| `tools/rivet_learn.py BATCH` | 1,500 ordinary right-half moments x 6 choices x 2 trials (option 2's data: `runs/frz3/learn/data.json`) |
| `tools/rivet_playout.py BATCH IDS` | every two-move sequence from every second of a death's last 12 |
| `tools/rivet_scen.py BATCH` | a setting tested on chosen moments (e.g. the deaths with the timer low) |
| `tools/death_video.py BATCH OUT --review FILE` | a review video for Matt (`REVIEW_BEFORE` frames of lead-in) |
| `tools/danger_rivets.py LOGRUN` | the learnt danger table (not used) |
| `native/rivsim.cpp` | the fireball simulator (`dkh_native.rivsim`) |

## Ideas not yet tried (or not properly)

- **A proper all-knowing search** (fix the fall test, better progress), then compare its choices with his in the same states: where they differ is where rules are.
- **Move-to-meet hammer use with the middle hammer** (the experts' farming, not a fixed spot): stay on girder 4 left of 4R, walk to meet each fireball coming through the 4R spot facing it, pull 4R as the hammer ends.
- **Steering fireballs** with the measured pull (they turn towards his side when he's level or below): positioning to draw them away from where he's going next. The simulator can't model the pull with a fixed course; it would need the course to react.
- **The safe room:** wait in girder 3's middle (cut off at both ends) to time the move up, as the experts do.
- **More replays per moment** for option 2 (2 trials per choice is mostly luck): ~10 trials per choice on fewer moments, to find patterns that hold.
- **A rivet-board version of the barrel player's danger table done causally** (from replays, not from logged play).
- Matt's review videos of current deaths have consistently been the best source of gains.
