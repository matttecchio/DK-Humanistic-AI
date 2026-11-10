# DK Barrel Lab: findings

What we've learned about playing level 1-1 safely, including what didn't work. `RESULTS_LOG.md` has every test batch's result, added automatically.

Coordinates are game memory values. Lower y is higher up the screen. There are 60 frames a second.

## Goal and rules

- **Goal:** clear the board at 9,500+ in 20 of 21 games (95.2%), with survival first.
- **Reactions:** he sees the game 133–150 ms (8–9 frames) late, and inputs land 0–1 frames late. The user allowed moving closer to 130 ms from the original 133–200 ms on 2026-11-01.
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
- **Wild barrels:** about two per game, all 2,249 recorded starting at x=59, y=77. They mostly drop straight down that column at 1–2 pixels a frame, sometimes angling off at a girder. They can show the same direction values as normal barrels, so check the wild flag first. After a bounce they went left 50–54% of the time whichever way he held the joystick, a rough check that found no effect but doesn't rule out the fling technique.

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

Split by direction relative to the ladder (1,200 games, Mario below):

| Input | Took the ladder |
|---|---|
| Towards the ladder | 25.2% of 7,108 |
| Away from the ladder | 21.8% of 14,417 |
| Nothing | 6.5% of 38,939 |

"Away" is only high at two ladders: x=106 (32%) and x=92 (51%). It's about 4–7% at the others. The pattern may be that pressing the way the barrel is rolling matters most: at x=106, where barrels roll right, the rate is about 50% holding Right, 15–16% holding Left, 8–9% with nothing and 6–7% holding Up. Mid-jump presses seem weaker there (19% Right, 8–9% Left). Not yet a controlled test.

These earlier figures aren't split by barrel direction, or by whether he's pressing towards that ladder. Inputs also correlate with where he is, so treat this as a strong clue, not a controlled test.

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
| Reactions at 133–150 ms; slightly later jumps | 91.0% on 2,000 fresh games (at least 89.6%) |
| Straight jumps on floors 3 and 4 | 93.2% on the set used to choose it, 91.5% on 2,000 fresh games (at least 90.2%). The gain over 91.0% is within noise, and the 93.2% was flattered by tuning on that set |

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
| Tapping Left on floor 5 as barrels pass the broken ladder (exam, 1,000 games) | 90.8%, against 90.9% | No measurable gain, and deaths barely changed. He already walks right there, which may already steer barrels down it |
| Small changes to margins and timing (exam, 1,000 games each) | 88.9–91.7%, against 90.9% | A plateau near 91%: tuning alone won't reach 95% |
| Predicting wild barrels as a fixed zig-zag (2,000 fresh games) | 89.3%, against 91.0%; wild barrel deaths 79, against 62 | Too confident in one path. Treat each bounce as uncertain until the influence of Mario's position and input is measured |
| Preferring straight jumps on floors 3 and 4 only (same 1,000 games) | **93.2%, against 91.6%**; 91.5% on fresh games | Adopted, as floor 4 deaths fell. Fresh games show a smaller gain than the tuning set did |
| Also preferring straight jumps on floors 2, 5 or 6 | 92.6–93.2%, against 93.2% | No gain |
| Preferring straight jumps everywhere (1,000 fresh games) | 88.0%, against 91.6%. Floor 4 deaths 29, against 51; top section 61, against 10 | Good on floor 4, bad near the top. Being tested per floor |
| Only jumping at barrels really coming at him, everywhere | 87.3%, against 91.6%; top section deaths 51, against 10 | Too passive near the top |
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
| When heading for the right ladder on floor 5, steer top-girder barrels down the broken ladder in front of Kong: press Left as they pass, by jumping straight up, or while jumping a barrel | **Being tested** |
| The first wild barrel falls straight down; later ones zig-zag, influenced by Mario's position and the direction he holds at each bounce | **First wild confirmed: straight down to the fourth girder in 181 of 181 games.** Later ones: 148 of 186 moved sideways before there. Influence of held direction: see "Wild barrels: measured" |
| Combinations of steering can avoid scenarios that can't be jumped | **Not built yet** |
| Holding left or right as a wild barrel hits a girder flings it away | **Not tested yet** |
| Only barrels on his level, or coming down ladders, need jumping | Already how he behaves |
| Grouping barrels and fireballs for points | Scoring step, not started |
| Holding left or right during a jump widens the scoring area | Scoring step, not started |
| Top-right double backjump is low value | Not planned |

