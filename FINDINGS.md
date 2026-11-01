# DK Barrel Lab: findings

What we've learned about playing level 1-1 safely, including what didn't work. `RESULTS_LOG.md` has every test batch's result, added automatically.

Coordinates are game memory values. Lower y is higher up the screen. There are 60 frames a second.

## Goal and rules

- **Goal:** clear the board at 9,500+ in 20 of 21 games (95.2%), with survival first.
- **Reactions:** he sees the game 133–167 ms (8–10 frames) late, and inputs land 0–1 frames late. The user moved this from 133–200 ms on 2026-11-01.
- **Allowed:** he knows his own inputs and can anticipate. He can't see the game's upcoming random numbers.
- **Not allowed:** frame-perfect tricks such as deliberate all-800 hammer smashes, or farming points without moving up the board.

## Facts about the game (measured)

### Collisions

| Hazard | Kills when | Evidence |
|---|---|---|
| Barrel | within 5 sideways and 7 vertically | No contact was seen at 6 sideways across thousands of near misses |
| Fireball | within 6 sideways and about 8 vertically | Same method, a smaller sample |

### Mario

| Action | Measurement |
|---|---|
| Walking | 0.67 pixels a frame |
| Climbing | 0.36 pixels a frame |
| Jump | Lasts 41–44 frames, rises 14 pixels, moves 0.5 pixels a frame sideways |
| Landing | **A jump pressed before his feet are down is ignored.** He needs about 6 frames after the 41-frame arc, and stalls about 8 frames before walking again |

### The route

| Floor | Ladder x | Climbs to y | Notes |
|---|---|---|---|
| 1 | 203 | 213 | The only ladder on this floor |
| 2 | 115 | 175 | x=51 also exists |
| 3 | **131** | 143 | x=203 also works, but the walk here is 88 pixels instead of 16 |
| 4 | 51 | 114 | |
| 5 | **203** | 81 | **x=107 is broken and stops at y=97.** It does not complete the board |
| 6 | **147** | about 50 | Walk left along Kong's girder, then up to Pauline to clear |

### Barrels

- **Speed:** they roll at 1 pixel a frame, faster than Mario can walk, so running away doesn't work.
- **Girder heights:** these fit straight lines to within 0.5 pixels. See `LEVEL` in `lua/policy.lua`.
- **Girder ends:** at x=27 and x=227 a barrel arcs 9 pixels out and 19 down over 24 frames, then rolls back the other way.
- **Kong's throws:** every 80–128 frames. New barrels appear near x=88, y=76. Wild ones start near x=56.
- **Memory bytes for each barrel:** +1 means wild, +2 is direction, +3 is x, +5 is y, and +21 means blue (it matched the screen colour in 1,542 of 1,561 samples).
- **Wild barrels:** they fall about 2 pixels a frame, about twice as fast as a rolling barrel, and often straight down a column near x=59. They can show the same direction values as normal barrels, so check the wild flag first.

### When barrels take ladders (about 67,000 crossings)

| Where Mario is | Took the ladder | Out of |
|---|---|---|
| Above the barrel | 0.0% | 10,139 |
| Same level | 0.6% | 16,629 |
| Below the barrel | 13.7% | 47,104 |

With Mario below the barrel, his input matters, which supports the user's steering advice:

| Input | Took the ladder |
|---|---|
| Up | 6.9% |
| Nothing | 7.7% |
| Down | 8.7% |
| Left | 15.3% |
| Right | 27.0% |

These figures aren't yet split by barrel direction, or by whether he's pressing towards that ladder. Inputs also correlate with where he is, so treat this as a strong clue, not a controlled test.

Ladder rate by ladder, with Mario below:

| Ladder | Rate |
|---|---|
| Level 6, x=106 | 18% |
| Level 6, x=202 | 12.5% |
| Level 5, x=92 | 21% |
| Level 5, x=52 and x=188 | 11% |
| Levels 3 and 4 | about 7–9% |

## What improved survival

Clear rates aren't all on the same games, and different batches had different settings. The first 100 game numbers are unusually lucky (58%, against about 39% at the time), so judge changes on fresh games.

