# DK Playbook

The short record of what the player does, what we've learned and what we've decided. It exists so nothing gets lost or undone. `FINDINGS.md` holds the full detail and `RESULTS_LOG.md` every test.

## Keeping 1-1 from getting worse

- **Benchmark:** 98.68% cleared on 3,000 new games (at least 98.2%), 97.27% counting fireballs. Deaths: 20 barrel, 18 wild, 43 fireball, 1 other. Batches `t1` and `t1c` (identical play), first game 1400000.
- **Frozen player:** `baselines/1-1/lua` is the exact code and settings behind that result. Don't edit it.
- **The check:** `python3 tools/regress_1_1.py NAME` replays the benchmark's games and compares them one by one. Run it after any change to shared code.
  - No games played differently: 1-1 is untouched.
  - Any difference: the change needs a fresh exam on 1-1 as well, comparing old and new on the same new games. It stays only if 1-1 is no worse.
- **Changes for later boards:** make them apply only on those levels, so 1-1 plays identically. A setting that suits 2-1 doesn't automatically become the 1-1 default.

## Decisions

| Decision | Why |
|---|---|
| Barrel boards only for now, moving from 1-1 to 2-1 | The user's direction, November 2026. Later barrel boards are harder and safe spots may shift |
| Target on 2-1: 97%+ | The user's target |
| Leave the hammer until the scoring stage | Best case it prevents about 0.8% of deaths on 1-1. The one attempt at using it dropped the clear rate from about 98% to 93% |
| Headline figure excludes fireball deaths | The user's call. The figure with fireballs is always shown beside it |
| Exams show live on the boards, never `--no-grid` | Viewers would be bored otherwise |
| Later levels start through the game's own board-clear step | The game itself sets the bonus, difficulty and board order |
| A change is only believed after a fresh exam | Gains on tuning games have repeatedly shrunk on new games (98.35% became 97.8%) |
| 97% on 2-1 is judged on 10,000-game fresh exams | Fresh 3,000-game sets differ in difficulty by about a point (96.99% on one, 96.59% on another), so one set can't settle a figure that close |
| 2-1 reached its target; next is 3-1 | 97.03% and 97.07% on two separate sets of 10,000 new games (`fx1`, `fx2`). 2-2's barrel board is the same board, so the user chose to move to 3-1 once 2-1 was dependably 97%+ (November 2026) |
| Tests run on the native runner (`--native`) | 5.1x faster than MAME, with every game identical to MAME's. MAME stays for the live stream and videos |

## Rules from the user

- **Keep the logic as it is when speeding things up.** Speed work must give identical games, input for input, checked with `native/check.py` (November 2026).
- **Context over blanket rules.** A rule that works in one situation may not apply overall. When a test saves some games and loses others, compare the positions in both, find what separates them, and retest it only there.
- **Steer anywhere it helps.** Steering isn't limited to one girder: pull a barrel down a ladder, or keep it rolling past, wherever that leaves him safer.
- **Keep the machine busy.** Start the next test before reporting; an idle machine wasted about two hours on 2026-11-03.
- **Human limits:** reactions of 133–150 ms (8–9 frames), inputs land 0–1 frames late. Never move these into the tunable rules.
- **Fair play:** no reading upcoming random numbers, no frame skipping in MAME, no frame-perfect tricks.
- **No farming:** no fireball leeching, no all-800 hammer smashes, no stalling on lower girders, no farming barrel jumps. Grouping fireballs is fine at the top or in transitions.
- **Judgement:** weigh the odds in each situation as a person would. A rule that works in one setup may not work in another, so no blanket strategies.
- **Acceptable deaths:** only wild barrels a human couldn't have avoided.
- **Consistency matters most.** Clearing comes first, scoring later. Real-world human play is the standard.
- **Updates:** plain language on the page and in replies. Warn before any windowed MAME run. Commit or push only when asked.

## What's switched on for 1-1

Every change below improved or corrected something; `lua/params.lua` holds the values.

| Setting | What it does |
|---|---|
| `ladder_fix`, `ladder_top_fix` | Barrels on ladders are predicted straight down, landing on the girder below |
| `tail_stay` | Plans can land and stand still, rather than always walking on |
| `second_straight`, `land_stall2`, `seconds` | When and how a second jump can follow a landing |
| `double_tap` | Taps jump twice in case the first came too soon after landing |
| `top_guard` | Never presses jump on the last rungs of a ladder, where the press is ignored |
| `wild_model`, `first_straight`, `wild_tail` | The measured way wild barrels rest and fall, how the board's first falls, how far ahead to check |
| `exact_arc`, `arc_timed`, `arc_snap` | Barrels leave girder ends at exactly the measured spot and time |
| `odds_risk`, `odds_fallback` | A possible barrel only counts if he couldn't react; with no clean option he plays the measured odds |
| `kong_watch`, `kong_chance=0.1`, `kong_y=125` | Weighs the moment Kong could release a wild barrel |
| `wild_smooth` | Judges a wild barrel by its motion since its last bounce |
| `first_drift` | Times a wild barrel's sideways speed from when it starts moving |
| `w_commit=20` | Avoids turning back when a wild barrel is about |
| `ham_face`, `ham_avoid` | Stays away from the top hammer; if he holds one, no jumps |
| `ladder3=131`, `arrive3`, `arrive5` | Route: shorter way up from floor 3, waits past ladders so barrels roll away |

## Tried and rejected on 1-1

Don't retry these without a new reason.

| Idea | Result | Why it failed |
|---|---|---|
| Measured odds for wild bounces (`wild_rays`) | 96.89% v 97.57% | No gain |
| Predicting Kong's next barrel "correctly" (`kong_fix`) | 96.08% | The old bug's caution was helping; top floor deaths doubled |
| Facing barrels with the hammer | 93.05% | 135 deaths while holding it |
| Rewarding him for sticking to plans (`w_commit` as a reward) | 85.2% | He kept putting jumps off |
| Weighing Kong's wild barrels further down (`kong_y=145`) | 98.01% v 98.35% | More wild deaths |
| Weighting Kong's rhythm twice (`kong_chance=0.2`) | 98.65% v 98.68% | Nothing added |
| Longer fireball prediction | 96.3% v 96.3% | No overall gain |

## Key things we've learned

**Measuring**
- Compare versions on the same new games, 3,000 at a time. Small gains on tuning games vanish.
- Look game by game: which saved, which lost. The headline alone hides swaps.
- A game's `floor` is the highest floor reached; `at` is the floor where he died. Before batch `t1c`, `floors` could count a jump as reaching a floor, and `at` didn't exist.
- A move that worked in a replay doesn't prove a person would have chosen it.

**Game behaviour on 1-1**
- Difficulty (`0x6380`) starts at 1 and rose to 2 at about frame 1984.
- Kong: wild barrels appear at (59,77), only 80 frames after a normal throw or 64 after a wild, about 10% of the chances.
- Wild barrel from Kong: rests until about frame 15, starts sideways about frame 10, reaches the girder below about frame 44. Bounce direction stays the same about 2/3 of the time.
- Girder ends: barrels go over at exactly x=26 or x=228.
- Jump needs a fresh press at least 4 frames after landing. A jump pressed on a ladder or with a hammer does nothing.
- Hammer on floor 5 is at about x=37, y=113.
- The bonus starts at 5000 on level 1.

**Fireballs on 1-1**
- All 37 fireball deaths in the sample came from the first fireball. It appears at frame 284 and always climbs from the bottom at x=99.
- When it climbs straight away (frame 514, 17% of games) his fireball death rate is 4.85%; when it never climbs it's 0%.
- He usually waits at x≈105 on floor 2 just as it climbs beside him, because a barrel above is passing his next ladder.
- Reaching floor 3 early goes with far fewer fireball deaths, but this may only reflect games with no barrel to wait for.
- 10 of the 43 fireball deaths in batch `t1c` were on floor 2, in games where he never got up to floor 3. Mildly slow games weren't riskier.

**Wild barrels on 1-1**
- Being unsure which way a fresh wild barrel will go is safer than guessing from a few noisy frames.
- Straight jumps at x=43–49 where a wild barrel appears just after takeoff look close to unavoidable.
- Still to examine: 4 deaths at about (56,136), waiting while moving would have saved him.

## 2-1: where it stands (November 2026)

**Result:** 97.03% (`fx1`, first 4000000) and 97.07% (`fx2`, first 4100000), each on 10,000 new games, lowest likely 96.7%. Counting fireballs: 96.61% and 96.76%. Target met. Deaths per 10,000: about 230 barrel, 58 wild, 38 fireball. By floor: 4th girder about 177, 5th about 108, 2nd about 33. Hotspots: 4th girder x=80–100 (waiting at and climbing ladder 91), 5th girder x=90–105 (just off ladder 91's top, beside the broken ladder's foot), 5th girder x=150.

**Switched on for 2-1 only (`params.levels[2]`), and why:**

| Setting | What it does | Evidence |
|---|---|---|
| `jump_ready=49` | Second jump pressed on the exact frame the game accepts it after landing | Measured; fresh +0.5 |
| `press_lag=2` | Allows 2 frames for a press to become a jump | Fresh 96.99% against 96.72% |
| `climb_ym=7` | Sets out to climb if a barrel will pass 7 px below him (real contact), not 9 | Fresh 16 saved / 5 lost |
| `w_risk=250` | A barrel that only might take a ladder costs half as much as before | Fresh 2 / 0. 60 was much worse: he does need to respect them |
| `w_with=60, with_drop, with_cl=2` | Back jump: with a barrel close and coming at him (or dropping down a ladder beside him), jump the way it rolls, if that jump clears comfortably | Matt's deaths 8 and 9. Fresh 11 / 6. Without the room condition it lost (16 / 19) |
| `steer_off=10, steer_here={[5]=true}` | Lets go of the stick as a barrel above crosses a ladder he's walking towards, 5th girder only | From early 2-1 work |
| `ladder4=91, ladder4_top=112, arrive4=-1` | Climbs ladder 91, waiting just left of it | Matt's own waiting spot |
| `after_climb2/3=14`, `wild_after=72`, `guard_free=2`, `w_no_next=150` | Earlier 2-1 tuning | See the tables below |

**Learnings from 2-1:**

- **Fixing what the deaths show is often wrong.** Four times a habit that looks foolish in the deaths was helping in the games he survives: the imagined next throw (`kong_fix`, `throw_every`, `next_drop`, `kong_pose`) and backing down ladder 91 (`ladder_real`, `ladder_commit`). Always count games lost, not just saved.
- **Timing Kong more accurately has never helped** (four tries). The real gap is how a barrel coming down the broken ladder beside him is weighed: only as a possible risk with a 3 px margin, so landing right beside its foot barely registers.
- **Matt's video reviews gave the best fixes** (back jump, the risk penalty). Combine them with `tools/probe_plans.py`, which grinds a death out from thousands of plans, and `tools/why_plan.py`, which shows how he scored each option.
- **Whole-board knob turning is exhausted.** A 14-setting sweep found nothing (`et01`–`et14`). Gains now need new abilities.
- **Practice-set gains under about 5 games are noise.** `steer_far` gave 3 / 0 on practice games and 2 / 5 fresh.
- **A level's settings used to override `--set`** (fixed): treat two identical results as a warning sign.

**Still unsolved on 2-1 (for later, or for the same board on 2-2):**

- Timing the climb at ladder 91. He checks whether the path is clear now; Matt times it, steering barrels down ladders from his waiting spot first (deaths 2, 3, 5, 7 of Matt's review).
- Deliberate steering, pulling a barrel down a ladder or keeping it rolling, wherever it pays, including on ladders. Only the defensive kind exists, on one girder.
- Reacting to Kong releasing a wild while just on the ladder: going back down (Matt's death 1).
- Quicker follow-up jumps when barrels are lined up (Matt's death 10).
- Not landing beside the broken ladder's foot as Kong's barrel comes down it (Matt's death 8, the x=105–125 deaths).

## 3-1: where it stands (paused 2026-11-05, moving on to 4-1)

**Result:** about 88.9% on fresh 10,000-game exams (`hp02` 88.94%, `hi01` 88.80%), counting fireballs about 87%. Up from 75.5% with the 2-1 settings. Not at 97%: Matt chose to move on to 4-1, carrying the level 3 learnings forward (the level 3+ barrel boards share these behaviours).

**What got it here, in order (fresh-game gains):**

| Change | Setting(s) | Gain |
|---|---|---|
| No press-lag allowance: barrels are faster on level 3, so allowing 2 frames per press made jumps late | `press_lag` removed | +5.5 |
| Model bug: after jumping past his waiting spot, `along()` put him back on it at once | `along_fix` | +2.6 |
| Level 3 wild-barrel settings together | `kong_rays`, `kong_y=180`, `ladder_sure`, `wild_dynamic`, `wild_spd=1` | +1.4 |
| Wild bounces as the game's code does them: towards Mario's x at each landing, random speed 1–2 right / 0–1 left | `wild_rom` | +1.3 |
| Matt's steering: in any jump (free, either way) and standing when a few steps are safe | `steer_air`, `steer_pull=3`, `pull_safe` | +0.8 |
| Matt's climb timing: at ladder 91, allow for Kong's next barrel, timed from his pose | `kong_pose`, `next_drop_climb={0}`, `next_drop_pose`, `next_drop_approach` | +1.4 |
| Walls: jumps bounce off x=22 and x=233; the 2nd girder reaches the right wall | `wall_jump`, `wall_right={[2]=true}` | +0.1 |

**Learnings from 3-1 (for every later level):**
- **Wild barrels follow the game's code, not guesswork.** At difficulty 3–4, each bounce heads towards Mario's x at that instant; at 1–2 it's random; at 5 it's aimed with speed growing with distance. On 3-1 the difficulty is 3 from the start, 4 after about 2,000 frames, 5 after about 4,000. Most games end at 3. See the wild barrel notes above.
- **The juke** is being on the far side of a wild barrel's x as it lands. The stick itself isn't read for wild barrels.
- **Steering** is the stick pointing at a ladder as a barrel reaches it (after a difficulty check). Pull barrels down ladders on the side his own girder's barrels roll away to. In the air it's free. Standing, only if the steps it causes are safe. Jumping just to steer cost more than it gained, and so did steering barrels on girders further up.
- **Waiting is cheaper once steering thins the barrels.** The climb timing that lost before steering won after it. Ideas that failed earlier may win on a new base: retry them.
- **Practice-set gains need fresh checks.** Three changes that looked good there lost on fresh games (`steer_far`, steering further up, on-ladder-only climb timing). On 3-1, 3,000-game comparisons have a spread of about 0.6 points; use 10,000.
- **Death recordings are biased** (barrels that came at Mario are over-represented). Test mechanics directly by replaying a real moment with changed inputs (`native/experiments/`).
- **The trace tool must replay native batches natively.** Native-only features made MAME traces show different games. Fixed in `autopsy.py`.
- **Grinding** (`tools/grind.py`, `probe_plans.py --native --steer`): judge by the latest moment a move still works. Changes 3–4 s early alter the random numbers and "survive" by luck. In nearly every kind of 3-1 death a move still worked 23–47 frames before.
- **Board edges:** the left wall is x=22 and the right x=233 (jumps bounce off both). The 2nd girder's right end is at about x=224; his jump model runs 2–3 px short over a full jump, so leave a margin.

**Still unsolved on 3-1 (per 10,000 fresh games, about 1,100 deaths):** the foot of ladder 91 (barrel trains, climbs that turn back, about a quarter), wild barrels on the 2nd, 3rd and 5th girders, just off ladder 91's top beside the broken ladder's foot, and the 5th girder corner drift. Grinding suggests the escapes (`runs/hj00/grind_summary.txt`, latest-moment analysis above).

## Later barrel boards

**2-1 as the game sets it up:** bonus 6000, difficulty 2 from the start. The skipped boards leave points on the score (9,800 in the games checked). Scores now count only this board's points. Batch `u1` was played before this, so its scores are too high.

**Don't change the score in memory:** the one attempt, zeroing it when saving the starts, produced different games even though nothing else was changed. The starts must stay as they are or batches stop being replayable. Everything measured above on 1-1 needs rechecking here. The user notes that positions which feel safe on 1-1 can shift on later boards.

**Measured differences from 1-1 (about 450 games on 1-1, 240 on 2-1):**

| | 1-1 | 2-1 |
|---|---|---|
| Barrels taking the ladder at x=115, floor 3 (only when he's below) | 18% | 69% |
| Ladder at x=131, floor 4 | 11% | 56% |
| Ladder at x=91, floor 5 | 20% | 41% |
| Broken ladder at x=107, top floor | 18% | 32% |
| Usual gap between Kong's throws, in frames | Mostly 128 | Mostly 96 or 120 |
| Wild barrel appears after a normal throw, in frames | Mostly 80 | 48 or 72 |

Barrels only take a ladder when he's below it, on both boards. In the autopsy of 300 deaths, 174 came from barrels coming off a ladder, 53 off a girder end, 43 wild and 30 fireball. In 281 of the 300, some simple move still worked at least 20 frames before death.

Kong's wild barrel seems to come 48 frames before the next normal throw would, on both boards: 128 gives 80, 120 gives 72, 96 gives 48. The player assumes 80, which is wrong on 2-1.

**Learned from the 2-1 deaths so far:** a typical death is a necessary jump over a rolling barrel while another comes down a ladder ahead of him, so he lands 10 pixels from it with no time left. Choosing a jump that lands further from that ladder would have helped in the case traced. Barrels fall exactly 1 pixel a frame on ladders, on both boards; the player's estimate is 0.95.

**His own stick steers barrels.** Percent of barrels taking a ladder above him, by what he's pressing as it crosses (240 games on 2-1, compared with about 450 on 1-1):

| | Nothing | Left | Right | Up |
|---|---|---|---|---|
| 1-1, all ladders (Up not split out) | 4% | 8% | 19% | |
| 2-1, all ladders (Up not split out) | 11% | 24% | 31% | |
| 2-1, x=115 floor 3 | 8% | 77% | 9%, few games | |
| 2-1, x=131 floor 4 | 7% | 29% | 16% | 96% |
| 2-1, x=91 floor 5 | 6% | 41% | 58% | 21% |

With nothing pressed, individual ladders stay around 5–8% on 2-1. These figures are matched by what he happened to be doing, so they aren't a controlled test yet.

**Controlled test, the better evidence (about 1,660 crossings on 2-1, each tried from the identical moment with each input):** pressing **towards** the ladder is what matters. Typical rates: pressing towards it 40–60%, nothing about 10%, pressing away about the same as nothing. Up makes no real difference, so the 96% above came from where he was standing. Examples, with him one or two floors below: x=131 8% with nothing, 43% pressing towards; x=203 top floor 5%, 45%; x=51 3%, 26%; x=187 11%, 51%.

Separately, barrels crossing at x=91, x=107 and x=115 come down about 90–100% of the time whatever he presses when he's far below or far from them, seen early in a game. This isn't explained yet.

**The game's own rule for ladders, read from its code (routine at 0x216D), November 2026.** This explains all the measurements above. When a rolling barrel reaches the top of a ladder:

1. If the oil drum isn't lit yet (`0x6348` is 0), it always takes the ladder. That's the "x=91, 107, 115 come down nearly every time" mystery from early in the board.
2. If Mario isn't at least 9 pixels below the barrel, it never does.
3. A difficulty check: chance `(difficulty/2 + 1) / 4`, rounded down inside. Difficulty 1 gives 1 in 4, difficulty 2 or 3 gives 1 in 2, difficulty 4 or 5 gives 3 in 4.
4. If Mario's x is exactly the ladder's x, or the stick is pressed towards the ladder, it takes it. Otherwise only 1 time in 4.

| Difficulty | Stick towards ladder, or directly under it | Anything else |
|---|---|---|
| 1 | 25% | 6.25% |
| 2, 3 | 50% | 12.5% |
| 4, 5 | 75% | 18.75% |

This matches the controlled test (40–60% against about 10%). It applies to every ladder above him in the direction he's pressing, not just the nearest, and to any floor above.

**Difficulty** is the level number plus 1 for every 2,048 frames or so (about 34 seconds), and stops at 5. So 2-1 starts at 2 and goes to 3 near the end of a typical clear.

**Wild barrels also change with difficulty (0x22CB):** at 1 and 2 their sideways direction is random, at 3 and 4 they head towards Mario's side, at 5 they aim at him. Kong's chance of throwing one also rises with difficulty (0x2C23). So later boards will need this handled.

**He was holding the stick in the air:** 66% of jumps kept the direction pressed for the whole jump. It does nothing to the jump, but it makes barrels four times likelier to come down ladders that way. That's probably a large share of "jump forward, barrel lands on him" deaths. Letting go is ordinary play for a person. Being tested as `air_free`.

**The game's rule for jumping, from its code (0x009F, 0x1ADF, 0x1C63), November 2026:** jump only counts on the first frame the button goes down. Holding it does nothing. After landing there's a countdown of 4 before input is read at all, and a press in that time is simply lost until he lets go and presses again. He presses for 4 frames, releases for 1, presses for 4. His first press comes about 3 to 5 frames after landing, so about half of quick second jumps miss and go on the retry: 9–10 frames after landing rather than 5–6. Those few frames are the difference in deaths like 2200071: two barrels 37 pixels apart, the second jump leaves 4 frames later than it could have, and he's hit by a single pixel. Pressing slightly later (`land_wait`) should give a dependable 6–7. That's ordinary timing, not frame-perfect. Being tested.

**Second-jump timing test (2,000 new games, first 2400000):** yardstick `tn0` 90.85%, `land_wait=7` (`tn1`) 91.12%, `=8` (`tn2`) 90.44%, `=9` (`tn3`) 89.81%. No real gain. Left at 6.

**Lesson on noise:** moving one press by one frame saved 177 games and lost 167, out of about 180 deaths. Almost every death gets replaced by a different one, because any small change re-rolls the game's random numbers from then on. So a saved/lost split is about as noisy as comparing two separate samples, and a 1-point gain needs several thousand games to show. Only changes that remove a kind of danger will get us to 97%, not fine tuning.

**The game's ladder list (0x6300), November 2026.** Mario can climb: x=203 (three of them), 51 (two), 91, 115, 131, 83 and 99 (Kong's girder up to Pauline's level), 147. Broken, barrels only: x=99 floor 1, 83 floor 3, **187 floor 4**, 107 floor 5. So up from floor 4 is x=51 or x=91 only, and floor 5 always has to be crossed to x=203.

**Nearer ladder on floor 4, waiting on the far side (2,000 new games, first 2400000, against `tn0` 90.85%).** Goes up at x=91, not x=51, and waits at x=81, so barrels coming down it roll away from him. The earlier nearer-ladder tests had him waiting on the wrong side.

| | Cleared | Counting fireballs | Wild | Died on floor 4 / 5 | Saved / lost |
|---|---|---|---|---|---|
| Yardstick (`tn0`) | 90.85% | 90.30% | 36 | 80 / 104 | |
| `tp1` | 93.03% | 92.75% | 7 | 47 / 91 | 169 / 120 |
| Waiting closer, 6 pixels (`tp2`) | 86.05% | 85.75% | 9 | 220 / 57 | 155 / 246 |
| A little more clear time, `after_climb4=16` (`tp3`) | 93.43% | 93.15% | 9 | 46 / 84 | 167 / 110 |

**Fresh exam (`ex3`, 3,000 games, first 2200000): 92.55% cleared, lowest likely 91.6%, 92.33% counting fireballs, against 90.90% and 90.53% for `ex1`. Saved 254, lost 200. Barrel 207, wild 14 (was 53), fireball 7 (was 12). Died on floor 4: 84 (was 131), floor 5: 140 (was 147).** Replays 8 of 8. 1-1 check `rg3`: 0 of 3,000 played differently. This one held up, though less than the 93.43% on the tuning games.

Variations: further away, `standoff4=14` (`tq1`) 92.37%, worse. Usual climb time, `after_climb4=24` (`tq2`) 93.68%, within noise of `tp3` (saved 28, lost 23), but it's one less special setting, so `after_climb4` is dropped from the 2-1 settings and he uses the usual 24.

The change removes a danger rather than tuning: it keeps him away from the left side under Kong, where wild barrels fall, and cuts 80 pixels of walking.

**Where floor 5 deaths are now (`ex3`, 140 deaths):** 96 at x=90–99, right at the top of the new x=91 ladder. In the 13 of 16 traced, he steps off the ladder with a barrel rolling at him, and takes off about 4 frames before he's hit. It's a late jump, not a landing. Commonly the barrel has just come down x=107, 16 pixels away. **The cause looks like our own guard:** "never press jump on the last rungs" goes by what he sees, which is about 9 frames old, so he's off the ladder for about 9 frames with no way to jump, even though he knows how far he's climbed. Testing `guard_free`, which lets him go by that knowledge.

| | Cleared | Counting fireballs | Died on floor 4 / 5 | At x=90–99 | Saved / lost against `tq2` |
|---|---|---|---|---|---|
| Yardstick (`tq2`, 2,000 games, first 2400000) | 93.68% | 93.40% | 53 / 72 | 40 | |
| `guard_free=2` (`gf1`) | 95.14% | 94.85% | 53 / 43 | 14 | 31 / 2 |
| `guard_free=0` (`gf2`), pressing a little sooner | 93.18% | 92.85% | 54 / 81 | 51 | 21 / 32 |

Saved 31, lost 2 is well outside chance, and it only changes games at that moment. Too soon is worse, because a press before he's off the ladder is lost.

**Fresh exam (`ex4`, 3,000 new games, first 2600000): 94.04% cleared, lowest likely 93.1%, 93.70% counting fireballs, against 92.74% and 92.40% for the version before on the same games (`ex4b`). Saved 46, lost 7.** Barrel 162, wild 15, fireball 11. Died on floor 4: 94, floor 5: 83. Replays 8 of 8. 1-1 check `rg4`: 0 of 3,000 played differently. Tried on 1-1 too (`oa2`): 98.68%, saved 3, lost 1, no gain, so it stays a 2-1 setting.

**The user's review of the first 8 floor 5 jump deaths in the `ex4` video, November 2026.** The user's words, in short: Mario takes too long over the second jump after straight-jumping the first barrel. He could have jumped a little earlier and straight, or used a **back jump** (from close to the barrel, in the direction the barrel is travelling). He jumps forward over one barrel and lands on another, and should have known he couldn't clear both. "A human would have seen this before they had even jumped the first barrel." "Why is Mario making such rookie errors?" Also asked whether he should have known a barrel was coming down the broken ladder from Kong's timing.

**What the traces show:**
- **It's one recurring situation:** 15 of the 18 deaths checked with two barrels near him have them 30–39 pixels apart. A barrel goes round the right-hand end of the top girder, and the next one takes x=203, which puts it about 37 pixels behind.
- **He only checks the barrel in front of him:** a plan's check stops about 20 frames after landing. It doesn't ask whether he can deal with the next barrel from where he lands.
- **Forward jump onto the next barrel (deaths 2, 4, 6):** every option is already thin by then (scores around -80), so he dithers between left, stand and right, then jumps forward.
- **Second jump too late (deaths 1, 3, 5):** with pairs 37 apart, a straight first jump only works from about 24–29 pixels away, leaving about 20 for the second. He goes at about 24, and his plan assumes a second jump 6 frames after landing, when it really goes 8 or 9. That's 2–3 frames short.
- **The arithmetic favours the back jump:** it lands about 20 pixels further from the second barrel than a straight jump does.

**Fix being tested:** a jump costs extra unless he can then stand where he lands for 45 frames, or a realistic second jump (straight or back) works. `seconds` starts at 9, not 6.

**Next-barrel check (2,000 games, first 2400000, against `gf1` 95.14%):**

| | Cleared | Counting fireballs | Died on floor 4 / 5 | Saved / lost |
|---|---|---|---|---|
| True second-jump timing alone, `seconds={9,16,30}` (`nx1`) | 91.06% | 90.70% | 71 / 107 | 33 / 116 |
| Plus next-barrel check, `w_no_next=150` (`nx2`) | 95.98% | 95.60% | 44 / 36 | 52 / 37 |
| Same, `w_no_next=60` (`nx3`) | 95.08% | 94.70% | 63 / 35 | 46 / 49 |
| `w_no_next=150`, usual `seconds` (`ny1`) | 96.59% | 96.30% | 44 / 23 | 38 / 24 against `nx2` |
| `w_no_next=300`, `seconds={9,16,30}` (`ny2`) | 95.98% | 95.60% | 44 / 36 | Same as `nx2` |
| `next_tail=60`, `seconds={9,16,30}` (`ny3`) | 96.03% | 95.65% | 43 / 36 | 1 / 0 against `nx2` |

`ny1` is now the 2-1 setting: it plans second jumps as before, but only trusts a jump if a realistic follow-up exists.

**Death 7, and Kong's rhythm, measured from a 2-1 game.** Replaying what he could see through the planner: when he committed to that jump, the top barrel wasn't in what he saw yet. He'd rated the jump fine because he didn't know about it. His guess at the next throw (80 frames after the last) is too early, so the guessed barrel was already past the ladder. A person could have known, because **Kong's throw is a fixed animation, in steps of 24 frames, always 97 frames long** from the start of the cycle to the release. Kong's sprite tile (`0x690D`) shows it: tile 44 is 73 frames before the release, tile 172 is 25 frames before. Between cycles he pauses for 0, 6 or 30 frames. Release gaps in that game were 97, 103 or 127. Reading his pose is fair: it's on screen and players watch it. Being tested as `kong_pose`.

**The user's review of the first 12 deaths in the `ex5k` video, November 2026, close to their words:**

1. A horrible combination that can't be jumped. The real problem came earlier: he didn't guide a barrel down the broken ladder between the 4th and 5th girders, so at that level he had it to contend with along with one he'd steered down from Kong. He went to the right of the 3rd girder's middle ladder, which steered the barrel down from the top. He should probably have climbed and steered it down that broken ladder to the right if it was still in the way. "Hard one, need a lot of forethought, but important."
2. Shouldn't have changed his mind while climbing. Should have climbed up and jumped the barrel; he backed away instead.
3. Same: backing away too late on the ladder. Smarter to climb.
4. Should have known a second barrel was coming after the first. Took too long, as though he didn't know. Definitely worth looking into.
5. Backing down the ladder again, indecisive.
6. Should have noticed the fireball climbing up. With his ladder blocked, he should have started moving to the left ladder.
7. Steered the barrel down the ladder, then jumped under that ladder. "Jumping under the ladder while barrels are there is a nono." Probably should have moved to the right of it sooner. A hard one.
8. Again jumping in front of or under a ladder. Could maybe have jumped right to get away. "Standing on/under ladders encourages the barrels to steer down."
9. Why did he jump away from two barrels? Influenced by the barrel above? If he'd moved right earlier he might have steered those three together and jumped left. Suggests grinding this out: start a few seconds earlier and play out the options.
10. Straight jumping under the ladder again, "rookie mistake".
11. A legitimate death.
12. A strange jump, didn't seem to expect the second barrel, then too slow. "Why is he doing so many jumps under this ladder? Seems suspect."

**The user's standing instruction for this work:** focus on the deaths that are occurring and find solutions and legitimate smarts. "You must learn like a player does: if a player sees a pattern to their deaths, they ask what is happening, why are they in that situation, what is a better way to approach this situation."

**Exams `ex5` and `ex5k` (3,000 new games, first 2800000):** with the next-barrel check, 94.95% cleared, lowest likely 94.1%, 94.70% counting fireballs. Barrel 129, wild 21, fireball 8. Died on floor 4: 101, floor 5: 51. Adding Kong's pose timing (`ex5k`): 94.68%, 94.40% counting fireballs, saved 44, lost 53. No gain, left off, so timing the next barrel better isn't what's holding him back. Replays 8 of 8, 1-1 check `rg5` 0 of 3,000 played differently. The fresh figure is well below the 96.59% on tuning games.

**What the traces show for the user's review:**
- **Deaths 2, 3, 5, backing down the ladder:** a barrel comes down the broken x=107 ladder and rolls left across the top of x=91 while he's on it. Being on that ladder puts him at the barrel's x, so it has the full 1-in-2 chance of coming down onto him. He backs down at 0.5 pixels a frame, flips between up and down, and because what he sees is 9 frames old, he doesn't know he's reached the bottom, so he climbs back into it (2 and 5). Fix under test: `ladder_commit` (knows he's at the bottom, stops dithering). Variant: `retreat_top` (near the top, climb and jump, as the user says).
- **Deaths 7, 8, 10, 12, jumps under a ladder:** deaths 8 and 10 straight-jump at x=106–107. A straight jump at exactly x=107 gives a barrel above the full 1-in-2 chance. He also backs up left into that spot, partly because waiting scores a small bonus (`w_later`). Fix under test: `w_under`.
- **Death 4, the second barrel:** he does know about it. His plan is two straight jumps. But at the second jump, with options thin, he jumps forward, because forward scores for progress. A forward jump needs about 16 pixels of room, a straight one 12, and he had 12. Fix under test: `thin_safe`. Also, plans that already include a second jump skip the next-barrel check.
- **Deaths 1 and 9:** forethought about which barrels to steer. Not tackled yet. **Death 6:** fireball, blocked ladder, needs a change of route. Not tackled yet.

**A lot of floor 5 deaths are two barrels close together.** A barrel taking the x=107 ladder skips about 250 frames of rolling compared with one going round the end, so it can land right next to another. Under about 23 pixels apart, one forward jump clears both. Between about 23 and 45 pixels, he needs a quick second jump. The route across floor 5 is also long: x=51 to x=203.

**Fresh exam of letting go in mid-air on floor 5 (`ex2`, 3,000 games, first 2200000): 90.93%, against 90.90% for `ex1`. Saved 60, lost 58. No real gain.** The 92.85% on the tuning games (saved 34, lost 14) was luck, picked out from many tests. On 1-1 (`oa1`) it also made no difference: 98.68%, saved 6, lost 3. Turned off. **Lesson: even a good-looking saved/lost split on 1,000 tuning games isn't evidence. Only fresh exams count.** Also, most killer barrels probably cross while he's walking, not in the air.

**Deliberate steering, from the user:** humans moving up to the top levels also steer barrels down a ladder to make their own path easier. It can cost points, because fewer barrels are left to jump, so it should only be used when required. Not built yet. Comes after the let-go test, and should be judged situation by situation, not switched on everywhere. Holding right as a barrel crosses (2-1): x=91 58%, x=187 40%, x=203 top floor 29%, x=107 27%, against about 6–8% with nothing pressed.

The user adds that difficulty affects how well steering works. Our figures fit: holding right gives 19% on 1-1 and 31% on 2-1 across all ladders. Difficulty also rises during a board (on 1-1, from 1 to 2 at about frame 1984), so steering odds should be measured by difficulty, not only by level.

**Floor 5 under the best version so far (`le3`, 63 deaths):** 37 are at x=90–109, just before the top ladder at x=107. 52 of the 63 are barrels off a ladder. A common plan is a forward jump from about x=77 that lands at x≈97–101 just as a barrel arrives from x=107. In the case traced, that barrel had only just been thrown when he committed. The player's estimate of Kong's next throw is based on 1-1 timing (soonest 80 frames, 2-1 mostly 96 or 120), which may be why he doesn't see it coming.

| Result | Cleared | Counting fireballs | Notes |
|---|---|---|---|
| 1-1 player unchanged (batch `u1`, first game 2000000) | 88.13% (at least 86.9%) | 86.90% | Barrel 297, wild 53, fireball 42. Deaths on floor 4: 191, floor 5: 168 |
| Treating every possible ladder drop as coming (`v1`, 1,000 games) | 82.54% | 81.30% | Worse: nearly every plan looks risky. Compare 87.68% for the same games |
| More time allowed to react (`respond=24`, `v2`) | 88.16% | 87.10% | Saved 55, lost 52: no real change |
| Holding back longer (`maybe_within=70`, `v3`) | 87.68% | 86.80% | Identical play |
| True ladder speed (`drop_rate=1`, `w1`) | 88.42% | 87.80% | Saved 70, lost 60: small gain at best |
| Planning around most-taken ladders (`w2`) | 86.46% | 85.60% | Saved 79, lost 91 |
| Same, plus top ladder and true speed (`w3`) | 87.98% | 87.10% | Saved 91, lost 88 |
| Waiting further from all ladders (`standoff=18`, `x1`) | 87.42% | 84.80% | Fireball deaths 10 to 30 |
| Free sideways jumps on floors 3 and 4 (`x2`) | 87.02% | 86.50% | Saved 100, lost 103 |
| Both, with true speed (`x3`) | 85.71% | 84.00% | Worse |
| Waiting further on floor 4 only (`standoff4=18`, `y1`) | 88.81% | 87.30% | Saved 93, lost 88. Fireball deaths 10 to 17 |
| Nearer ladder up from floor 4 (`ladder4=91`, `y2`) | 87.39% | 86.60% | Saved 99, lost 101. Wild deaths 17 to 7, floor 4 barrels worse |
| Both (`y3`) | 89.85% | 87.60% | Saved 106, lost 98. Fireball deaths 10 to 25, floor 5 deaths 51 to 30, floor 4 up 70 to 83 |
| Letting go of the stick for any barrel above, 6 pixels before a ladder (`steer_off=6`, `z1`) | 67.97% | 62.40% | Saved 81, lost 325. Stops him constantly, even for barrels floors above |
| Same, 12 pixels (`z2`) | 36.55% | 31.40% | Far worse |
| Same as `z1`, with true ladder speed (`z3`) | 53.72% | 49.80% | Far worse |
| Stops pressing towards a ladder as a barrel crosses just above (`la1`) | 85.17% | 83.30% | Saved 114, lost 149. Floor 5 deaths 51 to 37, floor 4 70 to 108 |
| Same, up to two floors above (`la2`) | 85.70% | 84.50% | Saved 110, lost 133. Floor 5 44, floor 4 99 |
| Same as `la1`, a little earlier (`la3`) | 85.89% | 84.00% | Saved 113, lost 141. Floor 5 29, floor 4 115 |
| Eases off on floor 5 only (`lb1`, 10 pixels) | 88.10% | 87.40% | Saved 36, lost 30 |
| Plus nearer ladder from floor 4 (`lb2`) | 88.21% | 87.50% | Saved 105, lost 98. Wild deaths 17 to 8 |
| Plus waiting further from it (`lb3`) | 90.23% | 87.70% | Saved 105, lost 96. Fireball deaths 10 to 28, so the headline flatters it |
| Less clear time needed before climbing (`after_climb=14`, `ld1`) | 89.73% | 89.10% | Best so far. Saved 69, lost 46. Floor 4 deaths 70 to 41, floor 5 51 to 62 |
| Much less (`after_climb=6`, `ld2`) | 74.30% | 74.00% | 148 deaths on floor 6: too little at the top ladder |
| `ld1` with nearer ladder (`ld3`) | 89.31% | 88.60% | Saved 111, lost 93 |
| Less clear time, floor 4 ladder only (`after_climb4=10`, `le1`) | 89.11% | 88.40% | Saved 41, lost 25 |
| Even less there (`after_climb4=6`, `le2`) | 87.51% | 86.90% | Saved 40, lost 39. Too little |
| Less on floors 2, 3 and 4 (`after_climb2=14, after_climb3=14, after_climb4=10`, `le3`) | 89.84% | 89.30% | Best so far. Saved 72, lost 47. Floor 4 deaths 37, floor 5 64 |
| `le3` plus easing off the stick on floor 5 (`steer_off=10`, `lf1`) | 90.63% | 90.00% | Best so far. Against unchanged: saved 90, lost 58. Floor 4 deaths 37, floor 5 57 |
| `le3` plus true ladder speed (`lf2`) | 89.83% | 89.20% | No gain |
| `le3` plus nearer ladder (`lf3`) | 89.82% | 89.10% | No gain. Wild deaths 6, floor 4 54, floor 5 49 |
| `le3` with Kong's next throw expected later (`throw_every=96`, `lg1`) | 87.60% | 86.90% | Worse: floor 5 deaths 64 to 84. The earlier expectation was helping, like the old `kong_fix` lesson |
| `le3` with wild barrel timing for 2-1 (`wild_after=72`, `lg2`) | 90.44% | 89.90% | Saved 81, lost 50 against unchanged |
| Both (`lg3`) | 88.19% | 87.40% | Worse |
| Climbing, easing off and wild timing together (`lh1`) | 90.93% | 90.20% | Best on tuning games. Saved 88, lost 54 against unchanged. Now the 2-1 setting in `params.levels` |
| Same, next throw expected sooner (`throw_every=64`, `lh2`) | 89.30% | 88.50% | Floor 5 deaths 71 |
| Same, sooner still (`throw_every=48`, `lh3`) | 81.67% | 81.10% | Floor 5 deaths 145. So 80 is about right |
| `lh1` plus letting go in mid-air on all floors (`na1`) | 90.97% | 90.70% | Floor 5 deaths 54 to 39, but floor 4 37 to 50. Saved 92, lost 87 against `lh1` |
| Same plus easing off walking on floors 4 and 5 (`na2`) | 87.64% | 87.20% | Floor 4 deaths 86. Pausing on the walk is what hurts there |
| Same plus easing off on every floor (`na3`) | 84.59% | 84.00% | Floor 4 deaths 101, floor 5 54 |
| `lh1` plus letting go in mid-air on floor 5 only (`nb1`) | 92.85% | 92.20% | Best so far. Floor 5 deaths 54 to 34, floor 4 unchanged at 37. Saved 34, lost 14 against `lh1` |
| Floors 2, 3 and 5 (`nb2`) | 91.18% | 91.00% | Floor 4 deaths 46 |
| Floor 4 only (`nb3`) | 89.79% | 88.80% | Floor 4 deaths 45, floor 5 60. Letting go low down makes things worse higher up. Fits the user's point about steering: barrels drawn down ladders while he's low are out of his way later |
| `nb1` weighing the true ladder odds by what the stick is doing (`stick_odds`=0.125, 0.05, 0.25: `nc1`–`nc3`) | 92.66%, 92.35%, 92.85% | 92.10%, 91.80%, 92.20% | No gain. Left off |
| `nb1` waiting further from the floor 4 ladder (`standoff4`=18 `ne1`, 14 `ne2`) | 90.11%, 91.73% | 89.30%, 91.00% | Worse |
| `nb1` plus nearer ladder on floor 4 (`nd1`) | 91.13% | 90.40% | Wild deaths halved to 6, but floor 4 deaths 54. Saved 62, lost 80 |
| `nb1` pressing left in mid-air on floor 4 (`nd2`) | 89.91% | 89.10% | Saved 51, lost 82 |
| `nb1` pressing right in mid-air on floor 4 (`nd3`) | 91.32% | 90.50% | Saved 52, lost 69 |
| `nb1` pressing left in mid-air on floor 3 (`nd4`) | 92.33% | 91.50% | Saved 18, lost 25 |

Steering by pressing all the time in mid-air on lower floors doesn't help. If steering is worth doing, it has to be chosen for the situation, as the user said. On 1,000 games, a change that alters many games has about ±1 point of noise, so saved against lost matters more than the headline.

**Fresh exam, 3,000 new 2-1 games (first game 2200000), live, November 2026:**

| | Cleared | Lowest likely | Counting fireballs | Barrel | Wild | Fireball | Died on floor 2 / 3 / 4 / 5 / 6 |
|---|---|---|---|---|---|---|---|
| Unchanged 1-1 player (`ex0`) | 89.04% | 87.9% | 88.03% | 263 | 61 | 34 | 19 / 3 / 183 / 151 / 3 |
| 2-1 settings (`ex1`) | 90.90% | 89.8% | 90.53% | 216 | 53 | 12 | 4 / 1 / 131 / 147 / 1 |

Saved 253, lost 178. Replays match 8 of 8. So the real gain is about 1.9 points (2.5 counting fireballs), a bit under the 3.3 seen on the tuning games, as usual. Almost all of it is floor 4 and early fireballs. Floor 5 has barely moved and is now the biggest problem. The 1-1 check (`rg1`): all 3,000 games play exactly as before.

**The fixes from the user's review of `ex5k`, tested on 2,000 new games (first 3000000), yardstick `dv0` 96.33% (95.90% counting fireballs). `dv0` scored higher than `ex5` on these games, so only compare within this set:**

| Change | Cleared | Saved / lost against `dv0` | Result |
|---|---|---|---|
| Decisive on ladders, knows when he's at the bottom (`ladder_commit`, `dva`) | 94.36% | 27 / 70 | Rejected: floor 4 deaths 44 to 86 |
| Same, climbs on and jumps near the top (`retreat_top=8`, `dvb`) | 94.46% | 27 / 68 | Rejected |
| Avoids jumping right under a ladder (`w_under=60`, `dvc`) | 96.18% | 50 / 53 | No gain: floor 5 deaths 31 to 24, floor 4 44 to 50 |
| Safest jump when nothing's comfortable (`thin_safe=30`, `dvd`) | 95.82% | 49 / 62 | Rejected |
| Next-barrel check counts barrels that may take ladders (`next_risk`, `dve`) | 96.28% | 15 / 17 | No gain |

So the review's complaints were fair observations, but these simple rules for them don't work. Next: why.

**Second jumps start late, measured November 2026.** Going through `dv0`'s 82 deaths frame by frame: 25 are a second jump, and most have a gap of 9–10 frames from landing to take-off, where his plan assumed 6. Save-state test from three real games, pressing jump at each frame after landing: the game rejects every press up to its fourth frame back on the ground, then accepts from the next one on (0x621E counts down from 4, and jump is only read on the first frame of a press). His first press came one frame before that in all 18 cases traced, so it was always lost and the retry was what jumped. Those 4 frames are the deaths at floor 5 x=139–143: the second barrel is 37 behind the first, so a first jump from 24–31 away would work with a dependable second jump, and only 29–31 with the late one. `land_wait` was tried before and didn't help, because it also stopped him thinking for those frames. The new `jump_ready` only holds the press, and his plans know a jump can't start before then. A second finding: backing down a ladder was judged as if the girder was 40 pixels below him and at climbing speed, so 4 pixels from the bottom he thought he'd be caught and climbed back into the barrel (3000135). `ladder_true` fixes that. Both being tested (`dx1`–`dx5`).

| Against `dv0` 96.33%, same games | Cleared | Saved / lost | Result |
|---|---|---|---|
| `jump_ready=49` (`dx1`) | 96.89% | 24 / 12 | Best. Floor 5 deaths 31 to 17; x=140–149 went from 7 to 0 |
| `jump_ready=50` (`dx2`) | 96.08% | 22 / 27 | One frame later loses it all, floor 4 deaths 54 |
| `jump_ready=49`, plans second jumps at 8 (`dx3`) | 96.64% | 33 / 26 | |
| `jump_ready=50`, plans at 9 (`dx4`) | 96.08% | 31 / 37 | |
| `ladder_true=4` (`dx5`) | 95.83% | 28 / 40 | Rejected. More accurate, but ladder deaths 10 to 28: he backs down more, and backing down is what gets him killed |
| On `jump_ready=49`, against `dx1`: `jump_ready=48` (`dy0`) | 96.29% | 3 / 15 | Floor 5 x=140–149 deaths back to 7: 49 really is the right frame |
| Climbs on near the top, `retreat_top=8` (`dy1`) | 96.64% | 4 / 9 | No gain |
| `retreat_top=16` (`dy2`) | 96.18% | 22 / 36 | Floor 4 deaths 45 to 28, floor 5 17 to 48 |
| Never backs down, `retreat_top=100` (`dy3`) | 95.88% | 24 / 45 | Floor 4 28, floor 5 55, x=90–99: 45 |
| Knows he's on the ladder near the bottom (`ladder_known`, `dy4`) | 96.99% | 5 / 4 | Small, right in principle |

The user's point that he should climb and jump instead of backing down: it moves deaths rather than removing them. Fewer die on the ladder, but many more step off the top into a barrel at x=90–99 on floor 5. So neither is the answer at the top of the ladder. A player has a third choice, which he has never had: **stop on the ladder just under the girder and let the barrel roll over** (`ladder_hold`). The game won't send a barrel down a ladder unless Mario is at least 9 below it, and it touches him only within 7, so there's a small safe spot. Being tested.

| On `jump_ready=49`, against `dx1` 96.89% | Cleared | Saved / lost | Result |
|---|---|---|---|
| Stops near the top, `ladder_hold=16` (`ea2`) | 95.98% | 24 / 42 | Ladder deaths 12 to 32 |
| `ladder_hold=12` (`ea3`) | 96.64% | 16 / 21 | Ladder deaths 19 |
| `ladder_hold=24` (`ea4`) | 95.63% | 33 / 59 | Ladder deaths 44 |
| Allows 1 frame for a press to become a jump, `press_lag=1` (`ea0`) | 96.49% | 54 / 61 | |
| Allows 2 frames, `press_lag=2` (`ea1`) | 97.00% | 69 / 62 | Walking deaths 23 to 8, fireballs 8 to 3, wild 3 to 10. Changes many games, so needs a fresh test |

Holding on the ladder only gets him killed unless he's within the safe spot: further down, barrels come down the ladder on to him. Testing the tightest version next, then fresh exams.

**Fresh exam, 3,000 new 2-1 games (first 3200000), live, November 2026:**

| | Cleared | Lowest likely | Counting fireballs | Barrel | Wild | Fireball | Died on floor 2 / 3 / 4 / 5 | Saved / lost against `fb3` |
|---|---|---|---|---|---|---|---|---|
| Previous best (`fb3`) | 96.25% | 95.5% | 95.87% | 99 | 12 | 12 | 9 / 3 / 56 / 56 | |
| Right second-jump timing, `jump_ready=49` (`fb0`) | 96.72% | 96.0% | 96.37% | 82 | 16 | 11 | 10 / 3 / 63 / 33 | 39 / 24 |
| Same, allowing 2 frames for a press, `press_lag=2` (`fb1`) | **96.99%** | 96.3% | 96.67% | 73 | 16 | 10 | 5 / 1 / 68 / 26 | 120 / 96 |
| Same, allowing 3 frames (`fb2`) | 95.45% | 94.6% | 95.20% | 119 | 17 | 8 | 2 / 7 / 85 / 50 | 120 / 140 |

Replays match 4 of 4. `fb1` is now the 2-1 setting. Floor 5 deaths halved, and x=140 on floor 5 went from 14 to 0. Caution: the old player scored 94.95% on the games from 2800000 and 96.25% on these, so game sets differ by more than a point. Only comparisons on the same games mean anything, and the honest gain here is about 0.7, not the 2 it looks like against `ex5`. `ladder_hold=9` (`ea5`) never came into effect: what he sees is 3 pixels behind where he's climbed to.

**Reviewing `fb1`'s 100 deaths, November 2026.** Two patterns stand out:

- **Floor 5, x=153–157, six near-identical deaths (3200555, 3200193...).** He's backing left to keep the right distance from a pair of barrels, and his plan is good ("walk left 12 frames, then straight jump", score +16). Then a barrel on the top girder comes up to the broken ladder, and our own rule "let go of the stick when a barrel crosses a ladder, so as not to draw it down" stops him walking for 5–10 frames. His plan assumed he was still walking. The room is gone, and all that's left is a jump towards the second barrel. A player would do what the moment needs, and steer only when there's nothing else to do. Testing `steer_calm`.
- **Floor 4, x=82, waiting at the ladder (3200003, 3201638).** Pair of barrels from the left, he decides nothing works and jumps left at the last moment, into the second barrel. His check on whether a straight jump leaves time for a second one assumes the second comes 9 after landing, when it now really comes at 7–8, so it's rejecting jumps that work. Testing `next_waits` starting at 7.

**Tested after that review (same 2-1 games, against `ea1` 97.00%; 1-1 games against `t1c` 98.68%):**

| | Cleared | Saved / lost | Decision |
|---|---|---|---|
| 1-1 unchanged check (`rg6`) | | played differently 0 | Good: 2-1 work hasn't touched 1-1 |
| 1-1 with `jump_ready=49, press_lag=2` (`ob1`) | 98.01% | 61 / 74 | Rejected for 1-1: worse |
| 1-1 with `jump_ready=49` alone (`ob2`) | 98.68% | 9 / 7 | No gain, left off 1-1 |
| 2-1 `ladder_hold=10` (`ec1`) | 96.89% | 10 / 13 | Rejected: ladder deaths 9 to 13 |
| 2-1 `ladder_known` on the new setting (`ec2`) | 96.80% | 1 / 5 | Rejected: it helped before `press_lag`, not after |

**Results on the two fixes above (same games, against `ea1` 97.00%):**

| | Cleared | Saved / lost | Decision |
|---|---|---|---|
| Lets go of the stick only when nothing's pressing, `steer_calm` (`ed1`) | 96.44% | 5 / 17 | Rejected as a general rule. Floor 5 x=150 went 3 to 1, but x=100 went 4 to 15: letting go there is what keeps barrels off him near the broken ladder |
| Knows the second jump can come at 7, `next_waits` (`ed2`) | 96.95% | 0 / 1 | Rejected: changes almost nothing, so my reading of x=82 was wrong |
| Both (`ed3`) | 96.39% | 5 / 18 | Rejected |

**More from looking at positions before ladder deaths (`fb1`), November 2026:**

- **Ladder 91, floors 4 and 5, about 19 of the 100 reviewed.** He's climbing with nothing near him, reaches y=124, then backs down. The top barrel is 70 px away, too far to matter. What turns him back is a barrel he's only imagining: Kong's next throw, which hasn't happened, predicted as a wild barrel dropping straight down at x=88 to 92, right beside the ladder top (3202473, 3200263, 3200659). That check only starts at y<125, which is why it always happens at the same height. He dithers up and down, and a real barrel on the girder below rolls through x=91 while he's near the bottom. Testing `ladder_real`: on a ladder, only barrels that exist turn him back.
- **Earlier warning:** `kong_fix` (predicting that barrel correctly everywhere) made things worse, so the fix applies only to the ladder.
- **Floor 5, x=92 to 105, and floor 4, x=94 to 101, about 25 of the 100.** A straight jump lands him about 11 px from the next barrel, too close, as a press only counts 5 frames after landing. On floor 5 that barrel is Kong's next throw coming off the broken ladder at x=106, 13 px from where he lands; he can't see it coming when he commits to the jump. On floor 4 he walks past the ladder, deferring his jump ("12 frames from now") while the barrel behind closes up, and ends up jumping at 21 px instead of 24 to 31. Testing a smaller margin for setting out to climb (`climb_ym`) and planning around the top barrel taking the broken ladder (`sure_ladders`).

**Results on the ladder findings (same games, against `ea1` 97.00%):**

| | Cleared | Saved / lost | Decision |
|---|---|---|---|
| Unthrown barrel doesn't turn him back on a ladder, `ladder_real` (`ee2`) | 96.64% | 5 / 12 | Rejected. Ladder deaths stayed at 9 and floor 5 x=100 went 4 to 9 |
| Ignores any uncertain wild barrel on a ladder, `ladder_sure` (`ee1`) | 96.64% | 5 / 12 | Rejected, same games lost as `ee2` |
| Sets out to climb if a barrel will pass 8 below him, `climb_ym=8` (`ee3`) | 97.15% | 4 / 1 | Better |
| Same, 7 below (real contact distance), `climb_ym=7` (`ee4`) | 97.25% | 5 / 0 | **Adopted for 2-1**, pending fresh exam |
| Top barrel expected to take the broken ladder, `sure_ladders` (`ee5`) | 97.00% | 0 / 0 | Did nothing |

The imagined barrel is a wrong reason for a useful delay. It's the third time this has shown up (`kong_fix`, `throw_every`, now this): the backing down looks foolish in the deaths, but in the games he survives it gets him to the top after the barrels have passed. Going straight up only moves the death to floor 5. Don't "correct" this again without a better way of timing arrival at the top. Fixing what you see in the deaths alone misses the games the habit saved.

**Further tests on top of `ee4` (97.25%, same games), all left off:**

| | Cleared | Saved / lost | |
|---|---|---|---|
| Keeps a planned move going when the ladder above is 40+ px away, `steer_far=40` (`ef1`) | 97.29% | 3 / 3 | Floor 5 x=150 3 to 2, but no real gain |
| Floor 4 climb stays clear 14 after the top, `after_climb4=14` (`ef2`) | 97.10% | 20 / 23 | Ladder deaths 9 to 17 |
| Same, 18 (`ef3`) | 97.15% | 18 / 20 | Ladder deaths 9 to 14 |
| Floor 5 climb, `after_climb5=14` (`ef4`) | 97.30% | 1 / 0 | Too small to mean anything |
| Tighter side margin when setting out to climb, `climb_xm=6` (`ef5`) | 97.24% | 24 / 26 | Moves deaths, ladder 9 to 14 |

**Fresh exam, 3,000 new 2-1 games (first 3400000), November 2026:**

| | Cleared | Lowest likely | Counting fireballs | Barrel | Wild | Fireball | Saved / lost |
|---|---|---|---|---|---|---|---|
| Previous best (`fg2`) | 96.15% | 95.5% | 95.67% | 90 | 24 | 15 | |
| With `climb_ym=7` (`fg1`) | **96.52%** | 95.8% | 96.03% | 79 | 24 | 15 | 16 / 5 |

`fg1` is the 2-1 setting, and replays match 16 of 16. 1-1 check `rg7`: played differently 0. These games are harder than the last set (the old player got 96.99% there and 96.15% here), so 96.52% isn't a fall from 96.99%. The honest measure is the same-games gain of about 0.4. 2-1 has now been at 96.5 to 97.0 on fresh sets, still short of the 97%+ target as a dependable figure.

**A test-tool bug found and fixed, November 2026.** A level's own settings overrode `--set`, so a test of something already in `levels[2]` silently did nothing. `fg0` was meant to be the old setting and was just the new one again, which showed up as two identical results; `fg2` is the correct rerun. `run_batch.py` now lets `--set` win. A check of all 182 stored test runs found only one other affected: `ex4b`'s `guard_free=nil` was ignored, so that comparison had guard_free on in both. Identical results between two settings should always be treated as suspect.

**Still unsolved on 2-1 after this review:**

- Floor 4, x=80, standing and waiting: the climb takes about 70 frames, longer than most gaps in the barrels above, so he waits while up to three barrels 17 to 19 px apart build up on his left. No single jump clears them. Needs a better way to time the climb, not a rule about the jump.
- Floor 5, x=92 to 105: landing about 13 px from where the next barrel comes off the broken ladder. Not fixed.
- Floor 4, x=130 to 147: trains 20 px apart chasing him right. Each jump lands him a little closer to the next barrel, and by the third there's no room. Not fixed.
- Fireball blocking the ladder, so he should take the other ladder: not tested.

**Matt's review of 10 unsolved deaths, and replaying them, November 2026.** New tools: `tools/probe_plans.py` tries about 7,000 plans from before a death (walk, jump, jump again, at every moment), and `tools/why_plan.py` prints the score of each plan he considered. Every one of the 10 had surviving plans. Death 8 (3402727): a left jump works up to 7 frames before death, as Matt said. Death 9 (3400020): a left jump works up to 3 frames before.

**Why he jumped right in deaths 5 and 10:** going straight or left carried `risk=true`, a flat 500-point penalty for going near a barrel that only might take a ladder, however unlikely. The only jump without it had almost no room (clearance about 1), so he took that. Against `ee4` (97.25%), same games:

| | Cleared | Saved / lost | |
|---|---|---|---|
| `w_risk=250` (`eg1`) | 97.40% | 3 / 0 | Candidate |
| `w_risk=120` (`eg2`) | 97.24% | 8 / 8 | No gain |
| `w_risk=60` (`eg3`) | 96.09% | 11 / 34 | Much worse: he does need to respect those barrels |

On top of `eg1` (97.40%), same games:

| | Cleared | Saved / lost | |
|---|---|---|---|
| Keeps climbing, `ladder_real` (`eh1`) | 96.90% | 4 / 14 | Rejected again |
| `w_risk=180` (`eh2`) | 97.45% | 1 / 0 | Same as 250 in practice; kept 250, further from where it turns bad |
| `w_no_next=100` (`eh3`) | 97.40% | 0 / 0 | Did nothing |
| `w_thin=50` (`eh4`) | 97.20% | 4 / 8 | Worse |
| Floor 5 prefers sideways jumps, `w_sideways5=-20` (`eh5`) | 96.49% | 6 / 24 | Much worse |

`w_risk=250` adopted for 2-1, pending fresh exam. **Why climbing straight on loses:** of the 14 games `eh1` lost, 6 are the same death: at the ladder top he steps left to x=83, jumps right over a barrel with a confident score of +62, and lands at x=101 beside the foot of the broken ladder just as Kong's next barrel comes down it (3000278, 3000656, 3001440, 3001449, 3001817, 3001171). When he pressed, that barrel hadn't been thrown. 2 more are the same at x=94 (Matt's deaths 8 and 9). Testing `next_drop`: he expects that barrel when it's due.

On top of `eg1` (97.40%), same games:

| | Cleared | Saved / lost | |
|---|---|---|---|
| Expects Kong's next barrel down the broken ladder, `next_drop={0}` (`ei1`) | 95.59% | 11 / 47 | Rejected. x=90 down, but x=110 went 0 to 23: staying away from that ladder's foot puts him somewhere worse |
| Same, also allowing a late throw (`ei2`) | 95.59% | 11 / 47 | Rejected, only 1 game played differently from `ei1` |
| Same, plus keeps climbing (`ei3`) | 95.39% | 12 / 52 | Rejected |

Matt had already said of deaths 8 and 9 that where he lands is fine and the answer is reacting faster with a back jump. Avoiding the landing spot went against that, and the test agrees. The back jump itself is still to solve.

**Testing rule from Matt, November 2026:** a rule that works in one situation may not apply overall, so choosing the right option can take more context. A test that saves some games and loses others isn't finished when the total is worse. Compare positions in the saved and lost games, find what tells them apart, and retest the rule only in that situation. Rejected whole-board tests worth revisiting this way: `ladder_real` (4 saved / 14 lost), `steer_calm` (5 / 17), `w_sideways5` (6 / 24).

**Fresh exam of `w_risk=250`, 3,000 new games (first 3600000):** `fh1` 96.42% (lowest likely 95.8%, 96.00% counting fireballs) against `fh0` 96.35% for `w_risk=500` on the same games, 2 saved / 0 lost. Small but clean, so kept. 1-1 check `rg8`: played differently 0. Replays 16 of 16.

**Committing to the climb, with context (`next_drop_climb`):** keeps climbing unless Kong's next barrel, rolling to the broken ladder and down it, would reach the top of ladder 91 when he does. Against `eg1` (97.40%): `ej1` 95.69%, 13 saved / 47 lost, with floor 4 deaths up from 27 to 48. Allowing for a late throw (`ej2`, `ej3`) made no difference at all. Rejected. That prediction blocks far more climbs than the imagined wild barrel did, so he waits on floor 4 longer and dies there. The deciding context for 1 to 3 isn't found yet.

**Back jump (Matt's deaths 8 and 9), `w_with`:** a bonus for jumping the way a close barrel is rolling, when it's coming at him, so it passes under him while he's highest. First try against `eg1` (97.40%): `ek1`/`ek2` (60 and 120) 97.44%, 4 saved / 3 lost; floor 5 only (`ek3`/`ek4`) 97.30%, 1 / 3. It rarely applied, for two reasons. Right after landing, his earliest possible jump counted as "later" (fixed). And in death 8, when he decides, the barrel is still coming down the broken ladder, so to him it isn't rolling at him yet. `with_drop` also counts a barrel coming down a ladder beside him. With both, death 8 (3402727) clears. Single-game checks on the current setting: death 5 (3400001) now clears with `w_risk=250`, and death 10 (3401055) still dies.

`with_drop` first version (`el1` to `el4`): 92.7 to 95.1% against 97.40%, up to 35 saved / 129 lost. A bug: it also counted barrels rolling along the girder just above him as "coming down beside him", so he jumped away from barrels that weren't coming. Fixed to count only barrels that are dropping, and retested as `em1` to `em3`.

Fixed `with_drop`, against `eg1` (97.40%): `em1` (`w_with=120`) 97.19%, 7 / 11; **`em2` (60) 97.49%, 7 / 5**; `em3` (120, floor 5 only) 97.10%, 3 / 9. Saved games are exactly Matt's setup: floor 5 x=94 (3 games) and floor 4 x=96 to 99. Lost games die later, after the back jump has taken him to floor 5 x=65 to 78, at the next barrel. So the context needed is whether he can deal with the next one: `with_next` gives the bonus only then. Testing `en1` to `en3`.

`with_next` (`en1` to `en3`) changed nothing: identical games to `em2`/`em1`. He already believes he can handle the next barrel in the lost games. Fresh check of `em2`'s setting on 3,000 new games (`fh2`, first 3600000): 96.32% against `fh1` 96.42%, 16 saved / 19 lost. Not kept. Same pattern: x=90 down, x=60 to 80 up. **Cause, from positions in the lost games (3000399, 3001005, 3001788):** a back jump leaves the barrel only 0.5 px per frame to pass under him, so it covers 22 px in the whole jump. From a gap of about 14 it's only 8 past when he lands, and he dies on landing. The model rated those as clearance of about 1 (thin), and the bonus made him pick them. Testing `with_cl`: the bonus only applies with comfortable clearance.

`with_cl`, against `eg1` (97.40%): **`eo1` (`w_with=60`, `with_cl=2`) 97.60%, 5 saved / 1 lost**, and floor 5 x=60 to 80 deaths gone; `eo2` (`with_cl=4`) never triggered (0 / 0); `eo3` (120, 4) 97.35%, 1 / 2. Fresh check `fh3` next, then `with_cl=3` (`ep1`).

**Fresh exam of the back jump with room (`fh3`, first 3600000):** 96.59% (lowest likely 95.9%, 96.17% counting fireballs) against `fh1` 96.42% on the same games, 11 saved / 6 lost. **Adopted for 2-1** (`w_with=60, with_drop=true, with_cl=2`). The context rule did what the plain version (`fh2`, 16 / 19) couldn't. 2-1 work then paused (unfinished `ep1` deleted) while the native emulator is set up, so speed comparisons are clean.

## 3-1 (started 2026-11-03)

Matt: the level 3 barrel boards are the hardest in the game and the wild barrels are murderous. Target is again 97% (judged on 10,000-game fresh exams); if reached, move on to 4-1. If not, find what's killing him and work out fixes. Starts: `l3_000`–`l3_063` (MAME `starts/`, native `native/starts`). Native runner checked on 3-1: 200 of 200 games identical to MAME (`ga0m`).

**Baselines, 3,000 new games (first 5000000):**

| | Cleared | Counting fireballs | Barrel | Wild | Fireball | Died on floor 1 / 2 / 3 / 4 / 5 / 6 |
|---|---|---|---|---|---|---|
| Settings as for 1-1 (`ga0`) | 76.23% | 74.30% | 379 | 304 | 76 | 0 / 138 / 70 / 263 / 246 / 54 |
| Settings as for 2-1 (`ga1`) | 75.52% | 73.13% | 364 | 317 | 95 | 37 / 293 / 78 / 295 / 85 / 18 |

`levels[3]` starts as a copy of `levels[2]`. The 2-1 settings fix the 5th girder (246 to 85) but wreck the 2nd (138 to 293). Next: switching off each 2-1 setting in turn (`gb01`–`gb11`).

**Switching off each 2-1 setting in turn on 3-1 (against `ga1` 75.52%, same 3,000 games):**

| Switched off | Cleared | Saved / lost | |
|---|---|---|---|
| Back jump `w_with` (`gb01`) | 76.02% | 45 / 31 | Slightly better without |
| Halved risk penalty, back to 500 (`gb02`) | 75.35% | 1 / 6 | Keep halved |
| Climb margin, back to 9 (`gb03`) | 75.12% | 19 / 31 | Keep |
| Second-jump timing `jump_ready` (`gb04`) | 75.25% | 66 / 75 | Keep |
| **Press lag allowance `press_lag` (`gb05`)** | **81.05%** | **529 / 369** | **Removed for 3-1.** 2nd girder deaths 293 to 126, 1st 37 to 0. Barrels are faster on level 3, so allowing 2 frames per press makes his jumps too late |
| Floors 2–3 climb timing (`gb06`) | 75.31% | 54 / 60 | Keep |
| Letting go of the stick on floor 5 (`gb07`) | 75.84% | 35 / 27 | Slightly better without |
| Kong's wild timing (`gb08`) | 75.59% | 9 / 7 | No difference |
| Ladder 91 route on floor 4 (`gb09`) | 72.60% | 274 / 357 | Keep: much worse without |
| Guard after the top (`gb10`) | 75.53% | 20 / 20 | No difference |
| No-follow-up cost (`gb11`) | 71.22% | 27 / 148 | Keep: much worse without |

New 3-1 base: the 2-1 settings without `press_lag` (81.05%). Round 2 (`gc01`–`gc10`) tests press lag 1, back jump, steering, and the wild-barrel weights.

**Round 2 on 3-1 (against `gb05` 81.05%):** press lag 1 (`gc01`) 80.23%, 335 / 362; without the back jump (`gc02`) 79.65%, 18 / 60 (so the back jump helps once press lag is gone); without letting go of the stick (`gc03`) 80.64%, 28 / 42; `kong_chance` 1.5 / 0.6 (`gc04`/`gc05`) 80.83 / 80.97%; `ray_block` 0.25 / 0.6 and `wild_tail=60` (`gc06`–`gc08`) identical; `w_ray` 2000 / 500 (`gc09`/`gc10`) 80.66 / 81.22% (28 / 23, noise). Nothing adopted: the wild-barrel weights aren't what's limiting him.

**Where 3-1 deaths are (`gb05`, 569 deaths):** 4th girder 338: barrels mid-jump 113, barrels walking 52, wild 124. By position: x=60–69 93 (nearly all ordinary barrels, where barrels come down the left ladder from the 5th girder), x=80–99 135 (ladder 91, half wild). 2nd girder 126 (wild 77). Wild barrels on ladders 52.

**A bug in his plan model, found in the x=60 deaths on 3-1 (5000561, 5000598, 5000015...):** from his waiting spot left of ladder 91 (x=82, target 81), he jumps left over a barrel rolling right and lands at x=61, right where the next barrel from the left end of the 5th girder arrives. His model rated the jump as safe (clearance 6.2) because, after landing, `along()` puts him straight back at his target: walking towards a target he's already past clamps him to it. So the plan had him at x=81 from the moment he landed (`tools/why_plan.py ... dbgplan={act,w1,j1}` prints the predicted positions step by step). The fix exists as `along_fix` (walks back instead of appearing there) but has been off since early 1-1 testing. Testing on 3-1 (`ge01`) and 2-1 (`ge02` against `ge00`). Barrels take exactly 61 frames from the left end of the 5th girder to x=51 on the 4th, on both 2-1 and 3-1, so the end-of-girder model isn't the issue.

**Walk-back model fix (`along_fix`):** 3-1 (`ge01`) 83.68% against 81.05%, 110 saved / 33 lost, 4th girder x=60 deaths 91 to 19. **Adopted for 3-1.** 2-1 (`ge02` against `ge00` 97.26%): 97.36%, 8 / 5, left off there for now (2-1 is confirmed and finished). Round 3 (against `gb05`): measured wild bounce odds `wild_rays` (`gd01`) 78.77%, 201 / 265; `ladder_sure` (`gd02`) 81.53%, 34 / 21; `w_with=90` (`gd03`) 81.11%; `with_x=20` (`gd04`) 80.66%.

**Wild barrels on level 3 are a different animal** (from the traces of `gb05` against `fh3`):
- Once loose they mostly drift sideways at 1.0 px a frame (65%), some 1.5–2; on 2-1 mostly 0.5–0.75.
- Leaving Kong, every one on 3-1 goes right, at 1.0 (71%), 1.25 (7%), 1.5 (12%), 1.75 (5%), 2.0 (6%). On 2-1, 75% at 0.75. His model (`KONG_RAYS`, measured on 1-1) expects anything from left to right, a quarter straight down.
- They seem faster when Mario stands at x=90–150 (about 1.5) than at x=60–90 (1.0), so they may aim at him. That's a small sample, from deaths only.
- Kong throws wild about as often on both: 23% of throws on 3-1, 21% on 2-1.

New `kong_rays` setting lets a level use its own measured directions. Testing (`gf01`–`gf03`, reference `gf00`).

**Level-3 Kong rays (`kong_rays`, against `gf00` 83.68%):** `gf01` 83.48% (27 / 33); with `ladder_sure` (`gf02`) 83.72%; `ladder_sure` alone (`gf03`) 84.00% (37 / 28). Small: Kong's rays only matter near the top, and most wild deaths are lower down.

**Wild barrels head for Mario every time they land.** From pauses on a girder in the traces: on 3-1, 384 of 385 landings with Mario more than 10 px away went towards him (`gb05`), mostly keeping 1.0 px a frame, some 1.25–2. On 2-1, 534 towards, 54 away, at 0.75. His model instead allows left, straight or right after each landing at the old speed. In the deaths (5000458, 5000545) a wild barrel lands near him and comes straight at him at about 1.5 while his plan rates standing there safe. New `wild_toward` (one path, heading for Mario after every landing) and `wild_spd` (a minimum speed after landing). Testing `gg01`–`gg03`.

`wild_toward` results (against `gf00` 83.68%): `gg01` 82.61% (135 / 165), with `wild_spd=1` (`gg02`) 82.96% (198 / 219), plus `ladder_sure` (`gg03`) 82.82%. Rejected. Ladder deaths 87 to about 110. Which way it heads depends on where Mario is when it lands, which depends on the plan being weighed; using where he stands now gives one fixed path that's wrong whenever the plan takes him past it. The old three-way guess covered that. Next: keep three directions with the real speed (`wild_spd`), or drop "stays put" (`wild_sides={1,-1}`), `gh01`–`gh04`.

Speed and direction variants (against `gf00` 83.68%): `wild_spd=1` (`gh01`) 83.16%, 175 / 189; `wild_sides={1,-1}` (`gh02`) 83.44%, 102 / 110; both (`gh03`) 81.99%; plus `ladder_sure` (`gh04`) 82.16%. All worse, and **every one raised ladder deaths** (87 to 110–144). Any change to how wild barrels are predicted also changes his up-and-down decisions on ladders, and that logic is fragile: it's the hesitation Matt saw in his deaths 3 and 5. New `wild_split`: the measured model guides jumps and walking, the old one stays for ladder decisions (`gi01`–`gi04`).

`wild_split` (against `gf00` 83.68%): with `wild_spd=1` (`gi01`) 83.72%, 163 / 160; plus never staying put (`gi02`) 83.36%; heading for Mario (`gi03`) 83.63%; never staying put alone (`gi04`) 83.63%. Neutral with heavy churn, ladder deaths still up to about 105. How he predicts an already-bouncing wild barrel isn't the lever on 3-1. Next: watching for Kong's release from anywhere on the board (`kong_y`), with level-3 directions (`gj01`–`gj03`).

Watching for Kong's release lower down (`kong_y`, against `gf00` 83.68%): to 250 with level-3 directions (`gj01`) 84.08%, 171 / 162; to 180 (`gj02`) 84.25%, 168 / 155; to 250 with 1-1 directions (`gj03`) 83.75%. **Noise warning for 3-1:** changes there swap about 330 of 3,000 games either way, so the difference has a spread of about 0.6 points. Under about 1 point on 3,000 games means nothing. Use 10,000-game runs to decide.

**Are 3-1 deaths escapable?** `tools/probe_plans.py` on 16 random deaths of `gf00`: all 16 had surviving plans, most from 15–55 frames before the death, within human reaction time. But that's hindsight: the replay knows where each wild barrel will bounce, and he can't.

**Wild barrels moved in step with each plan (`wild_dynamic`, native only):** the compiled plan check moves each wild barrel frame by frame, heading for Mario's planned position each time it lands; ladders keep the old model. Against `gf00` 83.68%: `gk01` 83.33%, 160 / 171; with `wild_spd=1` (`gk02`) 83.81%, 199 / 193. Wild deaths 310 to 282, but barrel deaths 150 to 175. Within noise. Off by default; with it off, games are identical (400 / 400 checked).

Running: the small wild-barrel gains, alone and together, on 10,000 new games (`gl00`–`gl03`, first 5100000). Matt has a video of 10 typical 3-1 deaths (`runs/gf00/review3.txt`, `~/Movies/dk_3-1_deaths.mp4`) for review.

**10,000 new 3-1 games (first 5100000):** current setting (`gl00`) 83.62%; **all the small wild-barrel gains together (`gl01`) 84.98%, 965 saved / 834 lost** (about 3 times the noise), wild deaths 992 to 872; watching Kong from the 3rd girder up alone (`gl02`) 84.09%, 570 / 523; wild barrels moving with each plan alone (`gl03`) 83.71%, 662 / 655. **Adopted for 3-1:** `kong_rays` (level 3), `kong_y=180`, `ladder_sure`, `wild_dynamic`, `wild_spd=1`. Each alone was within noise; only together do they clearly help. Note: `wild_dynamic` works only on the native runner, so 3-1 under MAME (live view) plays a little differently from the exams.

**Ladder options on the new base (10,000 games, against `gm00` 84.98%; `gm00` matched `gl01` game for game):** `ladder_real` (`gm01`) identical: with `ladder_sure` on it has nothing left to change; `retreat_top=8` (`gm02`) 84.94%, 17 / 21; `ladder_known` (`gm03`) 84.82%, 52 / 67; `ladder_hold=12` (`gm04`) 84.61%, 38 / 72. None adopted.

**Hammer deaths on 3-1:** 58 per 10,000 die holding the hammer, nearly all on the 2nd girder at x=80–120, after grabbing the lower hammer by jumping at about x=168–180 (from the traces: pick-ups at (168–180, 208)). With the hammer parked, new `ham_avoid2={from,to}` rules out jumps through that spot (Lua and compiled alike). Testing `gn01`, `gn02`.

`ham_avoid2` (10,000 games, against `gm00` 84.98%): {160,186} (`gn01`) 82.22%, 1,087 / 1,336; {155,192} (`gn02`) 83.53%. Rejected. Fireball deaths on the 2nd girder rose from about 200 to over 500: ruling out jumps there leaves him unable to deal with what comes, and the hammer was sometimes saving him.

**Weights on 3-1 (10,000 games, against `gm00` 84.98%):** `w_risk` 150 / 400 (`go01`/`go02`) 84.29 / 84.91%; `w_no_next` 100 / 220 (`go03`/`go04`) 84.99 / 84.82%; `min_clear=3` (`go05`) 81.65%; `w_jump=30` (`go06`) 85.26%, 361 / 336 (noise); without the back jump (`go07`) 83.35%, 88 / 246 (the back jump matters on 3-1); `next_waits` from 7 (`go08`) 85.01%, 5 / 2. Nothing adopted. The machine then sat idle from 05:36 to 08:23: that batch was started without a completion notice.

**3-1 status, morning of 2026-11-04:** 84.98% on 10,000 fresh games (`gm00`, first 5100000), 83.28% counting fireballs, up from 76.2% at the start. Not at 97%, so no move to 4-1. Per 10,000: 4th girder 790 deaths (467 at x=80–100, round ladder 91 and his waiting spot), wild barrels about 870 across every girder, 2nd girder 379 (mostly wild). Matt has a video of 10 typical deaths to review.

**Live filler on the boards:** `gp00`, 4,000 more fresh 3-1 games on 2 boards while traces ran: 84.63% (consistent with `gm00`). A second filler run (`gp01`) was stopped and deleted when the 8-board tests restarted.

**Deaths around ladder 91 on 3-1 (`gm00`, 102 traced at the 4th girder x=78–102):** 54 died while climbing or having just chosen to climb. The pattern (5101754, 5102332) matches Matt's deaths 3 and 5 on 2-1:
1. He starts the climb when the path is clear.
2. Moments later Kong throws a barrel that comes down the broken ladder and rolls left to the top of ladder 91.
3. Any barrel crossing that ladder top while Mario is on the ladder is very likely to come down it: being right under it counts as pressing towards it in the game's rule.
4. He backs down, and a barrel on the 4th girder rolls under the ladder foot.

Testing: before starting the climb (`next_drop_approach`) and during it (`next_drop_climb`), allow for Kong's next barrel, timed from his pose (`gq01`, `gq02`) or the usual rhythm (`gq03`).

Kong's next barrel at ladder 91 (10,000 games, against `gm00` 84.98%): timed from his pose (`gq01`; `gq02` identical) 84.05%, 426 / 519. Ladder deaths 289 to 257, but 4th girder deaths 790 to 919: he waits longer at the foot and dies waiting. On the usual rhythm (`gq03`) 76.50%. Rejected.

**Matt's review of 10 3-1 deaths (`runs/gf00/review3.txt`), 2026-11-04:**
1. (5000701) Very common: **juke** the wild barrel by pressing right as it lands on each girder, which flings it to the side.
2. (5002969) Same; also he's slow getting to the 2nd girder; stand just to the side of the hammer and juke from there.
3. (5001331) Fair death.
4. (5000931) Juke it right as it hits the girder above him, staying as still as possible before and after.
5. (5002787) Maybe stay a bit on the ladder holding right to juke it, or juke at the top of the ladder. Grind it out.
6. (5002093) Stay fairly still near the left side and juke; moving to the middle made it home in.
7. (5001966) Jumped too late: straight-jump earlier, for both barrels.
8. (5000934) Should have steered the barrels above down the ladder to the right; not doing so made a combination he couldn't jump to his left.
9. (5001005) Why did he jump into a barrel? Answer: for about 70 frames he walked left away from his ladder, because Kong's possible wild barrels (which on 3-1 always head right) made the right look dangerous. Boxed into the corner by the left end and the hammer-avoid rule, he had no safe plan and fell back on a jump into the barrel. Matt asked whether a wall jump off the left side would work. Grinding it: single jumps left survive if started 39–59 frames before the death, and end 10–20 px further right than a plain jump would land, so he bounced off the left wall. His model treats x<30 as falling off and has no wall bounce.
10. (5000331) Legit death.

**The juke is real, from the traces (`gm00`).** At the moment a wild barrel lands:

| Mario's stick | Where the barrel went |
|---|---|
| Pressing right | Right in 1,766 of 1,886 landings, even with Mario to its left (803) |
| Not pressing | Towards Mario (466 of 494) |
| Pressing left | Left 218, right 183; probably timing |

So "heads for Mario" was half of it: it follows the stick, and with the stick centred it heads for him. New `wild_stick` (with `wild_dynamic`): each plan's stick at each landing decides where the barrel goes, so the planner can find jukes. Testing `gr01`. Next: measure and model the wall bounce.

**Juke and wall bounce on 3-1 (10,000 games, against `gm00` 84.98%):** `wild_stick` both ways (`gr01`) 83.82%, 552 / 661 (wild deaths up); right presses only (`gr02`, as measured) 84.67%, 202 / 235. Knowing about the juke isn't enough: none of his plans is a juke, a short tap right timed to the landing while staying still. New `juke` lets him choose one (native only). Testing `gt01`, `gt02`.

The wall bounce, measured on the native runner: a jump that reaches the left wall at x=22 reverses and lands as far back out. Walking, he just stops at the wall. New `wall_jump` reflects jumps off it and lets him use the space down to x=22. Lua and compiled play identically with it on (200 / 200, `gs00m`/`gs00n`). On 3-1 (`gs01`) 84.99%, 1 saved / 0 lost: the situation is rare. Adopted for 3-1 as correct physics.

**Juking tested directly in the game (native runner, real 3-1 landings replayed with changed inputs), 2026-11-04:**
- My "barrels head for Mario" and "follow the stick at landing" figures came from death recordings, which are biased: barrels that came at Mario are the ones that end up there. That's why `wild_toward`, `wild_stick` and `juke` (`gt01` 84.80%, `gt02` 84.77%) didn't help. All off.
- Pressing right or releasing the stick for 6 frames either side of a landing: no change at all (5 landings).
- Moving Mario far left or right for 60 frames before Kong lets go: no change.
- **Holding left against holding right through the 40 frames before a landing: the barrel goes the way the stick was held** (5100001, 5100027 twice, 5100042). It works even with Mario stuck on a ladder (5100018), so it's the stick, not where he is.
- **Timing:** what counts is pressing about 10–30 frames before the landing, while the barrel is still falling from the girder above. At or after the landing does nothing.
- Not yet clear: centred, left and right don't map cleanly to straight, left and right; it varies from barrel to barrel. Needs the game's own wild-barrel code (a disassembly), or Matt's description of exactly when and how he presses.
- Test scripts: `native/experiments/juke_replay.lua` and `native/experiments/juke_window.lua` (wall bounce: `native/experiments/wall_jump.lua`) (replay to a frame, then change the stick).

**The game's own wild-barrel code (disassembled with MAME's debugger: `native/experiments/rom/dkong.asm`, script `native/experiments/dasm.lua`).** Wild barrels branch off at `0x1F97` to `0x20EC`. At each bounce `0x22CB` sets the new direction (`ix+$10`) and speed fraction (`ix+$11`). Once the oil is lit (`$6348`), it depends on the difficulty (`$6380`):

| Difficulty | Direction after a bounce | Speed |
|---|---|---|
| 1–2 (`0x22F6`) | random, from the random number `$6018` | random |
| 3–4 (`0x2303`) | **towards Mario's x at that instant** (`$6203` against `ix+$03`) | random: 1 + u px a frame right, 1 − u left (u from `$6018`) |
| 5 (`0x231A`) | aimed at Mario | grows with the distance to him |

Before the oil is lit, a fixed pattern by level (`0x22E1`). **The stick is never read for wild barrels.** Matt's juke works by where Mario is at the instant of the bounce: step across the barrel's x as it lands and it goes the other way. In the stuck-on-ladder test the stick changed the result only through the random number's timing (the speed). Measured with `native/experiments/difficulty.lua`: 3-1 is at difficulty 3 once the oil lights (about frame 366), 4 from about frame 1,984, 5 from about 4,032. 2-1 is at 2, then 3 from about frame 1,984. So on 3-1 nearly every bounce heads for Mario's x, while on 2-1 it's mostly a coin flip.

`wild_dynamic` already used this direction rule, with the plan's own x at each landing. It had the speed wrong: one fixed speed against the game's lopsided random one. New `wild_rom` checks each plan against three speeds per bounce (u = 0, 0.5, 0.99). Testing `gv01`. (Wild-barrel paths at difficulty 1–2 and 5 aren't modelled this way yet.)

**Fresh 3-1 runs with the current setting:** `gu00` 85.29% and `gu01` 84.84% on two new sets of 10,000.

**`wild_rom` result:** 10,000 games against `gm00`: 86.10%, 565 saved / 469 lost; fresh set against `gu00` (`gv02`, first 5600000): **86.57%** against 85.29%, 543 / 425. **Adopted for 3-1.** Wild deaths about 860 to about 620 per 10,000. Ordinary barrel deaths rose on the 5th girder (about 250 to 400), mostly at x=40–59 (15 to 53) and x=80–99 (11 to 41). x=40 is the left corner by the top hammer, the trap from Matt's death 9: dodging wild barrels takes him left, and the hammer-avoid rule boxes him in. Testing `ham_avoid=false` on 3-1 (`gw01`).

**Trace tool bug (fixed):** `autopsy.py` re-runs the player to trace a death. It did that in MAME even for batches played natively, so once a native-only feature (`wild_dynamic`, adopted at `gm00`) was on, it traced a different game. The `gm00` traces (400) are invalid, including the ladder 91 analysis drawn from them: 157 of them "ended" with Mario at the top of the last ladder, a clear in the MAME version of the game. Earlier traces (`gb05`, `gf00`) are fine. Now native batches are traced on the native runner, and the traces match the recorded deaths. Also new: `autopsy.py --ids`.

**The real 5th-girder corner deaths (`gw00`: 5101612, 5109396, 5101230):** barrels keep coming from the right (off the broken ladder, and from the right end). He jumps each one to the left, a back jump, and drifts left until he's pinned at x=43–47. There he straight-jumps barrel after barrel until one jump is too late. Suspect: the back-jump bonus (`w_with`) always favours jumping left on that girder. Corner allowed with the hammer (`ham_avoid=false`, `gw01`) 85.74% against `gw00` 86.10%, 31 / 68: rejected.

Back jump by girder (against `gw00` 86.10%): not on the 5th (`gx01`) 85.30%, 99 / 178; only on the 4th (`gx02`) 85.31%. Rejected: 5th girder deaths rose 401 to 470. The back jump helps there too. The corner drift comes from each jump being the best single move while together they carry him away from his ladder (x=203), against the flow of barrels.

`with_min_x` (no back-jump bonus for a landing left of x=60 / 75, against `gw00` 86.10%): `gz01` 86.16% (22 / 16), `gz02` 86.14% (39 / 36). No effect: few jumps are affected, so the corner drift comes from his plans as a whole, not the bonus. **Fresh check of the current setting:** `gy00` (first 5800000) 86.34%; with `gv02` 86.57%, 3-1 is at about 86.5%.

**Valid traces of 3-1 deaths (`gy00`, 400, all ending on the recorded frame):** biggest clusters are the 4th girder at x=80–99, the foot of ladder 91 (66 barrel, 29 wild, 10 fireball = 105 of 400), then the 5th girder at x=100–139 (mostly wild), the 3rd girder at x=120–139 (wild), and the 2nd girder at x=200–219 (wild). At ladder 91's foot: 29 jumping, 23 walking, 14 on the ladder. Two patterns:
1. **Barrel trains from the left while waiting (5800068).** On 3-1, barrels off the left ladder and round the left end arrive 10–16 px apart. From his spot at x=82 he jumps the first and lands with the next 9 px away, too close to jump again.
2. **Climb, back down, caught at the foot (5800137, 5800058).** He starts climbing, Kong's barrel comes down the broken ladder and rolls to ladder 91's top, he backs down, and an ordinary barrel catches him at the foot. Same dilemma as on 2-1, tighter with level 3's faster throws.

**Wild barrel behaviour, confirmed from an annotated disassembly Matt shared (only this part kept):**
- Sideways movement per frame (`0x239C`): x += step + carry, where step is `ix+$10` (+1 right, −1 left, or 0) and a fraction accumulator `ix+$04` += `ix+$11` supplies the carry. So the speed is step + `ix+$11`/256: right 1 + u, left −(1 − u), with step 0 giving +u.
- At each girder hit, and at release from Kong, `0x22CB` sets step and fraction. Once the oil is lit, by difficulty `$6380`:
  - 1–2: step 0 or −1 at random, fraction random. Drifts 0–1 px a frame right, or 0–1 left.
  - 3–4: fraction random; step +1 if Mario's x ≥ the barrel's x, else −1. Towards Mario, right at 1–2, left at 0–1.
  - 5: velocity (8.8 fixed point) = (Mario's x − barrel's x) × 4 / 256, so about dx / 64 px a frame, aimed at him.
- Before the oil is lit (the first wild barrel): fraction 1 on level 1 (almost straight down), `0xB1` on level 2 (0.69 right), `0xE9` from level 3 (0.91 right), step 0.
- A girder hit isn't checked until the barrel is 26 px below its last one (`ix+$19`). At y ≥ `0xE0` it becomes a normal barrel rolling left.
- So `wild_rom` matches difficulty 3–4 (nearly all of 3-1). Not modelled yet: difficulty 5 (late in a board) and the 1–2 random drift that most of 2-1 plays at.

Waiting spot at ladder 91 on 3-1 (10,000 games, against `gw00` 86.10%): further away, `standoff4=16` (`ha01`) 85.74%; closer, `=6` (`ha02`) 81.40%; on the right, `arrive4=1` (`ha03`) 82.60%. The current spot (10 px left, where Matt waits too) is best. **Fresh 3-1 run:** `gy01` (first 5900000) 86.84%.

**3-1 current setting, large fresh run:** `gy03` (30,000 games, first 6100000) **86.49%** (lowest likely 86.1%, 84.70% counting fireballs); `gy02` 86.59%. Of 4,589 deaths, 4,234 came at difficulty 3, 347 at 4 and 8 at 5. The wild-barrel model matches the game at 3–4, so 3-1 is limited by his decisions now (ladder 91 timing, barrel trains at its foot, the 5th-girder corner), not by his knowledge of wild barrels. Waiting on Matt's advice on timing the climb and crossing the 5th girder.

**Matt's review of 10 3-1 deaths (`runs/gy00/review4.txt`), 2026-11-04 evening:**
1. (5802254, ladder 91 climb) Fair, but he could have gone up sooner by steering some barrels down to the right.
2. (5801137, ladder 91 climb) Climbed too early: unsafe, shouldn't have climbed then.
3. (5801460, ladder 91 climb) Probably fair.
4. (5802564, ladder 91 foot) He needs to steer barrels right at this spot, to avoid stacks of barrels like this.
5. (5802283) Same: not steering let a bad set pass over him and to the left.
6. (5802289) Same.
7. (5802527, 5th girder corner) Should have stood near the top of the ladder and straight-jumped the first barrel. Why did he get stuck there?
8. (5800413, 5th girder corner) Why did he go left, or not straight-jump?
9. (5802241, wild) Should have jumped straight, not into the wild barrel. Why jump right? Could have stopped right of the ladder, jumped straight and steered it right.
10. (5801174, wild) Should have steered it right, standing still just left of the hammer and jumping.

**Steering, as the game does it (`0x216D`):** when a barrel reaches a ladder, after a difficulty check (random `& 3` < difficulty/2 + 1, so about half the time on 3-1) it takes the ladder if Mario is level with it or the stick points towards it; otherwise 1 in 4. From the foot of ladder 91 (x=82), tapping right as 5th-girder barrels cross the ladders at x=92 and 188 sends them down to the 4th girder on his right, where they roll right, away from him. It also means they rarely take the x=52 ladder on his left, which feeds the trains that kill him. New `steer_pull`: while standing, tap towards a ladder above that a barrel is about to cross, on the side his own girder's barrels roll away to. Testing `hb01`–`hb03`.

`steer_pull` first results (against `gw00` 86.10%): 3 frames ahead (`hb01`) 85.65%, 753 / 790; 6 ahead (`hb02`) 80.55%; 4th girder only (`hb03`) 85.77%. It does what Matt said: fireball deaths 210 to 127 and wild 615 to 548, as fewer barrels reach the oil drum and the left side. But walking deaths rose, because each tap walks him right without his planner checking those steps. New `pull_safe`: steer only when a few steps that way (`pull_walk` frames) are clear. Testing `hc01`–`hc03`.

Matt's death 9 (5802241), why he jumped right: on the 3rd girder a barrel was already coming down the x=131 ladder when he walked right to x=139, 8 px from its foot, leaving only a forced jump right over it. A wild barrel then appeared above, bounced towards him, and the jump back left met it. The mistake was earlier: walking up beside a ladder with a barrel coming down it.

`pull_safe` results (against `gw00` 86.10%): `hc01` 86.25%, 296 / 281; `pull_walk=12` (`hc02`) 86.28%; 4th girder only (`hc03`) 86.31%. Counting fireballs 84.69% against 84.29%; 4th girder deaths 669 to 631. **But these runs had a bug:** a steering tap returned early and skipped his record of his own movement, so his idea of his position drifted after each tap. Fixed, and retested as `he01`.

**Steering, chosen to suit the situation (Matt):** he steers "only as best needs":
- In any jump (`steer_air`) he can steer either way: the stick can't change his path mid-air. Which side a ladder is on is judged from where he'll land. It stops 4 frames before landing, so the press doesn't become a walk.
- Standing, he taps if a few steps that way are safe (`pull_safe`).
- Standing, if steps aren't safe but a straight jump is (`pull_jump`), he jumps straight and steers from the air.
- When steering, the let-go rule (`steer_off`) doesn't undo it.

Testing `he01`–`he05`.

**Steering results (fixed code, 10,000 games, against `gw00` 86.10%):**

| Steering | Cleared | Saved / lost |
|---|---|---|
| Standing, when steps are safe (`he01`) | 86.48% | 307 / 268 |
| In any jump, either way (`he02`) | 86.97% | 419 / 331 |
| **Both (`he03`)** | **87.32%** | **571 / 450** |
| Both, plus jumping straight to steer (`he04`) | 86.70% | 573 / 509 |
| Straight jumps only (`he05`) | 86.74% | 339 / 276 |

With both: 4th girder deaths 669 to 554, fireballs 210 to 177. **Adopted for 3-1** (`steer_air=true, steer_pull=3, pull_safe=true`). Jumping just to steer costs more than it gains. Fresh check next.

Fresh check of steering (`hf01`, first 6000000): **87.37%** against `gy02` 86.59% on the same games, 524 / 455; counting fireballs 85.94% against 84.98%. Kept.

Checks after the day's planner changes: 1-1 (`rg10`) played differently 0 of 3,000; 2-1 natively against `ge00`, 400 / 400 identical. All of today's changes stay level-gated to 3-1.

Steering timing (against `he03` 87.32%): `steer_pull=2` (`hg01`) 87.53%, 266 / 246 (noise); `=5` (`hg02`) 87.31%; `pull_walk=12` (`hg03`) 87.30%. Unchanged.

**Latest 3-1 deaths (`hf01`, 400 valid traces):** 4th girder x=80–99 (49 barrel, 32 wild), of which 47 climbed and then backed down; 5th girder x=100–119 wild 35 (just off ladder 91's top, by the broken ladder's foot); 2nd girder x=200–219 wild 28; 3rd girder x=120–139 wild 20. Climb timing (Matt: "climbed too early, unsafe situation") is the biggest single pattern. Retrying the climb-timing ideas on the steering base (`hh01`–`hh03`).

Climb timing on the steering base (against `he03` 87.32%): Kong's next barrel timed from his pose, before and during the climb (`hh01`) **87.99%**, 507 / 438, 5th girder deaths 385 to 292 but 4th 554 to 607. Before steering, the same setting lost (`gq01`): now that steering thins the barrels at the foot, waiting there costs less. Longer clear spell `after_climb4=40` (`hh02`) 87.09%; climbing on near the top `retreat_top=10` (`hh03`) 87.06%. Fresh check of `hh01` next.

Fresh check of the climb timing (`hi01`, first 6000000): **88.80%** against `hf01` 87.37%, 510 / 374; ladder deaths about 250 to 188, 5th girder 380 to 271. **Adopted for 3-1** (`kong_pose`, `next_drop_climb={0}`, `next_drop_pose`, `next_drop_approach`). This is Matt's "climbed too early": he waits at the foot until Kong's next barrel won't meet him at the top.

**Overnight plan, 2026-11-04 (Matt: grind out the scenarios that won't resolve, hundreds or thousands of times):**
- `probe_plans.py --native` grinds a death on the native runner. Checked identical to the MAME version (5001005: same 219 of 5,200 surviving plans).
- `--steer` adds plans that hold a different direction mid-jump (it can't change his path, but it steers barrels).
- `tools/grind.py BATCH LABELS` grinds many deaths in parallel, looking back 240 frames (4 s: back to the decision, still the same situation). Per kind of death it reports how many had a way out a person could start in time (20+ frames before) and which moves worked most often.
- Steering on girders further up (`pull_up`): the game only checks that Mario is below the barrel (`0x217F`), so standing taps can steer barrels anywhere above him. Matt: "encouraging a barrel on the other side of the board to go down to avoid a bad situation". Testing `hk01`, `hk02`.
- The chain is in `/tmp/claude_night.sh`. Results go to `runs/hj00/grind_summary.txt`.

Climb timing parts (against `hj00` 87.99%, the adopted setting): **only on the ladder, not when deciding to start (`hj01`) 88.59%, 381 / 327**, counting fireballs 87.02% against 86.07%; allowing for a slightly late throw (`hj02`) identical, no effect. Fresh check of `hj01` running (`hl01`).

Fresh check of on-ladder-only climb timing (`hl01`, first 6000000): 88.63% against `hi01` 88.80%, 330 / 344; counting fireballs 87.17% against 86.90%. Not adopted: no gain on the headline (fireballs excluded). The adopted setting stays.

**Overnight results:**
- Steering on girders above (against `hj00` 87.99%): two girders (`hk01`) 87.83%, 408 / 426; **any girder above (`hk02`) 88.80%, 1,005 / 920**. Fresh check running (`hm01`).
- Grinding 287 deaths of `hj00` (`runs/hj00/grind_summary.txt`). Read naively, almost everything survives if started 3–4 s early. But any change in input that early also changes the game's random numbers (they depend on input timing), so those escapes are luck. The meaningful measure is the **latest** moment a move still works. In nearly every kind of death a move still worked 23–47 frames before, within reaction time:

| Kind of death | Latest escape, median frames before | Move that most often still works there |
|---|---|---|
| Ladder 91 foot, barrels (41) | 41 | walk right, then jump (either way) |
| 2nd girder, wild (40) | 23 | walk right, then jump right |
| Ladder 91, climbed then backed down (28) | 35 | walk left, then jump left |
| 5th girder off ladder 91's top, barrel (27) | 23 | stand or walk left, then jump left |
| 3rd girder, wild (24) | 41 | stand or walk left, then jump left |
| 5th girder off the top, wild (24) | 47 | walk left, then jump right |

- **The 2nd-girder wild deaths** (x=192–216): the surviving "right, then jump right" escapes mostly end at x=212–224, past the x=222 limit his model allows. The right wall is at x=233, measured the same way as the left: a jump bounces off it, and walking stops at x=234. New `wall_right` extends the wall bounce and the usable space to it. Checking Lua and compiled agree (`hn00m`/`hn00n`), then testing `hn01`.

Fresh check of steering on any girder above (`hm01`, first 6000000): 87.50% against `hi01` 88.80%, 916 / 1,044. **Rejected**: the practice-set gain was churn. Steering stays on the girder directly above.

`wall_right` (Lua and compiled agree, 200 / 200): on 3-1 against `hj00` 87.99%, `hn01` 87.72%, 89 / 110. 2nd girder deaths 300 to 242 (the escape works there), but 1st girder 2 to 45, Kong's girder 60 to 127, and falls 57 to 94: other girders' right ends stop short of the wall, and the extra space walks him off. Now `wall_right` takes floors, `{[2]=true}`. Testing `ho01`.

Right wall on the 2nd girder only, landing on the girder (in the air up to the wall at x=234, but standing at x≤224). Lua and compiled agree (200 / 200). Against `hj00` 87.99%: `hp01` 88.56%, 85 / 28. Fresh against `hi01` 88.80%: `hp02` 88.94%, 56 / 42. **Adopted for 3-1** (`wall_right={[2]=true}`). Without the landing limit (`ho01`), 45 jumps came down beyond the girder's end at x=228–233 and fell. About 30 falls remain.

Standing margin before the 2nd girder's right end (against `hq00` 88.56%): x≤220 (`hq01`) 87.95%, 32 / 94; x≤216 (`hq02`) 87.82%, 58 / 132. The margins stop the falls, but 2nd girder deaths go back above 300: the escape only works by going right to the end. Kept at 224.

## 4-1 (started 2026-11-05)

Target: above 95% (Matt). The loop for each round: trace deaths (native traces), grind the biggest kinds, turn the latest working moves into a rule for that situation, test on 10,000 games and confirm on fresh ones, repeat, with videos for Matt's review when stuck. Starts `l4_000`–`l4_063` in MAME and natively. `levels[4]` starts as a copy of the final `levels[3]`. The website's default label now reads Level 4-1 (it shows the live game's level when batches run).

**4-1 baseline:** `ia00` (10,000 fresh games, first 7000000) **86.90%**, counting fireballs 84.48%. It ran with the 3-1 settings, despite its note saying "settings as for 1-1": I added `levels[4]` as it started. The first native-against-MAME check (`ia0m`, 1 of 200) was invalid for the same reason. Rechecked with matching settings (and `wild_dynamic` off, which MAME can't run): `ic0m`/`ic0n` 200 of 200 identical. Deaths: 2nd girder 329, 4th 617 (x=90–99 171), 5th 385 (x=40–49 64, x=100–139 215).

**4-1 grind (339 deaths of `ia00`, `tools/grind_latest.py ia00`):** every death had a way out a person could start in time, usually about 23 frames before. Most common latest escapes: 5th girder off ladder 91's top (37), stand then jump left; ladder 91 foot (36), stand or step right then jump left; 4th girder wild (33), step right then jump left; 5th girder corner (32), step left then jump left; 2nd girder wild (29), step right then jump right. `why_plan.py` now scores native batches natively. In those 5th-girder deaths he's mid-jump when the danger appears, and his model says every option is hit ("no safe plan"), partly because it allows for the slowest and fastest barrel speed. The replays survive with a left jump on landing. 73 of 400 4-1 deaths had "no safe plan" in their last 30 frames. New `fallback_pref`: with no safe plan, prefer the jump direction grinding found works there, if it lasts nearly as long in his model (`fallback_slack` frames). Testing `id01`–`id03`.

`fallback_pref` by girder (against `ia00` 86.90%): `id01` 84.23%, 11 / 266; `id02` 84.23%; 5th girder only (`id03`) 84.21%, 3 / 261. Kong's girder deaths rose from 61 to 322. Cause (7000068): with no safe plan at the far right of the 5th girder, below the last ladder, it jumped him left, straight under a barrel coming down that ladder. Grinding found "jump left" works near ladder 91, not across the whole girder, so a preference has to name its area. `fallback_pref` is now `{{floor, from x, to x, direction}, ...}`. Testing `ie01`–`ie03`.

Area-specific `fallback_pref` (against `ia00` 86.90%): just off ladder 91's top (`ie01`) identical; plus its foot (`ie02`) 86.88%, 1 / 3; plus the 2nd girder's right (`ie03`) 86.88%. It almost never triggers: in those deaths the no-safe-plan moment comes mid-jump, when no new jump is possible yet. The problem is upstream: his model calls it hopeless when the replays show it isn't. Suspect: the wild-barrel model checks every plan at three bounce speeds (u = 0, 0.5, 0.99) and rejects it if any would hit. New `wild_rom_us` sets those speeds. Testing one, two and five speeds (`if01`–`if03`).

Bounce speeds checked (against `ia00` 86.90%): **middle speed only, `wild_rom_us={0.5}` (`if01`) 87.82%, 518 / 431**; two speeds (`if02`) 87.47%, 474 / 419; five (`if03`) 86.74%. Assuming the worst case at every bounce cost more than it saved. Fresh check next (`ig00`/`ig01`, first 7100000).

Fresh check (first 7100000): `ig01` **88.32%** against `ig00` 86.83% on the same games, 540 / 394. **Adopted for 4-1** (`wild_rom_us={0.5}`).

**Matt's review of 10 4-1 deaths (`runs/ig01/review5.txt`):**
1. (7101814) He moved or steered right when he could have stood still; the wild barrel was flying off right anyway. Avoid running right towards it in this spot.
2. (7105336) He should have steered the first barrel above him right, not just the second.
3. (7108205) Not sure; grind it, there may be no solution.
4. (7101655) Avoidable with an early straight jump, with time to jump the second, and not going back left.
5. (7100249) Fair.
6. (7107338) Back-jumped the barrel coming down the ladder for no reason (look into this!). That caused the death.
7. (7102703) With the hammer he walked forward near a barrel and it went under the hammer. **Pro tip:** stop just before the barrel so it can't go under.
8. (7102962) A straight jump over the barrel, missing the wild, would probably have worked, though the second wild might have got him.
9. (7109283) Hesitating on the ladder: he should have backed down.
10. (7108563) After avoiding the wild he turned left into it. If it's that close, jump right.

New settings from it: `pull_nowild` (no standing steer with a wild barrel above him and near, for 1); `with_needed` (back-jump bonus only when standing still isn't safe, for 6); `ham_stop` (with the hammer, stop and face a barrel rolling at him from close by, for 7). Testing `ij01`–`ij03` against `ij00`.

`wild_rom_us={0.5}` on 3-1, fresh (`ih01`, first 6000000): **89.62%** against `hp02` 88.94%, 478 / 410. **Adopted for 3-1 too.** 3-1 now about 89.6%.

Review rules on 4-1 (against `ij00` 87.82%): `pull_nowild=40` (`ij01`) 87.70%, 9 / 23, rejected; `with_needed` (`ij02`) identical: when a barrel is that close, standing still is never safe, so the bonus didn't cause death 6's back jump; **`ham_stop=24` (`ij03`) 88.15%, 48 / 21, hammer deaths 68 to 36.** Fresh checks next (`ik01` on 4-1, `ik02` on 3-1).

Fresh checks of `ham_stop=24`: 4-1 (`ik01`) 88.59% against `ig01` 88.32%, 46 / 26; 3-1 (`ik02`) 89.70% against `ih01` 89.62%, 31 / 26. **Adopted for both** (small, but the same direction on both, and hammer deaths halve).

**Matt's 4-1 death 6 (7107338), the back jump for no reason:** just off ladder 91's top (x=92), Kong's barrel is still 24 px up the broken ladder (107, 88) when he jumps left with a high score, because the back-jump rule's `with_drop` counts a barrel coming down a ladder beside him as rolling at him. He lands at x=70, the barrel lands and rolls left after him, and the second jump comes too soon after landing. A player waits, then straight-jumps it once it's rolling. New `with_drop_h`: such a barrel counts only within this many px of his girder. Testing 12 and 20 (`il01`, `il02`) against `il00`.

`with_drop_h` (against `il00` 88.15%): 12 (`il01`) 88.14%, 1 / 2; 20 (`il02`) 88.16%, 1 / 0. No effect: the dropping-barrel bonus was rarely what made him back-jump, so my reading of death 6 was wrong. The planner scored that left jump as good on its own.

**Second 4-1 grind (`ig01`, `runs/ig01/grind_latest.txt`):** biggest kinds: 4th girder barrel (41), **ladder 91 climbed then backed down (40)**, off ladder 91's top barrel (36), ladder 91 foot barrels (29), 4th girder wild (29), 2nd girder barrel (28). Every death had a move that still worked in time. The climb-and-back-down traces (7100002, 7100018) show the hesitation Matt saw in death 9: up, down, up again, flipping for 50+ frames, until a wild barrel from Kong bounces towards the ladder and catches him in the middle. Testing commitment once he starts down (`ladder_commit`, with and without `ladder_true`) and holding just below the top (`ladder_hold`): `im01`–`im03`.

Ladder settings on 4-1 (against `il00` 88.15%): `ladder_commit` (`im01`) 88.24%, 121 / 114 (noise); plus `ladder_true=4` (`im02`) 87.66%; `ladder_hold=12` (`im03`) 88.07%. Committing one way doesn't stop the flipping, since he also turns from down back to up. New `lad_hyst`: any change of direction on a ladder holds for at least N frames. Testing 12 / 24 / 40 (`in01`–`in03`).

`lad_hyst` (against `il00` 88.15%): 12 (`in01`) 87.96%; 24 (`in02`) 87.50%; 40 (`in03`) 86.42%, 136 / 301. Rejected: many of his direction changes are correct reactions, and forcing him to keep going walks him into barrels. The ladder flipping needs a judgement of when up or down is right, not a blanket rule. Video of these deaths made for Matt's review.

**4-1 fresh exam, current setting:** `io00` (30,000 games, first 7200000) **88.41%** (lowest likely 88.0%), counting fireballs 86.02%. Per 30,000: 4th girder 1,646 deaths, 2nd 978, 5th 959, 3rd 383, Kong's girder 227.

**3-1 fresh exam, current setting:** `io01` (30,000 games, first 6500000) **89.89%**, counting fireballs 87.74%.

**4-1 long run:** `io02` (60,000 fresh games, first 7300000) **88.38%** (lowest likely 88.1%). Confirms `io00`.

**4th girder barrel deaths away from ladder 91 (`ig01`, 41 traced: x=60–69 13, x=100–169 26):** barrel trains. Barrels off the left ladder and round the left end chase him right at 1 px a frame, faster than his 0.67 walk. He walks ahead until they catch up (around x=130, 7100084) and two barrels 20 px apart are too close to jump; or from the ladder 91 foot spot he jumps left into the next (7100016). Matt's earlier advice (steer 5th girder barrels down the ladders on his right, so fewer reach the left) addresses the cause; he does that at ladder 91's foot, but trains still form. Waiting on Matt's view of the ladder-91 hesitation video and of how to handle a chasing train.

**Why didn't he take the escape grinding found? (`tools/escape_check.py ig01 60`, `runs/ig01/escape_check2.txt`)** At the frame each escape would have had to start, what did his planner make of the same move? Of 60 deaths:
- 36: he wasn't weighing plans then: on the ladder 14, in "nothing near, just walk" mode 10 (`walk_clear`), mid-jump 6.
- 16: he saw the escape as safe but scored another move higher (a scoring problem).
- 5: his model predicted a hit (a model problem).
- 3: he rated it best but didn't do it (timing).

So his model is mostly right; he switches off too readily ("nothing near" is too relaxed for level 4), and his scoring sometimes ranks the escape below a worse move. (He only re-plans every 2 frames, `decide_every`, so checks must use a frame where he decides.) Testing a stricter "nothing near" (`walk_clear` 10, 16; default 6): `ip01`, `ip02`.

`walk_clear` (against `il00` 88.15%): 10 (`ip01`) 88.20%, 201 / 200; 16 (`ip02`) 87.99%. No effect: weighing options more often doesn't help, since he still picks the move that looks safe for a second.

**The "rated it lower" cases, looked at closely:** mostly not scoring mistakes. The move he chose looked safe to his model (clearance 3–7) and he still died: his plans look about a second ahead, and the chosen move leads somewhere fine for a second, then with no way out. In a couple, the escape was also marked down by the "maybe" barrel penalty. The gap is foresight. Looking further ahead (`plan_tail`) made 2-1 much worse, since it requires standing clear for the whole time. New in the compiled planner, **`follow_check`**: for each plan, from where it leaves him (end position, and the wild barrels moved along with that plan), is there still some simple safe move for `follow_steps` steps? The moves tried are standing, a step left or right, and a jump either way or straight, now or 8–16 frames later. Plans without one lose `w_no_follow`. Off by default (400 / 400 identical). Testing `iq01`–`iq03`.

`follow_check` (against `il00` 88.15%): `w_no_follow=100` (`iq01`) 88.41%, 127 / 102; 300 (`iq02`) 88.48%, 135 / 103; `follow_steps=20` (`iq03`) 88.35%; 1000 (`iq04`) 88.46%; 40 steps (`iq05`) 88.38%. **Fresh (`iq06`, first 7100000) 88.63% against `ik01` 88.59%, 104 / 100: not adopted.** The practice-set +0.3 didn't carry over. The check rarely changes his choice, or its alternatives are no better.

**4-1 status:** about 88.3% on 120,000-game fresh runs. The last day of rule changes (no-safe-plan preference, ladder commitment and holds, stricter "nothing near", dropping-barrel timing, foresight) all came out neutral or worse. Only the hammer tip and the wild-speed change helped. The deaths that remain (ladder 91 hesitation, barrel trains, just off ladder 91's top) need either Matt's judgement on specific moments or a bigger change to how the planner searches.

## 5-1 (started 2026-11-06)

Matt: from level 5 the barrel boards stop changing difficulty, and it should be possible to build something with a 100% pass rate so long as fireballs don't stop him. Starts `l5_000`–`l5_063` (MAME and native). Native against MAME: 200 / 200 identical (`ja0m`/`ja0n`, with `wild_dynamic` and `follow_check` off). `levels[5]` starts as a copy of `levels[4]`. The website's default label now reads Level 5-1.

**Baseline (`jb00`, 10,000 fresh games, first 8000000):** **82.06%**, counting fireballs 77.37%. Deaths: wild 980, barrel 683, fireball 571; 2nd girder 861, 4th 880 (x=80–89 318), 5th 270. **Difficulty is 5 from the start** (`native/experiments/difficulty.lua`), where wild barrels are aimed: each bounce, and Kong's release, at (Mario's x − barrel's x) / 64 px a frame (`0x231A`). The 3–4 model (`wild_rom`) doesn't fit. New: `wild_aim` (compiled planner) and `kong_aim` (Kong's releases). Testing `jc01`–`jc03`.

Difficulty-5 model (against `jb00` 82.06%): aimed bounces `wild_aim` (`jc01`) 93.78%, 1,249 / 223, wild deaths 980 to 33; **with aimed releases `kong_aim=1` (`jc02`) 94.26%, 1,333 / 273, wild deaths 29**; aimed releases alone (`jc03`) 82.63%. **Adopted for 5-1.** At difficulty 5 a wild barrel's path is fully predictable from where Mario stands. Remaining (per 10,000): fireballs 606 (not in the headline), barrels 504; 4th girder 468, 2nd 336, 5th 184.

**5-1 fresh check (`jd01`, first 8100000): 94.62%**, counting fireballs 89.78%. Remaining non-fireball deaths per 10,000: 4th girder barrels mid-jump 229 (trains, x=60–150), 5th girder barrels 129 (off ladder 91's top, x=90–119), Kong's girder 40, 2nd girder with the hammer 27 (x=100–119), wild 19. Fireballs 512 are now the biggest single killer.

**5-1 hammer deaths on the 2nd girder (8103280, 8102550, 8103843):** holding the hammer near the foot of the x=115 ladder as a barrel comes down it. The "face it" hammer rule turns him towards it, walking him to the ladder's foot just as it lands. The hammer only reaches what's in front of him at his height. New `ham_ladder`: holding the hammer, step away from a barrel coming down a ladder close beside him. Testing `je01`/`je02` against `je00`, after the analysis chain.

`ham_ladder` on 5-1 (against `je00` 94.26%): 16 (`je01`) 94.41%, 16 / 4; 24 (`je02`) 94.41%, 19 / 8. **Adopted 16 for 5-1.**

**5-1 grind (`jd01`, 201 non-fireball deaths, `runs/jd01/grind_latest.txt`, `escape_check.txt`):** 4th girder barrels 67, off ladder 91's top 44, ladder 91 foot 38, Kong's girder 14, 2nd girder 13. Of 60 escapes, 36 came when he wasn't weighing options: mid-jump 13 (mostly off ladder 91's top), "nothing near, just walk" 10 (8 at ladder 91's foot), on a ladder 5. 17 were rated lower. At the ladder foot his quick check says walking is clear for the next second, and the barrels come just after. New `think_zones`: in those spots he always weighs every plan. Testing `jf01`/`jf02`.

`think_zones` on 5-1 (against `je01` 94.41%): ladder 91's foot (`jf01`) 95.59%, 320 / 204; **foot and just off its top (`jf02`) 95.63%, 347 / 222**, 4th girder deaths 472 to 361. **Adopted for 5-1.** Fresh check and "everywhere" next.

Fresh check of `think_zones` + `ham_ladder` (`jg01`, first 8100000): **95.53%** against `jd01` 94.62%, 330 / 244; counting fireballs 90.62%. **5-1 above 95% on fresh games.** Weighing every plan everywhere (`jg02`) 93.81%, 331 / 482, fireballs 589 to 914: the quick "just walk" is right in most places, and only misses near ladder 91. Trying the same zones on 3-1 and 4-1 (same ladder 91).

`think_zones` (ladder 91's foot and just off its top), fresh: **4-1 (`jh01`) 89.39%** against `ik01` 88.59%, 518 / 442; **3-1 (`jh02`) 90.01%** against `ik02` 89.70%, 499 / 471. **Adopted for both.**

**Matt's 5-1 4th-girder review (from `jg01`, video `~/Movies/dk_5-1_girder4.mp4`):**
1. 8105515: no reason to jump left. 2. 8105549: walked under ladder 91 and let a barrel fall on his head. 3. 8108047: avoiding the fireball (fair). 4. 8105123: jumped left for no reason, then went right and jumped straight too late. 5. 8102497: went right and jumped late. Tip: from there, tap left to steer the top-left barrel down to merge with the one to his left. **Grouping barrels makes things easier in general.** 6. 8107905: again right then a straight jump too late (recurring). 7. 8107508: grouped a bad batch, 3 barrels that can't be jumped: don't do that. 8. 8109599: **should have committed to the climb: on level 5 the wild barrel can't harm you there once you're going up.** 9. 8101854: bad luck, probably shouldn't have steered that first barrel. 10. 8108024: ran right away from the fireball, jumped far too late. Jumping right a few frames earlier would have landed him past the barrel as it moved with him.

**Cause of the late jumps (4, 5, 6, 10):** the traces show him walking right ahead of a barrel and re-planning "walk on, then jump" every 2 frames. The planned wait comes from a fixed list (0, 6, 12, 20, 30, 44), and with a small preference for later, the jump keeps slipping. New `keep_jump`: also weigh the jump planned a moment ago at the same moment; `w_keep` adds loyalty to it. Testing `jj01`–`jj03`. #8: he backed down ladder 91 (`ladder retreat`) for a wild barrel. New `climb_nowild`: going up, ignore wild barrels. Testing `jk01`.

More `think_zones` on 5-1 (against `jf02` 95.63%): further along the 4th girder to x=160 (`ji01`) 95.09%, 257 / 306, worse; the 2nd girder (`ji02`) 95.69%, 210 / 202, noise; Kong's girder (`ji03`) 95.59%, 3 / 6. None adopted: ladder 91 is the spot where the quick check fails.

### How fixes are tested from now on (Matt, 2026-11-06)

A fix for one kind of death can't show up in 3,000 or even 10,000 random games: the situation may happen a handful of times, worth less than the noise (about ±0.4). So each fix is now tested **on the deaths it's meant for**. `tools/death_groups.py BATCH` sorts non-fireball deaths into situations (`runs/BATCH/groups.txt`). `tools/scenario_test.py BATCH --level N --groups FILE [--set k=v]` plays each recorded game back to 60–180 frames before the death, then hands over to him (agent.lua `MODE=scenario`), several times with different human timing. It reports how many he clears, per group. Rules are gated to the situation (floor, area), kept if they clearly raise survival in their scenarios, then checked on 10,000 games for side effects. With nothing changed, a takeover 4 frames before death dies 10 / 10, and from 1.5–3 s before he clears about 57% of the reviewed deaths. Many deaths are bad timing luck rather than a wrong decision every time.

On Matt's 10 reviewed deaths (200 takeovers): as is 114 cleared; `keep_jump` + `w_keep=20` 103; `climb_nowild` 113 (#8 4 / 20 to 9 / 20).

**5-1 death groups (`jg01`, per 10,000):** 5th girder off ladder 91's top 109, 4th girder right 59, middle 51, ladder 91 foot 50, Kong's girder 32, 4th left 32. **Ladder 91 top:** in 4 of 6 traces a barrel on Kong's girder rolls right to the x=107 ladder just as he's holding right in the air. Either his jump direction or the deliberate in-air steering (`steer_air` through `pull_dir`, which pulls barrels down ladders ahead of him) brings it down onto his girder just ahead, and it rolls straight back into him. The walking let-go rule (`steer_off`) doesn't cover the air. New, gated by `steer_here` (5th girder on 5-1): `air_off` (in the air, let go as a barrel above crosses a ladder on the held side) and `pull_gap` (no pulling down a ladder that lands closer ahead than this on his own girder).

`keep_jump` on 10,000 games (against `jf02` 95.63%): alone (`jj01`) 95.49%, 367 / 379; `w_keep=20` (`jj02`) 94.85%; 60 (`jj03`) 94.81%. **Rejected**, as the scenario test predicted.

Ladder 91 top scenarios (109 deaths, 1,090 takeovers): as is 77.5%; **`air_off=10` 80.0%**; 20 79.4%; 30 79.8%; `pull_gap=40` 77.9% (no effect); both 79.9%. With `air_off=10`, every one of the 109 deaths is survived in at least 4 of its 10 takeovers. 10,000-game check `jl01`.

`climb_nowild` (Matt's #8) on 10,000 games (`jk01`): **95.93%** against `jf02` 95.63%, 57 / 27. **Adopted for 5-1.**

`air_off=10` on 10,000 games (`jl01`): 95.74% against `jf02` 95.63%, 26 / 18, 5th girder deaths 150 to 142, nothing else worse. Scenario gain plus no side effects: **adopted for 5-1.** Fresh check of both (`jm01`, first 8100000, against `jg01`).

Fresh (`jm01`, first 8100000): **95.88%** against `jg01` 95.53%, 69 / 39; counting fireballs 91.35%. **5-1 stands at 95.9% fresh.**

**5-1 4th girder grind (40 of the right and middle deaths, `runs/jg01/grind_latest.txt`):** right (x of about 120–150): typically a barrel 20–28 px behind him rolling his way, and his plan is "walk right 12–30 frames, then jump straight". The latest moves that still work are a jump back left over it (median 41 frames before the death). The existing `w_with` bonus favours jumping *with* a barrel (its way). New, gated: `chase_zone {floor, x from, x to}` with `chase_x`, `chase_w`, `chase_dir` ("back" / "any"), `chase_now`: with a barrel chasing close behind, a bonus for jumping back over it now. Scenario-testing on the 59 "4th girder right" deaths.

Chaser scenarios (59 "4th girder right" deaths; 590 takeovers, then 1,180): as is 60.5 / 58.9%; jump back over it (`chase_dir="back"`) 60.3%, with `chase_w=150` 54.9% (worse); **any jump now (`chase_dir="any"`) 62.4 / 60.8%**; `chase_w=120` 60.0%; `chase_x=40` 60.2%; `chase_now=12` 60.9%. A small, steady gain (+2): jump soon rather than walking on, but not necessarily back over it. 10,000-game check `jn01` against `jn00` (current settings).

`chase_zone` + `chase_dir="any"` on 10,000 games (`jn01`): 95.76% against `jn00` 95.97% (current settings), 114 / 133; "4th girder right" deaths 41 to 40. **Not adopted**: a +2 gain in scenarios worth about 0.4% of games can't show. **Lesson:** once a rule fires, the rest of that game plays out differently, so saved / lost counts in the hundreds are mostly reshuffling. For a gated rule the scenario test is the measure; the 10,000-game run guards against big regressions.

**Kong's girder (5-1):** typically he walks right, away from a barrel rolling from Kong, until he's trapped near the end, then makes a forced jump (sometimes off the edge). His plans all score unsafe there. Scenarios (42 deaths, 840 takeovers): as is 52.7%; `kong_aim=0.3` 55.1%; 0.1 55.1% (identical: below some level the aimed throw stops counting). `kong_aim=1` earned its place overall (`jc02`), so new `kong_aim_top`, only on Kong's girder. Testing 0.3 (`jo01`).

### Solving deaths one by one (Matt, 2026-11-06)

Matt: a 5-1 barrel board can be cleared every time apart from fireballs, so each death is a puzzle with an answer: play it back until the solution is found, going further back if needed (often a barrel should have been steered earlier), make sure the solution isn't a fluke, and don't apply it beyond its own situation. "Eventually you will have all the solutions."

- `kong_aim_top` (Kong's-throw odds on the top girders only): on Kong's girder it never fires (the throw only matters below). Top two girders: 52.7 to 53.7%, ladder 91 top 78.3 to 79.0%: noise. Not adopted.
- **Situation memory, first try (`cases/l5_v1.lua`, `tools/solve.py` from the old grinder): 67.6% to 18.1% on its own deaths.** Two causes: the old grinder's solutions assume he stands still afterwards, and cases with no barrels near him matched whenever he stood at that spot. Scrapped. Cases now need at least one barrel.
- **Turning points:** taking over with no move at 30–900 frames before each death shows where it turns. 8107905: 9 / 10 from 90 back, 0 / 10 from 60 back. Most of the 6 tried turn 60–120 frames before. 8108024 (fireball chase) is risky as far back as 720.
- **A takeover can make a move, then he plays on** (agent.lua scenario rows with "a w j1 j2 h"; policy `c.script`). **`tools/deep_solve.py`:** finds each death's turning point (going back up to 900 frames until he usually survives), tries 60 moves from every 12 frames between there and 20 frames before the death (ground taps and walks either way, which steer barrels, and jumps each way holding each way, after 0–16 frames standing or walking), then confirms the most promising: 30 tries (6 frames early, on time, 6 late, 10 timings each) **against the same moments with no move**. A move is kept only if it clears 80%+ and beats no move by 30+ points. The first version without the control kept two "taps" that were flukes (no move cleared as often).
- First results: 8107905 (Matt's #6) solved: 39 frames before, walk right 8 then jump straight holding right, 29 / 30 against 0 / 120. Others came close (21 / 30 against 0 / 120) without passing.
- Running on 100 current deaths (`jn00`, spread over the groups): `runs/jn00/deep_solve.txt`, `cases/l5_v2.lua`.

**Turning points of 100 current 5-1 deaths (`jn00`):** with no move he still usually survives from 30–45 frames back in 21 (timing luck: the decision was right, the 8–9 frame reaction or 0–1 frame press landed badly); 60–120 back 38; 150–300 back 23; 360–900 back 17; doomed as far as 900 back 1. **`deep_solve` solved 32 of 100** (`cases/l5_v2.lua`, `runs/jn00/deep_solve.txt`). Many are a 4–20 frame tap or walk with no jump, 1–5 s before the death (steering). Others are jumps held in a steering direction. Testing the memory on the same 100, on unseen deaths (`jm01`), and on 10,000 games (`jp01`).

**Situation memory, second try (`cases/l5_v2.lua`, 32 solved deaths): rejected.** Scenarios on its own 100 deaths 62.9% to 50.0%; on 393 unseen deaths (`jm01`) 65.2% to 54.5%; 10,000 games (`jp01`) **76.63%** against `jn00` 95.97%, 5th girder deaths 141 to 1,864. In 400 games the cases fired 576 times; two (8002359, 8008956) fired in nearly half of all games. A spot plus one or two barrels near him is a common sight, so the move was made where it didn't belong. Matching on every barrel on screen (`case_all`, `cases/l5_v3.lua`, `case_x=2`, `case_b` 4 or 2): 86 / 66 firings in 1,000 games, still mostly 8000028 and 8008956 (early in the board, with few barrels on screen). In the 64 games it changed, 57 cleared against 58 without it. **Conclusion: an exact memory doesn't carry over** (loose, it misfires; tight, it never recurs). What carries over has to be the pattern behind the solutions, as a rule for that situation.

**What the 32 solutions look like:** 15 at the foot of ladder 91 on the 4th girder (x of about 73–86), most a 4–10 frame tap or walk either way, or a jump left holding right. Ladder 91 top / 5th girder 8, mostly a 4–20 frame step left. Few line up with a barrel above about to cross a ladder, so many taps seem to work by shifting his timing (when he starts the climb, or which moment a barrel passes) rather than steering. No single rule is visible yet. Solving 100 more (`jm01`) to compare.

**64 solved deaths (`jn00` + `jm01`, 32 each), by spot and move:** 5th girder x 80–160: 14 of 17 a 4–20 frame step left. In the traced ones a barrel on that girder is rolling left at him from 14–24 px, so stepping briefly with it changes the timing of the jump he makes next. 4th girder at ladder 91's foot (x 60–100): 6 tap left, 4 tap right, the rest jumps, no single direction (timing). New `step_with {floor, x from, x to, nearest, furthest, frames}`: with a barrel on his girder rolling at him that close, a short step its way first, once per barrel. Off: 200 / 200 identical. Scenario test on 122 5th-girder deaths (`jm01`).

`step_with` scenarios (122 5th-girder deaths, `jm01`): as is 76.9%; `{5,70,160,12,30,4}` 45.6%; 10 frames 35.7%; 8–24 px 42.2%. **Much worse, rejected.** The step only helped at the exact moments where it was found; as a rule for the spot it's harmful (Matt's "no blanket strategies"). Solutions are tied to their exact timing.

What does carry over: 21 of 100 deaths are timing luck (a right decision, a reaction or press that landed badly). New `jitter` / `w_jitter`: each jump is also checked pressed `jitter` frames later, and marked down if that fails, as a person picks jumps with room for error. Testing on scenarios (all 100 `jn00` deaths) then 10,000 games.

`jitter` scenarios (100 `jn00` deaths): as is 62.9%; `jitter=2` 63.1%; with `w_jitter=40` 63.1%; `jitter=1` 62.3%. No effect: the timing-luck deaths aren't about the press landing late. Next suspect: his view is 8 frames old one moment and 9 the next, so he can pick a different plan from the same scene. Large fresh exam `jq01` (30,000 games, first 8200000).

**A timing-luck death looked at closely (8006745, girder 2, hammer):** from 30 frames back he survives 9 / 12. Survived and died runs differ by one frame: starting to walk left on frame 774 survives, on 773 dies. He holds the hammer and a wild barrel is coming down; the `ham_face` rule ("face it") holds the stick towards the nearest barrel the whole time, walking him into it, so whether the hammer meets it is down to a frame. Matt's hammer tip (`ham_stop`) covered only rolling barrels. New `ham_tap`: one press to face it, then stand. Scenario test on 25 hammer deaths (`jn00`, `jm01`).

`ham_tap` scenarios: `jn00` hammer deaths (11, 220 takeovers) 37.7% to **61.8%**; `jm01` (14, 280) 50.7% to **60.7%**. 10,000-game check `jr01` against `jn00`.

**5-1 exam (`jq01`, 30,000 fresh games, first 8200000): 95.70%** (at least 95.5%), counting fireballs 91.11%. Deaths per 30,000: barrel 1,124, fireball 1,437, wild 90; 4th girder 965, 2nd 792, 5th 454, Kong's girder 310.

`ham_tap` on 10,000 games (`jr01`): 95.98% against `jn00` 95.97%, 15 / 12 (only 27 games changed), no side effects. With its scenario gain: **adopted for 5-1.**

**Timing-luck deaths, first difference between a survived and a died run (12 of the 21 `jn00` deaths fine from 30–45 back):** mostly the same jump pressed one frame earlier or later ("BBB222" vs "1BBB22"). Sometimes the decision flips (walk right vs jump straight, 16 frames before) when his view is a frame older. His planner rated those moves safe, yet one frame decides them: the model is slightly off at the pixel level in tight spots. Next: how close his predicted clearances are to the game's real ones in those moments.

`ham_tap` fresh (`js01`, first 8100000): 95.88% against `jm01` 95.88%, 16 / 18 (34 games changed): neutral, as expected for a rare spot.

**His collision model is right; his predictions are a pixel out.** In 233 of 246 barrel deaths the killing barrel's closest approach in the last 12 frames is exactly at the edge of the model's hit box (5 px sideways or 7 vertically, clearance 0), as the model says a hit starts. So the deaths in tight spots come from predicting Mario's and the barrels' positions a pixel out about a second ahead, not from the hit box. Testing more room for error (`min_clear`, `w_thin`) on the 100 `jn00` scenarios.

Clearance scenarios (100 `jn00` deaths, as is 62.9%): `min_clear=5` 63.9%, 6 63.1%, `w_thin=60` 62.7%. No effect.

`ham_tap` on earlier levels' hammer deaths: **4-1** (34 deaths from `jh01`) 39.4% to **70.9%**; **3-1** (8 from `jh02`) 21.9% to **65.6%**. 10,000-game checks `jt01` (4-1, first 7100000, against `jh01`) and `jt02` (3-1, first 6000000, against `jh02`).

### Prediction accuracy (2026-11-07)

`PREDLOG` (policy.lua): at every 8th frame, each barrel's predicted paths (0, 8, 16, 32, 48 frames ahead), and every frame each barrel's real position, status and colour. Scripts in the job tmp dir (`pred_err.py`, `pred_err2.py`, `lad.py`, `arc.py`, `arc2.py`). 100 games of 5-1 (first 8300000):
- **Rolling barrels:** within 1 px 85–89% up to 16 frames ahead; 32 ahead 73%; 48 ahead 64% (19% off 2 px+). Mostly the branches at girder ends and ladders.
- **Ladders: barrels come down at exactly 1.0 px a frame** (2,303 of 2,330 descents), but the model used 0.95 (`DROP_RATE`), drifting about 1.5 px in half a second; 40–80% off 2 px+ at 16–32 frames ahead at some ladders. They start rolling within 0.3 px of the girder line (right). All three uses now go through `drop_rate` (nil keeps 0.95: 200 / 200 identical against `jr01`). Testing `drop_rate=1.0` (scenarios, then `ju01`).
- **Girder ends:** the drop matches the model for 24 frames (9 out, t²/30 down). After landing there are two kinds: about two thirds carry on outwards about 0.5 px a frame and leave the screen; one third roll back at 1 px a frame. They're identical until landing, so they can't be told apart beforehand. The model always predicts the roll-back (the only one that can reach him): pessimistic but safe. That accounts for most of the measured end "error" (a mean of 4–5 px at "now" for barrels at x>215 or <40).
- **Wild barrels:** the Lua paths are far off, but with `wild_dynamic` they only guide ladder decisions (and `climb_nowild` ignores them going up on 5-1). The compiled wild model isn't measured yet.

- **Mario's own movement is right:** walking 0.625 / 0.688 px a frame (model 0.67); jumping 0.5 px a frame sideways (model 0.5); the arc agrees within 1 px at every point (lands at 44 frames, model 41).
- **The compiled wild model (5-1), replayed offline with Mario's real moves:** 8 frames ahead only 31% within 1 px, 43% off 3 px+; mostly vertical. Two causes:
  1. **Before the oil drum is lit** the game (0x22E1) sends every landing right at a fixed 0xE9/256 = 0.91 px a frame (level 3+), whoever Mario is: measured landings head right at 0.89 (x = 59, 89, 117, 147 every time), 11 of 17 even with Mario to the left. The aim at (Mario x − its x) / 64 is right only once the oil is lit. New `o.oil` (0x6348, the flames on the drum) and `wild_pre` (Lua catch-up and plan.cpp `set_wild`'s 3rd argument). In these 400 games most wild states came after the oil was lit, so on its own it hardly moved the error.
  2. **The state handed to the compiled planner is a frame ahead**: falling wild barrels are 1–2 px too low. Catching up one frame less: 159 of 192 states within 1 px, against 98. New `wild_catch1`.
  Both off by default (200 / 200 identical against `jr01`). Scenario test, then `jv01`.

`ham_tap` on 10,000 games: 4-1 (`jt01`) 89.45% against `jh01` 89.39%, 36 / 34; 3-1 (`jt02`) 90.07% against `jh02` 90.01%, 24 / 22. No side effects; with the scenario gains, **adopted for 3-1 and 4-1.**

`drop_rate=1.0` scenarios (100 `jn00` deaths, current 5-1 settings): as is 62.7%, **with it 64.5%**. 10,000-game check `ju01`, then the wild fixes (scenarios, `jv01`). (A queued chain had stalled waiting on its own command line, since `pgrep -f "run_batch.py jt0"` matched the script itself; it was restarted as one chain, `chain_l5y.sh`.)

**Prediction fixes tested (against `jr01` 95.98%, current 5-1 settings):**
- `drop_rate=1.0` (`ju01`): scenarios 62.7 to 64.5%, but **10,000 games 95.31%**, 251 / 311, barrel deaths 338 to 416. Rejected.
- `wild_catch1` + `wild_pre=0.91015625` (`jv01`): scenarios 61.5%; `wild_catch1` alone 62.2%; **10,000 games 95.51%**, 90 / 125, wild deaths 38 to 86. Rejected.
- **Lesson:** "more accurate" by my measurement made him worse. The measurement compared predictions with where things were on the frame he decides, but his press lands 0–1 frames later, so a prediction a frame ahead is what planning needs. The wild state being "a frame ahead" was probably doing a job. Other settings were tuned around the 0.95 ladder speed, and it gives a small margin. Accuracy has to be measured against the moment his move takes effect. Any fix needs retuning alongside it, not swapping in alone.

Testing the "a little ahead helps" idea (against `jr01` 95.98%): `wild_lead=1` (wild barrels carried one more frame ahead, `jw01`) 95.86%, 98 / 103, neutral; `drop_rate=0.9` (`jw02`) **94.25%**, 236 / 398, clearly worse. So 0.95 beats both 0.9 and 1.0, and one frame either way on wild barrels is neutral or worse: **the prediction settings are already at their best for this player.** Gains from accuracy would need a rework that retunes alongside. Exam `jx01` (30,000 fresh, first 8400000, all of today's adopted rules).

**5-1 exam (`jx01`, 30,000 fresh games, first 8400000, everything adopted): 95.80%** (at least 95.6%), counting fireballs 91.30%. Per 30,000: fireball 1,410, barrel 1,110, wild 80; 4th girder 959, 2nd 744, 5th 447, Kong's girder 317.

**Matt's review 2 (`js01`, video `~/Movies/dk_5-1_review2.mp4`; 1–5 ladder 91 foot, 6–10 Kong's girder or jumping up to it):**
1. Steered the two barrels at the top down the leftmost ladder near the barrel at the bottom, so they grouped in a way he couldn't jump. Waiting, there was a good chance they wouldn't have grouped. Or steer one or two down first to break them up. 2. A straight jump would have got him out (grinding should find it); also not steering enough there to make his path easier. 3. Jumped left when a straight jump would have done: favouring left jumps for no reason here. 4. Should have jumped right, the way the barrel was going. Jumped far too late and went left again, the worst option. 5. Jumped late: stand a little more left and jump straight sooner (anticipate). 6. The second jump should have been left, the way the barrel was going: **a straight jump under a ladder just gets a barrel on his head.** 7. No reason to jump: steer that barrel down without getting in its path, standing a little more right and steering it gently down the ladder. 8. Tough: maybe steer left while jumping right, then run up the ladder. 9. **Jumping under the ladder again: you know a barrel will come down it.** Stand still and jump straight earlier. 10. Jumped for no reason (panicked about the fireball). **Why jump up into a barrel that can hit him from above? At that point the girder above tilts down and his tilts up, so a rolling barrel there can hit Mario's head.**

`w_under` (cost of taking off or landing within `under_x` of a ladder barrels can come down) was off on 5-1. Scenarios, review 10 (200 takeovers) / 100 `jn00` deaths (1,000): as is 60.5 / 62.7%; **`w_under=40` 62.5 / 64.6%**; 100: 59.5 / 63.2%; 100 with `under_x=10`: 57.5 / 64.6%. 10,000-game check `jy01`.

#3 (8100986, frame 894, `WHY_CURRENT=1 why_plan ... dbghz={20,34,8}`, new): he's at x=81. Every straight jump scores a hit at t=56: a second barrel (now dropping off the 5th girder's left end) lands and rolls into x=81 about 16 frames after the first. One straight jump lands just in time for it, and the two-jump plans can't fit a second jump in early enough. So the left jump (a near miss in his model) won.

`w_under=40` on 10,000 games (`jy01`): **95.38%** against `jr01` 95.98%, 235 / 289, barrel deaths up on every girder. Everywhere, it hurts. Matt's #6 and #9 are both on the 5th girder at x=107–111, under the short x=106 ladder from Kong's girder. New `under_zones`: the cost only for listed ladders. Testing `{{5, 100, 112}}`.

**`w_under=40` + `under_zones={{5, 100, 112}}`** (only the x=106 ladder from Kong's girder, Matt's #6 and #9): ladder 91 top scenarios (82 `jn00` deaths, 1,640 takeovers) 78.3% to **85.4%**; #6 + #9 (100 takeovers) 75 to **83%**; 10,000 games (`jy02`) 95.90% against `jr01` 95.98%, 98 / 107 (neutral). **Adopted for 5-1.**

`left_zone={4,70,100,40}` / 100 (a cost for left jumps at ladder 91's foot, Matt's #3 / #4): foot scenarios (52 `jn00` deaths) 74.4% to 75.1 / 74.6%; review 1–5 77.3 to 78.7%. No real effect: left jumps aren't the cause by themselves.

Kong's girder `deep_solve` (60 `jx01` deaths): 10 solved; 5 of those died at x=106–113 under the x=106 ladder, and their solutions were mostly walking left away from it 1–2 s before (matching `under_zones`, adopted after `jx01`).

**#3 tested directly** (8100986, from frames 880–908, 10 tries each, then playing on): a straight jump at 884 clears 8 / 10, at 888 2 / 10, later 0; left or right jumps 0; his own play 0. At 884 the first barrel is about 26 px away and he thought standing was fine. **Matt's "anticipate": with two barrels close together, jump the first early, so he's down in time for the second.** New `train_zone {floor, x from, x to, nearest, furthest, gap, bonus}`: a bonus for a straight jump now when the nearest barrel rolling at him is nearest..furthest away and the next within gap behind it. Scenario test at ladder 91's foot.

`train_zone={4,70,100,20,30,40,80}` / `{…,18,34,50,150}`: foot scenarios 74.2 / 73.9% (as is 74.4%), review 1–5 76.7% (77.3%). No effect. **Why:** at 884 the compiled check scores the early straight jump a hit (t=40) for every second-jump option, and a bonus only applies to moves it thinks survive. The predictions dumped there (`dbghz`): the first barrel off the x=51 ladder passes x=81 at about t=34 (right), a barrel on the girder above near the jump's top, and ladder 91's barrel to his right (maybe). By the arc these leave 1–4 px clearance. So there's a gap between those predictions and what the compiled check computes (perhaps the jump's start timing in plan.cpp). Next: a debug print inside the compiled check. Tight two-barrel moments like this are a big share of his deaths.

**Inside the compiled check (`dbgnative_at={act, w1, j1}` with `WHY_CURRENT=1 why_plan`, new; plan.cpp prints what's within 3 px):** at 884 the early straight jump has the first barrel at cl 1.9, 0.1, −0.3 at t=36, 38, 40: a hit. Its Mario is at **x=82.3, but he's really at 81**. His view is 8 frames old; he'd just walked left from 83 to 81. His own-position estimate (`c.moved`: 0.67 px for each frame he chose to walk) misses that the walk really moves 0 or 1 px a frame in a fixed rhythm, and that his press lands 0–1 frames late. 1.3 px turns a 1 px clearance into a hit. Exact knowledge of the walking rhythm would arguably be more than a human knows (a person knows his presses, not Mario's exact pixel), so it's left as it is for now. The window was 4 frames wide (884 8 / 10, 888 2 / 10, 880 0 / 10): one of the hardest kinds of moment even for a person.

Fresh check of the gated `w_under` (`jz01`, first 8100000): 95.90% against `js01` 95.88%, 105 / 100: neutral, no side effects. Stays adopted. Waiting on Matt: should he know his own position exactly from his own presses (the walking rhythm)?

**Matt (2026-11-07): "the don't jump under the ladder thing should apply only when there's a barrel that can go down that ladder. And yes he should know where he is. When I tell you things like 'don't be under the ladder' I am just talking about that scenario, or one very similar … Don't overly apply learnings."**
- `under_live`: `w_under` only for a ladder one of the predicted barrel paths goes down (including Kong's next throw), or that a barrel is on now.
- `know_self`: agent.lua hands the planner where Mario really is (`seen.now`), used for his own position on the ground in place of the delayed view's estimate. Barrels and the rest stay at the human delay.
- Both off: 200 / 200 identical against `jz01`. Scenario tests then 10,000 games (`ka01` know_self, `ka02` under_live, against `jy02`).

**`know_self` (`ka01`, 10,000 games): 96.53% against `jy02` 95.90%, 351 / 296; counting fireballs 92.10% (90.80%); barrel deaths 347 to 303, wild 40 to 22, fireball 532 to 459. Scenarios: Matt's 10 reviewed deaths 61.0% to 76.0%; 100 `jn00` deaths 62.7 to 64.5%. Adopted for 5-1.**

`under_live=true` (predicted paths only): ladder 91 top scenarios 78.0% (85.4% with the zone alone); #6 + #9 74%; 10,000 games (`ka02`) 95.78%. It loses the gain: the paths look about a second ahead and often don't yet include Kong's next throw, but every barrel on Kong's girder rolls right past that ladder. `under_live="rolling"`: any barrel on the girder above rolling towards the ladder at any distance, one on it, or Kong due to throw within 90 frames.

`know_self` fresh (`kb01`, first 8100000): **96.16%** against `jz01` 95.90%, 359 / 337; counting fireballs 91.72%. Holds (smaller than on the practice set).

`under_live="rolling"` (with `know_self`): ladder 91 top scenarios 83.5% against 82.8% for the zone alone; #6 + #9 **91%**. Keeps the gain while only applying when a barrel is heading for that ladder (Matt). **Adopted for 5-1.** Next: `know_self` on 2-1, 3-1, 4-1 (`kc01`–`kc04`).

**`know_self` on the earlier levels (10,000 games each):** 4-1 (`kc01`) **90.02%** against `jt01` 89.45%, 848 / 799; 3-1 (`kc02`) **91.37%** against `jt02` 90.07%, 823 / 686; 2-1 (`kc04`) **97.73%** against `kc03` 97.03%, 279 / 209 (`kc03` reproduces `fx1`'s 97.03% exactly). **Adopted for 2-1, 3-1, 4-1** (5-1 already). 1-1 check (`kd01`/`kd02`) and fresh confirmations (`kd03`–`kd05`).

**`know_self` checks:** 1-1 (`kd02` against `kd01`, 3,000 games) 98.55% against 98.68%, 39 / 39 (counting fireballs 97.73 against 97.27): no difference, so **1-1 stays as it was** (no regressions). Fresh: **2-1 (`kd03`, first 4100000) 97.62%** against `fx2` 97.07%, 266 / 209; **3-1 (`kd04`, first 6100000) 91.05%**; **4-1 (`kd05`, first 7200000) 90.29%**. New bests on 2-1, 3-1 and 4-1.

**5-1 exam (`ke01`, 30,000 fresh games, first 8500000, everything adopted incl. `know_self` and `under_live="rolling"`): 96.32%** (at least 96.1%), counting fireballs 91.86%. Per 30,000: fireball 1,387, barrel 955, wild 75; 4th girder 827, 2nd 721, 5th 453, Kong's girder 290.

**Matt's review 3 (`ke01`, video `~/Movies/dk_5-1_review3.mp4`): "these solutions are specific to scenarios, do not apply them EVERYWHERE, just in similar setups."**
1. (Ladder 91 top) Steer the barrel right while still on the ladder, to force it away and down the ladder. Steering it down made an unjumpable combination; otherwise move further left and, if they end up like this, wall jump at the right angle and length (bounce towards the wall, then back) to spend long enough in the air. Try all of these, perhaps thousands of times, for the timings. Easiest: steer that barrel to the far right while on the ladder.
2. Right idea, jumping with the barrel, but too early, so he landed on it. Wait a little longer, then back jump. The fireball made it hard: almost acceptable. Fireballs come later.
3. A nasty situation to avoid: likely from not steering barrels down the right broken ladder while coming up from below, or steering them into a bad combination going left. Only outs: spot the combination fast and go back down the ladder, hoping they break up, or run all the way right and wall jump over the 3 barrels.
4. Could have back jumped the blue one: jump right while close to it, land just left of it, then jump left over those two barrels (practise it).
5. Steered the left barrel into a bad combination and never steered the right barrel down the broken ladder again. **Not steering down this broken ladder sets up bad situations on the higher girders.**
6. Why jump the last barrel late? Back jump it (grind it); it's as if he wasn't aware it was coming. Or back jump the middle barrel.
7. Nasty: steer the left barrel down the ladder rather than letting it fall off the edge, and he'd have been fine. Again paying for not steering barrels right while coming up the middle ladder.
8. **Staying a few pixels left of that ladder (where he was before turning round), a straight jump clears both the barrel coming and the wild barrel coming down. Play this scenario out.**
9. Late jump again, as if he didn't realise the barrel was coming. A back jump, or jumping the first one slightly earlier: do the second jump faster. Grind a solution.
10. Jumped a barrel knowing he'd land in another, for no reason. Did the barrel above (which couldn't hit him) encourage it? Why not a simple straight jump? Grind the solution and remember it.

**Review 3 follow-up:**
- `deep_solve` on the 10 (`runs/ke01/deep_solve_rev3.txt`): 2 solved (8504121: right jump holding left, 264 frames before; 8501832: tap right 4, 60 before). #8, #9 and #10 are mostly timing luck: with no move he usually survives from 30–60 frames back (5 / 6, 6 / 6, 6 / 6), so no move can beat that by the margin needed.
- **#8 played out** (8529367, from frame 1008, 10 tries each): stand and jump straight after 20 frames 9 / 10 (any other moment 0 / 10); stand 30 frames, then play on, 10 / 10; his own play 10 / 10. Matt's read works, at a tight moment. The death came from how his timing fell: he turned and walked under ladder 91 as a barrel came down it (the gated under-ladder rule covers only the x=106 ladder).
- `ladder_steer {ladder x, girder above, {ladders}, window}` (new): on ladder 91, as a barrel above reaches a listed ladder, tap towards it. `{91, 5, {188}, 3}`: scenarios no gain (top91 77.4 to 78.2%, 4th girder middle / right 66.4 to 65.6%, review 1/3/5/7 58.3 to 54.2%; from 4–10 s back, as is 94.0% against 93.2%). **It never fired in 300 games:** while he's on ladder 91, barrels on the 5th girder are almost never passing x=188 (they're still coming off its right end). Re-reading #1, the barrel to steer "to the far right" is on Kong's girder: pressing right from ladder 91 points at the x=202 ladder. Testing `{91, 6, {202}, 3 / 6}`.

`ladder_steer={91, 6, {202}, 3}` / 6 (Kong's-girder barrels to the far-right ladder, from ladder 91): top91 scenarios 75.3 / 77.4% (as is 77.4%); #1 (70 takeovers) 67.1% (71.4%). No gain. Not adopted; asked Matt which barrel and ladder #1 meant.

**Matt's picture for #1** (`~/Desktop/dk.png`): the barrel to steer is on the 5th girder at its right end (about x=212, rolling left); it should go down the right broken ladder (x=188); and the time to steer it is while he's coming up the middle ladder (3rd to 4th girder, x=131, his route). "This will help you avoid a lot of later deaths." Matt: "the ability to steer a barrel on level 5 should be 50%, so it should work half the time."
- `ladder_steer={131, 5, {188}, 3}`: fired 3 times in 300 games (he's on that ladder about a second per board); 2 of 3 went down x=188. With `ls[5]=40` (wait on the ladder for a barrel due within 40 frames, unless a 4th-girder barrel is heading for this ladder): 3 / 3 went down, still rare.
- New `steer_zone {floor, x from, x to, girder above, ladder x, window}`: on the 4th girder between x=70 and 135 (from the middle ladder to ladder 91), a tap towards x=188 as a 5th-girder barrel reaches it. Both together: 13 steers in 300 games, 8 went down x=188 (about 60%, matching Matt's 50% plus the natural share).
- Testing both on scenarios (takeovers 60–600 frames back) and 10,000 games (`kf01`).

**The middle-ladder steer, made to happen (Matt: "you may need to extend that out to more seconds … as long as he doesn't wait so long it gets him killed"):** while he's on the middle ladder (about 80 frames), the 5th-girder barrels have usually already passed x=188. The next to reach it are still on Kong's girder, rolling right: they drop off its right end on to the 5th girder and roll back to x=188. The wait now counts those (arrival = 228 − x to the edge + 26 to land and turn + 49 rolling back). Steers in 300 games (`ladder_steer={131,5,{188},3,W}` + `steer_zone={4,70,135,5,188,3}`): W = 90 frames (1.5 s) 14 steered, 10 went down x=188; 150 (2.5 s) 22, 15; **240 (4 s) 41, 34 (83%)**. 10,000 games: `kf00` (as is), `kf02` (2.5 s), `kf03` (4 s).

**Waiting on the middle ladder kills him** (10,000 games): as is (`kf00`) 96.50%; up to 2.5 s (`kf02`) **89.42%**, 240 / 895, ladder deaths on the 3rd girder 45 to 728; up to 4 s (`kf03`) **44.35%**. Standing on that ladder (x=131), Mario is directly below the 4th girder's x=130 ladder, so 4th-girder barrels take it on to him (the game takes a ladder when Mario is right below it); the safety check didn't see all those heading for it. Rejected. Testing the steer without waiting (`kf04`: on the ladder and on the 4th girder; `kf05`: 4th girder only).

Steering without waiting (10,000 games, against `kf00` 96.50%, counting fireballs 92.07%): ladder + 4th girder (`kf04`) 96.01% (92.41%), 244 / 291; 4th girder only (`kf05`) 95.72% (92.13%). Barrel deaths 305 to 358 / 383, walking deaths 224 to 351 / 340: the tap overrides whatever he was doing (walking left out of a barrel's way, say). Fireball deaths fell 459 to 375. New `steer_zone[7]`: only tap when he'd be standing anyway. Testing (`kf06`).

**`ladder_steer={131,5,{188},3}` + `steer_zone={4,70,135,5,188,3,true}` (`kf06`): 96.92%** against `kf00` 96.50%, 177 / 138; counting fireballs 92.73% (92.07%); barrel deaths 305 to 265, 4th girder 279 to 230. Matt's steer, tapping only from the middle ladder or when he'd be standing anyway on the 4th girder. **Adopted for 5-1.** Fresh: `kg00` (reference) and `kg01`, first 8700000.

Fresh (first 8700000): **with the steer (`kg01`) 96.71%** against without (`kg00`) 96.36%, 170 / 140; counting fireballs 92.30% (91.92%); 4th girder deaths 274 to 218. Confirmed.

The middle-ladder steer on the earlier levels (10,000 games): **4-1 (`kh01`) 90.87%** against `kc01` 90.02%, 401 / 322, 4th girder deaths 471 to 375; **3-1 (`kh02`) 91.64%** against `kc02` 91.37%, 423 / 399, 4th girder 439 to 415. **Adopted for 3-1 and 4-1.** Fresh: `ki01` (4-1, first 7200000, against `kd05` 90.29%), `ki02` (3-1, first 6100000, against `kd04` 91.05%).

Fresh: 4-1 (`ki01`) 90.32% against `kd05` 90.29%, 357 / 357; 3-1 (`ki02`) 91.12% against `kd04` 91.05%, 418 / 413. Neutral on fresh games: 4th girder deaths fall (468 to 436, 463 to 385) but 5th girder deaths rise (265 to 287, 226 to 263). With the practice-set gains, a small positive overall and never a loss: kept on 3-1 and 4-1. On 5-1 it's a clear gain (+0.35 fresh).

**Overnight 2026-11-07 (Matt: "grind out some of the deaths overnight … find solutions that work to those particular setups … see if applying them to roughly those situations helps, as opposed to widely adopting them everywhere … I know we can hit 100% at some point"):** after the 30,000-game exam `kj01`, `deep_solve` on 100 deaths each (Matt) from the three biggest kinds, one job at a time (`solve_group.sh` in the job tmp dir; results `runs/kj01/deep_<kind>.txt`, cases `cases/kj01_<kind>.lua`): ladder 91 top, then 4th girder middle, then 4th girder right. For each: split the solutions by tighter setup (where he is, nearby barrels and their directions), build rules gated to each setup, scenario-test on those deaths, then 10,000 games for side effects.

**5-1 exam (`kj01`, 30,000 fresh games, first 8800000, with the middle-ladder steer): 96.79%** (at least 96.6%), counting fireballs 92.86%. Per 30,000: fireball 1,219, barrel 847, wild 66; 4th girder 713, 2nd 639, 5th 420, Kong's girder 225.

**Overnight, kind 1: ladder 91 top (100 `kj01` deaths): 20 solved.** 14 of the 20 are the same move, "left 4 frames", 48–102 frames before the death, all on the 5th girder at x=74–112 with a barrel 15–23 px to his right rolling left at him. **At that moment he's already in the air**, 4–6 frames into a straight jump over it: a mid-air press can't change the jump, so it's steering (the stick still decides which ladders nearby barrels take). That's why the ground version (`step_with`) was so harmful. New `air_tap {floor, x from, x to, nearest, furthest, from frame, to frame, dir}`: in a straight jump in that setup only, hold dir for those frames. Testing `{5,74,100,12,26,4,8,1}` and `{…,2,12,1}` on the 100 deaths it was learned from and 100 unseen ones of the same kind.

`air_tap` scenarios (ladder 91 top, 100 learned-from / 95 unseen): as is 78.2 / 75.7%; `{5,74,100,12,26,4,8,1}` 78.5 / 76.5%; `{…,2,12,1}` 77.5 / 76.2%. **The press itself isn't it.** Its side effect is: when the solver's move ends, it clears his "in the air" lock (`c.air_until`), so he plans during the jump and his next move is ready the moment he lands (Matt's "do the 2nd jump faster"). New `air_plan {floor (0 = any), x from, x to, frames}`. Scenarios: **`{5,74,100,10}` 88.0 / 84.0%**; everywhere `{0,0,255,10}` 89.7 / 81.3%. 10,000-game checks `kk01` (setup) and `kk02` (everywhere) against `kf06`.

**`air_plan={5,74,100,10}` (`kk01`): 97.09%** against `kf06` 96.92%, 51 / 36; 5th girder deaths 131 to 105. Everywhere (`kk02`): **94.79%**, 270 / 459: Matt's point about not over-applying, in numbers. **The setup-only version is adopted for 5-1.**

`air_plan` tuning (ladder 91 top scenarios, learned-from / unseen): 6 frames 88.0 / 82.5%; 16 frames 87.8 / 84.0%; x 66–112 88.2 / 84.8% (adopted `{5,74,100,10}`: 88.0 / 84.0%). All within noise; keeping the version checked on 10,000 games.

**Overnight, kind 2: 4th girder middle (100 `kj01` deaths): 40 solved.** Unlike ladder 91 top, most start on the ground (23 taps / walks, 9 jumps; 8 in the air). The 12 "left 4" solutions: he's walking right with a barrel 22–26 px behind rolling after him, on a "walk right 12, then jump straight" plan that keeps slipping (Matt's first-review late jumps). The left tap stops him running ahead of it, so the straight jump comes in time. New `chase_stop {floor, x from, x to, nearest, furthest}`: walking away from a barrel that close behind, stand instead. Scenarios on 100 learned-from / up to 100 unseen middle deaths. Kind 3 (4th girder right, 100) grinding.

`chase_stop` scenarios (4th girder middle; 100 learned-from / 59 unseen): as is 66.6 / 73.4%; **`{4,90,135,16,30}` 67.5 / 76.1%** (mostly survived 64 to 71, 44 to 50); `{…,12,26}` 65.9 / 72.5%. 10,000-game check `kk03` against `kk01`.

`chase_stop={4,90,135,16,30}` on 10,000 games (`kk03`): **96.00%** against `kk01` 97.09%, 128 / 230; 4th girder deaths 230 to 336. **Rejected.** A barrel 16–30 px behind on that stretch is common, and stopping there is usually wrong. The trigger would need to be his slipping "walk, then jump" plan itself, not just the barrel's position.

`chase_stop={4,90,135,16,30,true}` (only when his chosen plan is "walk on 6+ frames, then jump"; new `c.chosen`): scenarios the same as the broad version (67.5 / 76.1%); 10,000 games (`kk04`) 95.99%, 128 / 230. Walking away from a chaser, his plan is nearly always of that kind, so the condition doesn't narrow it. **Rejected.** The left-tap solutions in this setup were timing shifts, not a rule a stop can copy.

`air_plan2={4,95,135,10}` (planning during the jump on the 4th girder middle, where 8 of 40 solutions started mid-jump): learned-from 66.6 to 67.2%, **unseen 73.4 to 64.2%**. Rejected. The same idea that works just off ladder 91 belongs to that setup.

**Overnight, kind 3: 4th girder right (all 83 `kj01` deaths): 37 solved.** Mostly ground taps / walks (24) and jumps (10). A clear cluster: "jump straight now" 72–132 frames before the death (8820932, 8828286, 8806253, 8821391), all at x=120–129 with a barrel 24–29 px behind rolling after him and another 60–70 px behind that: Matt's "anticipate". A bonus can't do it (his model rates the early jump a hit), so new `chase_jump {floor, x from, x to, nearest, furthest}`: in that setup, jump it straight now, once per barrel. Scenarios on the 83 learned-from and the unseen 4th-girder-right deaths of `kf06`.

`chase_jump` scenarios (83 learned-from / 38 unseen 4th-girder-right deaths): as is 54.9 / 56.1%; `{4,115,132,23,30}` **40.7 / 45.0%**; `{4,110,140,22,32}` 35.2 / 36.1%. **Rejected**: forcing the jump is wrong in most moments that match the setup (other barrels around); the four "jump now" solutions were particular moments.

**`air_plan` fresh (`kl01`, first 8700000): 97.31%** against `kg01` 96.71%, 89 / 33; counting fireballs 92.83%; 5th girder deaths 159 to 99. **5-1 now 97.3% on fresh games.**

**Overnight, kind 4: ladder 91 foot (all 83 `kj01` deaths): 38 solved.** Subgroup: waiting at x=82–84 with a barrel *coming down a ladder* 8–27 px to his right and 22–42 px up (ladder 91 above him, or one heading to it): **all 9 solutions are a short step left (4–10 frames)**, 20–55 frames before. Other subgroups (barrels rolling on the 5th girder above) mix left and right taps: timing. New `foot_dodge {floor, x from, x to, dx from, dx to, frames}`: that setup only, step left once per barrel. Scenarios on the 83 learned-from and the unseen foot deaths of `kf06`.

`foot_dodge` scenarios (83 learned-from / 31 unseen ladder 91 foot deaths): as is 73.4 / 78.7%; 6 frames 75.3 / 79.4%; 10 frames 76.7 / 74.8%. Too small and inconsistent: not adopted.

**Overnight summary (2026-11-08):** 283 deaths ground (ladder 91 top 100, 4th girder middle 100, right 83, ladder 91 foot 83): 20 + 40 + 37 + 38 = 135 solved. **Adopted: `air_plan={5,74,100,10}`** (plan during the jump just off ladder 91's top): 10,000 games 96.92 to 97.09%; **fresh 96.71 to 97.31%** (5th girder deaths 159 to 99). Rejected: `air_tap` (the press itself), `air_plan` everywhere (94.79%) and on the 4th girder (unseen scenarios 73 to 64%), `chase_stop` (broad and plan-gated, 96.0%), `chase_jump` (scenarios 55 to 41%), `foot_dodge` (no clear gain). **Lesson:** most single-death solutions are a timing shift that only works at that moment. The useful ones point at a *mechanism* (here: not re-planning during a jump), which can then be gated to its setup.

**Kind 5: 5th girder right (94 `kj01` deaths): only 7 solved.** 47 of 94 are timing luck: with no move he still usually survives from 30–45 frames back, so there's no decision to fix there, only his reaction timing (the margin of the moves he picks). Kind 6 (Kong's girder, 100) grinding.

**Kind 6: Kong's girder (77 `kj01` deaths): 21 solved.** Nearly all happen on the 5th girder below it. Setup A: Mario on the 5th girder at x=105–112 (under the x=106 ladder), a barrel on his girder rolling at him 21–37 px away and one on Kong's girder overhead: **all 7 solutions are "walk left 10–20 frames"**, 75–96 frames before. The girders are close there, so jumping under a barrel overhead risks hitting it (Matt's review 2 #10); `w_under` covers take-off and landing, not standing there. New `low_roof {floor, x from, x to, nearest, furthest, overhead, frames}`. Setup B (x=211 under the ladder to Kong's girder): mixed moves (jump right, taps either way). Scenarios on the 77 learned-from and the unseen Kong's-girder deaths of `kf06`.

**Matt's review 4 (`kl01`, video `~/Movies/dk_5-1_review4.mp4`), one at a time. #1 (8702477), with a picture:** "you needed to right jump this barrel [the one just come off ladder 91, rolling right at him]. Jump in the direction it is going, a little closer to it. That will give you more time to jump left over the next two." Tested from frames 813–825 (10 tries each): jump right straight away 0 / 10 everywhere (too far from it); **walk left 8 frames (closer), then jump right: 7–10 / 10 from 817 on**; jump straight 9–10 / 10; his own play 6–10 / 10 (partly timing). New `back_jump {floor, x from, x to, nearest, furthest, step}`: step towards it `step` frames, then jump the way it's going, once per barrel. Scenarios on the 4th girder middle (learned-from / unseen) and right.

**#2 (8704011), with a picture:** "could have been avoided by straight jumping these two barrels after you came up the middle ladder … the best bet is to straight jump that barrel collection after coming up." He reached the top at frame 721 (x=128), walked left towards the pair (one from x=64, one off ladder 91), turned back, jumped left at 765 and landed near ladder 91 as a barrel came down it. From 741–749 (10 tries each): stand 16 then jump straight 10 / 10; stand 20 10 / 10 at 741–745; later 0–3 / 10; his own play 9–10 / 10 (timing). New `hold_ground {floor, x from, x to, range}`: at x=115–131 on the 4th girder (just up the middle ladder), don't walk towards barrels rolling at him within range; stand and let the planner jump them.

**#3 (8701996, 5th girder right), with a picture:** "jump this barrel as a back jump (the way it's going); you could also have jumped the one to his left a little earlier. Grind out the right times." He jumped straight at 1344 (barrel 21 px away) and a second barrel off Kong's girder's end caught him on landing. From 1324–1340 (10 tries each): **jump left at about 1344 10 / 10** (1324 wait 16, 1332 wait 12); left earlier 0 / 10; straight at 1324–1340 10 / 10; his own play 9–10 / 10 (timing: he jumped straight at the one moment left was right). Testing `back_jump={5,140,200,18,24,0}` (no step).

**#4 (8704295, 5th girder), with a picture:** he jumped right over one barrel straight towards the next, also rolling left: "a death jump. He should never do this kind of jump. Why didn't he just straight jump the first one?" From 1356–1374 (10 tries each): **jump straight at about 1360–1366 (first barrel 24–30 px away) 10 / 10**; from 1368 on 0 / 10; right jump 0 / 10 at every timing; his own play 4–7 / 10. From 1352 he kept planning "wait 6–12, then jump straight" and re-planned it later every 2 frames (the slipping jump again) until straight no longer worked. The right jump was then the least bad left in his model. (`why_plan` didn't reproduce this game's decisions: the trace lacks Kong's pose, the oil and `o.now`.) Testing `chase_jump`-style "jump straight now" for this setup: `{5,120,150,22,30}` (the 4th-girder version failed).

**#5 (8703384, 5th girder), with a picture:** he walked right under a barrel already coming down the short x=107 ladder; maybe jump the yellow-circled barrel earlier, or step left then jump right over both. With no move he survives 6 / 6 from 30 back (frame 1365) and 10 / 10 from 1372–1382 (timing); from 1386 nothing works. **Step left 16 frames, then jump right: 10 / 10 from 1377–1382** (left 12: 4–10 / 10; left 8: 0–3 / 10).

**#6 (8702511, ladder 91 top), with a picture:** he hesitated in front of the blue barrel: back jump it, or spot the setup sooner, move right of the ladder, jump it straight, then the next. From 1092–1108 (10 tries each): his own play 9–10 / 10 (timing); **back jump left with the barrel about 24 px away (1108): 10 / 10**; **walk right 8 then jump straight (from 1092): 10 / 10**. **#7 (picture) and #8:** the barrel next to him pushes him to jump straight, but the one Kong just threw (above) will kill him during it: he needs to back jump left with it. #8 is the same. So four notes (#1, #3, #6, #7/#8) come down to **back jumping a close barrel the way it's rolling**.

`low_roof` scenarios (77 learned-from / 22 unseen Kong's girder, plus ladder 91 top unseen): as is 49.7 / 59.5 / 84.0%; 10 frames 48.7 / 60.7 / 82.5%; 16 frames 48.4 / 61.8 / 81.2%. No gain: rejected. `back_jump={4,105,125,18,30,8}` (#1 as a rule): 4th girder middle **66.6 to 35.3%**: rejected. Matt's move works at that moment, but forcing it whenever a barrel matches the setup is wrong far more often than right.

**#9 (8705061, 4th girder right), with a picture:** "super hard". The top barrel (yellow) went down the short x=107 ladder and then ladder 91; either back jump the blue barrel as tightly as possible, or retreat quickly down the middle ladder and let the barrels break up. Played out: **retreat down the middle ladder 30 frames, then play on: 8–10 / 10 from 985–995** (his own play 6–10 / 10; 60 frames 4–10 / 10; 90 frames 0–4 / 10). **Tight back jump on the blue (stand 20, then right, from 1015): 8 / 10** at a moment where his own play is 0 / 10; a step either way 0–2 / 10; from 1025 nothing works. **#10: fine (the fireball set it up).**

Review 4 rule tests: `hold_ground={4,115,131,70}` (#2) scenarios 66.6 to 66.8%, 73.4 to 73.7%, 56.1 to 59.5% (small gains everywhere): 10,000-game check `km01`. `back_jump={5,140,200,18,24,0}` (#3): **84.9 to 26.8%**, even #3 itself 98 to 20%. It (and today's other one-barrel rules) measured the gap from his *delayed* view of himself, so it fired at the wrong distance.

**Setups that match the whole situation (Matt: "when barrels are in similar places, Mario is in the similar place"):** new `setups = {{floor, x from, x to, needs = {{girder up, dx from, dx to, dir, [ladder x, short from, short to]}, ...}, move = {a, w, j1, h}}}`, using his real position (`know_self`), barrels as he sees them. #7 / #8 found exactly: a left back jump pressed at about 1280 (#7, 9–10 / 10 against 0–3 / 10 for his own play) and 1355 (#8, 10 / 10). Setup: Mario on the 5th girder x=95–110 standing; a barrel on his girder 9–16 px right rolling left; one on Kong's girder rolling right 0–20 px short of x=106. **It fired 0 times in 1,000 normal games**, and in the replays of #7 Kong throws at a different moment (his throws follow the random numbers, which shift with Mario's inputs), so the setup doesn't recur. Exact setups are that rare: each is worth well under 0.1%. The remaining 2.7% on 5-1 is spread over hundreds of rare setups, so the faster lever is what many share: **the slipping jump** (#2, #4 and several overnight).

**Matt (2026-11-08): "if the numbers go down in your level testing, assume you have applied the rule too widely or it's a rare scenario that never showed up. See if those scenarios even played out (in close enough form). My answers are usually right, so they should all be feeding into a higher %."** (Saved to memory.)
- **Firing log** (policy.lua, read from `c.why`, changes nothing): every rule that overrides his play records "rule@frame:x" in the game's new `rules` field. `tools/rule_report.py BASE NEW`: per rule, games fired in, saved / lost against the same games in BASE, and for lost games the firings and how long after the last one he died. 200 / 200 identical against `kk01`.
- **Rule triggers now use his real position** (`me = o.now` with `know_self`), not his delayed view of himself: part of why today's one-barrel rules fired at the wrong distances. The adopted `steer_zone` keeps the delayed view it was validated with (200 / 200 identical).
- Slipping jump scenarios so far (100 `jn00` / 59 unseen 4th middle): as is 66.7 / 73.4%; `w_later=0` 67.6 / 71.0%; `fine_waits` still running.
- Queued one at a time, each with the log, against `kk01`: `kn00` reference, `kn01` `hold_ground` (#2), `kn02` `back_jump` 4th (#1), `kn03` `back_jump` 5th right (#3), `kn04` `chase_jump` 5th (#4). Then narrow each from where it fired.

Slipping jump scenarios (100 `jn00` / 59 unseen 4th middle): as is 66.7 / 73.4%; `w_later=0` 67.6 / 71.0%; `fine_waits` 64.2 / 69.5%; both 67.3 / 67.3%. Neither helps: more timing choices aren't better ones. Rejected.

**Rule reports (10,000 games each, against `kk01` 97.09%, with the firing log and real positions):**
- `kn00` (reference, no new rules) identical to `kk01`. Adopted rules fire often: lets go 5,024 games, steer from the ladder 4,677, replans in the air 3,106, steer it down 1,969.
- **#4 `chase_jump={5,120,150,22,30}` (`kn04`): 97.21%**, 16 / 5; the rule fired in 1,282 games: saved 33, lost 13; 5th girder deaths 105 to 88. **Adopted for 5-1** (Matt's answer, now with real positions).
- #2 `hold_ground` (`kn01`): 96.91%, 70 / 85; fired in **3,114 games**: saved 138, lost 175. Far too wide: his setup is a close *pair* just after coming up the middle ladder.
- #1 `back_jump={4,…}` (`kn02`): **69.39%**; fired in **3,765 games**, lost 2,649, nearly all dying 47–49 frames after (landing on a barrel). #3 `back_jump={5,…}` (`kn03`): **68.51%**; fired in 2,782 games, lost 2,704, dying 40 frames after. A back jump at those gaps only works in Matt's exact setups (with the other barrels where they were).
- Next: rebuild #1, #2, #3 with `setups` (every barrel from the moment his fix worked), check how often each fires, then 10,000 games.

**#1, #2, #3 rebuilt as full setups** (every barrel from the moment his fix worked; real positions): fired 0 / 0 / 0 times in 1,000 games. With the second barrel loosened (any state, wider range): 0 / 6 / 0. Matched on the whole situation, each of these setups comes up a few times per thousand games at most. Fresh check of the adopted #4 rule: `ko01` (first 8700000, against `kl01` 97.31%).

**#4 rule fresh (`ko01`, first 8700000): 97.45%** against `kl01` 97.31%, 13 / 1; the rule fired in 1,247 games: saved 22, lost 9 (the lost ones died of fireballs 370–1,130 frames later). Confirmed. **5-1 now 97.45% fresh.**

**Matt on back jumps (2026-11-08): "the way I judge if a back jump is needed is on how close the 2nd barrel will be to me, or how much time I'll have to react to the trailing barrels and their setup. You definitely don't want to apply my ideas to all scenarios."** New `trail_w` / `trail_need` / `trail_gap` / `trail_near`: only when two barrels roll at him on his girder, the first within `trail_near` px and the second within `trail_gap` px behind it. Then each jump over the first is scored by how many frames after landing before the second reaches where he lands; each frame short of `trail_need` costs `trail_w`. A back jump (with them) lands about 20 px further on, so it usually leaves more time. Off: 200 / 200 identical against `ko01`. Scenario test across the groups and Matt's #1, #3, #6.

Matt, refining: "It needs to apply when the 2nd barrel had enough room to jump, but a straight jump isn't the right answer … This usually only matters if a third barrel will be coming later, because two barrels close together can either be straight jumped or jumped across together." New `trail_group` (px): a *group* (2+ barrels within that of each other, cleared in one jump) with a *third* behind it (within `trail_gap` of the group's last). Only then is each jump over the group scored by the time it leaves before the third reaches where he lands. Queued (`chain_trail3.sh`, after the first version's test): `{trail_w=30, trail_group=16, trail_gap=90}`, `{…, trail_group=20, trail_gap=120, trail_near=60}`, and the same with `trail_need=40`.

First `trail` version (two barrels only; groups: ladder 91 top unseen / 4th middle unseen / 4th right `kf06` / 5th right `kf06` / Matt's #1, #3, #6): as is 83.8 / 73.6 / 55.8 / 85.5 / 93.3%; `trail_w=10` 85.6 / 67.5 / 52.9 / 86.2 / 95.6%; 30 78.4 / 64.7 / 49.5 / 89.3 / 91.1%; 30 with `trail_need=40` 79.1 / 65.4 / 49.7 / 88.3 / 91.1%. Helps on the 5th girder's right, hurts on the 4th: with only two barrels it fires where the pair could simply be jumped together (Matt's point). Not adopted; the group-plus-third version is next.

**Logging fix:** a stale wild-state log line (`D …`) crashed games whenever `PREDLOG` was on, so the earlier setup firing counts (0 / 0 / 0, 0 / 6 / 0, Kong's ladder 0) were wrong. Removed (200 / 200 identical). Recounted in 1,000 games: Kong's-ladder setup 2; #1 loosened 94; #2 loosened 563; #3 loosened 7.

**Banked solutions (Matt: "play out the games, find individual deaths, solve those situations and bank them as solutions when all the barrels on the board are in roughly those positions; if it doesn't reduce the average, start adding them … these situations occur so rarely they won't move the average even in 10,000 games, you'd need to bank all of them; we need bespoke solutions for each one"):**
- `tools/bank.py`: 196 solved deaths banked (`cases/bank_v1.lua`, from every `deep_solve` output): Mario's real position when the move starts, every barrel on the board as he saw it then, and the move.
- Matcher (`params.cases` + `case_now`, `case_all`, `case_x`, `case_b`, `case_far`): his real position, the same barrels each within `case_b` + `case_far` × its distance from him; each firing logged as "remembers <id>". 200 / 200 identical with it off.
- How often they match (1,000 games): x ±3 / barrels ±6: 133 firings by 32 different solutions (8000028 alone 40, 8501832 27); ±4 / ±8 / 0.05: 166 by 44; ±5 / ±10 / 0.1: 259 by 53.
- Next: 10,000 games with the whole bank on (`kq01`), a report per solution against `kn04` (same settings, with the log), keep those that don't lose, grow the bank as more deaths are solved.

**Whole bank (`kq01`, 196 solutions, x ±3 / barrels ±6): 96.72%** against `kn04` 97.21%, 25 / 67. Per solution (report): a handful do most of the damage: 8812762 fired in 29 games, saved 0, lost 21; 8102914 2 / 10; 8805224 1 / 5; 8501832 1 / 5; 8815766 1 / 4. Some help: 8000028 (342 games) 24 / 16; 8813297 4 / 1; 8826955 3 / 0; 8811654 3 / 1. Most never came up. `cases/bank_v2.lua`: dropped every solution that lost more than it saved. Confirming `kq02`.

**Trimmed bank (`kq02`, 179 solutions): 97.26%** against `kn04` 97.21%, 24 / 17; counting fireballs 93.38% (93.14%). The banked solutions fired and saved 49, lost 24. Doesn't lower the average: **adopted for 5-1** (`cases/bank.lua`, also dropping 8825195 and 8813783, which lost more than they saved here: 177 solutions). From here, each round of newly solved deaths is banked, run on 10,000 games, and trimmed by the per-solution report.

**Reaction time (Matt asked what it's worth, then allowed 30 ms on the barrel boards, 2026-11-08):** measured on 5-1 (10,000 games, first 8000000): 133–150 ms (8–9 frames) `kn04` 97.21%, counting fireballs 93.14%; **about 90 ms (5–6 frames) `kr01` 97.79% / 94.90%** (fireball deaths 419 to 296, barrel 237 to 189); 100 ms (6) `kr02` 97.42% / 94.41% (with the bank); **30 ms (2) `kr03` 97.66% / 95.62%** (fireball deaths 209; with the bank). `agent.lua` reads `params.react = {min, max}` per level (env `DELAY_MIN` / `DELAY_MAX` override, for measuring). **Adopted `react = {2, 2}` on levels 1–5** (all barrel boards; other boards keep 8–9). The bank is rebuilt for a 2-frame view (`SEEN=2 tools/bank.py`; 181 solutions with the 4 new 2nd-girder ones). Fresh comparisons per level: `ks01` (1-1, 3,000, against `kd01`), `ks02` (2-1, against `kd03`), `ks03` (3-1, against `ki02`), `ks04` (4-1, against `ki01`), `ks05` (5-1 with the bank, against `ko01`).

Matt: "you said the 90 ms one scored better than the 30; start with 90 ms and compare it across all boards, then work it down slowly towards 30 ms; test each a few times for random differences, or a larger sample." (The earlier 90 ms run had no bank and the 30 ms one did, so they weren't a clean comparison.) **Reaction sweep on 5-1, 20,000 games each (first 8000000), bank off:** `kt00` 8–9 frames, `kt01` 5–6 (about 90 ms), `kt02` 4 (about 65 ms), `kt03` 3 (50 ms), `kt04` 2 (30 ms). Then the best one or two on 1-1 to 4-1. (`react = {2, 2}` stays in `params.levels` until the sweep decides.)

**Strict banking (Matt, 2026-11-08): "run automated testing against barrel deaths; play through those deaths with different options going back to about 3 seconds before (different jumps, steers …); when you find a solution, play it back a thousand times; it needs to work every single time, then bank it; the solutions are not allowed to fail at all … the solutions need to be for those scenarios, not every scenario … if the solution works for 3 seconds before, tighten it to 2 seconds … you don't need to match on barrels below Mario's girder."**
- `tools/strict_solve.py`: from every 12 frames between 180 and 20 before each barrel death (on a girder), every move once (taps / walks either way, jumps each way holding each way, after 0–16 frames); moves that cleared get 30 tries (all must clear), then the best two (latest first, so closest to the death) get **1,000 tries; banked only at 1,000 / 1,000**, with how far before the death it starts (`early`). Works 50 deaths at a time and rewrites the bank after each lot; log in `OUT.log`. Trial on two `kl01` deaths (50 final tries): 8701996 banked (60 frames before, 50 / 50); 8702477 47 / 50, not banked.
- Matcher: `case_above` (px): only barrels on his girder or above are compared (and counted).
- Overnight (`overnight2.sh`): after the reaction sweep, the setting that scores best on 5-1; every barrel death of that 20,000-game run traced and strictly solved (`cases/strict_<run>.lua`). Then: 10,000 games with that bank (`case_above`), trim any solution that loses, confirm.

**Reaction sweep, 5-1, 20,000 games each (first 8000000, bank off):** 8–9 frames `kt00` 97.20% (counting fireballs 93.11%); 5–6 (about 90 ms) `kt01` 97.69% (94.81%); **4 (about 65 ms) `kt02` 97.88% (95.17%)**; 3 (50 ms) `kt03` 97.29% (94.77%); 2 (30 ms) `kt04` 97.54% (**95.31%**). Fireball deaths fall all the way (843 to 456), but barrel deaths are lowest at 4 frames (356) and rise again at 3 and 2: many planning settings were tuned for 8–9 frames. **`react = {4, 4}` on levels 1–5 for now** (best headline on 5-1); checks on 1-1 to 4-1 after the overnight grind. The overnight solver uses 4 frames.

Matt: "we should weigh the ones that are solved closer with a higher value." A solution found close to the death is more certain (the barrels that kill him are already in place) and more specific. (1) The matcher sorts banked solutions by `early`, so when several match, the one found closest to its death is used. (2) When trimming after the 10,000-game test: close ones (within about 1 s) stay if they don't lose; ones from 2–3 s out must clearly win.

**Overnight strict solve, lot 1 (50 `kt02` deaths, 4 frames):** 50 had a move that cleared once, 38 passed 30 / 30, **13 passed 1,000 / 1,000 and are banked** (`cases/strict_kt02.lua`). Most start 48–60 frames before the death; the commonest move is a 4-frame tap right (steering). Matt: "just keep a record of those ones that come close": `tools/near_misses.py LOG BATCH OUT.lua [990]`, the best move of each death that wasn't banked if it cleared 990+ / 1,000, kept apart (`cases/near_kt02.lua` + `.txt`, not used). Lot 1: 12 near misses (991–999 / 1,000). Refreshed as the run goes on.

**Overnight strict solve finished:** 406 `kt02` barrel deaths (4 frames), **96 banked** at 1,000 / 1,000 (`cases/strict_kt02.lua`; 37 of the first 39 on the 5th girder, most 24–60 frames before the death; commonest moves: 4-frame tap right, step left then jump right). 91 near misses at 990–999 / 1,000 (`cases/near_kt02.txt`, kept apart).

**Bank tests (10,000 games, first 8000000, 65 ms):** no bank `kv00` **97.94%** (counting fireballs 95.17%). Strict bank matched only on barrels at his level or above (`case_above=12`), `kv01`: **71.21%**, 41 / 2,626; strict + earlier bank `kv02`: 70.21%. A few solutions fire everywhere: 8007377 in 2,875 games (saved 13, lost 1,984), 8016860 372 (0 / 358), 8001761 203 (1 / 68), 8018427 114 (1 / 61), 8010426 323 (6 / 59). Ignoring barrels below him leaves one or two barrels to compare on the 5th girder, a common picture, so solutions fire in situations that differ in ways the match doesn't see. A solution that never fails in its own setup still needs a genuinely specific match. Next: every barrel on the board again (`kv03`), then trim per solution.

Strict bank matched on every barrel (`kv03`, x ±3, barrels ±6): **97.21%** against `kv00` 97.94%, 37 / 107. Losses concentrated: 8007377 fired in 60 games (1 / 37), 8001761 55 (3 / 13), 8001440 12 (0 / 9), 8018270 17 (0 / 6); most others neutral or ahead. Trimmed with closer solutions weighted higher (found within 60 frames of the death: kept if saved ≥ lost; further out: kept only if saved > lost, or never fired): `cases/strict_trim.lua`, confirming `kv04`.

Trimmed strict bank (`kv04`, 77 solutions): **97.88%** against `kv00` 97.94%, 34 / 40; fired solutions saved 35, lost 40. Near neutral, and trimming is whack-a-mole: with the worst gone, others fire in their place and lose too (8019150 3 / 13, 8013340 1 / 6). A solution that never fails in its own situation often fails in one that only *looks* the same; what differs isn't in the match (Kong's next throw, the random numbers, exactly where in his walk Mario is). Next: much tighter matching (Mario ±1, barrels ±3), `kv05`.

**Why do 1,000 / 1,000 solutions lower the rate? (Matt: "there must be more to this, or we've got some conflicting rules.")** The test games (8000000+) include 45 of the banked deaths' own games, played identically to the source run without the bank (45 / 45). There: no bank **0 cleared**, strict bank (`kv03`) **32 cleared**. The source solution fired at its moment in 37 of 45; in the other 8 **a different banked solution fired first** (e.g. 8008573 in game 8004452): conflicts within the bank. **All the net losses come from solutions firing in other games** at moments that look similar but differ underneath (Kong's next throw, the random numbers, his place in his walk), or a few frames off. Fixes: (1) `case_best`: when several match, the closest match, not the first; (2) tighter matching (`kv05`, Mario ±1, barrels ±3); (3) if needed, add hidden state such as Kong's pose / throw timing to each solution's fingerprint.

Tight matching (`kv05`, Mario ±1, barrels ±3): 97.96% against `kv00` 97.94%, but split: in the 45 source games no bank 0 cleared, bank **35**; in the 139 *other* games where a solution fired, no bank 136 cleared, bank **103**. On fresh games (no source games) the bank would lower the rate. **The solutions only work in the exact game state they were found in**: same-looking moments differ in Kong's rhythm, Mario's walk step, the random numbers.

**Matt chose option 1: fingerprint the visible hidden state.** The trace now records `K pose held-frames frame-counter` per frame (Kong's pose, how long he's held it, and the frame counter, which drives Mario's walk rhythm); `o.fc` (0x601A) observed. Bank entries get `kong`, `kage`, `fc` (`bank.py`, `ONLY_BANKED=1` to read strict_solve's log). Matcher: `case_kong` (same pose, held within that many frames as long), `case_walk` (same walk step, frame counter mod 4), `case_best` (closest match wins). **Tested on fresh games** (first 8700000, no source games): `kw00` no bank, `kw01` fingerprint with barrels ±6, `kw02` fingerprint with barrels ±3.

**Fingerprint test on fresh games (first 8700000, none of the source games):** no bank `kw00` **97.87%**; every barrel ±6 + Kong pose + walk step + closest match `kw01` **97.20%** (12 / 77); barrels ±3 `kw02` 97.75% (8 / 20); ignoring barrels below Mario `kw03` **82.65%** (36 / 1,508; 8007377 fired in 2,670 games, lost 1,155). The same solutions lose every time (8007377, 8019150, 8001440, 8018270, 8016860). **Conclusion: exact banked moves don't transfer to new games, even with Kong's pose and Mario's walk step in the match.** What decides them isn't visible (the barrels' random ladder choices, Kong's throw choices, the random numbers), and a person can't see it either. The tightest match is close to neutral only because it barely fires.

**The 17 tap-right solutions are one recurring situation:** Mario just off ladder 91's top (about 20 frames earlier) at x=95–99, a barrel coming down the short x=106 ladder from Kong's girder 8–12 px to his right and about 30 px up, another rolling at him about 65 px away on his girder. It recurs because the board's opening plays out the same from the same start positions. In its own game a tap right saved it 1,000 / 1,000; in other games with the same picture it sometimes kills him (whether that barrel comes down and which way it rolls is random, and invisible). These are the solutions that keep losing (8019150, 8018270, 8001761, 8015909, 8009349 …). **Earlier bank switched off for 5-1** (exact moves lose on new games).

**Matt: treat it as one setup, try every move on all its instances, use the move that wins most often.** `setups` entries can now be `detect = true` (only log "seen <name>@frame:x" in the game's `rules`, changing nothing). Detector: Mario on the 5th girder, x=90–101, on the ground; a barrel on Kong's girder level, on a ladder, 4–16 px to his right. Collecting instances (`kx00`, 10,000 games, first 8800000).

Detector run (`kx00`, fresh, first 8800000, earlier bank off): **98.16%** (counting fireballs 95.18%). The Kong's-ladder setup came up **1,215 times in 1,147 games**; only 34 of those games ended in a barrel death, so he usually gets through it. `tools/setup_moves.py BATCH NAME`: (1) no move at every instance (and 6 frames later), 3 tries each, to find the moments where no move sometimes dies; (2) 37 moves plus none on those moments, and on 150 moments where he always lives (to check a move doesn't break them). Output `runs/kx00/setup_moves.txt`.

**Overnight 2026-11-09 (Matt: keep boosting the %, 100% is the goal):** `tools/clusters.py` groups the latest fresh barrel deaths into recurring setups; `tools/overnight_setups.py` logs every instance of the 5 biggest plus Kong's ladder (`ky00`), tries every move at each (`setup_moves.py`), turns a move into a setup rule only if it beats no move by 10+ points where it matters and costs under 2 points where he lives anyway, then checks all of them together on 10,000 fresh games (`ky01` against `ky02`). Summary in `runs/overnight_setups.txt`; rules in `runs/overnight_rules.json`; **not adopted into params until checked.**

**Kong's-ladder setup, every move (`runs/kx00/setup_moves.txt`):** 1,215 instances; no move dies at least once at 268 of 2,430 moments (11%). There, the best moves were tap left 10 (77.0% against no move 54.1%), tap left 4 (74.5%), tap right 4 (71.4%); but at moments he lives through anyway they cost 6–14 points (tap left 4: 93.8%). Since 89% of the moments are the safe kind, **every move loses overall for the setup as a whole**: the picture doesn't separate the moments that need a move from the ones that don't. (The 54.1% was also biased low: stage 2 reused the same timings that picked the moments. Fixed: stage 2 now uses fresh timings, and `overnight_setups.py` only accepts a move whose gain, weighed by how often each kind of moment comes up, is positive overall.) Next idea: find what tells the two kinds apart (e.g. how far down the short ladder the barrel is, the rolling barrel's distance), so a move fires only at the dangerous kind.

**Overnight setup loop result (`runs/overnight_setups.txt`):** 6 setups. Passed: **s1** (5th girder x=92–98, barrel on Kong's short ladder 8–16 px right, another rolling left at him 57–72 px away: **walk left 20 frames**; no move 15.4% at its dangerous moments, the walk 53.8%, net +7.9 points across all its moments) and s5 (almost the same spot, same move). Rejected: s2 (best move −11 points net), s4 (+1.4, under the bar), Kong's ladder alone (−2.3). **s3** (x=87–94, barrel rolling left at him 20–28 px, another going over the end 64–72 px behind: **straight jump holding left right away**, 100% against 28.6%, net +11.6) failed only for too few moments (7). Fresh check (`ky01` → `ky02`, s1 + s5): **97.90% → 97.95%**, s1 saved 6, lost 2 (one a fireball 667 frames later); s5 changed nothing. Second check with s1 + s3 on other fresh games: `ky03` / `ky04` (first 9100000).

**Second check (`ky03` → `ky04`, first 9100000): 97.56% → 97.66%**, saved 12 lost 2 (s1 9 / 2, s3 5 / 1). **s1 and s3 adopted in `levels[5].setups`.** Round 2 of the loop (`TAG=kz`, first 9200000/9300000) works on the biggest setups behind `ky04`'s barrel deaths, with s1 and s3 on in every run.

**Round 2 (`kz`, from `ky04`'s 202 barrel deaths in 128 setups): nothing passed.** kzs1 (the s1/s5 spot again) had no instances left because adopted s1 now acts first. Every other setup (kzs2–kzs6, 184–702 instances each, mostly 4th girder) had dangerous moments only 7–12% of the time, and every fixed move cost more at the safe moments than it gained at the dangerous ones (best net −0.6 points). **Lesson: once the obvious setups are taken, the planner already plays these spots about as well as any one fixed move; the next gains need a way to tell dangerous moments from safe ones that look the same.** Fresh 30,000-game exam of the current 5-1 (with s1 + s3): `kz10`.

**Matt on ladder 91 (2026-11-10):** "I only climb up it after Kong has released a barrel (or at least put the barrel in front of him so I know it's not a wild). I then climb only if there's enough room to get up before a barrel reaches the ladder. I also try and steer things down the right-most ladder to reduce the number of barrels up there." There's a situation up there that needs a wall jump. And: "a good Kong player will always grab the hammer up there and jump vertically, then land with the hammer just as the barrel is in the perfect spot to be hit … it tends to clear out the scenarios to go right on that girder" (the 5th-girder hammer; he currently avoids it, `ham_avoid`). Built `climb_gate` {ladder x, window after a throw, room px, pose 172 ok, wait for the barrel to pass Kong's short ladder}: strips UP at the foot of ladder 91 until Kong has thrown (or shows the barrel in front, pose 172) and no barrel on the 5th girder is within `room` px right of the ladder. Fresh test after `kz10`: `lc00` reference, `lc01` {91,60,60,true,true}, `lc02` without the short-ladder wait.

**Learning the top hammer (Matt, 2026-11-10: "Go on, learn the hammer").** Found: the top hammer is at x=36, y=100 (0x6683/0x6685); 0x6680 = 1 while it exists, 0x6681 = 1 once taken (both reset after it wears off, so `c.ham_used` limits it to one a board); Mario faces right when 0x6207 >= 0x80 (`o.face`). Held, it swings 8 frames up / 8 down; a barrel is smashed when it is 11-22 px in front of him with the hammer down, so standing still facing it, a rolling barrel (12 frames across that spot) can't slip through. Built: `ham_top {hammer x, gap from, gap to, most wait, wait x}` (go to the wait spot, go in when the nearest barrel is in the gap window, walk under, jump straight up held 3 frames); `ham_avoid_x` (the planner plans nothing inside the hammer's reach, only from outside it; native too); `face_known` (with the hammer he presses until Mario really faces the barrel: one press didn't turn him, so barrels went under the hammer behind him); `ham_stop = 50` (turn to face from 50 px). Grabbing it mid-jump changes the jump (he comes down slower), so a planner jump over a barrel under the hammer kills him. Results, 5-1 (no hammer 97.11% / 97.30%): first try 26-39%; + facing fix 54-56%; + one a board, scripted run-in 75% (24 games); 1,000 games **68.45%** (window 90-110), 300 games 64.6% (70-95), 54.3% (60-85). Deaths with the hammer are now rare; nearly all are on the way to it, trapped at the wait spot by trains of barrels while it can't go left. **Not adopted.** Next: give the planner the hammer itself (the grab jump's slower fall, and that barrels reaching the hammer's spot while it's down are smashed), so it can plan the trip, the grab and the walk right like any other move instead of a hand-timed script.

**Fresh 30,000-game exam of 5-1 with s1 + s3 (`kz10`, first 9400000): 97.80%** (95.06% counting fireballs; barrel deaths 572, wild 62, fireballs 840). Before: 96.79% (30k, 2026-11-08, 8-9 frame reactions).

**Climb rule, first test (`lc00` 97.72% → `lc01` 97.11%, saved 25 lost 119; `lc02` without the short-ladder wait the same):** the extra deaths are on the 4th girder (176 → 265): waiting at the foot of ladder 91 while his own girder's barrels roll into him. Too wide again. `climb_gate[6]` = threat px: he only holds off while no barrel on the 4th girder is rolling at him within that range (nor coming down a ladder onto it, nor a wild above, that close). Tests: `lc03` the whole rule, `lc04` the Kong part only, `lc05` the room part only (all first 9500000).

**Matt's hammer routine (2026-11-10):** "go up the longer ladder [91], move left, turn around, stand where Mario's back feet meet the edge of the girder, jump up straight to get the hammer as the barrel reaches/crosses the bottom of the broken ladder in front of Kong, so landing smashes a barrel. Then stand just left of the ladder and steer barrels for as many smashes as possible. Never go left with the hammer unless going for a fireball; if a fireball comes up to the girder below, prioritise moving right if the hammer's about to run out, to get to the right ladder. Keep Kong in mind: no barrel to the head, don't walk under a barrel coming down the ladder." Measured: the hammer lasts 800-1,022 frames; from the edge a barrel at the broken ladder's foot (x=106) is ~73 px away, which is what the jump-and-pickup delay needs (matches Matt's cue). Built: edge x (31 falls off on landing; **33** works, 35 worse), `ham_hold = {84, 650}` (stand left of ladder 91, head right after 650 frames held), `ham_straight` (straight to the edge, no waiting part-way: my wait spot at x=51 put him between pairs of barrels ~30 px apart), `ham_top[6]` (at the edge, a barrel already too close: jump as it arrives so it passes under on the way up). Results (no hammer 97.1%): 1,000 games with the x=51 wait **59.6%**; straight to the edge, 40 games: 45% / **62.5%** / 62.5% (late jump at 10 / 14 / 18 px). Remaining deaths mostly at the edge (x=30-39), plus more fireballs (longer on the board). Not adopted.

**Learning from a top player's recording (2026-11-10).** Matt gave two INPs: DarkFaker 1,169,900 (WolfMAME 0.270: out of sync on our 0.264 at once) and barra 1,178,400 (WolfMAME 0.241: **in sync**, 120 boards to the level-22 kill screen, ending 1,177,400). `tools/inp_check.py` (sync check), `tools/inp_trace.lua` (per-frame trace of barrel boards from level 5, same layout as our autopsies plus joystick, facing, Kong, top hammer), `tools/inp_study.py`; trace in `inps/barra.trace`. **barra on 54 barrel boards at level 5+: 51 cleared, 3 died (94.4% counting everything)**; took the top hammer on 52. Jumps for it from x=35-38 (usually 37), facing right 38 of 52, the nearest barrel then at x=107-128 (just past the broken ladder's foot, Matt's cue), 42 frames in the air, landing with it 31-43 px away; waits at the spot 3-200 frames (median ~35); steps onto it almost only with the next barrel still at x>=107. **Climbs the left ladder (x=51) on 30 of 52** (straight to the hammer, often in 100-300 frames); from ladder 91 he lingers near its top first. With the hammer: at the landing spot (x=36-40), just left of ladder 91 (x=68-88, standing still most there) and x=108-120; leaves for the right ladder after ~900 of ~1,000 frames. **Our hammer versions on 5-1 (no hammer 97.1%):** barra's numbers 73% (40 games), + left ladder 82.5% (40), 1,000 games **79.8%** (`hammer5c`); straight jumps at the edge 79.9% (`hammer5d`); gating on the next barrel's distance 74% / 72%; landing 30-40 px like barra 78.1%; jumping close barrels to the right 69% / 72%. The remaining big group: ~65 deaths holding the hammer at the spot, from grabbing it (planner dodges) with a barrel too close, and he walks or turns into it. **Not adopted.** Important comparison: counting every death, his no-hammer play clears ~95% of 5-1 boards (`hm00` 94.0%, `kz10` 95.06%), about the same as barra's 94.4% on these boards; the hammer is how barra scores, not necessarily how he survives.

**`face_known` adopted on 5-1** (fresh, first 9500000: `lc00` 97.72% → `fk01` 97.86%, saved 23 lost 8; fireballs 274 → 246). Next: barra's left ladder (x=51) without the hammer (`ld00` / `ld01`, first 9700000); then barra's fireball handling and decision comparison at our death spots.

**Second expert recording (Matt, 2026-11-10): `inps/player3 2026-02-09.inp`, MAME 0.260, in sync** (replays on 0.264 to level 21, ending about 1,120,400, last life lost at level 21; its 3 deaths are spaced out and normal, no sign of a desync). Barrel boards at level 5+: **52, cleared 50 (96.2%)**, top hammer on 51; up ladder 91 on 33 and the left ladder on 18 (barra preferred the left one, 30 of 52). Trace `inps/player3.trace`. Together: 106 expert barrel boards at level 5+.

**Left ladder without the hammer (`ld00` 97.91% → `ld01` 92.89%, saved 135 lost 606; wild-barrel deaths 21 → 227, 5th-girder deaths 53 → 410): rejected.** The experts' left-ladder climbs go with the hammer plan; player 3 mostly used ladder 91. Next: decision comparison against the experts at his death spots (`ld00` barrel deaths traced).

**Expert comparison (`tools/expert_match.py ld00`, `runs/ld00/expert_match.txt`):** 86 of his barrel deaths had an expert moment with Mario on the same girder within 6 px and the same nearby barrels (within 10 px, same way); the experts' next move from there, tried 6 times each in his games: **no move 143/516 (28%), the experts' move 212/516 (41%)**. Varies a lot by spot (some 0/6 → 6/6, some 5/6 → 0/6). Clear repeat winners: x1 (5th girder at ladder 91's top between two barrels rolling left ~25 px either side: straight jump at once holding left, 6/6 vs 0-2/6, 3 deaths); x2 (5th girder x=94-97, a barrel rolling at him 27-29 px, one coming down Kong's short ladder 10-13 px right: tap right, 6/6 vs 0/6, 2 deaths; the Kong's-ladder setup with the barrel distance the experts react to); x3 (4th girder x=83-84, a barrel 16-19 px right, one on the girder above 17-19 px right: walk left ~10 frames, 6/6 vs 0-4/6, 3 deaths); x4 (4th girder x=80, a barrel ~72 px right, one above 19 px right: tap right, 5/6 vs 1/6). Testing all instances of each (`xe00`, first 9800000, then `setup_moves.py`).

**World-record video (Matt, 2026-11-10): `videos/Barrels.mp4`**, the barrel boards of the highest game ever played (Serphentizer, 1,269,600; arcade capture, 1280x720 at 60 fps, 2 h 20 min). Board cuts from a 10 fps scan (`videos/boards.npy`, 60 boards); levels read off the "L=" crops (`videos/levels.txt`): boards 04-58 are levels 5-21 (55 boards, extra boards at levels 13, 15 and 21 where a life was lost), 59 the level-22 kill screen. Calibration: game x = (video x - 338.8) / 2.475, game y = video y / 2.78; the playfield crop 339-973 x 0-712 scaled to 256x256 is 1 px = 1 game unit. `tools/vid_objects.py` (moving objects against each board's median background, classified by colour: Mario's red and blue blur to purple, so by mean colour; barrels; blue barrels; fireballs), `tools/vid_extract.py` (all frames, `videos/raw/`), `tools/vid_trace.py` (the INP trace layout: Mario's game position, ground / jump / ladder by how each off-girder stretch ends, hammer by blob size, stick and jump inferred, barrels followed frame to frame). Result `videos/kl.trace` (also `inps/kl_video.trace`): 409,744 frames, ~3,200 jumps, checked by eye on sample frames.

**Expert comparison with three experts (barra, player 3, Serphentizer's video; `runs/ld00/expert_match3.txt`):** 96 deaths matched (closest moments: barra 44, player 3 33, Serphentizer 19); no move 148/576 (26%), the experts' move 223/576 (39%); clearly better at 30 deaths, clearly worse at 15. Repeats: x1 (10 deaths), x2-like (6), x3-like (5), and new from Serphentizer: 2nd girder x=126-142 with a barrel right above coming down the ladder or on the girder above ~60 px left: **stand and wait** (4 deaths, 0-1/6 → 4-5/6). Queued as x5 / x6 (`xe01`, first 9900000).

**Steering, experts against him (Matt: "the expert probably made sure that bad luck didn't happen by steering the barrels above him"). `tools/steer_study.py`:** each time a barrel reaches a ladder on the girder above Mario (Mario on the ground, no hammer): his stick relative to the ladder and whether it came down. Stick towards: ~75% come down; away or neither: ~20% (INPs). Share of those moments with him right under the ladder (<=16 px): barra 19%, player 3 12%, **him 34%** (149 cleared games). 17-48 px off, the ladder **downstream** (where barrels on his girder roll away to): experts pull it down (stick towards) **81-85%**, **he 8%**; upstream: experts 50-61%, he 16%. His `steer_pull` only fires standing with nothing else to do and 3 frames before the ladder. Tests (queued after x6): `lp00` reference, `lp01` steer_pull = 8, `lp02` + `pull_walk` (also while walking), first 10000000. Also `autopsy.py` with `TRACE_ONLY=1` traces any game, cleared ones too.

**Expert spots, every instance (`xe00`, `xe01`, `setup_moves.py`):** x1 (150 instances, 15% where no move sometimes dies): walk left 8 then straight jump 88.6% there vs 36.4%, 91.4% vs 96.1% elsewhere: **passes** (~+3.7 net). x2: 7 instances, too rare. x3 (1,726) and x4 (1,936): best moves within noise of no move: **no gain** (the gap there is earlier steering, see below). Serphentizer's x5 (972; barrel coming down the ladder right above him on the 2nd girder): **stand 20 frames** 89.5% vs 70.6%, 92.7% vs 94.3%: passes (~+0.9). x6 (1,817; barrel ~60 px left on the girder above): **straight jump at once** 87.4% vs 74.8%, 96.3% vs 93.7%: passes. Combined fresh check `xc01` against `lp00` (first 10000000).

**Pulling barrels down like the experts (fresh, first 10000000):** `lp00` 98.03% (counting fireballs 95.61%); `lp01` steer_pull = 8: 98.13% (111 saved / 102 lost); **`lp02` steer_pull = 8 + `pull_moving` (also while walking): 98.52%, counting fireballs 96.44%**; barrel deaths 172 → 125, 4th-girder deaths 171 → 106, fireballs 247 → 211; 131 saved / 86 lost. (`pull_walk` was already a number, the safety check's steps; the switch is `pull_moving`, and the safety check now also runs while walking.) Second check queued: `lp10` / `lp12` (first 10100000).

**Combined spot rules (`xc01` vs `lp00`): 98.03% → 97.83%**, saved 70 lost 88 (x6 73/100, x1 10/14, x5 57/44): not adopted; the trials' 150-moment "safe" sample flattered x6. Lesson: copying an expert's move at one spot rarely beats his own play over every instance; copying their habit (pulling barrels down) did. **Overnight (`tools/overnight_pull.py`, `runs/overnight_pull.txt`):** second 5-1 check of the pull (`lp10`/`lp12`), adopt if +0.1 and more saved than lost; the same on 4-1, 3-1, 2-1 (`pl40`..`pl21`), adopted per level on the same bar (replacing the level's own `steer_pull = 3`); 1-1 (`pl10`/`pl11`) reported only; then a fresh 5-1 run with the day's settings (`pz00`), its barrel deaths traced and compared with the experts again. params.lua before the night: job tmp `params_before_overnight.lua`.

**Overnight results (2026-11-11, `runs/overnight_pull.txt`):** pull (steer_pull = 8 + pull_moving) **adopted on 5-1** (second check `lp10` 97.93% → `lp12` 98.35%, 116 / 83), **4-1** (94.15 → 94.78, 347 / 287) and **3-1** (95.22 → 95.58, 317 / 279). 2-1: 97.68 → 86.03 (166 / 1,329) and 1-1: 98.91 → 95.61 (95 / 423): not adopted; those levels lack `pull_safe`, so he pulled even when the steps weren't safe; retesting with pull_safe (`pl22`, `pl12`; 1-1 report only). Fresh 5-1 with everything on (`pz00`): **98.36%** (counting fireballs 96.24%). Expert comparison on its remaining barrel deaths: no move 178/468, the experts' move 191/468: little left to copy directly.

**2-1 / 1-1 pull with pull_safe, paired:** 2-1 `pl20` 97.68% → `pl23` 97.73% (129 / 124): even, not adopted; 1-1 `pl10` 98.91% → `pl13` 98.83% (36 / 43): unchanged. (`pl22` / `pl12` used other games by mistake: unpaired, ignore.) Pull stays on 3-1, 4-1, 5-1. Next (the experts' other habit, rarely under a ladder when a barrel arrives above: 12-19% vs his 34%): `w_under` for every live ladder (`under_zones = nil`), `pu01` (w_under 40) and `pu02` (80), against `pz00` (98.36%, same games).

**w_under on every live ladder (5-1, same games as `pz00` 98.36%):** `pu01` 98.32% (89 / 91), `pu02` w_under 80: 98.35% (91 / 91): neutral, not adopted. It only weighs where he takes off and lands, not where he stands while barrels come down, so it doesn't capture the experts' habit; that needs the planner to weigh standing spots. 30,000-game fresh exam of 5-1 with everything on: `pz10` (first 10700000).

**30,000-game fresh exam of 5-1 (`pz10`, 2026-11-11): 98.37%**, counting fireballs 96.29% (fireballs 634, barrels 418, wild barrels 47, falls 13). Before: 97.80% / 95.06% (`kz10`, 2026-11-10). Deaths by girder: 2nd 370, 3rd 102, 4th 332, 5th 184, 6th 124.

**30,000-game fresh exams with the pull on (2026-11-11):** 4-1 `pe40` **94.89%** (was 90.32% fresh on 2026-11-07, 94.15% in last night's reference); 3-1 `pe30` **95.49%** (was 91.12%, 95.22%). On both, wild barrels are now nearly half the non-fireball deaths (4-1: 693 wild, 771 rolling; 3-1: 619, 679).

**Matt's review of ten current 5-1 barrel deaths (2026-11-11, video from `pz10`):** 1 jumped back for no reason, then no time to go forward: move left, then right-jump the two barrels; 2 right jump instead of straight, landed in another barrel; 3 right jump instead of straight, into the ladder; 4 steer the barrel top-left of Mario down the ladder to group with the one to his left; 5 straight jump right but late; 6 right jump earlier, or straight-jump both; 7 first jump a back jump with the blue barrel; 8 go right for the hammer or commit to the climb earlier (fireball pressure); 9 a useless back jump like 1; 10 right jump into a barrel, should have straight jumped. Traces: in 2 the planner thought every option died by then (s<0) and picked a right jump; the miss is earlier (a straight jump then a quick second one). `tools/grind_review.py` tries each fix in its own game at every 4 frames from 2 s before, 8 timings each (`runs/pz10/review1.spec`).

**Jump timing, measured in the emulator (barrels and fireballs cleared each frame, measurement only):** holding the button never re-jumps (it needs a fresh press); after any landing a press **4 frames** later takes him up again, on flat and sloped girders alike. Time in the air: 42 frames landing level, **43-44 landing 1-2 px lower** (downhill), 41 landing higher (Matt: "when Mario lands on an incline it takes a little longer to jump again"). The planner treats every jump as 41 frames (ARC) and its earliest second jump is 6 frames after landing (`seconds = {6, 16, 30}`): candidates to fix.

**Matt's fixes in their own games (`runs/pz10/review1.spec.out`, only moments where his own play mostly still dies; earlier, a takeover reshuffles the luck and he lives anyway):** confirmed #1 (walk left then right-jump, 8/8 vs 1-2/8), #3 (straight jump with a 4-frame wait, 8/8 vs 0/8), #6 (straight jump, 8/8 vs 1-2/8), #7 (back jump or straight, 8/8 vs 0/8), #8 (walk right 8/8, or straight jump 8/8), #10 (straight jump, 8/8 vs 1-2/8); #2, #4, #5, #9: no fix inside the window where his own play dies. A straight jump wins in five of the six. Suspect: `w_with = 60` (a bonus for jumping the way a barrel rolls) biases him to sideways and back jumps. Tests (same games as `pz00` 98.36%): `sj01` slope_jump, `sj02` seconds {4,6,16,30}, `sj03` both, `sj04` w_with 0, `sj05` w_with 30.

**General planner fixes from Matt's review (same games as `pz00` 98.36%):** `sj01` slope_jump 98.25% (40 / 54); `sj02` second jump from 4 frames after landing 97.93% (60 / 101); `sj03` both **96.10%** (82 / 304); `sj04` no with-the-barrel bonus (w_with 0) **97.48%** (25 / 112: those back jumps do save games overall); `sj05` w_with 30: 98.41% (18 / 13, noise). None adopted: the current tuning is a local optimum again; the measured slope timing makes it worse, so other settings are already compensating for the fixed jump length. Matt's fixes work in their own games but no general change reproduces them.

**Matt (2026-11-11): "I am surprised that testing that showed a very small increase was considered no good, when you're talking about a situation that may never or rarely occur. You cannot expect a big % increase from a rare situation."** New bar for narrow rules: judge them on the games where they acted (saved vs lost there, from `rule_report.py`), confirmed on a second fresh set, not on +0.1 overall. Second checks of the small positives: x5 (Serphentizer's wait, 57 saved / 44 lost when it acted) `sm01`, w_with 30 (18 / 13) `sm02`, against `sm00` (first 11000000). `sj06` with_straight (0 / 1) did nothing. Wild barrels, measured on landing (traces): they sit 7 frames on the girder, then sink through over ~11 more (~18 in all), much as the planner's model (rest 6 + fall); the #10 misprediction is elsewhere (where it lands, or what counts as a hit while it sinks).

**Second checks (`sm00` 98.35%, first 11000000):** x5 `sm01` 98.20%, where it acted 55 saved / 62 lost (over both checks 112 / 106): not adopted. **w_with 30 `sm02` 98.43%, 16 / 11** (first check 18 / 13; both up overall): **adopted on 5-1** (w_with 60 → 30). s1 and s3 now act rarely and barely matter (1 / 1, 0 / 0).

**Predicted against real (`tools/pred_vs_real.py`, `runs/pz10/pred1.spec.out`):** in #8 the planner predicted the straight jump hit at t=40 (clearance -0.3); played for real 4/4 cleared with 1-2 px to spare. The barrel was where predicted (within ~2 px); **Mario was ~3 px higher than predicted**: the real jump starts a couple of frames after the planner assumes (the press lands late and he then leaves the ground), so it's pessimistic about late straight jumps. `press_lag` (frames a jump plan allows for the press) is on for 2-1 only. Tests: `pl51` / `pl52` / `pl53` press_lag 1 / 2 / 3, against `sm02` (current 5-1 settings, first 11000000). (#10's real trace came out frozen in this tool, a recording problem; the other four reported no near miss for those moves.)

**press_lag on 5-1 (against `sm02` 98.43% / 96.11% counting fireballs):** 1: 98.45% / **96.44%** (127 / 124; fireballs 236 → 204); 2: 97.00% (143 / 280); 3: 92.06% (133 / 745). The planner's other settings already absorb most of the real press delay; 1 frame is level on barrels and fewer fireball deaths: second check `pl60` / `pl61` (first 11100000).

**press_lag = 1 adopted on 5-1:** second check `pl60` 98.48% / 96.61% → `pl61` **98.68% / 96.86%** (123 / 105); over both checks 250 saved / 229 lost, counting fireballs up both times. Death #10 was a hammer case: with the hammer he can't jump, so the "straight jump" only kept him standing and the hammer smashed the wild barrel (the game freezes briefly on a smash: the "frozen" trace); his own play walked into it.

**30,000-game fresh exam of 5-1 with the pull, half bonus and press_lag 1 (`pz20`, first 11200000): 98.40%**, counting fireballs **96.42%** (barrels 411, wild 49, fireballs 605, falls 10). Last night's exam (`pz10`): 98.37% / 96.29%. The two small additions show as +0.03 / +0.13 here: smaller than their paired checks, within this exam's noise.

**press_lag = 1 on the other boards (fresh, paired):** 4-1 `pj40` 94.74% → `pj41` **95.39%** (402 / 340); 3-1 95.95% → 95.69% (272 / 298): not adopted; **2-1 (from its press_lag 2) 97.62% → 98.62%** (232 / 132; 5th-girder deaths 143 → 51); 1-1 98.99% → 99.04% (84 / 79): report only, unchanged. Second checks for 4-1 and 2-1: `tools/check_press_lag.py` (`pk40`/`pk41`, `pk20`/`pk21`), adopted per level if they win again; log `runs/check_press_lag.txt`.

**Second checks (2026-11-12):** 4-1 `pk40` 94.98% → `pk41` **95.71%** (373 / 299): **press_lag = 1 adopted on 4-1**; 2-1 `pk20` 97.57% → `pk21` **98.45%** (236 / 148): **press_lag 2 → 1 on 2-1**. Now: press_lag 1 on 2-1, 4-1, 5-1; 3-1 none (worse with it); 1-1 none (even, unchanged).

**30,000-game fresh exams (2026-11-12) with press_lag 1:** 2-1 `pe22` **98.47%** (was 97.62% fresh on 2026-11-07), counting fireballs 98.39%; 4-1 `pe42` **95.45%** (was 94.89% on 2026-11-11), counting fireballs 94.76% (wild barrels 689, rolling 625).

**"No barrel deaths while jumping on 5-1" (Matt, 2026-11-12).** `pz20` (30,000 games): 286 such deaths (0.95% of games; 62% of barrel deaths): 279 barrels, 7 wild; 5th girder x=100-119 (72), 4th x=80-99 (48), 4th 120-139 (33), 5th 80-99 (28), 4th 100-119 (27). Autopsies (save states, the real game): the killer had come off a ladder in 227 (79%), over a girder end in 46, rolled on his girder in 6. At take-off the killer was on his girder rolling at him (123), on the girder above 3-17 px before a ladder (58), already on a ladder (37). **The jumps are last-ditch**: taken 1-4 frames before death with his planner already scoring every option as death (s ~ -100); the probe's single held moves find no escape from 80+ frames before take-off in 208 (it can't do sequences). His last safe plan collapses within a few frames without a predicted hit (29 of 30 checked: `tools/collapse_check.py`), i.e. by the risk penalties for barrels that might come down ladders; and his waits come in coarse steps, so planned jumps slip. Next: retest `fine_waits` and `keep_jump` on today's settings (`fw01`, `kj01` against `pl61`'s settings, first 11300000, reference `fw00`).

**fine_waits retest (fresh, first 11300000):** `fw00` 98.27% → **`fw01` 98.50%** (160 / 140); **barrel deaths while jumping 112 → 86**. (`kj01` already existed from an old run, so keep_jump wasn't tested; redone as `kj02`.) Second check of fine_waits: `fw10` / `fw11` (first 11400000).

**fine_waits adopted on 5-1:** second check `fw10` 98.29% → `fw11` **98.52%** (159 / 143); barrel deaths while jumping **104 → 82** (first check 112 → 86). keep_jump (`kj02`, w_keep 20): 98.27% → 98.05% (164 / 181): rejected again. Next for jumping deaths: positioning around ladders a barrel might come down (the experts' habit), and fine_waits on the other boards.

**under_end (a cost for plans that leave him standing under a ladder a barrel above will reach soon), against `fw11` 98.52% (jumping barrel deaths 82):** {10,40,60} 98.29% (68 / 91; jumping deaths 112); {12,80,60} 96.00% (98 / 345; 177); {8,40,90} 98.26% (66 / 92; 110): rejected. Keeping him off live ladders just moves him into other trouble; the experts' habit is part of how they steer and time, not a separate keep-away rule.

**Matt's second review (ten jumping deaths from `fw11`), grind in their own games (`runs/fw11/review2.spec.out`):** confirmed #3 straight jump not right (8/8 vs 2/8), #5 straight jump (6/8 vs 0/8), #6 stay right / wait for the fireball (6/8 vs 0-1/8), #10 the right back jump earlier (8/8 vs 0/8); weak #4 (3/8), #9 (3/8); none in the window for #1, #7; no window for #2, #8. #5: near the end he stood by the right ladder jumping fireballs with no stick while Kong's barrels reached the short ladder (earlier on the 5th girder he did steer them). Common thread: jump earlier. `w_later` = 0.45 (a bonus per frame of wait) may now push jumps late: tests `wl01` 0.25, `wl02` 0.1, `wl03` 0 against `fw11` (first 11400000).

**w_later (against `fw11` 98.52%, jumping barrel deaths 82):** 0.25: 98.38% (131 / 139; 91); 0.1: 98.09% (142 / 181; 124); 0: 98.05% (145 / 187; 135). Earlier jumps everywhere cost more than they save: waiting tells him which way barrels go. Matt's "jump earlier" holds in those spots, not as a blanket rule. Testing larger: `wl04` 0.6, `wl05` 0.8.

**w_later larger:** 0.6: 97.51% (132 / 237; jumping deaths 168); 0.8: 87.29%. 0.45 is right. Every broad timing change except fine_waits made jumping deaths worse: his general settings are at a local best. **Next: Matt's confirmed review fixes as narrow rules** (`tools/review_rules.py`, `runs/review_rules1.spec`): the situation at each fix moment (his girder and x within 6 px, nearby barrels within 8 px, same way) becomes a detector; `rv00` (first 11500000) logs every instance; `setup_moves.py` tries every move there; judged by the games where they act.

**Review fixes as narrow rules (`rv00`, every instance, every move; judged where it matters vs where he lives anyway):** r1 (review 1 #1; 185 instances, 8 matter): walk left 8 then right jump holding left 87.5% vs 75.0%, no cost (99.3 vs 99.3): candidate. r2 (review 1 #3; 454, 56 matter): walk left 8 then straight jump holding left 91.1% vs 49.1%, 91.7 vs 95.7 elsewhere: candidate (net positive). r3 (review 1 #6): +8-10 / -2-5: no. r4, r6, r9: too rare. r5: no move helps. r7 (review 2 #5; 8,372, 153 matter): walk left 16 then right jump holding left 78.1% vs 69.0%, no cost (99.7 vs 99.7): candidate. r8 (review 2 #6): no. Combined fresh check `rr00` / `rr01` (first 11600000), judged by saved / lost where each acts.

**Review rules, combined fresh check (`rr00` 98.43% → `rr01` 98.69%, 49 / 28; jumping barrel deaths 98 → 81):** r7 38 saved / 7 lost (in 3,620 games), r2 43 / 22 (464), r1 2 / 5 (dropped). Hammer (Matt): the long "down" spells (81 frames) are the smash pause: all 24 measured followed a smash; the 8 / 8 swing carries on afterwards. Second check of r2 + r7: `rr10` / `rr11` (first 11700000).

**r2 and r7 adopted on 5-1** (second check `rr10` 98.67% → `rr11` 98.76%, 43 / 36; 6th-girder deaths 56 → 32; jumping barrel deaths 88 → 84): r7 41 / 13 (both checks 79 / 20), r2 42 / 32 (85 / 54). s1 has drifted to even or behind now that other rules act first (1/1, 1/4); s3 even (2/4, 3/3): candidates to drop. Ladder width (Matt): 8 px edge to edge (rails 7 px apart centre to centre): ladder 91 x=87-94, left ladder 48-55, middle 127-134.

**s1 and s3 removed from 5-1** (now worse than nothing: other rules and the pull cover their spots): `rr11` 98.76% → `ds02` 98.85% (11 / 2); second check `ds10` 98.56% → `ds12` 98.69% (15 / 2). 5-1 setups now: r2, r7. Fresh 30,000-game exam: `pz30` (first 11900000).

**Overnight 2026-11-12/13 (`tools/overnight_rules.py pz30 on1 12000000`, log `runs/overnight_rules_on1.txt`):** the review-to-rule cycle without Matt: the exam's (`pz30`) jumping barrel deaths, two from each of the 12 biggest spots, ground in their own games with 14 general moves; a move that lives 6/8+ where his own play lives ≤2/8 is the fix; each fix becomes a situation detector (`review_rules.py`, `on1r00`), every instance tried with every move; candidates (gain where it matters, under 2 points cost elsewhere, positive net) get two fresh checks; kept only if saved > lost where they acted both times; then added to levels[5].setups. Then a 30,000-game exam `pz40`. params.lua before the night: job tmp `params_before_night3.lua`.

**30,000-game fresh exam (`pz30`, 2026-11-12; finer timing, Matt's rules r2 and r7, s1/s3 gone): 98.67%**, counting fireballs **97.17%** (barrels 348, wild 40, fireballs 455). **Barrel deaths while jumping: 205** (was 286 in `pz20` the day before: -28%).

**Overnight result (2026-11-13, `runs/overnight_rules_on1.txt`):** 19 fixes from 24 ground deaths; situation trials passed 4 (on1r10, r15, r17, r18); fresh check `on1c00` 98.75% → `on1c01` 98.70% (9 / 12): r15 14 / 15, r17 2 / 4, r18 1 / 3, r10 0 / 1 (5 games): **none kept**. Final exam `pz40` **98.69%** / 97.21% (jumping barrel deaths below). Search-found fixes save their own death but rarely hold over every instance; Matt's reviewed fixes did (2 of 8 permanent). The script's 2-point cost bar wrongly excluded r9 (87% vs 28% where it matters, -4 elsewhere, net +1.7): checking it by hand (`r9c0x`). New review video from `pz40`.

**r9 by hand (two fresh checks, first 12800000 / 12900000):** where it acted 4 saved / 10 lost, then 4 / 7: rejected. The script's cost bar was right to turn it down. So far only Matt's reviewed fixes (r2, r7) have produced rules that hold; waiting on his review of `dk_jumping_deaths_5-1_v3.mp4` (`runs/pz40/review3.txt`).

**Matt's third review (ten jumping deaths from `pz40`):** 1 straight-jump the two barrels instead of moving left; 2 back-jump the 2nd barrel left with its motion, earlier (landed too late for the one coming down the ladder); 3 right jump under a ladder a barrel came down: straight jump; 4 a random left jump into a falling wild, no need to jump at all (wild detection problem?); 5 steer the barrels down from the left of the ladder, then straight-jump the leftmost; 6 steered a bad grouping (the top-left barrel into the other two); steer down the longer ladder while climbing the middle, or wait below, or worst case run right and wall-jump; 7 back-jump the first, then straight-jump the next two; 8 skip; 9 jumped into a barrel: just move left away from the fireball; 10 straight jump where he died. Running `overnight_rules.py pz40 on2 13000000 runs/pz40/review3.spec` (COST 0.05: r2 held with a 4-point cost).

**Wild barrels from Kong (Matt's review 3 #4: a random left jump under a falling wild):** at frame 1103 a wild left Kong at x=59; the planner (kong_aim = 1: every wild aimed at Mario) expected it to drift to him at x=82 and jumped left; it fell straight down at 59. Measured over the traced games (not the opening barrel): **279 drifted towards Mario (81%), 65 dropped straight down at x=59 (19%)**, none away. `kong_straight` = chance of a straight drop, a second ray. Tests `ks01` kong_aim 0.81 + kong_straight 0.19, `ks02` kong_aim 1 + kong_straight 0.19, against `ks00` (first 13500000).

**Kong's wilds test (`ks00` 98.63%, jumping barrel deaths 83, wild deaths 19):** `ks01` kong_aim 0.81 + kong_straight 0.19: 98.65% (6 / 4; 82; 19); `ks02` kong_aim 1 + 0.19: 98.63% (3 / 3). Rare. **Adopted on 5-1 (kong_aim 0.81, kong_straight 0.19)** at Matt's word: the scenario is real (measured), the change only acts when a wild leaves Kong, and it came out slightly ahead. Review 3 grind: fixes confirmed for #2 (back jump left, 44 before), #4 (stand, 68 before), #6 (run right, 60 before), #10 (straight jump, 16 before); situation trials running (`on2r00`).

**The #4 cause, properly:** `kong_straight` only touches the wild he expects before Kong lets go. In #4 the wild was already out, and for its first frames, before he'd seen it move, his code assumed it aimed at Mario (`wild_aim`); he jumped 4 frames after it appeared. `kong_straight_seen`: while a wild is on its first fall near x=59 and he hasn't seen its way yet, he also allows for a straight drop (a second dynamic wild with no sideways speed). In #4's own game: **8/8 from every moment 36+ frames before the death** (without: 0-6/8); in the last 32 frames neither lives. Fresh check `kw10` / `kw11` (first 13600000).

**Documentation updated (2026-11-13, Matt):** README.md rewritten (all barrel boards, current exams, the runner, the tools); FINDINGS.md gains "The barrel boards from level 2 to 5": measured game facts, what top players do, what improved 5-1, what didn't, current limits, testing lessons. Memory updated.

**kong_straight_seen adopted on 5-1** (fresh `kw10` 98.75% → `kw11` 98.76%, 4 saved / 3 lost: rare; in #4's own game 8/8 from 36+ frames before vs 0-6/8; acts only on a new wild's first fall before its way is seen). Review 3 situation trials so far: r1 (Matt's #2, back jump left): 72 instances, 22 matter, no move 23%, tap left 4 95.5% / 94% vs 97% elsewhere, step left then left jump 100% / 91%: strong candidate.

**Review 3 rule cycle (`runs/overnight_rules_on2.txt`): none kept.** #2's situation (on2r1: 95% vs 23% where it matters in trials) fired only 4 and 6 times in the fresh checks: it's r2's spot and r2 acts first; the trials missed that because `review_rules.py` loaded last week's s1 and s3 instead of the current rules (fixed: it now reads levels[5].setups). #4's spot (stand): net about even (its real fix was the wild model, adopted). #10's exact four-barrel set never recurred (0 instances). #6 skipped: at the decision moment the barrels were far away; it's a steering and waiting choice the nearby-barrel detector can't capture. Review 3 tally: #4 fixed (kong_straight_seen); #2 already covered by r2; #10 too rare; #6 needs a steering/positioning rule; #1, #3, #5, #7, #9 no fix found in their own games.

**Detector upgrade (Matt: "do you need to update your detector?"):** situation rules can now fire on a ladder (`lad = {y from, y to}` in a setup, matched on the real position); `review_rules.py` sees barrels up to 90 px away and two girders up, and for a barrel rolling towards a ladder on a girder above, records how far short of it (the existing ladder fields); `setup_moves.py --ladder` tries climb / climb steering left or right / stop and steer / back down. In their own games, Matt's climbing deaths were decided just after he stepped off the middle ladder: review 3 #6 walking right 8/8 vs 0/8 (44-56 frames before; his "worst case run right"); review 2 #9 almost any change 8/8 vs 0/8 (80 before). Trials: `lr00` (first 14100000), `runs/review_rules_lad.log`.

**Bigger levers (proposed to Matt 2026-11-13):** 1 contingent planning (plan with a fallback for a barrel that might take a ladder, instead of one fixed input sequence: the trap collapse behind most jumping deaths); 2 more of the experts' steering (upstream pulls: experts 50-61% from 17-48 px, he 16%); 3 a learned danger estimate from his own games; 4 the hammer, with the planner knowing the grab, the swing and the smash pause; 5 fireballs (the biggest single cause). Started with 2: `pull_upstream` (px), tests `pu12` (30) and `pu13` (45) against `pu10` (first 14200000), queued after `pz50`.

**#1 contingent planning (Matt: "put effort into #1"), first version:** a barrel that might come down a ladder counted as a risk (w_risk 500) whenever, after seeing it commit (see_lag 9), he'd have under 14 frames (respond) before it reached him: a crude "could I react"; near a ladder top almost every plan trips it at once (the collapse). `contingent` (plan.cpp): instead, from where the plan has him when he'd see it commit (on the ground), the existing way-out check (`follow_ok`: stand, step a little, and/or one jump) is run against that branch (the hazards committing at that moment) plus everything certain; a risk only if there's no way out. Tests after the upstream pulls: `ct01` contingent, `ct02` + w_risk 250, against `pu10`.

**30,000-game exam with the wild fixes (`pz50`, first 14000000): 98.64%** / 97.00% counting fireballs; barrel deaths while jumping 227, wild deaths 40 (`pz40` 98.69% / 236 / 39): unchanged within exam noise, as expected for a rare fix. Contingent planning: smoke test 10 games run, 9 cleared.

**Climbing-death situations with the wider detector (`lr00`):** 4 and 3 instances in 10,000 games: requiring every barrel it sees (four each) makes a rule almost never fire. Looser version of the key part (Mario just up the middle ladder, 4th girder x=112-132, a barrel on Kong's girder 0-16 px short of the short ladder at 106): `k1`, trials `kl00` after the contingent tests.

**Second expert video (Matt, 2026-11-13): `~/Desktop/TwinGalaxies12.mp4`** (a streamed arcade game, 3 h 53 min, 60 fps, every board). Playfield calibration: game x = (video x - 290.5) / 2.5, game y = video y / 2.80 (crop 640:717:290:0); barrels drawn red (`RED_BARRELS`), chat over the right edge (`RIGHT_OVERLAY`). 10 fps scan → 130 boards; barrel boards picked by matching a barrel board's background (difference ~3-4 against 22-31 for the others): 60; levels read from crops: 00-05 levels 1-4, **06-58 levels 5-21 (53 boards)**, 59 the kill screen (Matt: ignore everything after it). `videos/tg/`, trace `tg.trace` → `inps/tg_video.trace`. `vid_extract.py` now takes VCROP and (start, end) board pairs.

**Correction (Matt, 2026-11-13):** the first video (`videos/Barrels.mp4`, the highest game, 1,269,600) is **Serphentizer's**; "KL" was only a logo on screen, and every mention has been changed. barra is the first INP. The second video (`TwinGalaxies12.mp4`) is Matt's own game (Lyriell). Two-video comparison: Serphentizer 55 barrel boards L5-21 (4 replays after deaths: L13, L15, L21 x2), Matt / Lyriell 53 (2, both L21); Matt jumps straight more (69% vs 62% of jumps over a barrel coming at him), slightly earlier (21 px vs 19), waits a little longer at ladder 91's foot (9 vs 6.5 frames), holds a hammer more (18% vs 13%), uses the left ladder less (29 vs 40 boards); both spend ~22% of board time on the 2nd girder and ~40% on the 5th. Smashes per hammer (recordings): barra top 6.6 / bottom 8.1, player 3 top 6.5 / bottom 7.6; on video a smash isn't a clean freeze (the break-up animation), so not measured there yet.

**Note (Matt, 2026-11-13, corrected):** the **TwinGalaxies video (`videos/tg/`, `inps/tg_video.trace`) is Matt's own game (Lyriell)**: 53 barrel boards from level 5, 2 lives lost on them (both L21). "player 3" (`inps/player3 2026-02-09.inp`, MAME 0.260) is **player 3**.

**pull_upstream (against `pu10` 98.65%, jumping barrel deaths 75):** 30 px 96.05% (67 / 319; 5th-girder deaths 51 → 296; jumping deaths 271); 45 px 96.07% (50 / 300): rejected. Upstream pulls send barrels rolling at him; the experts do it mostly while holding the hammer on the 5th girder (about 45% of their time there), where a barrel coming at them gets smashed. That habit goes with the hammer.

**Matt (2026-11-13): "I just know my solutions have been correct for the scenarios."** True: every fix of his tested in its own game worked. The weak step is mine: deciding "is this the same scenario?" (too loose, e.g. r7 needs one barrel and fires in ~36% of games; too strict, four-barrel detectors recur 3-4 times in 10,000), and then rejecting rules that fire rarely. New approach, `tools/matt_bank.py`: each confirmed fix as a tight scenario rule (Mario within 6 px, every barrel within 60 px on his girder or the one above, each within 8 px, same way), all on together for two fresh checks; a rule stays if over both it saved at least as many as it lost where it fired. Spec `runs/matt_bank.spec`: review 1 #6, #7, #8; review 2 #3, #6, #10, #9; review 3 #6. Queued after the contingent and climbing tests (`mb00`/`mb01`, `mb10`/`mb11`, first 14500000).

**Scenario drills (Matt, 2026-11-13; abandoned for now):** `tools/drill.sh` / `lua/drill.lua` / `tools/drill_pack.py` / `tools/drill_clip.py`: replay a death's game in MAME to 3.5 s before the death, Matt plays from there (Q / E / W jump left / right / straight, arrows; G marks an attempt right, N next), inputs recorded, a clip for his confirmation before anything is learned. MAME needs `-samplerate 1000` to load the start states, and `-seconds_to_run` counts the game's own clock (a loaded state can exceed it). Over Jump Desktop a second key releases the first (no sideways jumps) and input lag made it unfair: Matt: "let's abandon this method for now, it doesn't work well remotely". Nothing learned from the sessions. Back to death-video reviews.

**#3, learning danger from his own games (Matt: "I would accept #3 improving things even a few tenths of a percent"; the hammer he wants me to learn on my own):** first the no-risk check. `FEATLOG` (agent.lua, off by default) logs every 4 frames Mario, the barrels and his planner's best score; `fl00` (10,000 fresh 5-1 games, first 14600000). `tools/danger_study.py fl00`: a danger table (death within 2 s, per simple description) learned on even games, tested on odd ones against his planner's score: AUC, and how far ahead each first flags a death. If the table sees deaths coming clearly earlier, wire it in and test on fresh games.

**Contingent planning, first version: rejected.** `pu10` 98.65% → `ct01` 93.44% (80 / 584; jumping barrel deaths 75 → 187; 3rd girder 26 → 177, 5th 51 → 314); `ct02` (w_risk 250) identical: the way-out check nearly always passes, so the risk cost almost never applies and he walks under ladders he used to avoid. Too optimistic: it ignored other barrels that might come down, wilds, and any delay before he reacts. Stricter: `contingent = 2` (the way out must dodge every "might" too), `contingent_lag` (extra frames before the escape starts). Tests `ct03` (2), `ct04` (2, lag 8) against `pu10`.

**Contingent, stricter (against `pu10` 98.65%, jumping deaths 75):** `ct03` contingent 2 (dodge every "might"): 93.44% (80 / 584; 190), the same as the first version; `ct04` contingent 2 + 8 frames' extra reaction: **98.12%** (72 / 124; 88). The margin is what matters: the way-out check assumes he reacts faster than he does. Next `ct05` (lag 16) after the danger logging. Climbing situation `k1` (loose): 5,520 instances, 189 moments where doing nothing sometimes dies; trials running.

**#3 danger table (`fl01`, 10,000 games, 4.3 M moments, 3,840 within 2 s of a barrel death; `runs/fl01/danger_study.txt`):** ranking the dangerous moments (AUC), table **0.88**, his planner's score 0.75; flagged within 4 s: table 28 of 58 test deaths (median 37 frames ahead), planner 51 of 58 (30 ahead); the table warns 20+ frames earlier (or he never does) in 11 of 58 (19%). An early warning, not a replacement. Exported as `cases/danger.lua` (1,074 descriptions seen 20+ times); `danger = weight` counts the learned danger of the spot a plan leaves him in (barrels moved on to then) against the plan. Tests `dg100`, `dg300` against `pu10`, after `ct05`. (FEATLOG first logged no planner score: `c.why` is just "plan" in play; now `c.best_s`.)

**Contingent with 16 frames' extra reaction (`ct05`): 98.24%** (61 / 100) against `pu10` 98.65%. Lag 8: 98.12%; lag 16: 98.24%: approaching the old rule from below as the margin grows, never above it. **Contingent planning shelved**: the old "can he react within 14 frames" rule is already a good stand-in.

**Loose climbing situation `k1` (`kl00`):** 5,520 instances, 189 where doing nothing sometimes dies (and there he lives 81%); best (tap right 4) 86% there but 96.3% vs 98.7% elsewhere: net negative, rejected. Too loose: it fires in many situations that aren't Matt's. The tight versions are in the scenario bank.

**Danger table in the planner (against `pu10` 98.65%, jumping deaths 75):** `dg100` 98.67% (21 / 20; 78), `dg300` 98.69% (34 / 30; 76): about neutral, leaning positive at 300. Second check `dh00` / `dh300` / `dh600` (first 14700000). Scenario bank `mb`: 5 rules built (m1 review 1 #6, m2 review 1 #8, m3 review 2 #6, m4 review 3 #6, m5 review 2 #9); 3 skipped (Mario mid-jump at the fix moment: review 1 #7, review 2 #3, #10).

**Scenario bank `mb` (Matt's confirmed fixes, "tight" by position): a clear failure, nothing kept.** `mb00` 98.76% → `mb01` 94.33% (36 / 466); `mb10` 98.68% → `mb11` 94.62% (40 / 438). Per rule over both: m3 (review 2 #6) fired in 5,863 games, 87 / 423; m5 (review 2 #9) 2,010, 46 / 329; m4 (review 3 #6) 1,280, 30 / 157; m1 (review 1 #6) 922, 15 / 387; m2 (review 1 #8) 186, 3 / 89. With only one or two barrels near Mario at the fix moment, "tight" by position matched thousands of ordinary moments: Matt's worry exactly. What made his scenario his was the trouble Mario was in. New gate `trouble` on a setup: fire only when his planner's best score last decision was below that (struggling, as in the death). `matt_bank.py` with `TROUBLE=` env. Rerun queued after the danger check (`mc`, first 14800000, TROUBLE 0).

**Danger table, second check (first 14700000, against `dh00` 98.79%):** `dh300` 98.68% (39 / 50), `dh600` 98.69% (50 / 62). With the first check (34 / 30, 21 / 20) it's a wash: **rejected.** The table spots trouble but adds nothing his planner doesn't already avoid. Bank rerun with the `trouble` gate (`mc`) running.

**Scenario bank with the `trouble` gate (`mc`, first 14800000; only when his planner's best score was below 0): still rejected.** `mc00` 98.78% → `mc01` 97.31% (7 / 151). Firing fell from thousands of games to 28-118 each, but every rule still lost where it fired: m5 5 / 69, m2 1 / 40, m1 0 / 20, m3 2 / 22, m4 1 / 9. Second check stopped (decisive). Matt's fixes, as these rules describe them, don't carry to other games: "the same picture" by position + struggling isn't his scenario. Next for his reviews: ask him what he looks at (the cue), rather than copying the position.

**#2, the hammer in the planner (Matt, 2026-11-14: "You can start building #2"; learnt from the game, not taught).** From the ROM (`native/experiments/rom/dkong.asm`) and frame logs (`HAMLOG`, agent.lua):
- Hit test (0x2913): boxes overlap if |dx| < w1 + w2 and |dy| + 1 < h1 + h2. Mario (4, 7) [the planner's existing check is exactly this], barrels (2, 2), hammer up (6, 3) at Mario's x, y - 16; down (5, 6) at x + 16 x facing, his y. So a rolling barrel is smashed at 10-22 px in front with it down, or right over his head with it up.
- Each frame (0x19B3): Mario's own hit test first (a barrel touching him kills him), then the hammer's; only the first barrel in the box is smashed, then everything (Mario, barrels, the counter) freezes about 73 frames.
- Swing: 0x6394 counts up each frame he holds it; down when bit 3 of (counter - 1) is set (716 / 716 frames). It ends when 0x6395 reaches 2: 512 counter frames, which is why it seemed to last 800-1,000 (the smash pauses).
- The grab: checked once a jump, at its 19th frame (0x1C13); Mario's (4, 8) box against the hammer's (3, 9) at (36, 100): x 30-42 at that frame. A straight grab jump is otherwise normal (lands at 42); 4 frames after landing the counter starts at 1; until then the hammer is held up.
- The hammer object's box before it's taken: (3, 9).
Built (`ham_plan`, native): the plan check knows the swing, his facing (from his movement), the boxes, the order, one smash a step, smashed barrels' paths gone, wilds and fireballs smashed too, and when it runs out; with the hammer he gets "step, then stand" plans (the step turns him); the hammer rules (ham_face, ham_stop, ham_ladder) and the steering rules (steer_off, steer_pull) stand aside while the planner holds it. `ham_grab {x from, x to, bonus}`: a straight jump over the hammer takes it (modelled); any other jump that would be over it at frame 19 isn't planned; the route goes right to the edge (not a ladder: no climb, no standoff). `ham_hold[3]`: head for the far ladder once less than that much hammer is left (Matt: a fireball below is a threat when it runs out).
30-game checks (games 14900000-29): scripted grab + old hold rules 21; + planned hold 23; planned grab + hold 22 (after fixing: the edge treated as a ladder, the standoff, the grab box). Fresh 1,000-game comparison `tp00` (no hammer) / `tp01` (scripted) / `tp02` (planned), first 14950000.

**The all-knowing mode (Matt, 2026-11-14: "think if there are any other identifiers ... that a human could not"; a record of its own, beside the human-limited one).**
- The barrels' ladder rule (0x2186): before the oil is lit, always; otherwise only with Mario below the ladder; then (0x6018 & 3) < difficulty / 2 + 1, then down if Mario is at the ladder's x or the stick points towards it, else 1 in 4 ((0x6018 & 0x18) == 0).
- The random number can't be predicted on its own: each frame 0x6018 += 0x601A (frame counter) + 0x6019, and 0x6019 is counted up in the idle loop while the CPU waits for the next frame (0x02CD), so it depends on how busy each frame was. Tested with the new `peek` (runner, a copy of the machine run ahead): a peek equals real play frame for frame (147 / 147), but a different press reshuffles the random number from the next frame (1-3 frames in 146 alike).
- So the dice can only be known for a given press list. Look-ahead built as a search in the runner (`dkh.cpp`, SEARCH=1): he always holds a press list a copy of the game has played out and survived, up to 120 frames ahead, as a chain of short moves (walk his route's way, stopping at the ladder; stand; climb; jumps played to landing); each frame it's grown from its end, a dying move is replaced by the next, and with none left the move before is undone (depth first, never anything already pressed). Moves along his route first.
- Bugs on the way: the first Lua version (`LOOKAHEAD`, plans checked a few at a time) either stood still (90-frame checks: a walk through a train never checked out) or jumped into traps (50 frames: landings beyond the check); jumps given no length; the stick left at the copy's last press; each move ending one hook late (the press before ran a frame too long at every join: plans drifted from the real game).
- First results: 3 / 3, then 30 / 30 (games 14970000-29; his own play 29 / 30), at normal game length, about 2,000-3,000 emulated frames a game. 10,000 fresh games `sx01` (first 14200000) against `pu10` (98.65%).

**All-knowing mode result: `sx01` 10,000 / 10,000 cleared, 100.00% (fireballs included)** against `pu10` 98.65% / 97.15% on the same games (133 saved, 0 lost). Every game a real clear (mode 0x16, top floor 6, timer at least 59 left); games shorter than his own (mean 1,466 frames against 1,769); only the first frame of each game unchecked; the search never ran out of options (`search_dead` 0); about 1,000 emulated frames a game. Checked: 40 random games' recorded inputs replayed in a fresh game with no look-ahead (MODE=replay): 40 / 40 clear. So with the dice known for each press list, 5-1's barrel board has no unavoidable deaths.

**Taking over his deaths (all 285 of `pu10`'s, MODE=scenario + SEARCH, the search starting afresh at the takeover):** 2 s before: 285 / 285 cleared (fireballs too); 1 s: 281 / 285; ½ s: 159 / 285 (barrels 74 / 114, fireballs 66 / 152, wilds 16 / 16). So everything he dies to was escapable 2 s out; within ½ s a third of the barrel deaths are already sealed. Video `runs/sx01/knowing_the_dice.mp4` (`tools/pair_video.py`): 4 deaths, each then taken over 2 s before. Other levels running: `sx21`, `sx31`, `sx41`, `sx11` (first 15000000).

**Oracle review tools (`tools/oracle_review.py`, Matt: use the all-knowing mode's knowledge to make the human-limited player better).** `seal` (latest takeover the search still clears from), `predict` (his planner's prediction for the barrel that killed him at that moment, against where it went), `robust` (each standard move at the sealing moment, played by the human-limited player with new dice). Reshuffling the dice: presses that change nothing on screen (down / up taps on quiet frames, presses in mid-air) don't change 0x6018 at all (0 of 71 tried): the dice follow what the game processes. So `DICE=1` sets 0x6018 to a new value at the takeover instead (the board exactly the same; checked). Queued after the level runs. All-knowing mode so far: 2-1 (`sx21`) and 3-1 (`sx31`) 10,000 / 10,000; 4-1 (`sx41`) 100% so far.

**All-knowing mode on every barrel level (first 15000000):** 2-1 `sx21` 10,000 / 10,000; 3-1 `sx31` 10,000 / 10,000; 4-1 `sx41` 10,000 / 10,000; 1-1 `sx11` 1,388 / 1,388 (stopped there, Matt: assume 100%). 100% everywhere, fireballs included.

**Oracle review of `pu10`'s 285 deaths (`runs/pu10/oracle_review/`, `runs/pu10/oracle_*.txt`).**
- Sealing point (the latest takeover the all-knowing mode still clears from): all 285 escapable 100 frames out; then 284 at 80, 283 at 65, 269 at 50, 233 at 40, 159 at 30, 141 at 20, 97 at 12. So most deaths are decided in the last 0.2-0.8 s, not 1-2 s as I first said.
- The barrel that killed him (130 barrel deaths), at the sealing moment: rolled as his planner predicted 78 (a choice, not a prediction); came down a ladder he hadn't foreseen at all 28; came down a ladder he had as a "maybe" 14; wild 10.
- Robust human answers at the sealing moment (60 standard moves, his own play, 6 new dice each): his own play clears 226 / 780; 55 of 130 deaths have a move that clears 6 / 6 with new dice. Confirmed with 20 fresh dice each: his own play 268 / 1100, those moves 1035 / 1100; 49 hold at 85%+. The commonest answers are tiny: step left 4 frames (14), step right 4 (7), jump left now (6), jump straight now (4).
- Next: why his planner turned those moves down (why_plan at the sealing moments), and why 28 ladder barrels weren't predicted at all.

**What his planner made of the confirmed answers (`tools/oracle_why.py pu10`, PLANDBG: the death game replayed exactly, every plan he weighed printed):** of 49: predicted it would be hit 23 (15 of them 10-20 frames after a short step: his plans can only "step, then carry on walking", and the carrying on walks into the barrel); no plans weighed (a rule or shortcut decided) 10; thought it safe but preferred another 9; safe but risky 7. New plan shapes: `stand_plans` (step, then stand) and `step_pause = {4, 8}` (step a few frames, stand, then jump at w1; native `step` argument). On the 130 barrel deaths' moments (at and 20 frames before the sealing point, 10 new dice each): as now 945 / 2600; stand_plans 951; step_pause 945; both 994. Fresh paired test `sp00` (as now) / `sp01` (both), first 15100000.

**Prediction check, corrected:** the first `predict` result was wrong: PREDLOG logged on `f % 8 == 0`, and his decisions don't come every frame, so once they fell on odd frames nothing more was logged (in 14200071 it stopped at frame 840 of 1224). Fixed (every 8 frames or more since the last). Of 130 barrel deaths, the killer at the sealing moment: rolled as predicted 56 (a choice, not a prediction); came down a ladder he had as a "maybe" 31; no fresh prediction because he was already in the air (13 of the 20 on the 4th girder, jumping: the deciding jump started earlier) 20; wild 16; came down a ladder he never gave a ladder path 6 (all walking on the 5th girder). So wrong predictions are a minority: his choices, and how he weighs "maybe" ladder barrels, matter most.

**New plan shapes rejected.** `sp00` (as now) 98.60% (matches `pu10` 98.65%: today's code changes leave his play as it was) → `sp01` (stand_plans + step_pause everywhere) 97.92% (116 / 177; jumping barrel deaths 81 → 153). As a last resort only (`extra_last`: a second pass when nothing is safe), on the death moments: 936 / 2600 against 945. The gain at the death moments came from taking those moves when other safe plans existed, which is what hurts in ordinary play.

**`risk_odds` (the oracle review: 31 of 130 barrel deaths were ladder barrels he had as a "maybe"):** 0x6380 (difficulty) is 5 throughout 5-1, so by the ROM's rule a barrel above him at a ladder comes down 3 in 4 with his stick at the ladder (or him at its x) and 3 in 16 otherwise (or never with him not below it). His planner charged the same w_risk for every "might". Now (native: each step's press kept; the "might" path's ladder x; risk_p = the likeliest undodgeable "might") the penalty is w_risk × p / 0.75. Test `ro01` against `sp00` (98.60%), first 15100000.

**`risk_odds` rejected: neutral.** `ro01` 98.60% against `sp00` 98.60% (16 / 16; jumping deaths 81 / 81): even a quarter of w_risk outweighs the rest of a plan's score, so his choices hardly change.

**A test set of tight ordinary moments (`tools/tight_set.py`):** 1,500 moments from `fl01` where his planner's best score was below 0 or it had no safe plan (on a girder, at most one a game per 120 frames, cleared and lost games alike); from each he plays on with 4 new dice (DICE). For tuning his settings on hundreds of tight spots, not just deaths; anything promising then confirmed on fresh games.

**Tuning on the tight-moments set (baseline 5,807 / 6,000):** w_risk 250: 5,807; 1,000: 5,808; min_clear 3: 5,811; 5: 5,733. Stopped there (Matt: a dead end): his settings sit at their best; more needs new information or new moves, not retuning. Estimate of what's left for a human-limited 5-1 player from the oracle review: 49 of 130 barrel deaths had a dice-proof answer at the last escapable moment, so at most about a third fewer barrel deaths from there (about 98.7% to 99.1%).

**3-1 and 4-1: 5-1's general settings (Matt: "see if you get any improvement on those").** 3-1 `lv30` 95.16% → `lv31` (fine_waits, press_lag 1, face_known, w_with 30) **95.83%** (458 / 392; barrel deaths 220 → 161). 4-1 `lv40` 95.13% → `lv41` (fine_waits, face_known, w_with 30; it already has press_lag) 94.55% (454 / 512; 5th-girder deaths 166 → 275). Split: `lv32` 3-1 press_lag alone; 4-1 each of the three alone.

**Split:** 3-1 `lv32` press_lag alone **95.73%** (349 / 293) (the bundle 95.83%). 4-1 alone: fine_waits `lv42` 94.20% (450 / 543; 5th girder 166 → 299: the culprit), face_known `lv43` 95.15% (5 / 3), w_with 30 `lv44` 95.22% (29 / 20). Second checks (first 15400000 / 15500000): 3-1 `lw30` / `lw32` / `lw31`; 4-1 `lw40` / `lw44`.

**Second checks and adopted (2026-11-15).** 3-1 (first 15400000): `lw30` 95.23% → `lw32` press_lag alone 95.40% (348 / 335) → `lw31` the bundle **95.90%** (449 / 384). The bundle twice +0.67: **adopted on 3-1** (press_lag 1, fine_waits, face_known, w_with 30). 4-1 (first 15500000): `lw40` 95.56% → `lw44` w_with 30 **95.76%** (32 / 12; first check 29 / 20): **adopted on 4-1**. FINDINGS.md, README.md and memory updated. Next (Matt): learn the 1-2 rivets from his TwinGalaxies game; human-limited, no fireball jumps unless life or death; fireballs spawn opposite Mario; the "star pattern".

## Native runner (dkx), November 2026

At Matt's suggestion, games can now run on `dkx`, his MAME-0.264-exact Donkey Kong emulator (github.com/matttecchio/DK-x86-AI, built in `~/dkx-build`), instead of MAME. 2-1 work was paused while this was set up, so speed figures are clean. The player's logic is unchanged: Matt asked that how he evaluates and decides stays exactly as it is. The test for every step is that games play out identically, input for input.

- `native/dkh` runs this project's own Lua scripts (`agent.lua`, `mkstart.lua`) on dkx, providing the bit of MAME's Lua API they use, with MAME's frame-hook timing. It uses MAME's own Lua 5.4.4. Starts are rebuilt in dkx's format in `native/starts` (all 128 in 7 seconds).
- `native/plan.cpp`: the planner's plan check and hazard table (`try_plan`, `fill_hz`), compiled. The same logic line for line and the same arithmetic in the same order, built with `-ffp-contract=off` so results are bit-identical. `policy.lua` uses it only under dkh; MAME runs the Lua as before.
- `native/check.py REF FIRST GAMES LEVEL` plays games on dkh and compares every game with a MAME batch.
- `run_batch.py --native` runs a batch on dkh. Website boards still work: they come from the position files the player writes, not from the screen. The live stream view (`LIVE`) and videos stay on MAME.

| All 8 cores | Frames per second | Against MAME |
|---|---|---|
| MAME with the player (the `fh3` exam) | 6,644 | 1x |
| dkx with the Lua player unchanged | 7,640 | 1.15x |
| + compiled plan check | 25,894 | 3.9x |
| + compiled hazard table | 31,872 | **4.8x** |
| + compiled barrel-roll prediction | 33,593 | **5.1x** |
| dkx alone, no player | 55,803 | (ceiling) |

Every step: 400 2-1 games (against `fh3`) and 400 1-1 games (against `rg8`) identical in outcome, frame count, score, positions and every input. Full check: the 2-1 exam `fh3` rerun natively (`fn1`, with website boards on) gave 3,000 of 3,000 identical games, in 160 s against MAME's 764 s; 1-1 in MAME after the change (`rg9`): played differently 0. What's left in Lua is spread thin (wild-barrel bounces, ladder checks, deciding), each a few percent, so speed work stopped at 5.1x.

**Back-jump tuning, native runner, against `eo1` (97.60%):** `with_cl=3` (`ep1`) 97.40%, 1 / 5; `w_with=40` (`eq1`) identical; `w_with=90` (`eq2`) 97.44%, 0 / 3; `with_x=12` (`eq3`) 97.40%, 1 / 5; `with_x=20` (`eq4`) 97.24%, 2 / 9. The adopted settings (60, 16, 2) stay.

**Retries on the improved base (native, against `eo1` 97.60%):** keeps climbing, `ladder_real` (`er1`) 97.09%, 2 / 12; **keeps a planned move going when the ladder above is 40+ px away, `steer_far=40` (`er2`) 97.74%, 3 / 0**, floor 5 x=150 3 to 1; `steer_calm` (`er3`) 97.09%, 5 / 15; `w_sideways5=-20` (`er4`) 96.64%, 5 / 24. `steer_far` was 3 / 3 on the older base, so it took the back jump and risk changes for it to help.

**Fresh check of `steer_far=40` (`fh4`, first 3600000):** 96.52% against `fh3` 96.59%, 2 saved / 5 lost, floor 5 x=100 up by 3. **Not adopted.** The 3-game gain on the practice games didn't carry over. `steer_far=30` and `=50` (`es1`, `es2`) both gave 97.74% there.

**Matt's pro review of 10 deaths around ladder 91 (`fh3`, `runs/fh3/review91.txt`), November 2026.** How he plays it: stand just left of the ladder foot on the 4th girder, steer barrels down ladders from there to set up a safe situation, climb when it's safe, and keep watching Kong. If Kong goes to release a wild barrel, change plan. From 5-1 that spot is safe from wild barrels, and mostly on level 4. Per death:

1. (3600669) As he got on the ladder Kong threw a wild and a barrel was rolling at him: go back down and straight-jump both, or avoid one and jump the barrel.
2. (3600290) Climbed at a bad time given the close barrel and the one Kong just let go: stand a bit further left, straight-jump the rolling barrel, wait for the new one above to pass the ladder top.
3. (3600537) Hesitated and died on the climb: should have gone up.
4. (3601052) Fair death.
5. (3600286) Didn't go all the way up, backtracked and got stuck. Track the whole setup (Kong's new barrel, the ones to his right, the one under/left of him) to recognise this play.
6. (3600811) Fair death. Maybe run right; the wild would probably have got him anyway.
7. (3600302) Too much coming to climb safely. Steering the top-right barrels down the broken ladder earlier would have helped. Steer while not on the ladder, but steering works on ladders too.
8. (3602808) Odd jump towards the broken ladder, then too slow to back-jump. Kong didn't release a wild, so why not straight-jump the first barrel? Grind it out.
9. (3601285) Forward jump that was 100% death; back jump, or maybe a tight straight jump. Grind it out.
10. (3600532) Third jump too late. Reactions to a 2nd, 3rd or 4th barrel are too slow: a human sees them lined up. Try faster straight jumps, or back-jump one to make room for the next.

Steering: Matt would let him steer anywhere it helps, in either direction.

**Sweep of 14 settings tuned for 1-1 and never for 2-1 (native, against `eo1` 97.60%), `et01` to `et14`:** `standoff` 7 / 14, `min_clear` 3 / 5, `clear_cap` 4 / 8, `w_prog` 25 / 60, `w_jump` 5 / 30, `plan_tail` 14 / 28, `w_later` 0.2 / 0.9. Twelve were worse, some badly (`plan_tail=28` 89.92%, `w_later=0.9` 87.81%). `w_jump=30` 97.79% (16 / 12) and `min_clear=3` 97.74% (24 / 22) are within noise. Nothing adopted: the existing settings are already near their best. More gains need new abilities (climb timing, deliberate steering, faster follow-up jumps), not knob turning.

**Watching Kong (Matt's death 8), against `eo1` 97.60%:** `kong_pose` alone (`eu1`) 96.54%, 8 / 29; with the expected broken-ladder barrel timed from his pose (`eu2`, `eu3`) 95.89%, 8 / 42. Rejected. The new deaths are at floor 5 x=105 to 125 (14 to 16 of them). In the lost games (3001908, 3001046, 3001052, 3001828) he jumps right just off the ladder top (score +64), lands at x=111 beside the foot of the broken ladder, and Kong's new barrel comes straight down onto him. Cause: his model treats a barrel coming down a ladder as only a possible risk, checked against a 3 px margin, so a barrel dropping right beside where he'll stand barely registers. Changing the timing of the imagined throw only moves him into it. Fourth time accurate Kong timing has made things worse (`kong_fix`, `throw_every`, `next_drop`, `kong_pose`). The fault is in how a barrel dropping down the broken ladder is weighed, not in the timing.

**Plan agreed with Matt:** 2-2's barrel board is the same board, so once 2-1 is dependably 97%+, move on to 3-1. Because fresh sets differ by about a point, 97% is judged on a 10,000-game fresh exam (`fx1`, first 4000000).

## How to run it

```sh
python3 tools/make_starts.py --level 2                     # build a level's starts (one time)
python3 tools/run_batch.py NAME --level 2 --games 3000 --first 2000000 --note "..."
python3 tools/autopsy.py NAME                              # goes through every death
python3 tools/regress_1_1.py NAME                          # checks 1-1 hasn't got worse
python3 tools/compare.py BASE OTHER...                      # rates, causes, saved/lost on the same games
```

## Rivets, 1-2 (from 2026-11-15)

### Summary (kept up to date; the dated log follows)

**Where it stands (2026-11-21):** ~87.2% of 1-2 boards cleared (`hp1` 8,722 / 10,000 at first 60000, current defaults). Earlier: `cv2` 8,666, `cvf` 8,690 (2026-11-19). Handover: RIVETS_HANDOFF.md. Reference runs with the current defaults: `cv2` (60000-69999), `cvf` (70000-79999). From 0% on 2026-11-15.

**What's switched on for 1-2 (`lua/params.lua`, `riv_*`):**

| Setting | What it does |
|---|---|
| (always) | the star order and Matt's crossing directions; both hammers; gap jumps in routes (cost 120); the maze (fireballs can't cross gaps); fireball headings; Kong as a wall; stale crossing direction forgotten |
| `riv_reach` 4, `riv_h` 36 | worst-case check: fireball allowance 4 px, 36 frames ahead |
| `riv_jump_hold` | every jump held 3 frames; a missed one is noticed |
| `riv_safe_w` 1 | the whole-board safety map in every choice |
| `riv_ladder_busy`, `riv_ladder_commit` 8 | never walk to a ladder a fireball is on; no hesitating on ladders |
| `riv_free_zone` 40, `riv_free_where` | free pass up the right (skip the middle hammer) when the right is clear and he's on the right |
| `riv_mc` 1, `riv_right` {reach = 3} | imagined futures as a tie-break; tighter allowance after the left sweep |
| `riv_lod_dy` 4 | life-or-death jump only for a fireball at his girder's height |
| `riv_plan2` 0.1 | two-step plans by the imagined futures when stuck or in danger |
| `riv_choice_mc` 0.1, `riv_choice_via` "mid" | middle hammer or the rivets (also via girder 3's middle), by playing the routes forward |
| `riv_down_mc` 0.15 | after 3R, down the right ladder or back over 3R's gap and down the middle, by playing both forward |
| `riv_skip_ham` 100 | (Matt) skip the middle hammer when nothing is up on the right |

The imagined futures (`native/rivsim.cpp`): fireballs moved by the measured odds (speeds by difficulty, 16% up a ladder, down 22% only with Mario below, 12% turning per 8 frames, never across gaps), calibrated against his logs.

**Matt's rules for the rivets:** human-limited (don't know what the fireballs will do); no fireball jumps unless it's life or death; the goal is clearing, not points (no leeching); the star pattern; finish well before the timer; it's fine for him to know the 2nd and 4th fireballs freeze and for how long; every test on the website; tests at 10,000 games.

**Tried and rejected:** see FINDINGS.md, "The rivet board, 1-2", "What didn't help".

**Running (2026-11-19 overnight):** the freezes (`riv_freeze`, `riv_freeze_short`), the approach to the last rivets (`riv_last_mc`), a fresh check of any winner (`xf9`), a 30,000-game headline (`hd8`).


Matt: learn the 1-2 rivet board; human-limited (not allowed to know what the fireballs will do); no fireball jumps unless life or death; baseline his TwinGalaxies game (`videos/tg/tg.mp4`, board at 238.5-353.7 s). His tips: fireballs spawn on the opposite side from Mario; most players use a "star pattern".

- **Starts:** `native/starts/r1_000`-`063` (SAVE_NEXT in agent.lua: 1-1 played by the search, saved the moment the next board's play begins; board 0x6227 = 4). Mario starts at (63, 240). The runner holds one save or load at a time, so the next game starts a frame after a save.
- **Layout** (video RAM tiles, 8 px; the tile map is mirrored: game x = (31 - column) × 8 + 3): girders at Mario y 240 (bottom), 200, 160, 120, 80, 40 (top). Ladders up from the bottom 27, 123, 227; from 200: 35, 91, 163, 219; from 160: 43, 123, 211; from 120: 51, 83, 171, 203; two short ones from 80 to the top. The ROM's ladder check rounds Mario's x to his tile column ((x | 3) & ~4), so a ladder can be grabbed anywhere across its 8 px. Rivets at x 72-79 and 176-183 on girders 200, 160, 120, 80.
- **Rivets in RAM:** 0x6290 = rivets left (8 → 7 on the first); one flag each (the 2nd girder's left one is 0x6298, 1 → 0).
- **First fireball:** about 3 s in, on the right (x 211) while Mario starts on the left.
- **Matt's order in his game** (the video, rivet spots checked at 10 fps): 2R 10.6 s, 2L 14.0 s, 4L 20.7 s, 5L 27.9 s, 3L 42.7 s, 3R 50.0 s, 4R 58.8 s, then about a minute at the top right before 5R at 115.2 s.
- **The star pattern** (Matt: 2R-first is only for the slower early rivet levels; look at the later ones; an alternative pattern when a fireball blocks the left side shows as the top hammer taken at a different time, for later). All 22 rivet boards in his game (`videos/tg/rivet_orders.json`): from the second board on, **2L, 4L, 5L, 3L, 3R, 2R, 4R, 5R** in 15 of 21; 5L before 4L in 2; 5R before 4R in 1; 2R before 3L in 1 (board 44, maybe the alternative); 2R last in 1; the second board (and the third) 2L, 4L, 5L, 3L, 3R, 2R then the right side. Typical times: 2L 7.5 s, 4L 13.5, 5L 15.5, 3L 22, 3R 29, 2R 34; 4R and 5R after a wait of 15-60 s (hammer / points?).
- **The wait before the last rivets** is points leeching off Kong (Matt: faster than the timer, plus a few after it runs out). Not needed: the goal is to clear the board.
- **First rivet player (`lua/rivets.lua`, used by agent.lua when 0x6227 = 4; the website shows rivet boards too: `web/bg_rivets.png` from Matt's video, pulled rivets blanked from each game's tile map).** Star order; route search over girder sections (a rivet he isn't after is a wall, a pulled one a gap); options each frame (go, wait, back off, escape up / down a ladder; on a ladder: on, back, hold) played 48 frames ahead against each fireball's reach from where he last saw it; a jump only with contact within 4 frames. Fixes on the way: the projected walk not stopping at its waypoint (he froze 30 s), aiming at the rivet's middle (it only comes out when crossed), the gap check's margin, a greedy route that pulled 3L early and trapped him, dithering inside the rivet's column, fireball vertical reach on girders.
- **Fireball speeds** (64 games, 16-frame runs; Matt: they move faster some ways than others): right median 0.50 / 90% 0.62 px a frame, left 0.38 / 0.50, down a ladder 0.50 / 0.62, up 0.19 / 0.31; towards or away from Mario makes no difference. Over 40 frames along a girder 99% move under 25 px. **Matt:** a fireball on Mario's level never goes down to the level below; they only go down if he's below them.
- So far (games r1_000-063): no clears; rivets pulled before dying: 4 in 33 of 64, 5-7 in 21.
- **CHAIN (agent.lua):** a barrel-board clear carries on into the next board as the same game (one input record from the 1-1 start; the board between waited out with no input; the search only on board 1), so rivet games replay in MAME from the ordinary 1-1 starts and death_video works. `rv01` (64 games, `CHAIN=1 SEARCH=1`, level 1, first 0): no clears; rivets pulled before dying: 4 in 30, 5-7 in 22, 1-3 in 12. Video of 8 deaths for Matt: `runs/rv01/rivet_deaths.mp4` (its captions' "floor" is the barrel numbering).
- **Hammers (Matt: "use the hammer in the middle to hit things while on the right half, so the fireballs respawn on the left and hopefully get trapped because they can't pass the rivets that were removed"; "the bottom hammer is usually used to transition left to right on the third girder, and to clean up some fireballs if lucky").** Hammers on this board: bottom (27, 140; 0x6680), taken with a straight jump from the 3rd girder's left end (he can walk to x 27 there, measured); middle (124, 100; 0x6690), from the 4th girder at x 119-129. Order now 2L, 4L, 5L, bottom hammer, 3L, 3R, 2R, middle hammer, 4R, 5R. Holding a hammer: no climbing; fireballs in front of him on his girder count as smashable. On r1_000-063: middle hammer only 2 / 64 cleared; with the bottom hammer too **14 / 64** (rivets pulled before dying: 3 in 14, 5-7 in 33; only 2 stop at 4 now).
- **Rivet starts made by the game itself:** `lua/mkstart.lua` takes BOARD (4: carry on to that level's rivet board the same way it reaches later levels) and `tools/make_starts.py --board 4` makes `r1_000`-`063` in MAME; the same script on dkh makes the native ones (replacing the SAVE_NEXT ones), so the two match: native games replay identically in MAME (3 / 3: outcome, frame, score). `run_batch.py --board 4` and `stats.use_starts` use them. `rv03` (512 chained games from 1-1): **103 cleared (20.1%)**.
- **Website:** `web/bg_rivets.png` now from MAME (each pixel's most common colour over ~750 frames of a replayed game, with the item table 0x6A0C-0x6A1F emptied each frame), no video holes; `web/bg_rivets_items.png` a frame with the items, from which the page draws each item while it's there. Items (0x6A0C, 4 bytes: x, picture, colour, y): hat (219, 200), handbag (147, 240), umbrella (51, 80): picked up = x goes to 0; the two hammers follow Mario once taken, so they're shown from 0x6680 / 0x6690 (on the stand, not held). (Matt: make the prizes disappear once picked up.) The page's null-board crash (every board black) fixed.
- **Rivet player choices on the 64 starts:** middle hammer always 14 / 64, skipped when the upper right is clear (Matt's rule, now on: `riv_skip_ham = 100`) 15 / 64, no hammers 0 / 64.
- **`rv10` (1,000 games on the board): 197 cleared (19.7%)**; stalls: 3 rivets pulled 227, 5-7 pulled 520. The 3-rivet deaths: a long detour to the bottom hammer (after 5L he was in the middle sections, 3L a wall). Walking into a pulled rivet's gap is fatal (tested: he falls through). Matt's board 50, frame by frame: 5L pulled walking left, down the left ladders to the bottom hammer, then right with it along the 3rd girder through 3L (the gap opens behind him) to 3R. So the left side is one sweep with set crossing directions (`CROSS`): 2L left, 4L right, 5L left, 3L right, 3R right. On 256 games: **91 cleared (35.5%)**; 3-rivet stalls 4 (from ~23%).
- **`rv11` (1,000 games): 346 cleared (34.6%)** with the crossing directions; rivets pulled before dying: 5-7 in 633 (the right side), 3 in 14. Next (Matt: "you can jump over removed rivets"): gap jumps in the route search (from 6 px short, a sideways jump carries 21 px; only with flight and landing clear of fireball reach; never with a hammer), test `rv12`.
- **Website hung** (Matt: "the live board page won't load"): `/api/batches` re-read every finished batch after each server restart (800+ folders, 13 GB), minutes with a batch running. Now finished batches' summaries are kept in `runs/.batch_summaries.json`, filled by a start-up thread; the page's request never waits (all endpoints under 0.3 s).
- **`rv12` (gap jumps): 353 cleared (35.3%)** against `rv11` 346 (4 saved / 1 lost where it differed; falls 68 to 40). Kept. (`compare.py`'s headline leaves fireball deaths out, nearly all the rivet deaths: read its "allfire" figure for rivets.) Video of 10 right-side deaths for Matt: `runs/rv12/right_side_deaths.mp4`.
- **`rv13` (1,000 fresh games, everything so far): 387 cleared (38.7%)**; rivets pulled before dying: 5-7 in 583, 3 in 22. Website: the held hammer drawn where the game has it (0x6680 / 0x6690 when held; down = at his height), with the game's own picture, turned when it's down. Waiting on Matt's review of `runs/rv12/right_side_deaths.mp4`.

**Matt's review of 10 right-side rivet deaths (`runs/rv12/right_side_deaths.mp4`, 2026-11-15):**
1. (3148) needed to jump right over the gap to get away on the right, then move up
2. (3808) bad place to stand with the hammer: better to the left, hammer facing right and landing down over the ladder (fireballs coming down sometimes sneak through the hammer if you're right under it)
3. (3327) needed to jump over to the left (over the gap)
4. (3038) should have rushed right, taken out the rivet, jumped back left, then up and taken the last rivet
5. (3303) should have backed down the ladder, gone right, jumped over the gap and then gone back up
6. (3119) probably could have snuck up the middle, or worst case jumped left and then gone down
7. (3604) same problem as 2, same solution
8. (3362) could have gone up the ladder, grabbed the hammer, moved right and eliminated the fireball up there; the other two were in the middle section with no way over to the right so long as Mario was on their level or above, so he could eventually have gone down the right side and taken the last rivet
9. (3951) could have just gone up and taken out the top rivet!
10. (3470) why on the left with the hammer, when the right made more sense (only one rivet left there; eliminating those first improves his chances); and why up that ladder: you can't cross over Kong at the top, there was no path to the rivet
Themes: escapes over a gap (1, 3, 5, 6); where to stand with the hammer (2, 7: left of a ladder facing right, the hammer coming down over it, not under it); the right side opportunistic, not a fixed order (4, 9, 10); fireballs stuck in a section (8: they can't cross gaps and only go down when Mario is below); no way over Kong at the top (10).
- **Review changes tested (1,000 games each, same games, first 4000):** `rv13` before 387; gap escapes + dynamic right side (`rv14`, re-chosen every frame: dithering) 134; target kept (`rv15`) 314; + maze (`rv16`: a fireball's reach along a girder stops at a pulled rivet's gap, Matt: "think of this level as a maze") 326; maze + gap escapes, fixed order (`rv17`) 406; **gap escapes only (`rv18`) 414**. The dynamic choice (fireballs counted per section on the way) costs ~80: off; gap escapes and the maze kept. Matt: he should know where every fireball is and which way it's going.
- **Fireball heading (Matt: he should know where every fireball is and which way it's going).** Measured: along a girder they turn every 8 frames or so (median 4 px), but their drift over 20 frames carries on: drifted 3+ px left, still going left over the next 40 frames 80% of the time (right 77%); drifting away, they come back at most ~12 px in 40 frames (90th percentile) against ~20 heading your way. So a fireball drifting away from a spot now reaches back towards it at 0.3 px a frame. **`rv19` 450 / 1,000 (45.0%)** against `rv17` 406.
- **World-record video** (Matt: "it's the WR game and it will contain great rivet play and strats"): downloaded to the Desktop ("Donkey Kong Arcade World Record 1,272,700.mp4", 3 h 33 min, 1280x720), linked as `videos/wr/wr.mp4`; same layout as `Barrels.mp4`: game x = (video x - 338.8) / 2.45, y = video y / 2.775 (crop 627:710:339:0). Scanning it for rivet boards.
- **The WR game's 21 rivet boards** (`videos/wr/rivet_orders_wr.json`; rivet spots at 10 fps; the bottom hammer by its stand against the board's end, the top one against the board in play): every board 2L, 4L, 5L, bottom hammer (~1.3 s before 3L), 3L, 3R (5L before 4L once); then 2R on 17 of 21; the top hammer on 17 of 21 (the 4 without went straight to 4R and 5R: Matt's clear-path rule); 4R then 5R mostly, after long waits (leeching). Typical times: 2L 4.7 s, 4L 10.5, 5L 12.5, bottom hammer 17, 3L 18.5, 3R 26, 2R 32. The same order his player uses now; what's left is execution on the right side. Each rivet game now records what he was doing when it ended (`riv_why`).
- **`rv20` (1,000 fresh games, first 5000): 424 cleared (42.4%).** Deaths by what he was doing: in the air 218, climbing 192, waiting at a gap to jump it 81, walking to 5R 53. The gap jump made one of his weighed options (no waiting at the gap; judged by the full check, `rv21`): 423, the waiting deaths moved into the air. Which jumps (400 games): **jumping a fireball 75 of 111 in-air deaths**, escapes over a gap 22, the bottom hammer 6, route gap jumps 7, the middle hammer 1. So his life-or-death fireball jumps are failing; that's next.
- (Matt: "why aren't you showing anything on the webpage?" Quick tests run straight on dkh had no GRID: every test goes through run_batch.py from now on.)
- **`rv22` (1,000 fresh games, first 6000): 418 cleared (41.8%).** Deaths: in the air after jumping a fireball 191, climbing 180, after an escape over a gap 62, walking to 5R 60.
- **The life-or-death fireball jump, which way** (500 games each, the same games): towards it (over it) 186 cleared, straight up 188, **away 207** (the original; kept); none at all 186. So the jump does save games; the deaths in it are traps formed earlier (as on the barrel boards), not a bad jump.
- **Autopsies (`rv22`):** ladder deaths after 3R on the right ladders (x 200-223, 70) and up the middle ones after 2R (x 120 / 160, 71); traps on the 5th girder at x 144-159 with 6 pulled (30) and the 3rd girder's right end with 5 (20). Two traces: (1) down to the last rivet, he waited 1,000+ frames on the 5th girder beside 5R for two fireballs penned in the right section beyond it; they never leave while he's on their level. But the last rivet ends the board the moment it comes out (measured: at the rivet's middle, x 76 walking right over 72-79, 74 walking left), so `riv_last`: aim for the pull point, and judge the walk only until he gets there. (2) he hung on the right-side ladders for hundreds of frames, holding, between fireballs above and below: `riv_ladder_off`: getting off (back) beats holding when going on isn't clear. Both off until the sweep is done (the sweep runs on the live code).
- **Matt:** generally grab the bottom hammer straight away; delaying can pay off if the fireballs need to sort themselves out (not a hard rule).
- **A full trace (game 6188):** after 3R he waits at the 3rd girder's right end for the bottom hammer to run out, goes down the right ladder for 2R into fireballs penned in 2R's section, holds and backs up as one climbs after him, retreats up the right side for ~1,000 frames to the 5th girder, jumps a fireball there (pulling 5R out of order) and dies later. `riv_2r_later`: with a fireball in 2R's section or on the ladder down to it, the rest of the right side first, 2R after (the WR player took 4R before 2R on 3 of 21 boards; Matt's review #4). Queued after the sweep (all on first 7000, against `rs00` 420): `rf01` riv_last, `rf02` riv_ladder_off, `rf03` both, `rf04` riv_2r_later, `rf05` all three.
- **Rivet settings sweep (1,000 games each, the same games, first 7000; `runs/rivet_sweep.txt`):** reference `rs00` 420; fireball allowance `riv_reach` 8: 464, 12: 346; look-ahead `riv_h` 36: 467, 64: 349; away-drift 0.2 / 0.4: 410 / 409; jump distance 6 / 14: 420 / 421; top-hammer skip 60 / 160: 419 / 417; maze off: 450. He was too cautious. Combined: reach 8 + h 36: 513; **reach 6 + h 36: 531**; 8 + 28: 485; 8 + 36 + maze off: 526; 6 + 28: 512. The maze rule had a bug: a fireball across a gap never counted, though it can come right up to the gap's edge and touch him at the near edge (13 px apart): `riv_maze_edge` fixes it (off until tested). Next: reach 4, h 42 / 32, then each fix on reach 6 + h 36.
- **On reach 6 + h 36 (531):** reach 4: 567; h 42 / 32: 479 / 527; `riv_last` 542; **`riv_ladder_off` 571**; `riv_2r_later` 459 (rejected: leaving 2R for later is worse); `riv_maze_edge` 531; maze off 539. Next: reach 4 + ladder_off + last (and reach 2 / 3, h 40, + maze_edge), then a fresh second check.
- **Combined (first 7000):** reach 4 + h 36 + ladder_off + last **593**; reach 2 / 3: 534 / 564; h 40: 577; + maze_edge 593. **Second check on fresh games (first 8000): defaults `rc00` 418 → `rc01` 577 (41.8% → 57.7%).** Adopted as the rivet player's defaults: fireball allowance 4 px, look-ahead 36 frames, off the ladder rather than hanging on it, the last rivet's pull point, and the maze rule with the gap edge (neutral, but how the board works). Deaths now: in the air after jumping a fireball 115, climbing down 94, escape over a gap 56, the route's gap jump to 2R 54, climbing up 35.
- **Sweep on the new defaults (first 7000, base `rs30` 593):** fireball speeds at their medians 429, halfway 490 (the 90th percentiles are right); route gap-jump cost 120: **615**; no route gap jumps 608; away drift 0.2: 578. Next: speeds a step faster, cost 60 / 240.
- **More sweep (first 7000):** speeds x1.12 (0.7 / 0.56 / 0.7 / 0.35) 609; gap-jump cost 240 609, 60 613; cost 120 + speeds x1.12 **625**; speeds x1.3 597, x1.45 620. **Second check (first 8000): `rc02` defaults 577 → `rc03` 615.** Adopted: gap-jump cost 120, speeds 0.7 / 0.56 / 0.7 / 0.35. **1-2 rivets now 61.5% on fresh games** (from 0 this morning).
- **Time (Matt: "the time seems to run out a lot; you should finish well before 99% of the time"):** only 1 in 1,000 actually ran out (the record's "timer" is in hundreds: deaths were at 2,800-3,700). Board allowance ~100 s (bonus 5,000 down ~100 every 2 s). Clears: median 49 s, 90% 66 s. Pace per rivet (median, `rc03`, recorded now in each game as "pulled" / "ham_at") against the WR: 2L 4.5 s (4.7), 4L 9.6 (10.5), 5L 11.6 (12.5), bottom hammer 16.1 (17), 3L 17.7 (18.5), 3R 20.9 (26), 2R 30.4 (32), top hammer / 4R ~39. The left side is at WR pace; the time goes on the right (about 9 s per rivet after 3R), mostly waiting on fireballs, which is where he dies.
- **Remaining deaths (`rc03`):** after 3R climbing down towards 2R 65; jumping a fireball with 6 pulled 49, with 5 30; escapes over a gap 28 + 15 + 13; climbing up 27 + 13. A trace (game 8484): on the right ladder between the 3rd and 4th girders, a fireball wandering below and another above, he switched between down / back up / hold every 15-30 frames for ~300 frames until they closed in. `riv_sticky` (favour the move he's already making: +0.5 when all clear, S frames of margin when not): S 6: 486, 12: 483, against 615. Rejected (on this board switching quickly beats holding to a move).
- **Fresh run with everything (`rv30`, first 9000): 631 / 1,000 (63.1%).** Review video of 10 deaths (5 climbing down to 2R after 3R, 5 trapped jumping a fireball after 2R): `runs/rv30/review_deaths.mp4`, on the Desktop as `rivet_deaths_review2.mp4`.
- **The experts' rivet boards from their recordings (Matt: "add barra's rivets to your learnings"):** `tools/inp_trace.lua` takes BOARD=4 (and records the rivet count and the top hammer); `inps/barra_rivets.trace` (21 boards), `inps/player3_rivets.trace` (22); `tools/inp_rivets.py`. Both: 2L 3.7 s, 4L 9.5, 5L 11.6, bottom hammer 15.6, 3L 17.2, 3R ~25, 2R ~32, top hammer ~40 (most boards), 4R ~50 (5L before 4L on a few; barra's board 13 a different order: 2L, then the right, then the left, maybe the alternative pattern). (The script's "life lost" is wrong: the last rivet ends the board before the trace sees the count reach 0.) From 3R to 2R: down the right ladder (216-223) mostly, barra sometimes the middle (160); most of that time standing still with the bottom hammer; while holding it on the 3rd girder they stand at x 184-195 facing right ~88% of the time (Matt's tip: the hammer comes down by the ladders).
- **Hammer parking** (`riv_park`, on): holding a hammer with a climb ahead in his route, wait ~30 px short of the ladder facing it, and walk over as the hammer runs out. First version keyed to the next step only: never triggered (631). Keyed to the first climb in the route: **0 / 1,000**: he sees a few frames late, so just after pulling 3L at its middle he still thought it was there, turned back and fell through the new gap. Fix (general): inside any rivet's column he never stops or turns back. Then `rp04` 630 (neutral against 631); both kept.

**Matt's review of `runs/rv30/review_deaths.mp4` (2026-11-15):**
1. (9020) should have committed to the climb, then jumped over left, then down to take out the rivets, then back towards the middle and up
2. (9036) all the way up to the top
3. (9084) should have gone all the way down to the bottom and tried to come up the middle
4. (9364) up and left
5. (9540) a fair death
6. (9004) should have jumped back to the right over the hole he just created
7. (9316) should have jumped back left
8. (9500) should have jumped left over the gap faster
9. (9892) should have gone down
10. (9916) should have gone right after getting off the ladder, and jumped over the hole
Matt's two observations: he hesitates a lot on ladders (better off on a floor, top or bottom; he jitters up and down them); and he seems to hate jumping back over pulled rivets ("if the board is free over in that area, why wouldn't you?"). Next: `riv_ladder_commit` (on a ladder: no holding; keep the climb's direction unless the other end is clearly safer) and `riv_gap_reach` (a gap escape from up to 16 px away: walk to the edge, then jump; including back over the gap he just made).
- **Testing review 2 (same games, first 9000; base 630):** `riv_ladder_commit` 8: 630 (climbing-down deaths 71 → 51, others up), 20: 626; `riv_gap_reach` 16 (gap escapes from up to 16 px): 583, escape-jump deaths 51 → 138, all fireballs just after landing. Cause: since the sweep's look-ahead of 36 frames, a 42-frame jump's landing was never checked. Fix (on): jumps checked through 56 frames (`riv_jump_h`): `mr5` 634. Still: gap reach 16: 599; + ladder commit 592; + route gap cost 30: 581. A bigger allowance for jumps (no drift discount; `riv_jump_safe`) 8: 634, 16: 595; with gap reach 16: 589 / 549. So a reflex gap escape keeps losing. Matt: "a gap jump should be considered at any length ... he may see a fireball above him and want to go into the middle where it's safer ... he needs to be thinking about the whole board and what paths are opened up." Next: a whole-board safety map (for each section of the maze, which fireballs can reach it and how soon, by the maze rules), heading for the safest reachable section (walking, ladders, gap jumps) when his spot gets dangerous, and choosing the right side's route by it.
- **Whole-board safety map, first version (`riv_escape`, off):** each fireball's soonest arrival at any spot over the maze (its own stretch only; up ladders slowly; down only towards a spot below it; measured speeds x 1.12); when every option could meet a fireball within ESC frames, he heads (by his routes, gap jumps at any distance included) for the spot (section middles, ladder ends) with the most time to spare (margin > 20 frames), for up to 3 s. On the same games (634): ESC 24: 618, ESC 40: 611 (climbing-down deaths 71 → 58, escape-jump deaths unchanged). Not yet good enough: next, check its fireball arrival times against what fireballs really do, and look at the escapes it chooses.
- **Checking the safety map against reality** (`fx01`: Mario and every fireball every 4 frames in 400 games, `runs/fx01_fire/`; checker `tools/` scratch): two bugs, both in fireballs partway along a ladder: snapped to the nearest girder (so one climbing was sent back to the girder it left), and the "girder above" lookup took the top of the board. Fixed: fireballs beat the map's time only 0-2% of the time (from 25-40% going up). Also measured: no fireball ever crossed a pulled gap (the maze rule holds); fireballs climb up a ladder at 0.20 px/frame (median; 0.23 at the fast 10%), down at 0.53 (0.62); all new fireballs appear on the side of the board opposite Mario. Matt asked whether this applied on the barrel boards: no; the barrel player grows a box around each fireball in every direction and doesn't route them.
- Escapes with the corrected map: ESC 24: 620, 40: 612; heading for the nearest safe spot instead of the safest: ESC 24: 612, 12: 632 (634 without). Off. Instead, the map's safety of where each move leaves him, in every decision (`riv_safe_w`): **1: 648** (634 without), 3: 140, 6: 24 (he stops moving).
- Matt (live board): he stood left of 2R "just kinda chilling instead of crossing over to remove the rivet and then having him jump back. He might be a little too cautious here." `riv_pullback`: a move across the rivet, pulling it, a step onto the far side, and straight back over the new gap (checked like any move: the walk, the jump, the landing).
- Matt: "he seems to be struggling to cover the third girder with the hammer." Measured (`sw1`): from the bottom hammer to 3R he's quick (3R at 20.9 s median; experts ~25) and loses ~1% there; the slow, deadly part is after 3R, 9.4 s to 2R (experts ~7; slowest 10% over 20 s). Trace (game 9001): ~3.5 s standing still with the hammer at x 188 while a fireball climbed the 160 ladder 25 px away and two sat on girder 2 by the 216 ladder's foot; then down that ladder when the hammer ran out (the "climb on down" deaths). `riv_hunt` (off until tested): holding a hammer, the nearest fireball he can reach in time on his stretch of girder: go and smash it; one climbing a ladder up to it (and due at the top, at the measured 0.20 px/frame, while he still has the hammer): stand ~10 px beside the ladder top facing it. Tests `hu1`, `hu2` (+ `riv_safe_w` 1).
- Matt: "it makes sense to smash on the right side if possible, so the fireballs reappear on the left." `riv_hunt_right` 60: a hunt with him on the left half counts as 60 frames further away. Test `hu3`.
- Matt (live): "I still see him hesitating near rivets he could pull out and then jump back over." Checked `riv_pullback` before its test: it never fired (6 games). Options at those moments: it rated the same as walking straight through, because (1) it still let fireballs beyond the rivet walk through it after he'd pulled it, and (2) it took him 6 px onto the far side before jumping back (a forward gap jump's take-off). Fixed: after the pull point the rivet walls off fireballs beyond it, and he jumps back from where a crossing stops (3 px on). Now it fires (game 9001: pulls 2R and jumps back instead of waiting). Test `pb1` uses the fix.
- **Results (same games, base `mr5` 634):** `sw5` safe_w 0.5: 624; `pb1` pull-and-jump-back: 622; `pb2` + safe_w 1: 627; **`hu1` hammer hunting: 652; `hu3` hunting + right-side preference: 657**; `hu2` hunting + safe_w 1: 623. So `riv_safe_w`'s 648 (`sw1`) doesn't combine with anything; off. Fresh check of `hu3` against no change: `fq0` / `fq1` (first 12000).
- **A big bug: jumps pressed for one frame, often missed by the game.** `pb1` lost 37 / saved 25, the losses mostly jumping back over 2R; trace (9172): he pressed jump at x 174 and stayed on the girder, frozen for the jump's 46 frames, and a fireball walked into him. In `mr5`, of 198 deaths "in the air", **129 were standing on the girder** (87 "escape over the gap", 35 "jumping a fireball"): so the gap escapes and fireball jumps looked worse than they are. The barrel player holds jump 3 frames. `riv_jump_hold`: hold 3 frames, and if he's still on the girder 6 frames after the press, decide again. Games 9004 and 9172 (both lost) now clear. Tests `jh1` (alone), `jh2` (+ pullback), `jh3` (+ hunting); then retest the gap-escape and jump ideas that lost before.
- **Fresh check of hunting (first 12000):** `fq0` no change 643, `fq1` hunting + right-side 647 (+4). Game by game: saved 129 / lost 125 fresh (141 / 118 on the first set). About 250 of 1,000 games change outcome with any change (the fireballs' paths follow from his moves), so a difference under ~30 between two runs is within luck. Hunting: not proven; not adopted yet; tested again on top of the jump fix (`jh3`).
- **Jump fix results (same games, base `mr5` 634): `jh1` jumps held 3 frames: 703** (saved 187 / lost 118; standing "in the air" deaths 129 → 7). `jh2` + pull-and-jump-back: 689; `jh3` + hunting: 699. Fresh check `fj1` (first 12000; against `fq0` 643); then the ideas that needed jumps, retested with it on the first set: gap reach 16 (`jg1`), safe_w 1 (`jg2`), ladder commit 8 (`jg3`), nearest-safe escape 12 (`jg4`), route gap-jump cost 60 (`jg5`).
- **Jump fix confirmed fresh: `fj1` 681 vs `fq0` 643 (saved 158 / lost 120). `riv_jump_hold` now on by default.** Retests with it (first set, against `jh1` 703): **safe_w 1 (`jg2`): 755** (saved 174 / lost 122); gap reach 16 (`jg1`): 724 (78 / 57); ladder commit 8: 691; nearest-safe escape 12: 698; route gap cost 60: 704. Next: fresh check of safe_w 1 (`fs1`), safe_w 1 + gap reach 16 (`js1`, fresh `fs2`), safe_w 0.7 / 1.5 (`js2`, `js3`).
- **Safety map confirmed fresh: `fs1` 726 vs `fj1` 681 (saved 173 / lost 128). `riv_safe_w` 1 now on by default.** 0.7: 734, 1.5: 456 (first set). With gap reach 16: `js1` 752 (vs 755), fresh `fs2` 710 (vs 726): no. Deaths in `fs1` (274): 106 on girder 2 right with 5-6 rivets pulled (around 2R); and 59 "fall_or_unknown" that are really the timer running out.
- **Timeout bug (the "time runs out" Matt saw):** trace (12182): he'd set off for 2R from the right, left the girder, came back at it from the left; the remembered crossing direction put the "far side" on his near side (x 173), so he stood there "arrived" until the timer killed him. Fix (on, a bug): forget the crossing direction off the target's girder, and whenever it would have him "arrive" on the side he's on. 12182 clears. Tests `ft1` (fresh, vs `fs1` 726), `ft2` (first set, vs `jg2` 755).
- **Timeout fix results: `ft1` 806 fresh (vs `fs1` 726; saved 88 / lost 8), `ft2` 821 first set (vs 755; 75 / 9).** Standing stuck at 2R had been costing far more than the timeouts (fireballs reached him there). Remaining "non-fireball" deaths: 30 of 2,000 "to the last rivet" at x 96-103 on the top girder: he was alive when the run ended (DEATHDBG dump): the game's "gone" check fired as he **walked into Kong**, whose feet (sprite list 0x6900) stand at x 115-139 on the top girder. Matt had said so ("you can't cross over kong at the top"). Fix (`riv_kong`, on): Kong splits the top girder's middle section in two in his routes (left half by the ladder at 80, right by 168), and any move reaching x 103-151 there counts as contact. 12820 clears. Tests `fk1` (fresh, vs 806), `fk2` (first set, vs 821).
- **Kong wall results: `fk1` 821 fresh (vs 806), `fk2` 841 first set (vs 821)**; non-fireball deaths 4 / 3 per 1,000. Next: re-tuning the caution settings (tuned while jumps were broken): reach 3 / 6, look-ahead 30 / 44 (`rk1`-`rk4`, first set, vs 841).
- Speed: a 1,000-game rivet test takes ~4.7 minutes on this machine (rivet boards are ~50 s of play each, and the safety map adds work every frame).
- Caution re-tuned with jumps working (first set, vs `fk2` 841): reach 3: 809, 6: 803; look-ahead 30: 775, 44: 718. The current 4 / 36 stay. Deaths in `fk1`+`fk2` (338 / 2,000): 70 girder 2 right with 6 pulled (after 2R), 66 girder 4 right with 7 pulled (4R/5R end), 40 girder 3 right with 5 (going down to 2R); by what he was doing: jumping a fireball 150, gap escapes 52, climbing up 46. Review video for Matt: `runs/fk1/review_deaths.mp4` (Desktop `rivet_deaths_review3.mp4`), list in `runs/fk1/review.txt`. Testing fireball jump direction again (toward `jd1`, straight `jd2`; away was chosen while jumps were broken).
- `jd1` / `jd2` (jump direction toward / straight) came out identical to `fk2` game for game: `--set` takes a Lua value, and an unquoted word is nil, so he fell back to "away". Text settings need quotes: `--set 'riv_jump_dir="toward"'`. (Every other setting tested today was a number or true.) Rerun as `jd3` / `jd4`.
- Jump direction, done properly (vs `fk2` 841): toward 831 (saved 2 / lost 12), straight 836 (0 / 5). "Away" stays. Next: hammer hunting again now 2R / Kong are fixed (`hk1`), and the top-hammer skip rule looser / stricter (`riv_skip_ham` 140 `sk1`, 999 = skip whenever none at all up there `sk2`).
- Vs `fk2` 841: hammer hunting `hk1` 826 (saved 79 / lost 94): off for good; `riv_skip_ham` 140: 833; 999 (skip whenever nothing up there): 719 (Matt: the top hammer is usually worth it). Headline measurement of the current player on 3,000 new games: `hd1` (first 20000).
- **Headline: `hd1`, the current rivet player on 3,000 new games (first 20000): 2,408 cleared, 80.3%** (from 63% this afternoon). Check that 1-1 barrels are unchanged (agent.lua got FIRELOG / DEATHDBG, both env-gated): `bb1`.
- 1-1 check `bb1` (games 0-1999): 1,964 / 2,000 (98.2%); no earlier 1-1 run on those games to compare game by game. Today's changes touching the barrel side: only new `riv_*` entries in params.lua (read only by rivets.lua) and the FIRELOG / DEATHDBG hooks in agent.lua (off unless the env var is set). So the 1-1 player is unchanged; 98.2% on 2,000 is within luck of the 98.7% headline (one standard error is ~0.3%).

**Matt's review of `runs/fk1/review_deaths.mp4` (2026-11-15, review 3):**
1. (12152) Didn't need to jump left; just go up the right-hand side and take out the last two rivets, which were free (why jump back towards a fireball that wasn't even in the way?)
2. (12875) At the top of that ladder, jump over to the right and go up and take out the two rivets. Why did he go back down?
3. (12307) Should have got on the right-hand side and then gone up
4. (12542) Let the hammer run out and then walked under the ladder (a no-no); could have jumped left and waited to see what the fireballs did, hopefully both down the right, then up the middle-right ladder to finish
5. (12079) Again walked under the ladder as the hammer was running out. Stand on the left of the ladder with the hammer facing right (over the ladder); if near the middle of the ladder when it runs out, be moving the way you want to go (left here)
6. (12509) Same as above: could have jumped left, or gone down the ladder
7. (12870) A fair death (could have tried to jump a fireball)
8. (12407) Should have run up the ladder, used the middle hammer to smash at least one of those fireballs, then finished the rivets
9. (12548) Should have gone right again and then up to take out the last 2 rivets (a pattern in a lot of these deaths)
10. (12579) Could have got up to the ladder a bit faster and up; might not have had time, might have had to go back down
Matt: "There's a real trend here where he seems to have a free pass to go up the right hand side and take out the two rivets, but instead he keeps moving back towards the middle... if he's got a free pass up the right to take out the last rivets, he should take it." And: "if there are fireballs in the middle sections and the right is free, he should try the right side."
- Cause: the middle-hammer skip was decided once, when he first got to it, by "any fireball up there?" `riv_free_right` (the safety map over the whole way to 4R then 5R, every moment): never fired (over an ~8 s route any fireball connected through the maze could get somewhere on it). `riv_free_zone` (where they are now, as Matt says): free when none is on the right sections of girders 2-5, none on the right-hand ladders, none in the middle of girder 4 / 5 within N px of 4R / 5R while it's in; committed once free. On #1 (12152) it fires: he goes up the right, pulls 4R from the right, then climbs the middle ladder (168) into a fireball on the top girder: the pull-and-jump-back (Matt's earlier tip) should fit there. Tests `fz1` (zone 40), `fz2` (+ pullback), `fz3` (zone 70), vs `fk2` 841.
- Next from review 3: the hammer running out with him under / walking to a ladder (#4, #5, #6): stand left of the ladder facing right, and as it runs out be moving the way he wants to go.
- `riv_ladder_busy` (Matt #4-#6): walking to a ladder with a fireball anywhere on it counts as contact on arrival. Tests `bl1` (alone), `bl2` (+ ladder commit 8).
- Matt: "perhaps he is not looking far enough ahead?" ... "trial a few different variations of how far ahead and find the best fit". The 36-frame look-ahead is worst-case (any fireball might turn and come straight at him at top speed), which froze him when stretched (44: 718). `riv_far_h`: beyond 36 frames, out to N, each fireball projected along its actual (smoothed) motion: a ladder only as far as the girder it's heading for, a girder only to its ends, with a spread of `riv_far_spread` px per frame (0.15). The safety-map score still uses the 36-frame point. Sweep `lk1`-`lk4`: 60, 90, 120, and 90 with spread 0.3.
- **Matt: 1,000 games is too small a sample with this RNG; use 3,000.** (Any change flips ~25% of games either way, so ±30 in 1,000 is luck.) From now on: screen on 3,000 games at first 20000 against `hd1` (the current player, 2,408 / 3,000; defaults unchanged since, the new rules are all off unless set), then confirm winners on 3,000 new games at first 30000. The 1,000-game queue (fz/bl/lk) was stopped and restarted as `xa1`-`xa3` (free pass), `xb1`-`xb2` (busy ladders), `xc1`-`xc4` (far look-ahead).
- Matt: "part of the trick should be to prevent as much as possible from spawning on the right after having taken out the left side rivets." Measured (`fx01`, 400 games): a new fireball appears opposite Mario, the line exactly at x 128 (Mario 112-127: 285 right / 2 left; 128-143: 60 left / 1 right). After the left sweep, 43 of 916 spawns (in ~1 game in 10) were on the right, nearly all with Mario on or by the middle ladder at 120 (3rd-4th girder) going for the middle hammer. `riv_stay_right` (px): after the sweep, ladders left of the middle cost that much more in his routes, and he goes for the middle hammer from its right edge (x 128-129; the grab works over 119-129) via the right-hand ladder. 12 games: 28 spawns after the sweep, 0 on the right. Tests `xd1` (300), `xd2` (150) at 3,000 games after the current nine.
- Matt: "It's not a hard and fast rule. Sometimes you gotta take the hammer left up the top to kill something, but you always try and give it a good effort to get back before a respawn." Measured (`fx01`): **a new fireball comes every 256 frames** (or a multiple) while fewer than 5 are out; the clock is steady through a game (1-2 phases per game, 4-frame logging) and its phase differs between games; after one is smashed the next comes 92-300 frames later (the next tick). So: `riv_stay_right` stays a route cost (not a ban) and now applies only with fewer than 5 out; `riv_spawn_clock` (weight): the clock learnt from the spawns he's seen (a fireball appearing), and on the left after the sweep a safe move that gets him past x 128 before the next tick gets that extra weight. Tests `xd1` (300), `xd2` (150), `xd3` (300 + clock 2), after the current nine.
- **3,000-game results (games 20000-22999, vs `hd1` 2,408):** free pass `xa1` 2,361 (110 / 157), + pullback `xa2` 2,367, zone 70 `xa3` 2,396; busy ladder `xb1` 2,420 (130 / 118); **busy ladder + ladder commit 8 `xb2` 2,453 (358 / 313)**; far look-ahead 60 `xc1` 2,345, 90 `xc2` 1,924, 120 `xc3` 1,448 (deaths "climb on up" multiply: seeing a fireball that might be there in 1.5 s, he hesitates on ladders; so not further, but committing). Fresh check of `xb2`: `xe0` / `xe1` (games 30000-32999).
- Where the free pass fired (`xa1`: skipped the middle hammer the baseline took): 808 games (too often), saved 55 / lost 157; elsewhere 55 / 0. Losses mostly on the left of girder 4 (jumping 4L's gap towards 4R): his way to 4R went up the middle, not the right. `riv_free_where`: only with him on the right (x >= 184, girder 2 or 3), and rechecked every moment until 4R is out (a fireball coming into the right side puts the middle hammer back). Test `xa4`.
- `xc4` (far look-ahead 90, spread 0.3): 1,691. Look-ahead settled: 36 frames worst-case, then commit (`xb2`).
- **Plan (Matt: "spend some time thinking about how you can build stuff out to learn this level even better ... time is not a problem"; then "you may do all of those"):** where the 20% of `hd1` dies: left sweep ~1.3% in all; 3R→2R 5.2% of those reaching it; 2R→4R (middle hammer) 8.2%; 4R/5R→last 6.5%. Building: (1) the computer's death review, (2) a fireball behaviour model and imagined futures, (3) a learnt danger table at the maze level, (4) per-stage settings, (5) the experts' right-half decisions, (6) spawn control (in test).
- **(1) `tools/rivet_review.py`**: for each death, back 2 / 4 s, 11 choices (own; hold left / right / up / down / still; jump left / right / straight; skip / take the middle hammer), 2 trials (the game's dice, then new dice he can't see, DICE); a choice clearing every trial is a real answer. agent.lua scenario rows take `R:input:frames:target`; scenario_test.run_rows takes `prefix` (rivet starts r1_). Queued: 300 of `hd1`'s deaths (13,200 takeovers).
- **(2) The fireball model, measured (`fx01`, per visit):** a ladder going up is taken on 16% of visits whatever Mario does; a ladder going down 22% of visits only with Mario below, never otherwise (Matt's rule, exactly); on a girder they move towards Mario only ~51% of the time; turning ~3.7% per 8 frames on open girder; typical speed with pauses (13% of the time still) right 0.48, left 0.40 px/frame (0.62 / 0.50 are the fast 10%). `native/rivsim.cpp` (`dkh_native.rivsim`): N imagined futures of every fireball by these odds against the course of a move; share touched. Calibrated against the logs (`simcal.py` in the job tmp): with typical speeds and a 12% turn rate per 8 frames the predicted share of a fireball reaching a spot within 90 frames matches the real one (0.72 → 0.74, 0.82 → 0.79; error 0.0052 per case, from 0.0124). In the player: `riv_mc` (weight: among moves the worst-case check passes, the share of futures touched counts against) and `riv_mc_only` (ranked by futures alone, the worst-case check only within 8 frames: 0 of 8 on a first try, before calibration). Native runner rebuilt with it (old copy `native/build/dkh_before_rivsim`). Tests `xf1` (1), `xf2` (3), after the review.
- **(5) The experts after 2R** (barra + player 3, 43 boards with fireballs; the trace's fireball fields are `F<slot> x y`): right side free by `riv_free_zone`'s test (40): skipped the middle hammer 6 / 6; right side busy: took it 30 / 37. Matt's rule exactly, and my zone test agrees with them; `xa1` lost because of where he was when it fired (his way up went through the middle), which `riv_free_where` (`xa4`) addresses. Fireballs on the right (x >= 184, girder 2 up) when they took it: 1.1 on average; when they skipped: 0.31.
- **(4) Per-stage settings:** `riv_right = {reach =, h =, safe_w =}` overrides the caution settings after the left sweep. Sweep `xg1`-`xg6` (reach 3 / 5, h 30 / 42, safe_w 0.7 / 1.3), after `xf2`.
- (3) a learnt danger table: left until the review and the simulator tests are in (the simulator covers much of the same ground).
- **Matt: "the difficulty will increase throughout this level. I think the fireballs may get faster."** Measured: the game's difficulty (0x6380) goes 1 → 2 at frame 2,040 on the board (34 s; same in 3 games), next presumably 4,080; fireball speed on girders steps with it: right 0.43 / 0.53 / 0.58, left 0.36 / 0.46 / 0.48 px/frame (with pauses) at difficulty 1 / 2 / 3; coming down ladders roughly triples by 3. The right half (where he dies) is mostly at difficulty 2. Now: the simulator takes the current difficulty's speeds (difficulty from the time on the board, which a player follows on the bonus timer); `riv_diff`: his worst-case fireball speeds x 0.9 / 1.1 / 1.2 / 1.3 / 1.4 by difficulty. Test `xh1` after the right-half sweep. (`DIFFDBG` in agent.lua prints 0x6380 and the timer every 2 s.)
- Stay-right (vs `hd1` 2,408): `xd1` 300: 2,413 (16 / 11), `xd2` 150: 2,413, `xd3` 300 + spawn clock 2: 2,417 (25 / 16). It changes few games (~1 in 100); kept for combining.
- **Fresh check of the ladder pair: `xe1` 2,480 vs `xe0` 2,442 (saved 365 / lost 327) on games 30000-32999. `riv_ladder_busy` and `riv_ladder_commit` 8 now on by default.** New reference `hd2` (3,000 games at 20000, ladder pair on) runs before the review; later tests (`xf`, `xg`, `xh`) compare against it. (Each run copies lua/ when it starts, so `xa4` ran with the old defaults: its comparison with `hd1` holds.)
- **Free pass, only from the right (`xa4`: zone 40 + `riv_free_where`): 2,445 vs `hd1` 2,408 (saved 42 / lost 5).** Matt's rule works once it fires only where he'd really go up the right. Fresh check on top of the ladder pair: `xi1` (games 30000-32999, against `xe1` 2,480), then the review.
- New reference `hd2` (ladder pair on): 2,453 / 3,000 at 20000. **Free pass fresh check `xi1`: 2,504 vs `xe1` 2,480 (saved 31 / lost 7). `riv_free_zone` 40 + `riv_free_where` on by default** (from ~83.5% on games 30000-32999).
- **The computer's review (`hd1`, 300 deaths x 2 / 4 s back x 11 choices x 2 trials = 13,200 takeovers):** at 462 of 600 moments some choice clears every trial; his own play does at 182 (other timing / dice). The lessons: 174 moments where his own play died in every trial; 85 of those nothing tried survives; **89 have a real answer**. By where he died: after 2R (girder 2 right, 6 pulled) "skip the middle hammer" 8 (now the free pass); after 3R (girder 3 right, 5 pulled) "jump left" back over 3R's gap 6, "up" 4 (Matt's review 1: jump back over the gap you made); 4R/5R end (girder 4 right) down / right / jump left 4 each. The takeover snapshot now records each fireball's heading, the rivets gone and the hammer (agent.lua, rivet board); `tools/rivet_review_states.py` replays the 89 to record them (queued after `xh1`), to turn the answers into gated rules.
- (Each run's copy of the defaults is in `runs/NAME/lua/params_base.lua` when it has `--set`s, `params.lua` otherwise.) **Imagined futures (difficulty-aware speeds), against `hd2` (ladder pair on, as they had): `xf1` weight 1: 2,501 vs 2,453 (saved 312 / lost 264); `xf2` weight 3 (free pass on too): 2,395.** Fresh check of weight 1: `xj1` (30000, against `xi1` 2,504, same defaults). The right-half sweep (`xg`) and `xh1` run with the free pass on: new reference `hd3` (ladder pair + free pass, 20000) at the end of the queue.
- Right-half settings (`xg`, ladder pair + free pass on; compare with `hd3` when in): reach 3: 2,496, reach 5: 2,435, h 30: 2,380, h 42: 2,271, safe_w 0.7: 2,477, 1.3: 2,463. `riv_diff` (`xh1`): 2,458.
- **The review's 89 moments with a real answer, with the board at the takeover (`runs/hd1/rivet_review/states.json`):** after 3R (14): Mario on girder 3's right stretch (x 188-219), a fireball coming up the 216 ladder below him or beside him on that stretch, the middle of girder 3 clear or heading away: **jump left back over 3R's gap** (Matt's review 1). He's 10-30 px from the take-off spot, beyond the 4 px he looks for a gap escape. `riv_gap_reach_3r` 40 (for 3R's gap only): tests `xk1`, `xk2` (+ right-half reach 3) against `hd3`. Last rivets (13, girder 4 right by the 200 ladder, often a fireball coming down it): mostly "go down" (208 to girder 3's right stretch), some "jump left": no single rule; 2R (11): scattered. Left to the imagined futures (fresh check `xj1`).
- **Against `hd3` (ladder pair + free pass, 2,476):** right reach 3 `xg1` 2,496 (320 / 300); reach 5 2,435; h 30 2,380; h 42 2,271; safe_w 0.7 2,477 (4 / 3: hardly changes anything), 1.3 2,463; `riv_diff` 2,458 (359 / 377); futures weight 3 2,395. **Futures weight 1 fresh (`xj1`): 2,516 vs `xi1` 2,504 (295 / 283)**: not proven (+48 on the first set). `riv_gap_reach_3r` 40 (`xk1`): 2,447 (102 / 131): where it acted directly, 12 more die in the jump (landing among girder 3's middle fireballs) against 8 saved there; narrow (~1 game in 300) and losing: off. + reach 3 (`xk2`): 2,487.
- Combined check on 6,000 new games each (40000-45999): `yb0` (the current player) vs `yb1` (futures 1 + right-half reach 3).
- **6,000 new games (40000-45999): `yb0` the current player 4,933 (82.2%); `yb1` futures 1 + right-half reach 3: 5,006 (83.4%), saved 705 / lost 632. Both on by default (`riv_mc` 1, `riv_right` {reach = 3}).** Headline now 83.4% on 6,000 new games (from 80.3% on 3,000 at the start of the evening's 3,000-game testing; 63% yesterday afternoon).
- New reference `hd4` (futures 1 + right reach 3 on): 2,483 / 3,000 at 20000. Futures tuning against it: weight 0.5: 2,499 (272 / 256); 1.7: 2,478; T 60: 2,504; **T 130: 2,519 (297 / 261)**; n 96: 2,503 (198 / 178). All within luck; T 130 + n 96 together checked on 6,000 new games (46000-51999): `yc0` / `yc1`.
- `yc0` (the current player, 6,000 new games at 46000): 4,987 (83.1%); `yc1` futures T 130 + n 96: 4,980 (552 / 559): no gain, settings stay. **The current player: 9,993 / 12,000 = 83.3% over `yb1` + `yc0`.** Next: a new computer review on the current player's deaths (`yc0`, 300 deaths), states captured for the moments with a real answer.
- **Second computer review (`yc0`, the current player, 300 deaths):** 390 of 600 moments have a choice clearing every trial (124 his own play); 97 with a real answer (his own play died every trial). No dominant pattern now (the free pass and the ladder rules took the big repeated ones); spread over the right half: girder 3 right after 3R (10), girder 2 right on the ladder to 2R (8), girder 3 right ladder after 2R (8), last rivets girder 4 right (7 + 6). A jump (straight / left / right) is a real answer in 9 of the 10 biggest groups. The life-or-death jump (Matt: only when it's life or death) fires only with contact within 4 frames whatever he does; `riv_fire_jump_at` 8 / 12 / 16 (`xn1`-`xn3`, against `hd4`).
- `riv_fire_jump_at` (vs `hd4` 2,483): 8: 2,481 (0 / 2), 12: 2,472 (4 / 15), 16: 2,467 (19 / 35). Stays 4. The review's jump answers are deliberate jumps 2-4 s before the death, with other moves open: outside Matt's rule ("don't go doing jumps of fireballs unless it's life and death"); asked him whether to try a narrow version. 1-1 regression check of the rebuilt runner (rivsim): `bb2`, same games as `bb1` (0-1999), should match game for game.
- `bb2` (1-1, rebuilt runner): 2,000 / 2,000 games identical to `bb1` (outcome, frames, score).
- **Matt: "Test a limited version"** (of deliberate fireball jumps). `riv_plan_jump`: only after the left sweep, on a girder without a hammer, exactly one fireball within 60 px on his stretch (no gap between) heading straight at him: a straight jump and a jump over it become two more moves (progress 1), judged by the same checks; in the air (frames 8-34 of the jump) he's modelled 16 px above the girder. 16 games: chosen a handful of times (straight only). Test `xp1` (vs `hd4`).
- **`xp1` (planned fireball jump, limited): 1,813 vs `hd4` 2,483 (saved 87 / lost 757).** 982 deaths during a planned jump, 962 of them the straight one, at 7-9 px above the girder: Mario's jump only gets ~9 px off the girder and a fireball still touches him there (the model had him 16 px up). So jumping a fireball is a real gamble in this game (Matt's rule: only when it's life or death). The review's "jump" answers were most likely the timing / position change of a forced jump with the fireball happening to turn, not clearing it. Off; Matt's rule stands.
- Review video 4 for Matt (the current player, `yc0`): `runs/yc0/review_deaths.mp4` (Desktop `rivet_deaths_review4.mp4`), list `runs/yc0/review.txt`: 4 deaths where the computer review found no escape 2 or 4 s before, 4 where it found one with no clear pattern; 8 s lead-in (`REVIEW_BEFORE` in death_video.py). Death 3 (51896) is the timer running out with one rivet left: in `yc0` ~50 of 1,013 deaths (0.8% of games) are the timer (frames 6,404-6,550); 137 clears took over 5,000 frames.

**Matt's review 4 (`runs/yc0/review_deaths.mp4`, 2026-11-16):**
1. (50610) A really bad situation: he could have tried to jump left (I think he did) but left it too late. He could have survived by jumping over the gap to the right as the fireball on the right started to climb up (leaving that area safer)
2. (51341) No clue, no time left
3. (51896) Potentially, jump left over the gap on the 4th girder, then push up the ladder and try to jump over the last rivet: dangerous, but no time left, so worth trying (you should play this out!). A 30% chance is better than a 0 one
4. (51961) Considering the time left, either follow the fireball closer and make it in time (a chance is better than 0) or try to jump it, considering the low timer
5. (51866) You could have finished this one! All you had to do was go left and jump... play this one out and learn; no reason to stand there and die. Also, he let the fireball come down on top of him: he could have jumped left onto the middle section
6. (50793) The whole left side was free: go up it to the 4th girder, jump across, grab the hammer to kill things
7. (49277) Plenty of time to jump left and go down the ladder, but did not
8. (50420) Why didn't he just jump back to the right on either of those girders? It was a free pass up the right. (And why did he try to straight-jump a fireball that was coming up under him?)
Themes: (1) with the timer nearly out, take the risk; (2) gap jumps as escapes and shortcuts, including onto the free pass (#8: one gap jump from a free run up the right; the free pass only counts if he's already on the right); (3) the life-or-death jump counted a fireball on the ladder below as on his girder; (4) bigger plans (#6). Built: `riv_lod_dy` (only fireballs within N px of his girder's height count for the life-or-death jump), `riv_urgent` (time left, from the bonus timer at ~137 frames a tick, under N frames per rivet still in: a move meeting a fireball only after 8 frames isn't unsafe; gap escapes from anywhere). Tests `xq1` (lod 4), `xq2` / `xq3` (urgent 450 / 600). Play-outs of #3 and #5 (Matt: "play this out and learn").
- **Matt: "as timer gets lower and lower, risk % increases"** and **"maybe 10,000 per [test] again".** `riv_risk_curve` (N frames needed per rivet still in): with less than twice that left, a move counts as unsafe only if it could meet a fireball within U frames, U from H down to 4 as the time left falls to nothing. Tested first on the moments it's for: `tools/rivet_scen.py` (the deaths after frame 4,800 in `yc0`: 77, 42 of them the timer; takeovers 15 s and 10 s before the end, 4 trials, new dice from trial 1): base, urgent 450 / 600, curve 300 / 450 / 600 → `runs/yc0/risk_scen.txt`. **Tests from now: 10,000 games** (reference on games 60000-69999, fresh checks on 70000-79999). The 3,000-game `xq` queue was stopped.
- **Risk vs timer, on the 74 late deaths (`runs/yc0/risk_scen.txt`, 592 takeovers each):** base 169 (28.5%); urgent 450: 149, urgent 600: 149 (both fully on in those last seconds); curve 300: 135, 450: 105, 600: 113. Taking more risk did worse overall; rerunning on the timer deaths only, with how each replay ends (`risk_scen_timer.txt`).
- **Timer deaths only (42; 336 takeovers each):** base 59 cleared (timer 233, fireball 44); urgent 450: 47 (timer 149, fireball 140); curve 300: 45 (152 / 139). Ignoring danger past 8 frames just swapped timer deaths for fireball deaths. `riv_risk_mc` (Matt's "risk %"): with less than twice the needed time (N frames per rivet still in), a move whose share of imagined futures with a touch is under a limit counts as safe, the limit from 5% to 70% as the time left falls. On the same scenarios: 300 / 450 / 600 → `risk_scen_mc.txt`.
- `riv_risk_mc` on the timer scenarios: 300: 28 cleared (timer / other 257, fireball 51), 450: 30, 600: 27: worse, with more "timer / other". Cause (all three risk versions): the contact check returns walls too (Kong, a girder's end, a gap), so relaxing it for fireballs let him walk off girders and into gaps. Fix: contact marks a wall hit on the course (`pts.wall`), and accepted risk never covers walls. Rerun → `risk_scen_nowall.txt`.
- **Walls excluded, timer scenarios (base 59):** urgent 450: 58 (timer 98, fireball 180); **curve 300: 64** (74 / 198); risk% 450: 60 (192 / 84). Timer deaths fall but become fireball deaths: these moments are nearly hopeless. Deciding at 10,000 games: reference `hd5` (games 60000-69999), `z1` lod_dy 4, `z2` curve 300.
- Play-outs (Matt: "play this one out and learn", review 4 #3 and #5): `tools/rivet_playout.py` (from every 1 s over the last 12 s before the death, every two-step sequence of left / right / up / down / jump left / jump right / still, then he plays on); agent.lua scenario rows take `S:in:n,in:n:x` (a sequence). Smoke test: #5 (51866) clears with "jump left, then right" from 5 s before. Queued after `zq2` → `runs/yc0/playout.txt`.
- **Matt: "you should have just compared it as normal vs engaging only when 300 left on the bonus timer, regardless of rivets left."** `riv_hurry_bonus` 3 (0x62B1 at or under 3, i.e. bonus 300): (a) a move meeting a fireball only after 8 frames isn't unsafe (walls never); (b) with `riv_hurry_pmax` 0.5: a move under 50% of imagined futures touched isn't unsafe. 10,000-game tests against `hd5`: `zq1` lod_dy 4, `zq2` hurry (a), `zq3` hurry (b); then the play-outs. (The curve test `zq2` from before was replaced.)
- **10,000 games (60000-69999): `hd5` the current player 8,304 (83.0%).** `zq1` lod_dy 4: 8,325 (saved 34 / lost 13): **on by default**. `zq2` hurry at bonus 300 (a): 8,308 (15 / 11); `zq3` (b, futures 50%): 8,309 (15 / 10): hardly changes anything (the late timer games are stuck behind a fireball); off. The lever on timer deaths is not getting that late.
- **Play-outs (`runs/yc0/playout.txt`, 1,188 tries each):** #5 (51866): something clears from every second of the last 12, even 1 s before ("down", "jump left" over and over): very escapable, as Matt said. Trace: he waited at the foot of the 200 ladder (x 203, girder 4) while a fireball sat at its top on the top girder (x 202), which then came down onto him; his check only counts a fireball that's already on the ladder. #3 (51896): many choices clear from 9-12 s before (mostly "down"); from 5-7 s only "up, then left / jump left" (Matt's plan: up, jump left over the gap, push for the last rivet). `riv_under_ladder` (px): at the foot of a ladder going up from his girder with a fireball at its top within N px of the ladder: contact. 10,000-game tests `zr1` (12), `zr2` (24) against `zq1` (the current defaults, 8,325).
- `zr1` / `zr2` (under_ladder 12 / 24, vs `zq1` 8,325): 7,947 (744 / 1,122) / 7,790: too wide (just being near a ladder's foot, walking past included, counted as immediate contact). Narrowed to Matt's point (don't stop and wait under it): only the point where the move ends him up, scored as the latest contact (H: the least preferred safe move). `zr3` (12), `zr4` (24).
- `zr3` / `zr4` (narrowed): 8,301 (809 / 833) / 8,260: still ~1,600 games changed: the end of every walk to a ladder is its foot, so every approach was marked. Restricted to moves where he stays put (Matt's #5: he waited there): `zr5` (12).
- `zr5` (under_ladder, waiting only): 8,285 vs 8,325 (588 / 628). Off: waiting at a ladder's foot is often his safest spot at that moment; three versions all lost. The imagined futures already weigh a fireball at a ladder's top (22% of visits down with Mario below).
- **Where it stands (2026-11-17): current defaults `zq1` 8,325 / 10,000 (83.3%) on games 60000-69999.**
- **Two-step planner (`riv_plan2`):** when his best move is waiting or could meet a fireball, he also weighs two-step plans (left / right / up / down for 20 or 45 frames, then left / right / up / down / still), each by the imagined futures over the same span as his own move's share (never off an end, into a gap or Kong; no worst-case contact in the first 8 frames); a plan safer by riv_plan2 (share of futures touched) is taken, first step now, re-planned every frame. 12 games: 10 cleared, ~1.8 s per game. 10,000-game tests `zp1` (0.1), `zp2` (0.2) against `zq1` (8,325).
- **Two-step planner, 10,000 games vs `zq1` 8,325: `zp1` (0.1): 8,400 (saved 989 / lost 914; +0.75%, ~1.7 SE); `zp2` (0.2): 8,321 (943 / 947).** Next: 0.05 (`zp3`), 0 (`zp4`), then a fresh reference `hd6` (70000-79999) and `zf1` (0.1) on it.
- **Matt (live): "I just watched a game fail because mario refused to pickup the hammer at the top to destroy the fireballs."** The skip is decided once (free pass, first look). In `zq1`: 1,104 of 1,675 deaths come after 2R; 769 of those never took the middle hammer (most on the way to it). `riv_ham_stuck` (frames): stuck that long in a row (waiting, or every move could meet a fireball) with the middle hammer still there: it's back in his plan (overrides the free pass and the skip). Tests `zh1` (60), `zh2` (120) after the planner tests, against `zq1`.
- **Matt: "what happens if you delay grabbing the hammer on the left side just a little, to see if you can encourage the fireballs above and below to sort of move somewhat towards the middle-ish area."** `riv_lham_delay` (frames): at the bottom hammer's spot, wait that long before jumping for it while standing there is safe (if not safe, as before). 10,000-game tests `zl1` (30 = 0.5 s), `zl2` (60), `zl3` (120) against `zq1`, after the hammer-when-stuck tests.
- Matt: "base your wait perhaps on distance / number of fireballs above / below / middle." `riv_lham_smart` (px): at the bottom hammer's spot, wait while a fireball is close above or below (girder above / below or a ladder between, within N px), at most `riv_lham_max` (180) frames; grab once they've moved off, or at once if none is close. Replaces the fixed waits: `zs1` (40), `zs2` (64), `zs3` (96).
- Matt: "I don't mean on the left side above and below, I mean anywhere above or below." `riv_lham_anywhere`: wait while any fireball not on his girder is out on a side (outside the middle sections, x 76-180 widened by `riv_lham_smart` px), at most `riv_lham_max` frames. 10 games: waits ~3 s nearly every time (some fireball is usually on a side). Tests `zs1` (middle as is, max 120), `zs2` (max 180), `zs3` (middle +24 px, max 180).
- **Planner: `zp3` (0.05) 8,355 (998 / 968); `zp4` (0) 8,359 (1,000 / 966); fresh (70000-79999): reference `hd6` 8,335, `zg1` (0.1) 8,368 (955 / 922). All four positive; 0.1 over 20,000 games: +108. `riv_plan2` 0.1 on by default.** Later tests in the queue start with it on: compare them with `zp1` (8,400, same games, planner on) where their params_base has riv_plan2.
- **Matt: "is it worth considering a 3 step planner as well?"** `riv_plan3` (beam): the N best two-step plans each get a third step (left / right / up / down / still), all plans and his own move judged over `riv_plan3_t` frames (150). 12 games: ~55% slower overall (it only acts when stuck or in danger). Tests `pt3a` (8, 150), `pt3b` (8, 120) against `zp1` (8,400), after the left-hammer tests.
- Hammer when stuck (planner on; vs `zp1` 8,400): `zh1` (60) 8,396 (27 / 31), `zh2` (120) 8,394 (5 / 11): the planner rarely leaves him stuck that long now; off.
- **Left-hammer wait, anywhere above / below (vs `zp1` 8,400): `zs1` (max 2 s) 8,049 (1,033 / 1,384), `zs2` (3 s) 7,857, `zs3` (3 s, middle +24) 8,043.** Waits mostly hit the limit (some fireball is nearly always out on a side); more fireballs spawn meanwhile (one every 256 frames while there's room) and he reaches the right half later and at higher difficulty: clears ~2 s slower (median 3,217-3,279 frames vs 3,079), timer deaths 138-167 vs 123. Matt said "just a little": `lw1` (max 0.5 s) after the three-step tests.
- `pt3a` (three-step, 150 frames): 8,335 vs `zp1` 8,400 (952 / 1,017).
- **Matt: "Does he have awareness to the locations of all fireballs on the board?"** Yes: every slot, every frame (seen a few frames late, as a human), heading from the last ~20 frames, in all three checks; not fireballs yet to appear. Measured: **new fireballs appear at a girder end (girders 1-4: right x 208-232, left x 16-40), on the side opposite Mario** (+ every 256 frames while fewer than 5 are out). Matt: "go ahead with all 4" (gap jumps in the planner, expecting spawns, the imagined futures for the big choices, a learnt danger score).
- **Built:** `riv_plan_gap`: planner steps "jump left / right" only across a pulled rivet's gap, landing on girder (no fireball jumps: Matt's rule), Mario at girder height throughout; `riv_spawn_mc`: the next spawn (clock from the spawns he's seen, fewer than 5 out) in every imagined future, at a random girder end opposite where he'll be (rivsim `spawn_t`; runner rebuilt). 12 games each: 9 / 10 cleared. Tests `gp1`, `sp1`, `gs1` (both) against `zp1`, after `lw1`.
- **The imagined futures for the big choice (`riv_choice_mc`):** while the middle hammer is next, his actual route to it and his actual route up to 4R then 5R are each played out in the imagined futures over 240 frames; the rivets if he survives them more often by the margin. 12 games: 10 cleared, the hammer taken in 10. Tests `cm1` (0.05), `cm2` (0.1) against `zp1`, after the logging run.
- **The learnt danger score:** logging run `dl1` (3,000 games at 90000, FIRELOG, current player) queued after `gs1`; then a table of situations (Mario's girder / section, each nearby fireball's relative position in 16 px steps, its girder relation, heading) → share leading to a death within 90 frames (no sklearn here; same approach as the barrel danger table).
- **Matt: "I also see him tend to get stuck in the middle part when he could go up the right side ... it'd finish the board faster."** Pulling 2R / 3R walking left leaves him in that girder's middle; the free pass only counted on the right, and the route's gap-jump cost (120) prefers the middle ladders. `riv_free_mid`: in the middle of girder 2 / 3 with that girder's right rivet out, the free pass counts too, and while it's on, hopping a gap costs nothing in his routes. 16 games: 13 cleared.
- **Matt: "Im not sure why the jump over a gap has a cost. You should try both."** The cost (120) came from the first sweep, when jumps were broken (a gap jump was a gamble then); with the jump fix only 60 was retried (`jg5`: 704 vs 703); 0 never. Tests `fm1` (free_mid) and `gc0` (`riv_gapjump_cost` 0) moved to the front of the queue (after `pt3b`, `lw1`).
- `pt3b` (three-step, 120 frames): 8,364 vs `zp1` 8,400 (902 / 938). Three steps lose at both spans: off. `lw1` (left-hammer wait, max 0.5 s): 8,265 (1,096 / 1,231): delaying the bottom hammer loses at every length tried; off.
- **vs `zp1` 8,400: `fm1` free pass from the middle 8,383 (205 / 222); `gc0` gap-jump cost 0: 7,874 (1,218 / 1,744); `gp1` gap jumps as planner steps 8,362 (383 / 421); `sp1` spawn expectation 8,405 (65 / 60); `gs1` both 8,370 (429 / 459).** All off. The route's gap-jump cost (120) does real work: a gap jump commits him for ~46 frames (no reacting, fireballs still reach him at that height); with it free his routes jump gaps everywhere and land among fireballs. Spawn expectation barely matters (after the sweep he's on the right; new ones appear at the far left ends). Next: logging run `dl1` for the learnt danger score, then `cm1` / `cm2`.
- **Learnt danger table (`tools/danger_rivets.py dl1` → `lua/danger_rivets.lua`):** 3,000 games, 8.8 M fireball-moments, 3,794 situations with 30+ cases, 10,044 killing moments. Most deadly: a fireball right above / below him on a ladder (0.58-0.86), right beside him on his girder heading his way (0.57-0.74). `riv_danger_w`: a move's end spot scored by all fireballs together (1 - product of (1 - rate)), counted against the move (moves the worst-case check passes). Tests `dw1` (1), `dw2` (3), `dw3` (8) after `cm2`.
- **Middle hammer or rivets by the imagined futures (vs `zp1` 8,400): `cm1` (0.05) 8,473 (224 / 151); `cm2` (0.1) 8,481 (221 / 140). `riv_choice_mc` 0.1 on by default (84.8%).** The danger-score tests `dw1`-`dw3` started with it on: compare with `cm2`. Fresh check `cf1` (70000-79999) against `zg1` (same defaults without it) after `dw3`.
- **Learnt danger score (vs `cm2` 8,481): `dw1` (1) 8,392 (625 / 714), `dw2` (3) 8,382 (935 / 1,034), `dw3` (8) 8,273 (962 / 1,170).** Off. The table is "danger given how he then played it", applied to where a move ends half a second later with today's fireball positions; the imagined futures (which move the fireballs) do that job better.
- **Matt's alternative play (2026-11-18): "When he finishes taking out the bottom left rivet and the 2nd one from the top on the left, maybe he could stand next to kong, and do vertical jumps (while holding sideways to extend his hit scan-box) to get points, until a fireball either starts to come up on the left hand side, or the fireballs are all in a better position on the right to grab the hammer and he can run over and smash them."** `riv_kong_wait` (frames): after 2L and 4L (5L still in), wait on the top girder at x 94 (Kong kills from 103), at most N frames; leaves when a fireball on the left half is climbing a ladder, or none is left on the left half; his usual checks keep him safe there. `riv_kong_jump`: straight jumps every 50 frames, held sideways (left) in the air. (A jump's direction is set at take-off: JUMP|LEFT jumped him 21 px onto 5L and through its gap, 0 / 12; straight up, then held: jumps in place at x 92-95, 9 / 12.) Tests `kw1` (600), `kw2` (600 + jumps), `kw3` (300 + jumps) against `cm2` (8,481), after `cf1`.
- **Hammer choice fresh check `cf1` (70000-79999): 8,475 vs `zg1` 8,368 (saved 244 / lost 137).** Confirmed: +188 over the two 10,000-game sets. **The rivet player: 84.8%.**
- **Matt: "is it that they are standing still, or is it standing still because he is smashing fireballs and therefore everything pauses"** — the pauses: smash freezes are 15.5% of moments with a hammer (0.2% without); without them fireballs move the same with or without the hammer (towards 47.6 / 49.6%, still 8.8 / 8.6%).
- **Second world-class video (Matt: https://www.youtube.com/watch?v=YMntId1cu5o; "Is there a strat we're missing, a behaviour...")**: `videos/wc2/wc2.mp4` (3.6 h, 720p60, a camera on a real cabinet; downloaded with yt-dlp in a job venv, certifi certificates). 21 rivet boards (blue girders, `videos/wc2/rivet_segs.json`), L=03 up. Rivet pulls (`rivet_pulls.json`; the 2L spot not read yet): left side at our pace (4L ~10 s, 5L ~12, 3L 18-27, 3R 25-35, 2R 30-40); same order as ours on 18 / 21; the last two rivets 20-50 s more (partly points leeching). **Contact sheets of the right half (`sheet_b4.png` L=5, `sheet_b8.png` L=9): every time, he takes the middle hammer, leaves 4R in and stands on girder 4 just left of it facing right, smashing what comes up the right-hand ladders and through the 4R spot (they respawn on the left, trapped); only as the hammer runs out does he pull 4R and go up to 5R.** He also waits in girder 3's middle section (cut off at both ends once 3L and 3R are out) to time his move up. Ours: pulls 4R straight away with the hammer, then waits at x 189 by the 200 ladder (in one trace from frame 2,240 to past 2,700). `riv_farm` (frames): holding the middle hammer with 4R in, stand at x `riv_farm_x` (164) on girder 4 until that many frames of hammer are left. Game 60004: farms, one smash, pulls 4R at 2,756, clears at 2,924. Tests `fa1` (60), `fa2` (30), `fa3` (60, x 150) against `cm2`, after the Kong-wait tests.
- **Wait by Kong (vs `cm2` 8,481): `kw1` (10 s) 8,306 (1,222 / 1,397); `kw2` (10 s + jumps) 8,167 (1,191 / 1,505); `kw3` (5 s + jumps) 8,172.** Off. Jumps add ~200 to the median score on a clear; waiting early costs clears (more fireballs spawn, the right half later and harder): clears 1.5-3 s slower, timer deaths 116 → 127-136. Any waiting before the right half has lost (the left-hammer waits too).
- **Hammer farming at x 164 (vs `cm2` 8,481): `fa1` (pull 4R at 60 frames left) 7,983 (201 / 699); `fa2` (30) on course for about the same.** 369 of the losses die standing at the farming spot: a fireball coming down the 168 ladder (girder 5 to 4, x 168-175) lands right beside him between swings (Matt: "they sneak through the hammer if you are right under it"). `fa3` stands at x 150 (one coming down then lands ~20 px in front and has to walk into the swing).
- **Matt: "It's like he has a better awareness of the fireballs and is able to manipulate them better."** Measured (`dl1`, turns on open girder): a fireball turning turns towards Mario's side 66% with him on its girder, **74% with him below**, 52% with him above. So they're pulled towards his side when he's level or below (and come down only when he's below): a way to steer them. In the simulator (`riv_bias`, rivsim `bias`: heading away turns 0.16-0.18 per 8 frames, towards 0.065-0.08) the calibration got worse: all spots 0.0064 vs 0.0053; at Mario's own spot (it already over-predicts: 0.53 said → 0.27 real) 0.0114 vs 0.008. The fireballs react to where he really goes, which a fixed course can't capture. Not used. `fa2` (farming, 30): 7,952 (203 / 732).
- **`fa3` (farming at x 150, pull 4R at 60 frames left): 8,431 vs `cm2` 8,481 (236 / 286).** Standing off the 168 ladder's foot fixed most of it; the remaining losses come after 4R, climbing the 200 ladder to 5R. `fa4` (x 150, 150 frames left), `fa5` (x 140, 60).
- **Overnight (2026-11-18, Matt to bed):** `fa4` / `fa5`; if the best farming version beats `cm2` by 40+, its fresh check `ff1` (70000, against `cf1`); headline `hd7` (the current player, 30,000 new games at 100000); the computer's review of `hd7`'s deaths with states; then `dm1` / `dm2`.
- **`riv_down_mc` (margin):** on girder 3's right stretch after 3R with 2R next, his route (down the 216 ladder) or back over 3R's gap into the middle and down the 160, each played out in the imagined futures over 240 frames; the middle if safer by the margin (once per visit). 16 games: chose the middle in 10 (e.g. right 0.92 vs middle 0.33). `DOWNDBG` prints the comparison. Tests `dm1` (0.05), `dm2` (0.15) against `cm2`.
- **Farming (vs `cm2` 8,481): `fa4` (x 150, pull 4R with 150 frames left) 8,398 (229 / 312); `fa5` (x 140, 60) 8,299 (230 / 412).** None beat the current player (best `fa3` 8,431); `ff1` skipped. Off. The expert moves along girder 4 and turns to meet them; a fixed spot facing right doesn't capture it.
- **Headline `hd7`: 25,444 / 30,000 new games = 84.81%.**
- **Way down to 2R by the imagined futures (vs `cm2` 8,481): `dm1` (0.05) 8,613 (778 / 646); `dm2` (0.15) 8,626 (734 / 589). `riv_down_mc` 0.15 on by default (86.3%).** Fresh check `df1` (70000, against `cf1` 8,475).
- Review of `hd7`'s deaths: 386 of 600 moments with a choice clearing every trial (138 his own play); 95 moments with a real answer recorded (states in `runs/hd7/rivet_review/states.json`).
- **Way-down fresh check: `df1 10000 @70000 way down (fresh) 8661 vs cf1 8475 | saved 746 lost 560`. Confirmed. The rivet player: ~86.3% (first set 8,626 / 10,000; fresh 8661 / 10,000).**
- **`riv_choice_via`:** the hammer choice also weighs the rivets by two more ways (through girder 3's middle, waypoint x 128; up its right stretch, x 200); the safest of the four; a way through is a waypoint he goes to first. 16 games: 15 cleared, waypoints used. Test `cv1` against `dm2` (8,626, current defaults on the same games).
- **`cv1` (four ways after 2R): 8,419 vs `dm2` 8,626 (492 / 699).** Losses mostly on girder 3's cut-off right stretch (jumping the gap to the hammer 75, gap escapes 66): the right-stretch way sends him into that dead end; and the middle hammer taken less (6,210 vs 6,952). `cv2`: the middle way only (`riv_choice_via` "mid").
- **`cv2` (the middle way only): 8,666 vs `dm2` 8,626 (228 / 188).** Fresh check `cvf` (70000, against `df1` 8,661).
- **`cvf` (middle way, fresh): 8,690 vs `df1` 8,661 (222 / 193).** +69 over 20,000 games (450 / 381). **`riv_choice_via` "mid" on by default. The rivet player: ~86.7% (8,666 and 8,690 on the two 10,000-game sets).**
- **General route choice (`riv_route_mc`, margin):** after the left sweep, heading for a rivet, about once a second his route vs going first through each other section of girders 2-5 (13 waypoints), each played out over 240 frames; a safer way through becomes a waypoint. First try (margin 0.1): 9 / 16 (the safest of 13 noisy estimates nearly always beat his route by luck: detours everywhere); then only with his route at 30%+ touched (`riv_route_min`) and the winner re-checked on 96 new futures: 8 / 16, mostly the timer (detours chained); then at most one detour per rivet and none with under ~11 s on the timer: 25 / 32 (26 / 32 without). Tests `rm1` (0.2), `rm2` (0.3) against `cv2` (8,666, current defaults).
- **Matt: "Is the player aware that the 2nd and 4th fireballs can freeze?" ... "it freezes for two different lengths of time etc... and it's okay for him to know that."** Measured (`dl1`, 3,000 games, stillness on a girder, smash freezes left out): every fireball pauses 60-80 frames many times a game; **the 2nd and 4th (slots 1 and 3) also freeze for 320-360 frames** (~100 times each; never slots 0, 2, 4), **204 of 209 at the top of a ladder going down, only from frame ~4,100 on (difficulty 3, frame 4,080)**. (A first look counting any y change as moving, and one counting ladder climbs as still, both hid it.) `riv_freeze` (frames): a 2nd / 4th fireball standing at a ladder top that long is frozen until ~336 frames from the start of its stop: in the worst-case check it doesn't move meanwhile, and the simulator keeps it still (rivsim takes a 5th value per fireball; runner rebuilt). 16 games: 14 cleared. Tests `frz1` (120), `frz2` (100) against `cv2`, after the route-choice tests. Matt had seen exactly this: Mario on girder 4's right, a fireball frozen at the top of that ladder, Mario hovering.
- **Correction (Matt: "it is not true that every fireball pauses on a girder, what you are seeing is the freezing from a hammer smash. only the 2nd and 4th stop of their OWN accord"):** right. Stops of 40+ frames on a girder, by whether a hammer was out: slots 1 / 3 / 5: ~3,700 each with a hammer out, 3 / 4 / 1 without (my smash-freeze filter needed 2+ fireballs on screen and leaked). **Only the 2nd and 4th stop on their own:** long (5+ s, ~336 frames, at ladder tops, difficulty 3+): 91 / 88; shorter: 77 / 98, mostly elsewhere on girders, lengths clustered near 56, 112, 168, 224 frames (and 336 = 6 x 56): whole multiples of a ~56-frame timer, it seems. `riv_freeze` (2nd / 4th standing at a ladder top for 100-120+ frames) is unaffected.
- Matt: "knowing about the freeze could help with mario being able to avoid things." `riv_freeze_short` (frames): a 2nd / 4th fireball stopped on a girder that long with no hammer out (not a smash freeze) is frozen at least until its next 56-frame mark (worst-case check and simulator). 16 games: 15 cleared. Test `frz3` (long 120 + short 16) after `frz2`.
- **General route choice (vs `cv2` 8,666): `rm1` (0.2) 7,860 (780 / 1,586); `rm2` (0.3) 7,893 (784 / 1,557).** Off. The targeted choices compare two sensible plans at a known decision point; the general one weighs many detours at any moment, some of which look safer over 4 s but cost time and trouble later, and the best of 13 still benefits from luck. Targeted simulator choices, one decision at a time.
- **`riv_last_mc` (margin):** heading for 4R or 5R on a girder, his route against going round the other side (5R: the top girder at x 166 or 192; 4R: girder 4 at x 128 or 196), each played out over 240 frames (frozen fireballs held still); the safest if better by the margin, once per rivet per girder. 32 games: 27 (26 without). Overnight 2026-11-19: after `frz1`-`frz3`, `lm1` (0.1), `lm2` (0.2); the best freeze and last-rivets versions, if 40+ better than `cv2`, together on fresh games (`xf9` against `cvf`); then a 30,000-game headline `hd8` (130000).
- **Long freeze (vs `cv2` 8,666): `frz1` (120) 8,661 (32 / 37); `frz2` (100) 8,653 (36 / 49).** No effect: it can only act from frame ~4,100, and most boards are cleared by ~3,000.
- `frz3` (long 120 + short 16): 8,686 vs `cv2` 8,666 (190 / 170): +20, within luck; under the +40 bar for tonight's fresh check. Possible small gain, to retest (perhaps combined).
- **Overnight results: `lm1` / `lm2` (last-rivets approach) 8,072 / 8,152 vs `cv2` 8,666 (289 / 883; 264 / 778): off** — the losses are gap jumps (4L's gap near x 64, 4R's near x 176) on the way to or from the "go round" waypoints: the simulator underrates a gap jump's risk. `xf9` skipped. Headline `hd8` stopped at ~5,900 games (86.58% so far): Matt, "the current test looks like it's not doing much".
- **Matt (2026-11-20): "fixing single scenarios is not likely to increase the % much, so dont throw away a gain if it happens."** `riv_freeze` 120 + `riv_freeze_short` 16 kept on by default (`frz3` +20, 190 / 170; true knowledge about the game). New reference: `frz3` (8,686 at 60000).
- **General lever: tuning the simulator itself** (every simulator decision uses it). rivsim takes `turn`; the player passes `riv_sim_rx` / `riv_sim_ry` (touch distances, default 8 / 9) and `riv_sim_turn` (default 0.12) to every call. Sweep `sm1` rx 10, `sm2` rx 6, `sm3` ry 12, `sm4` turn 0.08, `sm5` turn 0.16, against `frz3`.
- **Simulator settings (vs `frz3` 8,686): `sm1` rx 10: 8,680 (758 / 764); `sm2` rx 6: 8,684 (741 / 743); `sm3` ry 12: 8,657 (561 / 590); `sm4` turn 0.08 trending slightly worse.** The simulator's settings are about right; not the lever. Next: `pa1` (`riv_plan2_always`: the planner also weighs plans against ordinary safe moves, every 4th frame) and `lt1` (the hammer choice and the way down over 360 frames: `riv_choice_t`, `riv_down_t`), after `sm5`.
- **Matt: "Thinking outside the box, do you have any other ideas that might help?"** Measured (`frz3`, 10,000 games): deaths by time on the board, 17 s bins: 18, 225, **534 (34-51 s, just after the step to difficulty 2 at 34 s)**, 260, 113, 39, 125 (the timer); median pulls 3R 20.9 s, 2R 29.7, 4R 39.4, 5R 45.1; clears median 50 s. Ideas: (1) race the clock: more of the right half before 34 s, less waiting (first test `np1`: no hammer parking after 3R); (2) a learnt choice from replays of ordinary moments (the review tool's causal data at scale); (3) an all-knowing rivet player as a teacher; (4) the rivet order chosen by the maze (trapping fireballs); (5) managing the fireball count with smashes.
- **Matt: "try option 3, 2, 1 and 4 in that order", then #5.** Option 3, the all-knowing rivet player as a teacher: the barrel search (native, checked move sequences) made to run on the rivet board (`SEARCH=1 SEARCH_RIV=1`): it follows the rivet player's target x (`mac:search_route` 1-6), its climb direction (7) and its own press (8, tried first; move kind 9); "down" at the route point on rivets only. 8 games each: 0 cleared in every version (stalls, then with short plans early deaths): the search has no idea of progress on rivets and overriding the player's presses scrambles its state. A proper version needs a rivet-aware search (survival + progress to the next rivet): paused. All gated (barrels unchanged: route_v 0, route_in -1 by default).
- **Option 2, `tools/rivet_learn.py`:** N random moments on the right half (after 3R) from a batch's games, each replayed with 6 choices (own; left / right / still 30 frames; up / down 40) x 2 trials (new dice from trial 1), with the board at each moment; then which choice clears most per kind of situation. Running on `frz3` (1,500 moments, 18,000 replays) right after `sm4`.
- **Option 4, `riv_order_mc` (margin):** after the left sweep, with 2+ of 2R / 4R / 5R left, each as the next target played out over `riv_order_t` (300) frames (the simulator knows the maze); another if safer by the margin, kept until it's out; decided once per rivet pulled. 24 games: order changed in 10; 18 cleared (19 without). Queue (`q68`): option 2 data, `np1` (option 1), `om1` (0.1), `om2` (0.2), then `sm5`, `pa1`, `lt1`. Option 5 after.
- `sm4` (simulator turn 0.08): 8,612 vs `frz3` 8,686 (694 / 768). Turn rate stays 0.12. Option 2 data collection started (`runs/frz3/learn/`).
- **Dashboard (Matt: "the dashboard is not updating the games in this test"; "is there a way to consolidate the # to reflect the true value?"):** the "current test" panel follows the newest batch without `finished`, which was `hd8` (stopped by hand): stopped runs (6) now marked finished (`"stopped": true`). The total counted only `run_batch` games: now also **replays from the analysis tools** (`runs/replays.json`: 1,336,788 recovered from 75 tool logs, the largest count in each, a lower bound; from now on `scenario_test.run_rows` adds every replay via `stats.count_replays`). Dashboard: games 6,268,657, replays 1,336,788, everything ~7.6 M. (Option 2's 18,000 started before the change: add them by hand when it finishes.) Server restarted.
- **Matt (live): "mario sat in the middle area on the 2nd girder and refused to take a free right hand side path."** After pulling 2R walking left he's in girder 2's middle: the free pass only counts on the right, and the route's fixed gap-hop cost prefers the middle ladders. `riv_choice_hop`: the hammer choice also weighs "hop right over 2R's gap onto girder 2's right, then up the right" (24 games: 19, as without).
- **Matt: "why is hopping a gap with nothing on the other side of it costly?"** Because the route search doesn't look at fireballs: every hop costs 120 px (set when jumps were broken; 0 everywhere lost 5%). `riv_gap_dyn` (px): with no fireball within 64 px of the landing on that girder, or on a ladder near it, a hop costs only this. 24 games: 20 (19 without). Queue (`q69`, after option 2's data): `np1`, `om1`, `om2`, `gd1` (20), `gd2` (50), `hp1`, `sm5`, `pa1`, `lt1`.
- **Option 2 results (`runs/frz3/learn/data.json`, 1,500 right-half moments x 6 choices x 2 trials):** clear rate from the moment: own 89.1%, still 87.6, up 86.5, down 85.7, right 81.3, left 57.2; the best choice per moment 97.7% (an upper bound, flattered by luck). Grouped by situation (his position / section or on a ladder; the nearest fireball: on his girder / above / below, side, near / mid / far, coming / going), with 2 trials most apparent wins are luck; one stands out: **on a ladder, the nearest fireball close below and coming his way: climbing on up beats his own play by ~9% (66 moments, z 2.1)**. `riv_lad_flee_up`: there, climb on unless that meets a fireball within 8 frames. 24 games: 20 (19). Test `lu1` after `lt1`.
- **Vs `frz3` 8,686: `np1` (option 1, no hammer parking after 3R) 8,334 (913 / 1,265): the parking does real work; `om1` / `om2` (option 4, rivet order by the simulator) 8,107 / 8,224: the star order stays; `gd1` (hop cost 20 with a clear landing) 8,692 (176 / 170).** The simulator wins when choosing between ways to do the same next step, loses when it changes the plan itself.
- **Option 3 rebuilt as a real rivet search (`RSEARCH=1`, native `mac:rsearch(fn)`):** every 8 frames, every two-move sequence (stand, walk left / right, up, down, jump left / right / straight) on exact copies of the game, a 30-frame tail check, scored by rivets pulled (x 10,000) and otherwise minus the route cost to his target (`c.progress`); the first move of the best is played. Slow (a few minutes a game).
- **Matt: "Are you trying to do too much at once?" — yes:** I'd run the option-3 trial alongside the queued test (against one-at-a-time), kept many threads open, and tested many ideas shallowly. Agreed plan: one thing at a time; the queue trimmed to Matt's own items (`gd2`, `hp1`, `lu1`; the three simulator tweaks dropped); then option 3 alone (`rs1`, 64 games); then option 5; a "running now" list in every update.
- **Vs `frz3` 8,686: `gd2` (hop cost 50 with a clear landing) 8,674 (133 / 145): the fixed cost stays; `hp1` (hop right from girder 2's middle as a plan) 8,722 (384 / 348): kept on (Matt's observation, a gain: `riv_choice_hop`); `lu1` (option 2's ladder rule) 8,530 (754 / 910): off.**
- `rs1` first ran 0 games: run_batch's stall guard kills a batch with no result for 120 s, and RSEARCH games take minutes. `--stall SECONDS` added; `rs1` rerun with 3,600, alone on the machine.
- **Option 3, getting the rivet search to work:** (1) it ran the game inside Lua's frame callback and hung: now request-then-answer like the barrel search (`mac:rsearch(fn)` returns -2 while pending; the main loop searches between frames); (2) progress mid-ladder: the better of the girders above and below; only on a ladder; (3) the target was recorded only on one code path: now as soon as it's chosen; (4) the route's own cost leaves out the last walk across the rivet: progress is now the whole way step by step; (5) a hammer as the target isn't progress it can see: the normal player plays until the hammer's taken; (6) the tail check is 60 frames (a fall into a gap kills on landing). 4 games: 60000 cleared; the others got to 3-1 rivets left (2 falls before (6)). Batch `rs1` (64 games, alone, `--stall 3600`).
- **Option 3 results: `rs1` (64 games) 23 cleared vs the player's 55 on the same games (36 of its deaths falls into gaps: a fall only kills on landing, after the search looked); it cleared 4 the player died in. Falls counted as death at once (mv_rec: moving down off a ladder, not jumping): `rs2` 2 / 64 — too blunt (stepping off a ladder also moves him down), most options looked fatal. Stopped here (Matt's plan: stop if it can't beat the player). All gated by `RSEARCH=1`.**
- **Option 5, managing the fireball count: `riv_smash_right`:** after the left sweep, with a hammer and left of the middle, a fireball isn't smashable (avoid it): a smashed fireball comes back on the side opposite Mario, and three of the four left girder ends are cut off after the sweep (only girder 1's connects). 24 games: 19 (as without). Test `sr5` against `hp1` (8,722, the current defaults).
- **Option 5 (`sr5`, smash only on the right after the sweep): 8,672 vs `hp1` 8,722 (8 / 58). Off.** All five options done: 3 stopped (couldn't match the player), 2's rule lost at scale, 1 lost (the hammer parking does real work), 4 lost (the star order stays), 5 lost (a smash now beats where its replacement appears). **Current: ~87.2% (`hp1` 8,722 / 10,000 at 60000; current defaults).** Changing the plan itself (order, waiting, smashing) has lost every time; gains come from Matt's specific observations and the simulator choosing between ways to do the same next step.