## Expert review of 10 deaths (2026-11-01, video from batch v10)

| Death | Game | The user's view |
|---|---|---|
| 1 | 300386 | Jumped towards a ladder a barrel could come down. A straight jump would have avoided it |
| 2 | 300303 | Jumped over nothing on his own level. Maybe confused by barrels above or a girder edge |
| 3 | 300776 | Walked into a wild barrel. Standing still or a vertical jump probably misses it |
| 4 | 300487 | Wild barrel, fairly understandable. A straight jump across the barrels may have been safer |
| 5 | 301094 | Timing: his jumps left no time for the one that killed him. A back-jump in between might have helped |
| 6 | 301996 | Wild barrel, probably understandable. Could he stop moving left and guide it right? |
| 7 | 301857 | Jumped towards a barrel that could come down a ladder. Should wait to see what it does, then jump |
| 8 | 301804 | Tried to back-jump too late |
| 9 | 301604 | Jumped right into a barrel because a wild was coming. A calm vertical jump probably survives |
| 10 | 301669 | Jumped right towards a ladder a barrel could and did come down. Why not jump straight up? |

Themes: prefer calm straight jumps, stay away from ladders that barrels may use, wait for barrels to commit.

## Expert review of 10 more deaths (2026-11-01, video from batch v12)

| Death | Game | The user's view | What the trace showed |
|---|---|---|---|
| 1 | 400231 | After a ladder, walked towards a barrel and jumped too late. Did he not know it was there? | He knew. The obvious straight jump was rejected because each plan had to walk on after landing, into the next barrel 60 pixels away |
| 2 | 400287 | Legit death, but why jump for no reason? Look for a way out using save states | Wild barrels sit on a girder after a bounce, then speed up. He models a steady fall, so he thought it had gone past |
| 3 | 400292 | Jumped towards a ladder and the barrel came down it. So close to a ladder, jump straight | Same as death 1: standing still after a straight jump was never an option, so the risky sideways jump looked best |
| 4 | 400965 | Legit, unavoidable | |
| 5 | 400675 | Jumped right, then a barrel further along came down. Unaware of what was up there | |
| 6 | 401794 | Rough. Only fast reflexes jumping left would have worked | |
| 7 | 400578 | Walked under a ladder with a barrel above it. Completely avoidable | **Bug:** for the first few frames on a ladder, a barrel was still predicted to roll sideways, so the way looked clear |
| 8 | 401138 | Fireball pressure, unusual. Ignore for now | |
| 9 | 401245 | Jumped straight up beside a chasing fireball. Should have run | Fireballs are only predicted 30 frames ahead, and a jump lasts 41 |
| 10 | 401006 | Legit fireball death, ignore | |

Decision by the user: leave fireball deaths out of the percentage for now. Games lost to fireballs are dropped from the count, and the figure with them included is still recorded.

## Wild barrels: measured (2026-11-01)

- **How they fall:** they rest about 6 frames on a girder, then fall from 0.5 pixels a frame, gaining about 0.0625 each frame. Sideways speed changes at each bounce.
- **Internal difficulty:** the game's difficulty value (0x6380) rose from 1 to 2 at frame 1984 in all four games checked, about 33 seconds in. A median clear takes 2,044 frames, so most play is at difficulty 1.
- **Held direction at a bounce (save-state test, left v right v nothing):** at natural difficulty 1, 53 of 726 bounces changed, and not reliably in the held direction. With difficulty forced to 3 or 5 for the test, about 5% changed, with no consistent direction. Most of these bounces had Mario far away and early in the game, so this doesn't rule out steering in other situations. The user reports it does depend on difficulty.
- **Death 2 (game 400287), tested with save states:** walking right survived from almost any moment in the last 2 seconds. Standing still or jumping left rarely did. So it was avoidable with the right move, by getting out of the barrel's way.

## Going through every death (2026-11-01)

