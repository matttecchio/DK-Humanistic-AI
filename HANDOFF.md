# DK Humanistic AI: handover (all boards)

Everything learned from the start of the project (late October 2026) to 2026-11-21, written so someone new can pick it up without the conversation. This is the overview; the details are in:

- **RIVETS_HANDOFF.md**: the rivet board (1-2) in full: how the player works, every measured fact, everything tried with its numbers, how to test, ideas not yet tried.
- **FINDINGS.md**: what was learned, board by board, including what didn't work and lessons about testing.
- **PLAYBOOK.md**: every test in order, with its numbers and what was adopted (the working log).
- **RESULTS_LOG.md**: every batch's result, added automatically.

## The project

A program that plays Donkey Kong **as a human could**, as well as possible. Matt (the user) is a top DK player; he reviews death videos and gives the expert knowledge. It's classic game AI, not machine learning: every frame it looks (late, like a person), lists what it could do, scores each option, and picks the best, with the expert's rules on top. It learns between games through measurements, large paired tests and Matt's reviews.

## Where it stands

| Board | Cleared (fireball deaths left out) | Counting fireballs | Evidence |
|---|---|---|---|
| 1-1 | 98.68% | 97.27% | 3,000-game benchmark (`t1`/`t1c`), frozen in `baselines/1-1/lua` |
| 2-1 | 98.47% | 98.39% | 30,000-game exam `pe22`, 2026-11-12 (target was 97%) |
| 3-1 | 95.49%, then about +0.7 | 94.98% | `pe30` 2026-11-11; then 95.83% / 95.90% on two fresh 10,000-game checks (2026-11-15) |
| 4-1 | 95.45%, then about +0.1–0.3 | 94.76% | `pe42` 2026-11-12; then 95.22% / 95.76% (2026-11-15) |
| 5-1 | 98.69% | 97.21% | 30,000-game exam `pz40`, 2026-11-13. From level 5 the barrel board stops getting harder, so 5-1 is the main barrel target |
| **1-2 (rivets)** | **~87.2%** (fireballs counted: nearly every rivet death is a fireball) | | `hp1` 8,722 / 10,000, 2026-11-21. Matt's goal: above 90% |

