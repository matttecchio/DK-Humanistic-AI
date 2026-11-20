# DK Barrel Lab: findings

What we've learned about playing the barrel boards (1-1 first, then 2-1 to 5-1) safely, including what didn't work. `RESULTS_LOG.md` has every test batch's result, added automatically.

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

## The barrel boards from level 2 to 5 (2026-11-06 to 11-13)

The full log, test by test, is in `PLAYBOOK.md`. This is what it adds up to.

### Facts about the game (measured)

- **Wild barrels from difficulty 5 are aimed at Mario.** At each bounce a wild's sideways speed is (Mario's x − its x) / 64 px a frame. Knowing this took 5-1 from 82% to 94.6%.
- **Kong's wild barrels leaving his hands:** 81% drift towards Mario on their first fall; 19% drop straight down at x=59; none drift away (344 measured).
- **Landing:** a wild sits 7 frames on the girder it lands on, then sinks through it over about 11 more frames (about 18 in all).
- **Jumps:** a straight jump lasts 42 frames. Landing 1–2 px lower (downhill) adds a frame per pixel (43–44); landing higher takes one off (41). After any landing, a fresh press 4 frames later takes him up again, on flat and sloped girders alike. Holding the button never re-jumps.
- **Ladders:** 8 px wide, edge to edge, rails 7 px apart: ladder 91 is x=87–94, the left ladder 48–55, the middle ladder 127–134.
- **The hammer** (from the ROM, 2026-11-14): see "The hammer, exactly" below. In short: 8 frames up, 8 down, set by a counter (0x6394) that also ends it after 512 counts; a rolling barrel is smashed 10–22 px in front with it down; a smash freezes everything about 73 frames. With the hammer, one press doesn't always turn him: he has to watch which way Mario faces (0x6207).
- **Steering:** with the stick pointing towards a ladder, a barrel above takes it about 75% of the time; pointing away or neutral, about 20%.

### What top players do (two INP recordings and a video of the highest game ever played)

- **Recordings:** barra (1,178,400, WolfMAME 0.241) and player 3 (MAME 0.260) replay in sync on our MAME 0.264. DarkFaker's (0.270) doesn't. Serphentizer's 1,269,600 game was read frame by frame from video.
- **Results:** on barrel boards from level 5, barra cleared 51 of 54 and the second player 50 of 52, both taking the top hammer almost every time.
- **Steering is their big edge.** They're rarely right under a ladder when a barrel arrives above it (12–19% of those moments; he was at 34%). From 17–48 px on the side where a dropped barrel rolls away from them, they pull it down 81–85% of the time; he did 8%. Copying that took 5-1 from 98.0% to 98.5% and helped 3-1 and 4-1 too.
- **Copying their single moves at particular spots mostly failed** once tested on every instance of the spot. Copying their habits worked.

### What improved survival on 5-1 (each confirmed on fresh games)