`tools/autopsy.py BATCH` replays every death, records what he saw and planned, and tries six simple moves from save states at every moment in the last 4 seconds. Its first step checks that the original inputs still die on the recorded frame. An early version wasn't aligned to the frame, and that made death 2 look more escapable than it was. All 111 deaths in exam v13 passed the check. Every one had some simple move that worked at least 20 frames before death, but that's hindsight: barrels make random choices he can't know in advance.

Causes found by reading traces:

| What went wrong | Evidence | Fix | Result |
|---|---|---|---|
| After landing, plans had to walk on, so a straight jump looked unsafe | Games 400231, 400292 | Plans can land and stand still, and take a quick straight second jump | 93.9% to 95.8% on tuning games, with the ladder prediction fix below |
| Barrel starting down a ladder still predicted to roll sideways | Game 400578 | Predict it straight down | Part of the same gain |
| Barrel just entering a ladder predicted to land on the girder it was leaving, so the ladder looked free | Game 500188 | Find the right girder | With the next row, 94.3% to 94.8% on new games |
| A jump press within 3 frames of landing is ignored, and holding the button doesn't help: it needs a fresh press from 4 frames after landing | Game 500254, then save-state test | Tap twice; a tap during a jump does nothing | See above |
| Wild barrels modelled as a steady fall | Measured | Rest 6 frames on a girder, then accelerate | **94.8% to 96.3% on new games; wild deaths halved** |
| Planning teleports him back to his waiting spot after a jump past it | Game 400675 | Walk back at walking speed | No gain alone (95.8% v 95.8%), left off |

Exam v13 scored 95.3% on 2,000 new games, but the same player scored 94.3% on another 1,500, so single exams still move by about a point. Judge on the lower bound.

Things seen on floor 4 in the 96.3% version (batch d3, 1,500 new games; 47 of its 70 deaths were on floor 4, 7 of those to fireballs):

- **His waiting spot is under the wild barrel column.** He waits near x=61, and the first wild barrel falls at x=59. When nothing looked close he only checked 20 frames ahead, too late to step aside. 13 wild deaths were at x=60-79.
- **Retreating down the ladder for nothing.** Games 600022 and 600286: he backed down for a wild barrel falling straight at x=59, 8 pixels from the ladder at x=51, which can't touch him. A barrel rolling along below then killed him.
- **Treating every bounce as certain.** 18 of the 70 deaths came straight after "no safe plan", because all three directions counted as certain hits. He should weigh the likely ones instead.
- **Height between girders varies.** At the left of floor 4, the peak of a jump clears the girder above by under 1 pixel at x=61 and hits a barrel there at x=50. A human avoids jumping under barrels there. Near-miss scoring treated this exact gap like a timing risk (tested as `above_ok`: 96.3% v 96.3%, no gain alone).
- **Walking away from a rolling barrel is slow.** It rolls at 1.0 pixel a frame against his 0.67. Games 600386, 600523 and 600634 walked away for about 30 frames, then back-jumped too late. Worth studying.
- **Barrels coming off a girder end get to him 2 or 3 frames sooner than predicted** (games 600545, 600690), which matters when jumping towards the end.

Results on the same 1,500 games (first game 600000), counted without fireball deaths:

| Change | Cleared | Lesson |
|---|---|---|
| Starting point | 96.3% | |
| First wild falls straight, and looks 60 frames ahead whenever a wild barrel is about, for **all** barrels | 95.6% | Wild deaths 26 to 11, but deaths near the top tripled: **over-applied** |
| Same, but the long look applies only to the wild barrel | 97.2% | Wild deaths 9, and the top recovered. Keep rules to the situation they're about |
| Also better arc prediction for barrels leaving girder ends | **97.6%** (at least 96.7%) | Barrel deaths 32 to 20 |
| Flat penalty for any possible wild bounce | 95.3% | Too crude; weigh by whether he could react |
| Barrels on the girder above aren't near misses | 97.2% v 97.6% | No gain, left off |
| A might-come-down barrel only counts as a risk if he couldn't see it and jump in time | 97.6% | No change alone |
| Girder-end barrels timed exactly from the edge | 97.2% | Slightly worse alone |
| Both, plus wild bounces judged the same way | 97.7% | With fireballs counted, 96.9% v 96.5% |
| Plus on ladders, only certain wild paths count | **97.8%** | With fireballs counted, 97.1%. Each step is within noise, so judged by a fresh exam |