| Change | Clear rate |
|---|---|
| Simple climb and jump baseline | 0% (0 of 1,000) |
| Correct route to Pauline | 19% |
| Corrected tracking of barrels landing from ladders | 28% |
| Jump later; rethink every 2 frames | 39.7% (2,000 games) |
| Shorter floor-3 ladder at x=131 | about 48–52% |
| Don't jump into ladder columns; finish a climb when near the top | 63% |
| Wait on the far side of the floor-5 ladder | 73% |
| Wait 10 pixels from ladders instead of 14 | 80.6% (1,500 games) |
| Don't press jump until his feet are down | 88.4% |
| Predict fireball movement; correct fireball box; fix wild barrel handling | 92.0% on the first 1,000 games, 89.8% on 1,200 fresh games |

### Why these work

- **Go over barrels, not away from them.** Jumping towards one passes it about three times faster than jumping away.
- **Waiting spots matter hugely.** A barrel coming down a ladder lands and reaches him before he can react if he's on the side it rolls towards.
- **Ladders are danger zones when he's below them.** Jumping there lifts him into a falling barrel.
- **Finish a climb that's nearly done.** Retreating lets the barrel chase him down the ladder.
- **Compare short plans.** Choosing between "wait, jump, jump again" beats reacting one move at a time.
- **Anticipate like a person.** He has to work out his own position from his inputs, not wait to see it.

## What did not help

| Idea | Result | Lesson |
|---|---|---|
| Consider jumping earlier (within 28–50 frames, not 20–24) | 3–6% | He lands in front of the barrel |
| Heavy reward for wide clearance | 62.6% | He jumps when he doesn't need to |
| No preference for later jumps | 66.3%, against 80.3% | A slight preference for later is better. My "procrastination" theory was wrong; the real cause was the ignored jump press |
| Much stronger preference for later jumps | 48.7% | Too late |
| Waiting further from ladders (18–32 pixels) | 10–64% | The walk back takes too long |
| Waiting closer than 10 pixels (6–8) | 69–77% | Too close to falling barrels |
| Audio rate below 1 kHz | Slower | Not a speed gain |
| Moving the floor 4 waiting spot away from the wild barrel column (exam, 1,000 fresh games) | 89.8% and 88.9%, against 90.9% | Wild deaths barely changed and normal barrel deaths rose |
| Requiring a large margin on every plan, with no fallback | Worse | He gave up instead of taking the best real option |
| Heavily reducing the value of progress | 3.6% | He stops moving and time runs out |
| Planning 45 frames past each move | 9.4% | Nothing looks safe, so he stalls |

## What limits him now

- **Reaction delay:** the clear rate falls steeply with delay. These were measured on an earlier version, before the jump-press fix:

  | Delay (frames) | Clear rate |
  |---|---|
  | 0 (no input lag) | 98.4% on games that barely vary, so flattering |
  | 2 | 92.8% |
  | 4 | 92.2% |
  | 6 | 89.2% |
  | 8 | 84.5% |
  | 12 | 63.8% |

- **Remaining deaths (1,200 fresh games, 123 deaths):** 65 barrels, 47 wild barrels, 9 fireballs, 2 falls. Most are on floor 4 near x=48–64, which is under the wild barrel column.
- **Hammers:** in the 81 deaths from one batch of 700 games, none came while holding one.

## User's advice, and its status

| Advice | Status |
|---|---|
| Being under a ladder greatly increases the chance of a barrel coming down | Treated as high risk; the data agrees |
| Pressing towards a ladder encourages barrels down it, also depending on difficulty | Partly confirmed; **not yet used deliberately** |
| Combinations of steering can avoid scenarios that can't be jumped | **Not built yet** |
| Holding left or right as a wild barrel hits a girder flings it away | **Not tested yet** |
| Only barrels on his level, or coming down ladders, need jumping | Already how he behaves |
| Grouping barrels and fireballs for points | Scoring step, not started |
| Holding left or right during a jump widens the scoring area | Scoring step, not started |
| Top-right double backjump is low value | Not planned |

## Lessons about testing

- **Replays:** check them after any change to the runner with `tools/verify_replay.py`.
- **Fresh games:** use `--first` in `tools/run_batch.py` for a fair exam, and judge on hundreds of games or more.
- **Measure, don't assume:** the worst bugs (the ignored jump press, barrels falling through girders, the broken ladder) were all found by tracing one exact death.
- **RAM disk:** macOS logged every file change on it and filled it, which stalled a batch for 26 minutes. It now has `.fseventsd/no_log`, and batches stop themselves after 120 seconds without results.
- **Stopping stuck workers:** a normal stop didn't end the hung MAME workers. They used half the CPU for 3 hours until found, halving test speed without changing results. Use a forced kill, and check the count afterwards.
- **Moving wallpaper:** over Jump Desktop it costs about two CPU cores. Keep it still during tests.
