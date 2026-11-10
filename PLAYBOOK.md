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

**World-record video (Matt, 2026-11-10): `videos/Barrels.mp4`**, the barrel boards of the highest game ever played (KL, 1,269,600; arcade capture, 1280x720 at 60 fps, 2 h 20 min). Board cuts from a 10 fps scan (`videos/boards.npy`, 60 boards); levels read off the "L=" crops (`videos/levels.txt`): boards 04-58 are levels 5-21 (55 boards, extra boards at levels 13, 15 and 21 where a life was lost), 59 the level-22 kill screen. Calibration: game x = (video x - 338.8) / 2.475, game y = video y / 2.78; the playfield crop 339-973 x 0-712 scaled to 256x256 is 1 px = 1 game unit. `tools/vid_objects.py` (moving objects against each board's median background, classified by colour: Mario's red and blue blur to purple, so by mean colour; barrels; blue barrels; fireballs), `tools/vid_extract.py` (all frames, `videos/raw/`), `tools/vid_trace.py` (the INP trace layout: Mario's game position, ground / jump / ladder by how each off-girder stretch ends, hammer by blob size, stick and jump inferred, barrels followed frame to frame). Result `videos/kl.trace` (also `inps/kl_video.trace`): 409,744 frames, ~3,200 jumps, checked by eye on sample frames.

**Expert comparison with three experts (barra, player 3, KL's video; `runs/ld00/expert_match3.txt`):** 96 deaths matched (closest moments: barra 44, player 3 33, KL 19); no move 148/576 (26%), the experts' move 223/576 (39%); clearly better at 30 deaths, clearly worse at 15. Repeats: x1 (10 deaths), x2-like (6), x3-like (5), and new from KL: 2nd girder x=126-142 with a barrel right above coming down the ladder or on the girder above ~60 px left: **stand and wait** (4 deaths, 0-1/6 → 4-5/6). Queued as x5 / x6 (`xe01`, first 9900000).

**Steering, experts against him (Matt: "the expert probably made sure that bad luck didn't happen by steering the barrels above him"). `tools/steer_study.py`:** each time a barrel reaches a ladder on the girder above Mario (Mario on the ground, no hammer): his stick relative to the ladder and whether it came down. Stick towards: ~75% come down; away or neither: ~20% (INPs). Share of those moments with him right under the ladder (<=16 px): barra 19%, player 3 12%, **him 34%** (149 cleared games). 17-48 px off, the ladder **downstream** (where barrels on his girder roll away to): experts pull it down (stick towards) **81-85%**, **he 8%**; upstream: experts 50-61%, he 16%. His `steer_pull` only fires standing with nothing else to do and 3 frames before the ladder. Tests (queued after x6): `lp00` reference, `lp01` steer_pull = 8, `lp02` + `pull_walk` (also while walking), first 10000000. Also `autopsy.py` with `TRACE_ONLY=1` traces any game, cleared ones too.

**Expert spots, every instance (`xe00`, `xe01`, `setup_moves.py`):** x1 (150 instances, 15% where no move sometimes dies): walk left 8 then straight jump 88.6% there vs 36.4%, 91.4% vs 96.1% elsewhere: **passes** (~+3.7 net). x2: 7 instances, too rare. x3 (1,726) and x4 (1,936): best moves within noise of no move: **no gain** (the gap there is earlier steering, see below). KL's x5 (972; barrel coming down the ladder right above him on the 2nd girder): **stand 20 frames** 89.5% vs 70.6%, 92.7% vs 94.3%: passes (~+0.9). x6 (1,817; barrel ~60 px left on the girder above): **straight jump at once** 87.4% vs 74.8%, 96.3% vs 93.7%: passes. Combined fresh check `xc01` against `lp00` (first 10000000).

**Pulling barrels down like the experts (fresh, first 10000000):** `lp00` 98.03% (counting fireballs 95.61%); `lp01` steer_pull = 8: 98.13% (111 saved / 102 lost); **`lp02` steer_pull = 8 + `pull_moving` (also while walking): 98.52%, counting fireballs 96.44%**; barrel deaths 172 → 125, 4th-girder deaths 171 → 106, fireballs 247 → 211; 131 saved / 86 lost. (`pull_walk` was already a number, the safety check's steps; the switch is `pull_moving`, and the safety check now also runs while walking.) Second check queued: `lp10` / `lp12` (first 10100000).

**Combined spot rules (`xc01` vs `lp00`): 98.03% → 97.83%**, saved 70 lost 88 (x6 73/100, x1 10/14, x5 57/44): not adopted; the trials' 150-moment "safe" sample flattered x6. Lesson: copying an expert's move at one spot rarely beats his own play over every instance; copying their habit (pulling barrels down) did. **Overnight (`tools/overnight_pull.py`, `runs/overnight_pull.txt`):** second 5-1 check of the pull (`lp10`/`lp12`), adopt if +0.1 and more saved than lost; the same on 4-1, 3-1, 2-1 (`pl40`..`pl21`), adopted per level on the same bar (replacing the level's own `steer_pull = 3`); 1-1 (`pl10`/`pl11`) reported only; then a fresh 5-1 run with the day's settings (`pz00`), its barrel deaths traced and compared with the experts again. params.lua before the night: job tmp `params_before_overnight.lua`.

**Overnight results (2026-11-11, `runs/overnight_pull.txt`):** pull (steer_pull = 8 + pull_moving) **adopted on 5-1** (second check `lp10` 97.93% → `lp12` 98.35%, 116 / 83), **4-1** (94.15 → 94.78, 347 / 287) and **3-1** (95.22 → 95.58, 317 / 279). 2-1: 97.68 → 86.03 (166 / 1,329) and 1-1: 98.91 → 95.61 (95 / 423): not adopted; those levels lack `pull_safe`, so he pulled even when the steps weren't safe; retesting with pull_safe (`pl22`, `pl12`; 1-1 report only). Fresh 5-1 with everything on (`pz00`): **98.36%** (counting fireballs 96.24%). Expert comparison on its remaining barrel deaths: no move 178/468, the experts' move 191/468: little left to copy directly.

**2-1 / 1-1 pull with pull_safe, paired:** 2-1 `pl20` 97.68% → `pl23` 97.73% (129 / 124): even, not adopted; 1-1 `pl10` 98.91% → `pl13` 98.83% (36 / 43): unchanged. (`pl22` / `pl12` used other games by mistake: unpaired, ignore.) Pull stays on 3-1, 4-1, 5-1. Next (the experts' other habit, rarely under a ladder when a barrel arrives above: 12-19% vs his 34%): `w_under` for every live ladder (`under_zones = nil`), `pu01` (w_under 40) and `pu02` (80), against `pz00` (98.36%, same games).

**w_under on every live ladder (5-1, same games as `pz00` 98.36%):** `pu01` 98.32% (89 / 91), `pu02` w_under 80: 98.35% (91 / 91): neutral, not adopted. It only weighs where he takes off and lands, not where he stands while barrels come down, so it doesn't capture the experts' habit; that needs the planner to weigh standing spots. 30,000-game fresh exam of 5-1 with everything on: `pz10` (first 10700000).

**30,000-game fresh exam of 5-1 (`pz10`, 2026-11-11): 98.37%**, counting fireballs 96.29% (fireballs 634, barrels 418, wild barrels 47, falls 13). Before: 97.80% / 95.06% (`kz10`, 2026-11-10). Deaths by girder: 2nd 370, 3rd 102, 4th 332, 5th 184, 6th 124.

**30,000-game fresh exams with the pull on (2026-11-11):** 4-1 `pe40` **94.89%** (was 90.32% fresh on 2026-11-07, 94.15% in last night's reference); 3-1 `pe30` **95.49%** (was 91.12%, 95.22%). On both, wild barrels are now nearly half the non-fireball deaths (4-1: 693 wild, 771 rolling; 3-1: 619, 679).

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