Measured from every traced game:

- **Girder-end arc:** always starts at (26,117), (26,183), (228,84), (228,150) or (228,216). From the edge it moves out 9 pixels and falls t*t/30 over 24 frames, pauses about 2 frames, then rolls back at 1 pixel a frame.
- **Wild barrel direction at a bounce:** after moving right: same way 197, reverse 63, straight 24. After moving left: same way 158, reverse 74, straight 23. So about two thirds carry on the same way. Sideways speed afterwards varies between 0.1 and 1.0 pixels a frame.

**Fresh exam, same 3,000 new games (first game 700000):** the previous version scored 97.6% (at least 97.0%), with 38 barrel, 32 wild and 23 fireball deaths. The newest scored 97.1%, with 32 barrel, 52 wild and 22 fireball. So 97.8% on the tuning games was luck. Treating wild bounces as only possibilities **raises** wild deaths, even when judged by whether he could react. Lesson: small gains on tuning games prove nothing; always compare on the same fresh games.

**Sorting wild barrel deaths (exam v14old, 33 of them):** a bounce leaves about 21 frames before contact, and 9 of those go on reaction. In 10 deaths a move after seeing the last bounce still worked, mostly running straight away. In 23 only being elsewhere before the bounce worked, and most of those he was mid-jump. Many were at floor 5, x=45-75: he jumps right off the x=51 ladder just as Kong releases a wild barrel, and it falls onto him at the top of his jump. He couldn't have seen it when he pressed.

**Bug found while building odds for wild barrels:** Kong's next barrel, imagined before it appears, was being predicted as a wild barrel, because it had no type set.

**Same 3,000 new games (first game 800000):**

| Version | Cleared, not counting fireballs | Counting fireballs | Barrel / wild / fireball deaths |
|---|---|---|---|
| Earlier best | 97.0% | 96.0% | 51 / 32 / 32 |
| Plus odds-based risk and exact girder-end timing | **97.6%** (at least 97.0%) | 96.4% | 35 / 36 / 35 |
| Plus wild bounces as possibilities | 96.9% | 95.7% | 40 / 48 / 38 |
| Plus the imagined next barrel treated as normal | 96.1% | 94.0% | 65 / 36 / 66 |

So odds-based risk and exact girder-end timing stay. Wild bounces as possibilities failed a second fresh exam, so they stay off. Correcting the imagined next barrel doubled deaths near the top. The wrong prediction was accidentally making him cautious of Kong's next throw, so that caution matters and shouldn't be removed without replacing it.

**Kong's rhythm, measured:** a wild barrel only ever appears at one moment: 80 frames after a normal throw (79 or 80 in all 108 cases measured), or 64 after a wild one. A normal barrel comes at about 128 otherwise, so a person watching Kong can feel the moment coming. Roughly 1 chance in 10 it's wild. Once it appears at (59,77), it sits about 15 frames, then falls and reaches the girder below about 44 frames after appearing. About a quarter fall straight; the rest drift up to 1 pixel a frame, more often to the right.

**First tries on the same 3,000 games (97.6% before):**

- Weighing that moment before jumping cut wild deaths from 36 to 25, but scored 93.6%. It exposed an old bug: a jump chosen on the last rungs of a ladder is ignored by the game, yet he stood there for a whole jump thinking he was in the air. 114 deaths came from that spot.
- Rewarding him for carrying on with a plan scored 85.2%. The reward also applied to putting off a jump, so he put jumps off until too late. A simple reward for steadiness has to be narrowed to turning back under a barrel.

**Second tries, same games:** the ladder fix alone changed nothing, 97.5%, with floor 5 now clean. Adding Kong's rhythm scored 91.2%, and about 220 of the deaths were on the top floor holding a hammer. Waiting further left takes him over the hammer at x=37 on floor 5. He can't jump with a hammer, but he kept planning jumps, then stood with his back to barrels thinking he was in the air. Steadier choices improved that to 93.4%. Playing the odds added nothing yet, 93.5%. The player has never handled a hammer, because he rarely went near one before.

**Third tries, same games (first game 800000):**