**All-knowing mode** (`SEARCH=1`, a separate record, not human-limited): it only presses inputs that a copy of the game has played out and survived (the game has no randomness of its own, so that's exact). 100% on every barrel board, fireballs included. The rivet version (`RSEARCH=1`) was never finished (see RIVETS_HANDOFF.md).

## Matt's rules (all boards)

- **Human limits, never tunable:** sees the game 133–150 ms (8–9 frames) late on 1-1 to 4-1, 65 ms (`react = {4, 4}`) on barrel boards from 5-1 by Matt's agreement; presses land 0–1 frames late. It can't read the game's random numbers or know what an enemy will do; it may know what a skilled player knows (how barrels and fireballs tend to behave, measured from its own games).
- **Fair play:** no frame-perfect tricks (no deliberate all-800 hammer smashes), no frame skipping.
- **No farming:** no fireball leeching, no stalling on lower girders, no farming barrel jumps or points off Kong. Clearing first; scoring is a later stage, not started.
- **Rivets:** no fireball jumps unless it's life or death.
- **Context over blanket rules:** a rule that works in one spot may not work elsewhere. Gate every rule to its spot and trigger; when a test saves some games and loses others, find what separates them and retest only there.
- **Steer anywhere it helps** (barrels down ladders or past them).
- **Acceptable deaths:** only ones a human couldn't have avoided.
- **No regressions:** changes for later boards apply only on those levels; 1-1 must play identically (`tools/regress_1_1.py`).
- **Testing:** every test visible on the website (`tools/run_batch.py`, never `--no-grid`); one run at a time on the machine; but keep it busy (start the next test before reporting); a change is believed only after a fresh check on new games; don't throw away a small, consistent gain built on true knowledge of the game.
- **Updates:** plain language, in replies, on the website and in batch notes. Commit or push only when asked. Warn before any windowed MAME run (MAME shows a black screen on this Mac).
- **Privacy:** other players' INP recordings stay out of git; don't scrape or bypass protections to get recordings; refer to one player as "player 3", never by name; only authorise GitHub for Matt's personal repos.

## How it's built

| Part | What it is |
|---|---|
| `lua/agent.lua` | the fixed human limits (late sight, press lag), the frame loop, the website's board files, takeovers for replays |
| `lua/policy.lua` + `native/plan.cpp` | the barrel player: short plans (walk, wait, jump, climb) checked against predicted barrels, wild barrels and fireballs; the expert's rules on top |
| `lua/rivets.lua` + `native/rivsim.cpp` | the rivet player and its fireball simulator |
| `lua/params.lua` | all settings, per level under `levels[N]`; rivet settings are `riv_*` |
| `native/dkh` | the native runner: Matt's dkx emulator (MAME-0.264 exact, `~/dkx-build`) running our Lua, about 5x faster than MAME, game for game identical (checked with `native/check.py`). All batches use it (`--native`) |
| MAME 0.264 | the website's replays, videos and the experts' recordings |
| `web/server.py` | the website on port 8765: live boards, batch progress, totals (about 6.3 million games plus 1.3 million replays) |
| `tools/` | `run_batch.py` (batches), `compare.py` (saved / lost on the same games), `regress_1_1.py`, `autopsy.py`, `death_video.py` (review videos for Matt), `probe_plans.py` / `grind.py` (grinding a death out), `oracle_review.py` (the all-knowing review), and the rivet tools |

Build: `(cd native && make)`. A batch: `python3 tools/run_batch.py NAME --level N --games 10000 --first FIRST --native --note "…"` (rivets add `--board 4`). Each run copies `lua/` when it starts, so later edits don't change a running test.

## The barrel boards: what matters most

### Facts about the game (measured, or read from the ROM)

- **Jumps:** a straight jump lasts 42 frames (±1–2 on slopes); a fresh press 4 frames after landing jumps again; holding never re-jumps; a press on a ladder, on the last rungs, or with a hammer does nothing. The "ignored jump press" was the biggest early bug.
- **Barrels on ladders (ROM 0x2186):** before the oil drum is lit, always; afterwards only if Mario is below that ladder, and then if a random number is low enough for the difficulty, it goes down when Mario is at the ladder's x or his stick points towards it, else 1 time in 4. So **steering is real**: stick towards a ladder ≈ 75% down, away or neutral ≈ 20%.
- **Wild barrels:** at difficulty 1–2 the bounces are random; at 3–4 each bounce heads towards Mario's x at that instant; from difficulty 5 they're **aimed** (sideways speed = (Mario's x − its x) / 64 a frame). The first wild of a 1-1 board falls straight down (181 / 181). Kong's wilds: 81% drift towards Mario on the first fall, 19% drop straight at x=59. A wild sits 7 frames on a girder, then sinks through over about 11. Knowing the aim took 5-1 from 82% to 94.6%.
- **Random numbers can't be predicted:** 0x6018 depends on how busy each frame was, so any different press reshuffles everything after it.
- **Hit boxes (ROM 0x2913):** touch if |dx| < w1 + w2 and |dy| + 1 < h1 + h2; Mario (4, 7), barrels (2, 2).
- **The hammer (ROM):** up / down every 8 frames by counter 0x6394, ends after 512 counts; a smash freezes everything about 73 frames (the counter stops too, which is why it seemed to last 800–1,000 frames); down, it smashes a rolling barrel 10–22 px in front. The grab is checked once a jump, at its peak (frame 19).
- **Board edges:** walls x=22 and x=233 (jumps bounce off both).
- **Difficulty** (0x6380) rises with time on the board; on 3-1 it's 3, then 4 after about 2,000 frames, 5 after about 4,000.

### What made the big gains (in rough order)

1. **Bug fixes in his own model:** the route to Pauline, barrels landing from ladders, the ignored jump press (+8 points on 1-1), `along_fix` on 3-1 (+2.6).
2. **Measured game behaviour built in:** wild barrels as the ROM does them (`wild_rom`, `wild_aim`, `kong_aim`), exact barrel arcs off girder ends, ladder odds.
3. **Waiting spots:** on the far side of a ladder, 10 px from it; never under a live ladder; finish a climb that's nearly done.
4. **Matt's reviews of death videos:** every rule that held up came from them (back jumps, risk weighting, the climb timing at ladder 91, steering barrels down the middle ladder, rules r2 and r7 on 5-1).
5. **Copying the experts' habits, not their single moves:** they're rarely right under a ladder when a barrel arrives above it, and pull barrels down from 17–48 px on the side where they roll away 81–85% of the time (`steer_pull`, `pull_moving`). Copying single moves at particular spots mostly failed.
6. **Knowing where he is from his own presses** (`know_self`), a 1-frame allowance for his own jump press (`press_lag = 1`), finer jump timing (`fine_waits`), faster reactions on barrel boards from 5-1.

### What didn't work on the barrel boards (don't retry without a new reason)

- **Whole-board knob turning:** exhausted on every board (a 14-setting sweep on 2-1 found nothing). Gains need new abilities or Matt's observations.
- **Fixing what the deaths show:** four times a habit that looks foolish in the deaths was helping in the games he survives. Always count games lost, not just saved.
- **Timing Kong more accurately:** never helped (four tries).
- **Banking exact solutions to single deaths:** lost on new games; the hidden random state decides them.
- **The top hammer** (copied from the experts): about 70–80% against 97% without. The planner doesn't model the grab and the swing well enough; hand-timed trips get trapped.
- **Rules found by search alone** (no reviewer): saved their own death, didn't hold up (19 found overnight, none kept).
- **Contingent planning, a learned danger table, Matt's fixes as tight position rules:** neutral or worse on 5-1.
- **The all-knowing review of 5-1's deaths:** even finding every dice-proof answer would take it from about 98.7% to about 99.1%. **5-1 is near its human-limited ceiling.**

### Still unsolved (barrels)

- 3-1 and 4-1 (~95.5–96%): the foot of ladder 91 (barrel trains, climbs that turn back), wild barrels on the 2nd, 3rd and 5th girders, the 5th girder corner. On 4-1, finer jump timing lost (its 5th-girder deaths nearly doubled).
- 5-1: fireballs are the biggest cause (about 450 of 840 deaths in 30,000 games); barrel deaths while jumping are last-ditch jumps after he's been trapped by barrels that might take a ladder.
- 2-1: timing the climb at ladder 91 the way Matt does (steer first, then climb); quicker follow-up jumps when barrels are lined up.
- Deliberate steering everywhere (only partly built); flinging wild barrels by holding a direction as they bounce (untested); scoring (not started).

## The rivet board (1-2)

See **RIVETS_HANDOFF.md** for all of it. In short:

- From 0% to ~87.2% in a week (2026-11-15 to 11-21): 80.3% on the first day (Matt's tips plus four bug fixes), then about 7 points from Matt's observations and from letting the fireball simulator choose between two ways of doing the same next step.
- **The pattern:** changing the plan itself (rivet order, waiting, smashing, detours, looking further ahead) has lost every time, about 30 ideas. Matt's five "outside the box" options were all tested on 2026-11-21; none won.
- **The biggest open idea:** a working all-knowing rivet search, to compare its choices with his and find where the rules should differ.

## Lessons about testing (all boards)

- **Compare on the same games** and count saved against lost there. About 25% of rivet games (fewer on barrel boards) change outcome with any change, so ±30 in 10,000 is luck; a real gain needs about 2 standard errors (sqrt(saved + lost)).
- **Use enough games:** 10,000 per test, fresh games for the check. Fresh 3,000-game sets differ by about a point; the first 100 game numbers are unusually lucky.
- **Practice-set gains shrink on fresh games** (98.35% became 97.8%; `steer_far` 3 / 0, then 2 / 5).
- **A takeover reshuffles the game's luck:** from a second or two before a death his own play usually lives too. Judge a fix only at moments where his own play still mostly dies.
- **Narrow rules are judged where they fire** (saved against lost in those games, confirmed twice); broad changes need the overall figure to rise twice.
- **Check what a setting actually touches before testing it,** and that it fired.
- **Practical traps:** check a run name is free; `--set` takes Lua values (text needs quotes); a level's settings once overrode `--set` (fixed; two identical results are a warning sign); wait on result counts or `meta.json`, never on process names that match the waiter itself; don't edit a script that's running; mark a batch stopped by hand as finished; `--stall` for slow players.