| Change | Effect |
|---|---|
| Aimed wild barrels, `wild_aim`, `kong_aim` | 82% → 94.6% |
| Weighing every plan around ladder 91, hammer near ladders | → 95.5% |
| Knowing where he is from his own presses (`know_self`) | → 96.2% |
| Steering barrels down the middle ladder (Matt's picture) | → 96.7% |
| Faster reactions on barrel boards (65 ms, `react = {4, 4}`) | 97.2% → 97.9% |
| Pulling barrels down like the experts (`steer_pull = 8`, `pull_moving`) | +0.4–0.5 points, twice |
| A 1-frame allowance for his own jump press (`press_lag = 1`) | +0.02 and +0.20, more counting fireballs; on 2-1 (+1.0) and 4-1 (+0.7) too |
| Finer jump timing (`fine_waits`) | +0.2 twice; jumping deaths −22% |
| Rules from Matt's reviewed deaths, r2 and r7 | 98.43 → 98.69%, then 98.67 → 98.76% |
| Removing the older setup rules s1 and s3 | +0.09, +0.13 |

### What didn't help (and why, where known)

- **Banking exact solutions** for single deaths (1,000 out of 1,000 in their own game) lost on new games, even matched on Kong's pose and Mario's walk step: what decides them is the game's hidden random state.
- **Every broad timing change** except finer timing made him worse: the full real jump delay (2–3 frames), slope-aware jump lengths, a quicker second jump, more or less preference for later jumps, keeping a planned jump, and a cost for standing under a live ladder. His settings sit at a local best; one change on its own usually breaks something the others compensate for.
- **The top hammer**, copied from the experts, reached about 80% against 97% without it. The planner doesn't model the grab's slower fall or the swing, so hand-timed trips kept getting trapped.
- **Rules found by search alone**, without a reviewer, saved their own death but didn't hold up over every instance (19 found overnight, none kept).

### What limits him now (5-1)

- **Fireballs** are the biggest cause (about 450 of 840 deaths in 30,000 games).
- **Barrel deaths while jumping:** about 0.7–0.8% of games. They're nearly all last-ditch jumps after he's been trapped for a second or two, mostly by barrels coming down ladders. His planner's safe plan collapses under the risk of barrels that might take a ladder; the fatal jump is the end of that, not the cause.

### Lessons about testing

- **A takeover reshuffles the game's luck.** Any change of input changes the game's random numbers from then on, so from a second or two before a death his own play usually lives too. Judge a fix only at the moments where his own play still mostly dies.
- **Compare on the same games,** and count saved against lost there.
- **Exams vary:** two 30,000-game exams with the same settings gave 205 and 236 jumping deaths.
- **Narrow rules are judged where they act** (Matt: you can't expect a big overall gain from a rare situation): saved against lost in the games where the rule fired, confirmed on a second fresh set.
- **Broad changes** still need the overall figure to rise, twice.
- **Matt's reviews have produced every rule that held up.** A reviewer's eye picks the fix that generalises; search finds one that only saves its own death.
- **Check what a setting actually touches before testing it:** `kong_straight` acted before Kong's release, but #4's problem was just after it, so the test showed nothing.
- **Run names:** a batch name that already exists silently reuses the old run. Setting names: `pull_walk` already existed as a number, so the new switch broke games until it was renamed `pull_moving`.
- **Wait on result counts, not process names,** and don't edit a script that's already running.

## The all-knowing mode, and what it taught (2026-11-14 to 11-15)

Matt asked what a player who could see things no human can would do. The answers, and what they did and didn't teach the human-limited player. The test-by-test log is in `PLAYBOOK.md`.

### Facts from the ROM

- **When a barrel takes a ladder** (0x2186): before the oil drum is lit, always. Otherwise only if Mario is below that ladder; then if the random number's two low bits are under (difficulty / 2 + 1), it goes down when Mario is at the ladder's x or his stick points towards it, else 1 time in 4. Difficulty (0x6380) is 5 throughout 5-1, so: 3 in 4 with the stick towards the ladder, 3 in 16 without.
- **The random number can't be predicted on its own.** Each frame 0x6018 += the frame counter (0x601A) + 0x6019, and 0x6019 counts up in the idle loop while the CPU waits for the next frame, so it depends on how busy each frame was. Different presses reshuffle it from the next frame. Presses that change nothing on screen (down or up away from ladders, presses in mid-air) don't change it at all: the dice follow what the game processes.
- **Hit boxes** (0x2913): two objects touch if |dx| < w1 + w2 and |dy| + 1 < h1 + h2. Mario (4, 7) (the planner's check is exactly this), barrels (2, 2). Each frame Mario's own check comes first, then the hammer's.

### The hammer, exactly

- **Boxes:** up (6, 3) at Mario's x, 16 px above him; down (5, 6) 16 px in front at his height. So a rolling barrel is smashed 10–22 px in front with it down, or just over his head with it up. Only the first barrel in the box is smashed each frame.
- **Swing:** 0x6394 counts each frame he holds it; down when bit 3 of (counter − 1) is set (716 of 716 frames checked). It ends after 512 counts (0x6395 reaching 2), and the counter stops during a smash's pause (about 73 frames, everything frozen), which is why it seemed to last 800–1,000 frames.
- **The grab:** checked once a jump, at frame 19 (its peak): Mario's (4, 8) box against the hammer's (3, 9) at (36, 100), so he must be at x=30–42 then. A straight grab jump is otherwise normal (lands at 42). The swing starts 4 frames after landing; until then the hammer is held up.
- **Planned hammer (`ham_plan`, `ham_grab`):** the planner knows all of this, including fireball smashes and when it runs out (Matt: a fireball below is a threat then). It halved the deaths while holding it (217 → 108 in 1,000 games) but reached only 70% against 98% without: most deaths are at the girder's edge, on the way to it or just after. Off.

### Looking ahead (`SEARCH=1`, a separate record)

- He only presses press lists a copy of the game has played out and survived, 120 frames ahead, as a chain of short moves (walk, stand, climb, jumps played to landing), grown each frame from its end with backtracking. The game has no randomness of its own, so that's exact.
- **Every barrel board, 100% including fireballs:** 5-1 10,000 / 10,000, 2-1, 3-1 and 4-1 10,000 / 10,000 each, 1-1 1,388 / 1,388. 40 random games' inputs replayed with no look-ahead: all clear. About 1,000 emulated frames a game.
- **Handed his deaths before they happen** (all 285 of a 10,000-game run): from 100 frames before, 285 / 285 escape; 80: 284; 50: 269; 40: 233; 30: 159; 12: 97. Most deaths are decided in the last half-second or so.

### The oracle review of his deaths (`tools/oracle_review.py`, `oracle_why.py`)

- **What killed him**, at the last moment it could be escaped (130 barrel deaths): rolled exactly as he predicted 56; came down a ladder he had as a "maybe" 31; he was already in the air 20; wild 16; a ladder he never thought it could take 6.
- **Dice-proof answers:** with new dice set at that moment (0x6018 reset, the board unchanged), 49 deaths had a move that clears 85%+ (1,035 / 1,100 against his own 268 / 1,100). Usually tiny: a 4-frame step, then a jump when the barrel comes.
- **Why he missed them:** his planner predicted a hit for 23 (15 of them because his plans can only "step, then keep walking"), a rule or shortcut decided 10, safe but preferred another 9, safe but risky 7.
- **Didn't transfer:** adding "step, then stand" and "step, pause, jump" plans made him worse everywhere (98.60 → 97.92%) and did nothing as a last resort; weighing "maybe" barrels by the game's real odds was neutral (16 / 16); retuning his main settings on 1,500 tight ordinary moments found nothing better (his settings are at their best). Like the scenario rules, what's right at the moment of death doesn't carry to his ordinary play.
- **So 5-1 is near its human-limited ceiling:** even finding every dice-proof answer would take it from about 98.7% to about 99.1%.

### Also tried, and rejected (5-1)

- **Contingent planning** (plan for a "maybe" barrel with a way out): 93.4% at first, 98.1–98.2% with extra reaction margins, never above 98.65%.
- **A danger table learned from his own games:** it spots trouble earlier than his planner (AUC 0.88 against 0.75), but as a cost in his planning it was neutral twice.
- **Matt's confirmed fixes as tight position rules,** even gated to moments when his planner was struggling: 7 saved / 151 lost.

### 3-1 and 4-1 (2026-11-15, each confirmed on two fresh 10,000-game sets)

| Change | Effect |
|---|---|
| 3-1: 5-1's press timing, finer jump timing, hammer facing and w_with 30 | 95.16 → 95.83%, 95.23 → 95.90% |
| 4-1: w_with 30 | 95.13 → 95.22%, 95.56 → 95.76% |
| 4-1: finer jump timing (rejected) | 95.13 → 94.20% (its 5th-girder deaths 166 → 299) |

## The rivet board, 1-2 (2026-11-15 to 11-19)

From 0% to about 86.7% in five days (`cv2` 8,666 and `cvf` 8,690 of 10,000 new games). The day-by-day log is in PLAYBOOK.md, "Rivets, 1-2".

### Facts about the board (measured)

- **Layout:** Mario's girder y 240, 200, 160, 120, 80 (girders 1-5), Kong on top. Rivet columns x 72-79 and 176-183 on girders 2-5. A rivet comes out at its middle (x 76 walking right, 74 left); walking into a pulled gap is fatal; gaps can be jumped. Rivets left: 0x6290.
- **Kong** stands on the top girder's middle: touching him kills (Mario's x 103-151 there). He splits that girder in two.
- **Bonus timer** 0x62B1 (hundreds), one tick ~137 frames; it runs out ~6,400 frames into the board.
- **Difficulty** (0x6380) steps up every 2,040 frames on the board (34 s): 1, 2, 3 at frames 0, 2,040, 4,080. Fireballs get faster with it: on girders right 0.43 / 0.53 / 0.58, left 0.36 / 0.46 / 0.48 px a frame (pauses included); coming down ladders roughly triples by difficulty 3.
- **Mario's jump** only gets ~9 px off the girder, and a fireball still touches him there: jumping a fireball is a gamble (Matt's rule: only when it's life or death; a planned version lost 25%). A jump must be held 3 frames or the game often misses it (the 1-frame bug cost 129 of 198 "in the air" deaths before it was fixed).

### How the fireballs behave (measured in his own games)

- **Spawns:** one every 256 frames while fewer than 5 are out; always at the end of a girder (girders 1-4: right x 208-232, left x 16-40), **on the side opposite Mario** (the line is exactly x 128).
- **The maze:** a fireball never crosses a pulled rivet's gap. They walk through rivets that are still in.
- **Ladders:** a ladder going up is taken on 16% of visits, whatever Mario does; **a ladder going down only when Mario is below** (22% of visits then, never otherwise; Matt's rule).
- **Turning:** a fireball turns round on a girder ~12% per 8 frames; **it turns towards Mario's side 66% of the time with him on its girder, 74% with him below, 52% above**: they can be steered (Matt: "he has a better awareness of the fireballs and is able to manipulate them").
- **Freezes (Matt):** with a hammer out, a smash freezes the whole game for a moment (15% of hammer time). Apart from that, **only the 2nd and 4th fireballs (slots 1 and 3) stop of their own accord:** a long freeze of ~336 frames, almost always at the top of a ladder going down and only from difficulty 3, and shorter stops elsewhere in whole steps of ~56 frames (56, 112, 168, 224; 336 = 6 x 56). Fireballs 1, 3 and 5 never stop on their own.
- **The hammer** doesn't make them flee: apart from the smash freezes they move the same with or without it.

### How the experts play it (barra and player 3's recordings; the WR video; a second world-class video)

- **The star order:** 2L, 4L, 5L, bottom hammer, 3L, 3R, 2R, middle hammer (unless the right is clear), 4R, 5R; crossing directions 2L left, 4L right, 5L left, 3L right, 3R right. Their left-side pace matches ours.
- **After 2R:** right side free (by our zone test), they skip the middle hammer 6 / 6; busy, they take it 30 / 37.
- **With the middle hammer** (second video, every board): they leave 4R in and stand on girder 4 just left of it facing right, smashing what comes up the right-hand ladders through the 4R spot (each respawns on the left, trapped); 4R comes out only as the hammer runs out. (Our fixed-spot version lost in five variants: they move along girder 4 to meet each one.)
- **The safe room:** once 3L and 3R are out, girder 3's middle is cut off at both ends; they wait there to time the move up.
- **The last two rivets** take them 20-50 s more: points leeching off Kong, not needed for clearing.

### What improved clearing (each confirmed on fresh games)

| Change | Gain |
|---|---|
| Matt's crossing directions, the hammers, gap jumps, fireball headings | 0 → ~42% |
| Less caution (fireball allowance 4 px, look-ahead 36 frames) | → 57.7% |
| Jumps held 3 frames (`riv_jump_hold`) | 63 → 68% |
| Whole-board safety map (`riv_safe_w`, Matt: "think about the whole board") | → 72.6% |
| Forgetting a stale crossing direction (stuck at 2R until the timer ran out) | → 80.6% |
| Kong as a wall (`riv_kong`) | → 82.1% |
| Never walk to a ladder a fireball is on, no hesitating on ladders (`riv_ladder_busy`, `riv_ladder_commit`; Matt) | +~1% |
| Free pass up the right when the right is clear, only from the right side (`riv_free_zone`, `riv_free_where`; Matt) | +~1% |
| Imagined futures as a tie-break, tighter allowance on the right half (`riv_mc`, `riv_right`) | +1.2% |
| No straight jump at a fireball coming up the ladder below (`riv_lod_dy`; Matt) | +0.2% |
| Two-step planner by the imagined futures (`riv_plan2`) | +0.5% |
| **Middle hammer or rivets by playing both routes forward** (`riv_choice_mc`) | +0.8% |
| **The way down to 2R by playing both ways forward** (`riv_down_mc`) | +1.5% |
| The way up after 2R through the middle as well (`riv_choice_via` "mid") | +0.4% |

The pattern since the 18th: **the simulator comparing two sensible whole routes at a known decision point wins; hand rules and tuning no longer do.**

### What didn't help (and why, where known)

- Hammer hunting; leaving 2R for later; committing to moves; pull-and-jump-back (lost even after its bugs were fixed).
- Stay right after the left sweep, the spawn clock: changes ~1 game in 100.
- Waiting before the right half in any form (at the left hammer, by Kong, Matt's points play): more fireballs spawn meanwhile and the right half comes later and harder (clears 1.5-3 s slower, more timer deaths).
- Looking further ahead (worst case or along headings): he hesitates on ladders. Three-step planner: no better than two.
- Gap jumps free in his routes: -5% (a jump commits him ~46 frames; fireballs still reach him in the air).
- Hurry mode with the timer low (any form): the late timer games are stuck behind a fireball; risk only swaps timer deaths for fireball deaths.
- The learnt danger table: it measures "danger given how he then played it", which doesn't transfer to other choices.
- The general route choice (13 detours at any moment): -8%; the best of many noisy estimates looks good by luck, and detours cost time.
- Hammer farming at a fixed spot: lost in five variants (best -0.5%).
- The pull towards Mario in the simulator: real, but a fixed course can't capture the fireballs reacting to where he really goes; calibration got worse.

### Lessons about testing (rivets)

- Any change reshuffles ~25% of games either way: 1,000-game tests can't see a 1% change. Rivet tests are 10,000 games on the same games as a reference with the same defaults, and a fresh 10,000-game check before adopting (Matt).
- Test a change where it acts (scenario replays with new dice, `rivet_scen.py`), then at scale.
- A rule from Matt's review that loses was applied too widely or never fired: check where it fired (the free pass: fired in 808 of 3,000 games, from the wrong side; the under-ladder rule: three narrowings).
- Practical: each run copies `lua/` when it starts; `--set` takes a Lua value (text needs quotes); check a run name is free first; queue scripts must not wait with `pgrep -f` on text in their own command line.

### Later results (2026-11-20 to 11-21)

- **On since:** the 2nd / 4th fireballs' freezes held still (`riv_freeze`, `riv_freeze_short`, +0.2%); hopping right from girder 2's middle as one of the hammer choice's plans (`riv_choice_hop`, +0.4%, Matt). **Now ~87.2%** (`hp1`, 8,722 / 10,000).
- **Freezes corrected (Matt):** every other stop is a smash freeze; only the 2nd and 4th stop on their own (long ~336 frames at ladder tops from difficulty 3; shorter ones in ~56-frame steps).
- **Matt's five outside-the-box options, none won:** (1) no hammer parking to beat the clock -3.5%; (2) learning the best choice from 18,000 replays of ordinary moments: one pattern, -1.5% at scale; (3) an all-knowing rivet search as a teacher: never matched the player (23/64 vs 55/64); (4) the rivet order by the simulator -5%; (5) smash only on the right -0.5%. Also: simulator settings, the last-rivets "go round" choice (-5%), hop cost by landing (even).
- **The pattern:** changing the plan itself loses; gains come from Matt's observations and from the simulator choosing between two ways to do the same next step. Full handover: RIVETS_HANDOFF.md.