| Version | Cleared, not counting fireballs | Counting fireballs | Barrel / wild / fireball deaths |
|---|---|---|---|
| Previous best | 97.6% | 96.4% | 35 / 36 / 35 |
| Ladder and hammer fixes, keeps away from the hammer | 97.8% | 96.7% | 33 / 31 / 34 |
| Plus Kong's rhythm and steadier choices, using the hammer if he gets it | 93.1% | 91.9% | 179 / 27 / 38 (135 holding the hammer) |
| Same, but keeps away from the hammer | 97.9% | 96.7% | 36 / 25 / 37 |
| Plus plays the odds when no clean option is left | **98.0%** (at least 97.5%) | 96.8% | 33 / 25 / 37 |

Simply turning to face barrels with the hammer doesn't work, so hammer use needs proper study when scoring starts.

**Fresh exam (first game 1000000, 3,000 games):** new version 97.9% (at least 97.3%, 96.7% counting fireballs), previous 97.6% (96.5% counting fireballs). Barrel / wild / fireball deaths 32 / 27 / 37 against 39 / 30 / 35. On individual games the new version won 40, lost 30, and both died in 31. That difference alone could be chance, but it's the same direction as the 98.0% v 97.6% on the earlier games, so it's now the default.

**Bug found tracing floor 4 left-end deaths:** the predicted barrel coming back from the left girder end was about 4 pixels behind the real one. It went too far out and started back about 2 frames late, so he landed from long jumps exactly where it really was. Several of these were him jumping away from a wild barrel into that spot.

**Same games (first game 1000000):** following Kong's wild barrel past its first bounce 97.9%, no change. Fixing the girder-end prediction **98.35%** (at least 97.8%, 97.1% counting fireballs), with barrel deaths down from 34 to 20 and floor 4 deaths from 42 to 28. Weighing Kong's wild barrel one floor lower 98.0%, with wild deaths up from 25 to 34, so that stays off. These games have been used for tuning now, so 98.35% still needs a fresh exam.

**Checking every prediction against what happened (160 games):** normal barrels are now within 1 to 2 pixels up to 60 frames ahead. The wild barrel's sideways speed wasn't: it was judged from a few frames of whole-pixel positions, so it read 0.6, 0.0, 0.67, 1.0 pixels a frame within 8 frames for one steady barrel. In one traced death he saw "falling straight down" and stayed put under it.

Judging wild barrels by motion since the last bounce, tuning games: 98.25% v 98.35%, wild deaths 28 v 25. No gain, despite fixing a real measuring fault. It goes through the next fresh exam to settle it.

**Fresh exam (first game 1200000, 3,000 games):**

| Version | Cleared, not counting fireballs | Counting fireballs | Barrel / wild / fireball deaths |
|---|---|---|---|
| Before the girder-end fix | 97.6% | 96.3% | 35 / 34 / 40 |
| With the girder-end fix | 97.8% | 96.6% | 28 / 34 / 39 |
| Plus wild barrels judged since the last bounce | **98.15%** (at least 97.6%) | 97.0% | 22 / 30 / 34 |

So the 98.35% on tuning games was somewhat flattered; the same version scored 97.8% here. The girder-end fix is sound: game by game it saved 10 and lost 2. The wild barrel judgement saved 30 and lost 21 here, after a slight loss on the tuning games, so its evidence is weak. It stays because it corrects a real measuring fault and leads across both sets combined. Floor 5 deaths rose with it on both sets (1 to 6, and 3 to 8), so that needs checking.

**Remaining wild deaths (exam, 33):** 11 on the top floor at x=79-88, walking or just landed, where moving left still worked. His sideways speed for a barrel leaving Kong read too low, because it counted the 10 frames before it starts moving: 0.58 when it was really 0.75, so he thought he'd walk clear ahead of it. 7 more at x=43-49: a straight jump over a rolling barrel, with a wild barrel appearing just after he left the ground and drifting onto him. Those look close to unavoidable.

Speed of a wild barrel leaving Kong, timed from when it actually starts moving sideways (first_drift), on 3,000 new games:

| Version | Cleared (no fireballs) | At least | Counting fireballs | Barrel / wild / fireball |
|---|---|---|---|---|
| Before | 98.24% | 97.7% | 96.90% | 22 / 28 / 41 |
| Speed fix (now default) | 98.68% | 98.2% | 97.27% | 20 / 18 / 43 |
| Speed fix, Kong's rhythm weighted twice | 98.65% | 98.2% | 97.23% | 20 / 19 / 43 |

Game by game the fix saved 24 and lost 12. Wild deaths fell by about a third, and top floor deaths from 24 to 15. Weighting Kong's rhythm twice added nothing, so it stays at 0.1. Fireball deaths are the biggest killer left.

**The fireball that kills him (batch t1, 456 replayed games, weighted to all 3,000):** it's always the first one, in all 37 fireball deaths. It appears at frame 284, and always comes up from floor 1 at the ladder at x=99.

| When that fireball reaches floor 2 | Share of games | Fireball death rate |
|---|---|---|
| Straight away, frame 514 | 17% | 4.85% (25 of the 37 deaths) |
| By frame 800 | 6% | 3.4% |
| Later | 43% | 0.47% |
| Never | 34% | none |

The straight climb happens equally often however fast he goes (16–18%). Getting to floor 3 before about frame 550 went with far fewer fireball deaths (0.15% v 1.12%, four test sets), but those games may simply have had no barrel to wait for. Usually he waits at x≈105 on floor 2 for a barrel on the floor above to pass the ladder top, while the fireball climbs just beside him. Only 2 of the 37 deaths came before frame 1000, so the danger follows him up the board.

**Measuring faults, now fixed:** a game's `floor` is the highest floor reached, not where he died, so games now also record `at`, the floor where he died. `floors` used to count a jump on floor 2 as reaching floor 3; jumps no longer count. Replaying the same 3,000 games with the fix: none played differently, 7 arrival times changed.

| Time to reach floor 3 (corrected, batch t1c) | Games | Fireball deaths | All deaths |
|---|---|---|---|
| Under 9.2 sec | 312 | 1 (0.32%) | 4 (1.28%) |
| 9.2–10.8 sec | 2,546 | 29 (1.14%) | 62 (2.44%) |
| 10.8–11.7 sec | 87 | 0 | 0 |
| 11.7–16.7 sec | 35 | 1 (2.9%) | 1 |
| Over 16.7 sec | 7 | 2 (29%) | 2 |
| Never got there | 13 | 10 (77%) | 13 |

Where fireball deaths really happen: floor 2, 10; floor 3, 11; floor 4, 16; floor 5, 4; floor 6, 2. Nearly a quarter come on floor 2, so being stuck there is the real danger. Mildly slow games aren't riskier in this set; the earlier "slow" rows mostly reflected games that never left floor 2.

Changes with no gain so far, on new games: longer fireball prediction (96.3% v 96.3%, though 13 fireball deaths rather than 15).

## Lessons about testing

- **Save states:** check that replaying the original inputs gives the original result first. The frame after a load also uses whatever input is held at that moment, and getting that wrong changes the outcome.
- **Exams vary:** the same player scored 95.3% on 2,000 games and 94.3% on 1,500 others. Don't trust one exam, and compare changes on the same games.
- **Stopping processes by name:** a name match also killed a queue of tests that mentioned that name. Stop them by exact process or task ID.
- **Replays:** check them after any change to the runner with `tools/verify_replay.py`.
- **Fresh games:** use `--first` in `tools/run_batch.py` for a fair exam, and judge on hundreds of games or more.
- **Measure, don't assume:** the worst bugs (the ignored jump press, barrels falling through girders, the broken ladder) were all found by tracing one exact death.
- **RAM disk:** macOS logged every file change on it and filled it, which stalled a batch for 26 minutes. It now has `.fseventsd/no_log`, and batches stop themselves after 120 seconds without results.
- **Stopping stuck workers:** a normal stop didn't end the hung MAME workers. They used half the CPU for 3 hours until found, halving test speed without changing results. Use a forced kill, and check the count afterwards.
- **Moving wallpaper:** over Jump Desktop it costs about two CPU cores. Keep it still during tests.

## 2-1 reaches 97%, and the native runner (2026-11-03)

2-1 cleared 97.03% and 97.07% on two separate fresh exams of 10,000 games (`fx1`, `fx2`). The settings, the evidence for each, the learnings and the unsolved problems are summarised in `PLAYBOOK.md` under "2-1: where it stands". The native runner (dkx through `native/dkh`, 5.1x faster than MAME, identical games) is described there under "Native runner".
