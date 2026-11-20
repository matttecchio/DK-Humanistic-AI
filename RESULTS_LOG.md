# Test results

Added automatically after each batch. Conclusions are in FINDINGS.md.

| Date | Batch | What was tested | Rule changes | First game | Games | Cleared | At least (95%) | Hit 9,500+ | Median score |
|---|---|---|---|---|---|---|---|---|---|
| 2026-11-01 15:36 | x_18 | Exam: floor 4, a little further right | standoff4=18 | 200000 | 1,000 | 89.8% | 87.8% | 0.0% | 4,200 |
| 2026-11-01 15:40 | x_l | Exam: floor 4, left of the ladder | arrive4=-1 | 200000 | 1,000 | 88.9% | 86.8% | 0.0% | 4,100 |
| 2026-11-01 15:43 | y_fast | Exam: reactions at 133 to 150 ms |  | 200000 | 1,000 | 91.3% | 89.4% | 0.0% | 4,200 |
| 2026-11-01 15:46 | y_mc3 | Exam: accepts slightly tighter jumps | min_clear=3 | 200000 | 1,000 | 90.7% | 88.7% | 0.0% | 4,200 |
| 2026-11-01 15:48 | y_mc5 | Exam: wants slightly wider jumps | min_clear=5 | 200000 | 1,000 | 91.1% | 89.2% | 0.0% | 4,200 |
| 2026-11-01 15:50 | y_t15 | Exam: looks less far past each move | plan_tail=15 | 200000 | 1,000 | 88.9% | 86.8% | 0.0% | 4,200 |
| 2026-11-01 15:53 | y_t25 | Exam: looks further past each move | plan_tail=25 | 200000 | 1,000 | 85.0% | 82.7% | 0.0% | 4,100 |
| 2026-11-01 15:55 | y_l2 | Exam: slightly less keen to delay jumps | w_later=0.15 | 200000 | 1,000 | 90.1% | 88.1% | 0.0% | 4,200 |
| 2026-11-01 15:57 | y_l4 | Exam: slightly keener to delay jumps | w_later=0.45 | 200000 | 1,000 | 91.7% | 89.8% | 0.0% | 4,100 |
| 2026-11-01 15:59 | z_steer | Exam: tapping Left to steer barrels down the broken ladder | steer_top=true | 200000 | 1,000 | 90.8% | 88.8% | 0.0% | 4,200 |
| 2026-11-01 16:05 | v10 | Fresh exam: fastest allowed reactions, slightly later jumps |  | 300000 | 2,000 | 91.0% | 89.6% | 0.0% | 4,100 |
| 2026-11-01 16:10 | v11 | Fresh exam: knows wild barrels zig-zag |  | 300000 | 2,000 | 89.3% | 87.9% | 0.0% | 4,200 |
| 2026-11-01 16:11 | chk | Checking the restored player matches |  | 300000 | 400 | 90.2% | 86.9% | 0.0% | 4,100 |
| 2026-11-01 16:24 | h_a | Only jumps at what's really coming | only_needed_jumps=true | 300000 | 1,000 | 87.3% | 85.1% | 0.0% | 4,200 |
| 2026-11-01 16:26 | h_b | Same, and prefers straight jumps a little | only_needed_jumps=true, w_sideways=10 | 300000 | 1,000 | 89.2% | 87.1% | 0.0% | 4,100 |
| 2026-11-01 16:30 | h_c | Same, and prefers straight jumps a lot | only_needed_jumps=true, w_sideways=25 | 300000 | 1,000 | 84.0% | 81.6% | 0.0% | 4,100 |
| 2026-11-01 16:33 | h_d | Only prefers straight jumps | w_sideways=25 | 300000 | 1,000 | 88.0% | 85.8% | 0.0% | 4,100 |
| 2026-11-01 16:36 | k_a | Floor 4: prefers straight jumps | w_sideways4=25 | 300000 | 1,000 | 92.6% | 90.8% | 0.0% | 4,100 |
| 2026-11-01 16:39 | k_b | Floor 4: strongly prefers straight jumps | w_sideways4=50 | 300000 | 1,000 | 92.4% | 90.6% | 0.0% | 4,100 |
| 2026-11-01 16:41 | k_c | Floors 3 and 4: prefers straight jumps | w_sideways4=25, w_sideways3=25 | 300000 | 1,000 | 93.2% | 91.5% | 0.0% | 4,100 |
| 2026-11-01 16:44 | k_d | Floor 4: straight jumps, and only when needed | w_sideways4=25, only_needed4=true | 300000 | 1,000 | 91.3% | 89.4% | 0.0% | 4,100 |
| 2026-11-01 16:47 | m_2 | Floor 2 too: prefers straight jumps | w_sideways2=25 | 300000 | 1,000 | 92.8% | 91.0% | 0.0% | 4,100 |
| 2026-11-01 16:49 | m_5 | Floor 5 too: slightly prefers straight jumps | w_sideways5=10 | 300000 | 1,000 | 92.6% | 90.8% | 0.0% | 4,100 |
| 2026-11-01 16:52 | m_6 | Floor 6 too: slightly prefers straight jumps | w_sideways6=10 | 300000 | 1,000 | 93.2% | 91.5% | 0.0% | 4,100 |
| 2026-11-01 16:57 | v12 | Fresh exam: calm straight jumps on floors 3 and 4 |  | 400000 | 2,000 | 91.5% | 90.2% | 0.0% | 4,100 |

From here on, Cleared and At least leave out games lost to fireballs, as the user asked on 2026-11-01. The figure with fireball deaths counted is in brackets, and is the one comparable with the rows above.

| Date | Batch | What was tested | Rule changes | First game | Games | Cleared | At least (95%) | Hit 9,500+ | Median score |
|---|---|---|---|---|---|---|---|---|---|
| 2026-11-01 18:18 | a0 | Baseline, counting without fireball deaths |  | 300000 | 1,000 | 93.9% (93.3% with fireballs) | 92.2% | 0.0% | 4,100 |
| 2026-11-01 18:21 | a1 | Fix: barrel starting down a ladder is seen as going down | ladder_fix=true | 300000 | 1,000 | 94.6% (94.2% with fireballs) | 93.0% | 0.0% | 4,100 |
| 2026-11-01 18:23 | a2 | Plus: he can land and stand still | ladder_fix=true, tail_stay=true | 300000 | 1,000 | 95.3% (94.8% with fireballs) | 93.8% | 0.0% | 4,100 |
| 2026-11-01 18:27 | a3 | Plus: second jumps can be quick and straight | ladder_fix=true, tail_stay=true, second_straight=true, land_stall2=true, seconds={6,16,30} | 300000 | 1,000 | 95.8% (95.3% with fireballs) | 94.3% | 0.0% | 4,100 |
| 2026-11-01 18:29 | b1 | Fix: after a jump he must walk back to his waiting spot | ladder_fix=true, along_fix=true | 300000 | 1,000 | 0.3% (0.3% with fireballs) | 0.1% | 0.0% | 4,000 |
| 2026-11-01 18:31 | b2 | All planning fixes together | ladder_fix=true, along_fix=true, tail_stay=true, second_straight=true, land_stall2=true, seconds={6,16,30} | 300000 | 1,000 | 0.1% (0.1% with fireballs) | 0.0% | 0.0% | 4,000 |
| 2026-11-01 18:33 | b3 | Plus: wild barrels modelled as they really fall | ladder_fix=true, along_fix=true, tail_stay=true, second_straight=true, land_stall2=true, seconds={6,16,30}, wild_model=true | 300000 | 1,000 | 0.2% (0.2% with fireballs) | 0.1% | 0.0% | 3,900 |
| 2026-11-01 18:35 | b4 | Plus: fireballs predicted for a whole jump | ladder_fix=true, along_fix=true, tail_stay=true, second_straight=true, land_stall2=true, seconds={6,16,30}, fire_horizon=50 | 300000 | 1,000 | 0.1% (0.1% with fireballs) | 0.0% | 0.0% | 4,000 |
| 2026-11-01 18:40 | c1 | Plus: after a jump he must walk back to his waiting spot | ladder_fix=true, tail_stay=true, second_straight=true, land_stall2=true, seconds={6,16,30}, along_fix=true | 300000 | 1,000 | 95.8% (95.2% with fireballs) | 94.3% | 0.0% | 4,100 |
| 2026-11-01 18:47 | c2 | Plus: wild barrels modelled as they really fall | ladder_fix=true, tail_stay=true, second_straight=true, land_stall2=true, seconds={6,16,30}, wild_model=true | 300000 | 1,000 | 96.3% (95.9% with fireballs) | 94.9% | 0.0% | 4,100 |
| 2026-11-01 18:47 | c3 | Plus: fireballs predicted for a whole jump | ladder_fix=true, tail_stay=true, second_straight=true, land_stall2=true, seconds={6,16,30}, fire_horizon=50 | 300000 | 1,000 | 95.9% (95.7% with fireballs) | 94.5% | 0.0% | 4,100 |
| 2026-11-01 18:55 | v13 | Fresh exam: ladder fix, can stand after landing, quick straight second jumps |  | 500000 | 2,000 | 95.3% (94.5% with fireballs) | 94.2% | 0.0% | 4,100 |
| 2026-11-01 19:12 | d0 | New test games: where we are now |  | 600000 | 1,500 | 94.3% (93.7% with fireballs) | 93.0% | 0.0% | 4,100 |
| 2026-11-01 19:18 | d1 | Fixes: barrels entering a ladder, and tapping jump twice | ladder_top_fix=true, double_tap=true | 600000 | 1,500 | 94.8% (93.9% with fireballs) | 93.6% | 0.0% | 4,100 |
| 2026-11-01 19:24 | d2 | Plus: barrels on the girder above aren't near misses | ladder_top_fix=true, double_tap=true, above_ok=true | 600000 | 1,500 | 95.0% (94.1% with fireballs) | 93.7% | 0.0% | 4,100 |
| 2026-11-01 19:29 | d3 | Plus: wild barrels modelled as they really fall | ladder_top_fix=true, double_tap=true, wild_model=true | 600000 | 1,500 | 96.3% (95.3% with fireballs) | 95.2% | 0.0% | 4,100 |
| 2026-11-01 19:35 | d4 | Plus: longer fireball prediction | ladder_top_fix=true, double_tap=true, fire_horizon=50 | 600000 | 1,500 | 94.6% (93.9% with fireballs) | 93.3% | 0.0% | 4,100 |
| 2026-11-01 19:41 | e1 | Plus: barrels on the girder above aren't near misses | above_ok=true | 600000 | 1,500 | 96.3% (95.3% with fireballs) | 95.2% | 0.0% | 4,100 |
| 2026-11-01 19:47 | e2 | Plus: longer fireball prediction | fire_horizon=50 | 600000 | 1,500 | 96.3% (95.5% with fireballs) | 95.2% | 0.0% | 4,100 |
| 2026-11-01 20:02 | g1 | First wild barrel falls straight, and he looks further ahead for wild barrels | first_straight=true, wild_tail=60 | 600000 | 1,500 | 95.6% (94.8% with fireballs) | 94.4% | 0.0% | 4,100 |
| 2026-11-01 20:10 | g2 | Plus: weighs where wild barrels may bounce, rather than assuming the worst | first_straight=true, wild_tail=60, wild_soft=true | 600000 | 1,500 | 95.3% (94.2% with fireballs) | 94.1% | 0.0% | 4,100 |
| 2026-11-01 20:19 | g3 | Plus: better prediction for barrels leaving girder ends | first_straight=true, wild_tail=60, exact_arc=true | 600000 | 1,500 | 96.6% (95.5% with fireballs) | 95.6% | 0.0% | 4,100 |
| 2026-11-01 20:28 | g4 | Plus: barrels on the girder above aren't near misses | first_straight=true, wild_tail=60, above_ok=true | 600000 | 1,500 | 94.9% (93.9% with fireballs) | 93.6% | 0.0% | 4,100 |
| 2026-11-01 20:35 | h1 | First wild falls straight, longer look applies only to wild barrels | first_straight=true, wild_tail=60 | 600000 | 1,500 | 97.2% (96.5% with fireballs) | 96.3% | 0.0% | 4,100 |
| 2026-11-01 20:42 | h2 | Plus: better prediction for barrels leaving girder ends | first_straight=true, wild_tail=60, exact_arc=true | 600000 | 1,500 | 97.6% (96.5% with fireballs) | 96.7% | 0.0% | 4,100 |
| 2026-11-01 20:48 | h3 | Plus: barrels on the girder above aren't near misses | first_straight=true, wild_tail=60, exact_arc=true, above_ok=true | 600000 | 1,500 | 97.2% (96.2% with fireballs) | 96.2% | 0.0% | 4,100 |
| 2026-11-01 21:01 | i1 | Might-come-down barrels only count if he could not react in time | odds_risk=true | 600000 | 1,500 | 97.6% (96.5% with fireballs) | 96.7% | 0.0% | 4,200 |
| 2026-11-01 21:07 | i2 | Barrels leaving girder ends timed exactly | arc_timed=true | 600000 | 1,500 | 97.2% (96.5% with fireballs) | 96.3% | 0.0% | 4,100 |
| 2026-11-01 21:14 | i3 | Both, and bounces count only if he could not react | odds_risk=true, arc_timed=true, wild_soft=true | 600000 | 1,500 | 97.7% (96.9% with fireballs) | 96.8% | 0.0% | 4,200 |
| 2026-11-01 21:20 | i4 | Plus: on ladders, only certain wild barrel paths count | odds_risk=true, arc_timed=true, wild_soft=true, ladder_sure=true | 600000 | 1,500 | 97.8% (97.1% with fireballs) | 96.9% | 0.0% | 4,200 |
| 2026-11-01 21:34 | v14 | Fresh exam: 3,000 new games, newest version |  | 700000 | 3,000 | 97.1% (96.4% with fireballs) | 96.4% | 0.0% | 4,200 |
| 2026-11-01 21:47 | v14old | Same 3,000 games, previous version, to compare | odds_risk=false, arc_timed=false, wild_soft=false, ladder_sure=false | 700000 | 3,000 | 97.6% (96.9% with fireballs) | 97.0% | 0.0% | 4,100 |
| 2026-11-01 22:19 | k0 | New test games: best version so far | odds_risk=false, arc_timed=false | 800000 | 3,000 | 97.0% (96.0% with fireballs) | 96.4% | 0.0% | 4,100 |
| 2026-11-01 22:32 | k1 | Plus: might-come-down barrels judged by whether he could react, and exact girder-end timing |  | 800000 | 3,000 | 97.6% (96.4% with fireballs) | 97.0% | 0.0% | 4,200 |
| 2026-11-01 22:47 | k2 | Plus: weighs each possible wild bounce by its measured odds | wild_rays=true | 800000 | 3,000 | 96.9% (95.7% with fireballs) | 96.2% | 0.0% | 4,200 |
| 2026-11-01 23:01 | k3 | Plus: Kong's next barrel predicted properly | wild_rays=true, kong_fix=true | 800000 | 3,000 | 96.1% (94.0% with fireballs) | 95.3% | 0.0% | 4,100 |
| 2026-11-01 23:12 | zc | Safety check: switches off should change nothing |  | 800000 | 200 | 98.0% (97.5% with fireballs) | 94.9% | 0.0% | 4,200 |
| 2026-11-01 23:29 | m1 | Tries: sticks with his choice instead of changing his mind under a barrel | w_commit=20 | 800000 | 3,000 | 85.2% (84.3% with fireballs) | 83.9% | 0.0% | 4,100 |
| 2026-11-01 23:43 | m2 | Tries: watches Kong's rhythm and avoids jumping as a wild barrel could drop | kong_watch=true | 800000 | 3,000 | 93.6% (92.5% with fireballs) | 92.7% | 0.0% | 4,200 |
| 2026-11-02 00:01 | m3 | Tries: both | w_commit=20, kong_watch=true | 800000 | 3,000 | 85.6% (84.7% with fireballs) | 84.3% | 0.0% | 4,100 |
| 2026-11-02 00:04 | zt3 | Quick check that the new code runs | top_guard=true, kong_watch=true, w_commit=20, odds_fallback=true | 900000 | 32 | 90.6% (90.6% with fireballs) | 75.8% | 0.0% | 4,100 |
| 2026-11-02 00:20 | n1 | Bug fix: he no longer presses jump on the last rungs of a ladder | top_guard=true | 800000 | 3,000 | 97.5% (96.4% with fireballs) | 96.9% | 0.0% | 4,200 |
| 2026-11-02 00:42 | n2 | Plus: watches Kong's rhythm and weighs jumping as a wild barrel could drop | top_guard=true, kong_watch=true | 800000 | 3,000 | 91.2% (90.2% with fireballs) | 90.2% | 0.0% | 4,200 |
| 2026-11-02 01:04 | n3 | Plus: doesn't turn back under a falling barrel without good reason | top_guard=true, kong_watch=true, w_commit=20 | 800000 | 3,000 | 93.3% (92.2% with fireballs) | 92.4% | 0.0% | 4,200 |
| 2026-11-02 01:25 | n4 | Plus: with no clean option left, plays the measured odds of the bounce | top_guard=true, kong_watch=true, w_commit=20, odds_fallback=true | 800000 | 3,000 | 93.5% (92.3% with fireballs) | 92.5% | 0.0% | 4,200 |
| 2026-11-02 01:29 | zt4 | Quick check that the new code runs | top_guard=true, kong_watch=true, w_commit=20, ham_face=true | 900000 | 32 | 87.5% (87.5% with fireballs) | 71.9% | 0.0% | 4,100 |
| 2026-11-02 01:48 | o0 | Hammer: no jumps while holding it, turns to face barrels, and normally stays away from it | top_guard=true, ham_face=true, ham_avoid=true | 800000 | 3,000 | 97.8% (96.7% with fireballs) | 97.3% | 0.0% | 4,200 |
| 2026-11-02 02:08 | o1 | Plus: watches Kong's rhythm, and uses the hammer if he gets it | top_guard=true, ham_face=true, kong_watch=true, w_commit=20 | 800000 | 3,000 | 93.0% (91.9% with fireballs) | 92.1% | 0.0% | 4,200 |
| 2026-11-02 02:28 | o2 | Plus: watches Kong's rhythm, and stays away from the hammer | top_guard=true, ham_face=true, ham_avoid=true, kong_watch=true, w_commit=20 | 800000 | 3,000 | 97.9% (96.7% with fireballs) | 97.4% | 0.0% | 4,200 |
| 2026-11-02 02:49 | o3 | Plus: with no clean option left, plays the measured odds | top_guard=true, ham_face=true, ham_avoid=true, kong_watch=true, w_commit=20, odds_fallback=true | 800000 | 3,000 | 98.0% (96.8% with fireballs) | 97.5% | 0.0% | 4,200 |
| 2026-11-02 03:08 | p0 | Fresh exam: the current best version |  | 1000000 | 3,000 | 97.6% (96.5% with fireballs) | 97.0% | 0.0% | 4,200 |
| 2026-11-02 03:29 | p1 | Fresh exam: watches Kong's rhythm, stays steady, keeps away from the hammer, plays the odds when stuck | top_guard=true, ham_face=true, ham_avoid=true, kong_watch=true, w_commit=20, odds_fallback=true | 1000000 | 3,000 | 97.9% (96.7% with fireballs) | 97.3% | 0.0% | 4,200 |
| 2026-11-02 03:39 | zt5 | Quick check that the new code runs | arc_snap=true, kong_y=145 | 900000 | 32 | 96.9% (96.9% with fireballs) | 84.3% | 0.0% | 4,200 |
| 2026-11-02 03:59 | q0 | Tries: wild barrels from Kong followed past their first bounce |  | 1000000 | 3,000 | 97.9% (96.7% with fireballs) | 97.3% | 0.0% | 4,200 |
| 2026-11-02 04:20 | q1 | Plus: barrels coming back from a girder end predicted exactly | arc_snap=true | 1000000 | 3,000 | 98.3% (97.1% with fireballs) | 97.8% | 0.0% | 4,200 |
| 2026-11-02 04:39 | q2 | Plus: weighs Kong's next wild barrel one floor lower too | arc_snap=true, kong_y=145 | 1000000 | 3,000 | 98.0% (97.0% with fireballs) | 97.4% | 0.0% | 4,200 |
| 2026-11-02 04:50 | zt6 | Quick check that the new code runs | wild_smooth=true | 900000 | 32 | 93.8% (93.8% with fireballs) | 79.9% | 0.0% | 4,100 |
| 2026-11-02 05:10 | r1 | Tries: judges a wild barrel by how it has moved since its last bounce | wild_smooth=true | 1000000 | 3,000 | 98.2% (97.0% with fireballs) | 97.7% | 0.0% | 4,200 |
| 2026-11-02 05:30 | s0 | Fresh exam: before the girder-end prediction fix | arc_snap=false | 1200000 | 3,000 | 97.6% (96.3% with fireballs) | 97.0% | 0.0% | 4,200 |
| 2026-11-02 05:50 | s1 | Fresh exam: with the girder-end prediction fix |  | 1200000 | 3,000 | 97.8% (96.6% with fireballs) | 97.2% | 0.0% | 4,200 |
| 2026-11-02 06:10 | s2 | Fresh exam: plus judges wild barrels by their motion since the last bounce | wild_smooth=true | 1200000 | 3,000 | 98.1% (97.0% with fireballs) | 97.6% | 0.0% | 4,200 |
| 2026-11-02 06:19 | zt7 | Quick check that the new code runs | first_drift=true | 900000 | 32 | 100.0% (100.0% with fireballs) | 89.3% | 0.0% | 4,100 |
| 2026-11-02 06:39 | t0 | New games: current best version |  | 1400000 | 3,000 | 98.2% (96.9% with fireballs) | 97.7% | 0.0% | 4,200 |
| 2026-11-02 07:00 | t1 | Tries: reads a wild barrel's speed properly as it leaves Kong | first_drift=true | 1400000 | 3,000 | 98.7% (97.3% with fireballs) | 98.2% | 0.0% | 4,200 |
| 2026-11-02 07:20 | t2 | Plus: takes Kong's rhythm twice as seriously | first_drift=true, kong_chance=0.2 | 1400000 | 3,000 | 98.6% (97.2% with fireballs) | 98.2% | 0.0% | 4,200 |
| 2026-11-02 07:48 | t1c | Same 3,000 games, with floors now measured properly |  | 1400000 | 3,000 | 98.7% (97.3% with fireballs) | 98.2% | 0.0% | 4,200 |
| 2026-11-02 07:48 | u0 | Quick check that 2-1 runs |  | 2000000 | 32 | 83.9% (81.2% with fireballs) | 67.4% | 83.9% | 15,000 |
| 2026-11-02 08:03 | u1 | First look at level 2-1, using the 1-1 player unchanged |  | 2000000 | 3,000 | 88.1% (86.9% with fireballs) | 86.9% | 88.1% | 15,000 |
| 2026-11-02 08:03 | zu0 | Quick check of the score fix |  | 2000000 | 16 | 93.8% (93.8% with fireballs) | 71.7% | 0.0% | 5,300 |
| 2026-11-02 08:05 | zu1 | Quick check of the score fix |  | 2000000 | 16 | 86.7% (81.2% with fireballs) | 62.1% | 0.0% | 5,200 |
| 2026-11-02 08:05 | zv1 | Quick check that 1-1 is unchanged |  | 1400000 | 16 | 100.0% (100.0% with fireballs) | 80.6% | 0.0% | 4,200 |
| 2026-11-02 08:30 | v1 | 2-1: treats every barrel that might take a ladder as coming | odds_risk=false | 2000000 | 1,000 | 82.5% (81.3% with fireballs) | 80.0% | 0.0% | 5,200 |
| 2026-11-02 08:34 | v2 | 2-1: allows more time to react to a barrel taking a ladder | respond=24 | 2000000 | 1,000 | 88.2% (87.1% with fireballs) | 86.0% | 0.0% | 5,200 |
| 2026-11-02 08:39 | v3 | 2-1: holds back longer from barrels that might drop | maybe_within=70 | 2000000 | 1,000 | 87.7% (86.8% with fireballs) | 85.5% | 0.0% | 5,200 |
| 2026-11-02 08:46 | w1 | 2-1: barrels come down ladders at their true speed | drop_rate=1.0 | 2000000 | 1,000 | 88.4% (87.8% with fireballs) | 86.3% | 0.0% | 5,200 |
| 2026-11-02 08:51 | w2 | 2-1: plans around the ladders barrels take most often | sure_ladders={[5]={[92]=true},[4]={[130]=true},[3]={[116]=true}} | 2000000 | 1,000 | 86.5% (85.6% with fireballs) | 84.2% | 0.0% | 5,200 |
| 2026-11-02 08:55 | w3 | 2-1: same, including the top ladder, at true speed | drop_rate=1.0, sure_ladders={[6]={[106]=true},[5]={[92]=true},[4]={[130]=true},[3]={[116]=true}} | 2000000 | 1,000 | 88.0% (87.1% with fireballs) | 85.8% | 0.0% | 5,200 |
| 2026-11-02 09:01 | x1 | 2-1: waits further from ladders | standoff=18 | 2000000 | 1,000 | 87.4% (84.8% with fireballs) | 85.2% | 0.0% | 5,200 |
| 2026-11-02 09:05 | x2 | 2-1: free to jump sideways on floors 3 and 4 | w_sideways3=0, w_sideways4=0 | 2000000 | 1,000 | 87.0% (86.5% with fireballs) | 84.8% | 0.0% | 5,200 |
| 2026-11-02 09:09 | x3 | 2-1: both, with true ladder speed | standoff=18, w_sideways3=0, w_sideways4=0, drop_rate=1.0 | 2000000 | 1,000 | 85.7% (84.0% with fireballs) | 83.4% | 0.0% | 5,200 |
| 2026-11-02 09:15 | y1 | 2-1: waits further from the floor 4 ladder only | standoff4=18 | 2000000 | 1,000 | 88.8% (87.3% with fireballs) | 86.7% | 0.0% | 5,200 |
| 2026-11-02 09:19 | y2 | 2-1: takes the nearer ladder up from floor 4 | ladder4=91, ladder4_top=112 | 2000000 | 1,000 | 87.4% (86.6% with fireballs) | 85.2% | 0.0% | 5,200 |
| 2026-11-02 09:23 | y3 | 2-1: nearer ladder, waiting further from it | ladder4=91, ladder4_top=112, standoff4=18 | 2000000 | 1,000 | 89.8% (87.6% with fireballs) | 87.8% | 0.0% | 5,200 |
| 2026-11-02 09:28 | z1 | 2-1: lets go of the stick as a barrel crosses a ladder above | steer_off=6 | 2000000 | 1,000 | 68.0% (62.4% with fireballs) | 64.9% | 0.0% | 4,900 |
| 2026-11-02 09:32 | z2 | 2-1: lets go a little earlier | steer_off=12 | 2000000 | 1,000 | 36.6% (31.4% with fireballs) | 33.4% | 0.0% | 4,700 |
| 2026-11-02 09:38 | z3 | 2-1: lets go, with true ladder speed | steer_off=6, drop_rate=1.0 | 2000000 | 1,000 | 53.7% (49.8% with fireballs) | 50.5% | 0.0% | 4,900 |
| 2026-11-02 09:56 | la1 | 2-1: stops pressing towards a ladder as a barrel crosses it just above | steer_off=6 | 2000000 | 1,000 | 85.2% (83.3% with fireballs) | 82.8% | 0.0% | 5,100 |
| 2026-11-02 10:03 | la2 | 2-1: same, for barrels up to two floors above | steer_off=6, steer_floors=2 | 2000000 | 1,000 | 85.7% (84.5% with fireballs) | 83.4% | 0.0% | 5,100 |
| 2026-11-02 10:10 | la3 | 2-1: same, a little earlier | steer_off=10 | 2000000 | 1,000 | 85.9% (84.0% with fireballs) | 83.6% | 0.0% | 5,100 |
| 2026-11-02 10:17 | lb1 | 2-1: eases off the stick for barrels above, on floor 5 only | steer_off=10, steer_here={[5]=true} | 2000000 | 1,000 | 88.1% (87.4% with fireballs) | 85.9% | 0.0% | 5,200 |
| 2026-11-02 10:23 | lb2 | 2-1: same, with the nearer ladder up from floor 4 | steer_off=10, steer_here={[5]=true}, ladder4=91, ladder4_top=112 | 2000000 | 1,000 | 88.2% (87.5% with fireballs) | 86.0% | 0.0% | 5,200 |
| 2026-11-02 10:29 | lb3 | 2-1: same, also waiting further from that ladder | steer_off=10, steer_here={[5]=true}, ladder4=91, ladder4_top=112, standoff4=18 | 2000000 | 1,000 | 90.2% (87.7% with fireballs) | 88.2% | 0.0% | 5,100 |
| 2026-11-02 10:36 | ld1 | 2-1: climbs with a little less clear time at the top | after_climb=14 | 2000000 | 1,000 | 89.7% (89.1% with fireballs) | 87.7% | 0.0% | 5,300 |
| 2026-11-02 10:41 | ld2 | 2-1: climbs with much less clear time at the top | after_climb=6 | 2000000 | 1,000 | 74.3% (74.0% with fireballs) | 71.5% | 0.0% | 5,300 |
| 2026-11-02 10:46 | ld3 | 2-1: less clear time, with the nearer ladder | after_climb=14, ladder4=91, ladder4_top=112 | 2000000 | 1,000 | 89.3% (88.6% with fireballs) | 87.2% | 0.0% | 5,200 |
| 2026-11-02 10:53 | le1 | 2-1: less clear time needed, floor 4 ladder only | after_climb4=10 | 2000000 | 1,000 | 89.1% (88.4% with fireballs) | 87.0% | 0.0% | 5,200 |
| 2026-11-02 10:59 | le2 | 2-1: even less at the floor 4 ladder | after_climb4=6 | 2000000 | 1,000 | 87.5% (86.9% with fireballs) | 85.3% | 0.0% | 5,200 |
| 2026-11-02 11:05 | le3 | 2-1: less on floors 2, 3 and 4, top ladders unchanged | after_climb4=10, after_climb3=14, after_climb2=14 | 2000000 | 1,000 | 89.8% (89.3% with fireballs) | 87.8% | 0.0% | 5,300 |
| 2026-11-02 11:21 | lf1 | 2-1: best so far, plus easing off the stick on floor 5 | after_climb4=10, after_climb3=14, after_climb2=14, steer_off=10, steer_here={[5]=true} | 2000000 | 1,000 | 90.6% (90.0% with fireballs) | 88.7% | 0.0% | 5,200 |
| 2026-11-02 11:27 | lf2 | 2-1: best so far, plus true ladder speed | after_climb4=10, after_climb3=14, after_climb2=14, drop_rate=1.0 | 2000000 | 1,000 | 89.8% (89.2% with fireballs) | 87.8% | 0.0% | 5,200 |
| 2026-11-02 11:32 | lf3 | 2-1: best so far, plus the nearer ladder | after_climb4=10, after_climb3=14, after_climb2=14, ladder4=91, ladder4_top=112 | 2000000 | 1,000 | 89.8% (89.1% with fireballs) | 87.8% | 0.0% | 5,200 |
| 2026-11-02 11:38 | lg1 | 2-1: best so far, knows Kong throws less soon here | after_climb4=10, after_climb3=14, after_climb2=14, throw_every=96 | 2000000 | 1,000 | 87.6% (86.9% with fireballs) | 85.4% | 0.0% | 5,200 |
| 2026-11-02 11:44 | lg2 | 2-1: best so far, knows when wild barrels can come here | after_climb4=10, after_climb3=14, after_climb2=14, wild_after=72 | 2000000 | 1,000 | 90.4% (89.9% with fireballs) | 88.5% | 0.0% | 5,300 |
| 2026-11-02 11:50 | lg3 | 2-1: best so far, with both of Kong's timings | after_climb4=10, after_climb3=14, after_climb2=14, throw_every=96, wild_after=72 | 2000000 | 1,000 | 88.2% (87.4% with fireballs) | 86.0% | 0.0% | 5,200 |
| 2026-11-02 11:56 | lh1 | 2-1: climbing, easing off and wild timing together | after_climb4=10, after_climb3=14, after_climb2=14, steer_off=10, steer_here={[5]=true}, wild_after=72 | 2000000 | 1,000 | 90.9% (90.2% with fireballs) | 89.0% | 0.0% | 5,200 |
| 2026-11-02 12:03 | lh2 | 2-1: same, expects Kong's next throw sooner | after_climb4=10, after_climb3=14, after_climb2=14, steer_off=10, steer_here={[5]=true}, wild_after=72, throw_every=64 | 2000000 | 1,000 | 89.3% (88.5% with fireballs) | 87.2% | 0.0% | 5,200 |
| 2026-11-02 12:10 | lh3 | 2-1: same, expects it sooner still | after_climb4=10, after_climb3=14, after_climb2=14, steer_off=10, steer_here={[5]=true}, wild_after=72, throw_every=48 | 2000000 | 1,000 | 81.7% (81.1% with fireballs) | 79.1% | 0.0% | 5,200 |
| 2026-11-02 12:11 | zlv | Quick check of level settings |  | 2000000 | 16 | 100.0% (100.0% with fireballs) | 80.6% | 0.0% | 5,200 |
| 2026-11-02 12:31 | ex0 | Fresh test of 2-1: the 1-1 player unchanged | levels=nil | 2200000 | 3,000 | 89.0% (88.0% with fireballs) | 87.9% | 0.0% | 5,200 |
| 2026-11-02 12:53 | ex1 | Fresh test of 2-1: with what we've learned so far |  | 2200000 | 3,000 | 90.9% (90.5% with fireballs) | 89.8% | 0.0% | 5,200 |
| 2026-11-02 13:17 | rg1 | Checking 1-1 hasn't got worse |  | 1400000 | 3,000 | 98.7% (97.3% with fireballs) | 98.2% | 0.0% | 4,200 |
| 2026-11-02 13:34 | na1 | 2-1: lets go of the stick in mid-air, so barrels aren't drawn down ladders | air_free=true | 2000000 | 1,000 | 91.0% (90.7% with fireballs) | 89.0% | 0.0% | 5,100 |
| 2026-11-02 13:49 | na2 | 2-1: same, and eases off walking towards a ladder on floors 4 and 5 | air_free=true, levels={[2]={after_climb2=14,after_climb3=14,after_climb4=10,steer_off=10,steer_here={[4]=true,[5]=true},wild_after=72}} | 2000000 | 1,000 | 87.6% (87.2% with fireballs) | 85.4% | 0.0% | 5,000 |
| 2026-11-02 14:04 | na3 | 2-1: same, and eases off on every floor | air_free=true, levels={[2]={after_climb2=14,after_climb3=14,after_climb4=10,steer_off=10,steer_here=nil,wild_after=72}} | 2000000 | 1,000 | 84.6% (84.0% with fireballs) | 82.2% | 0.0% | 5,000 |
| 2026-11-02 14:12 | nb1 | 2-1: lets go of the stick in mid-air on floor 5 only | air_free={[5]=true} | 2000000 | 1,000 | 92.8% (92.2% with fireballs) | 91.1% | 0.0% | 5,100 |
| 2026-11-02 14:19 | nb2 | 2-1: lets go in mid-air on floors 2, 3 and 5 | air_free={[2]=true,[3]=true,[5]=true} | 2000000 | 1,000 | 91.2% (91.0% with fireballs) | 89.3% | 0.0% | 5,100 |
| 2026-11-02 14:27 | nb3 | 2-1: lets go in mid-air on floor 4 only | air_free={[4]=true} | 2000000 | 1,000 | 89.8% (88.8% with fireballs) | 87.7% | 0.0% | 5,200 |
| 2026-11-02 14:28 | zd1 | Quick check of letting go in mid-air on floor 5 |  | 2000000 | 16 | 100.0% (100.0% with fireballs) | 80.6% | 0.0% | 5,100 |
| 2026-11-02 14:35 | nc1 | 2-1: weighs true odds of a barrel taking a ladder, using the game's rule | stick_odds=0.125 | 2000000 | 1,000 | 92.7% (92.1% with fireballs) | 90.9% | 0.0% | 5,100 |
| 2026-11-02 14:43 | nc2 | 2-1: same, smaller weight | stick_odds=0.05 | 2000000 | 1,000 | 92.4% (91.8% with fireballs) | 90.5% | 0.0% | 5,100 |
| 2026-11-02 14:50 | nc3 | 2-1: same, larger weight | stick_odds=0.25 | 2000000 | 1,000 | 92.8% (92.2% with fireballs) | 91.1% | 0.0% | 5,100 |
| 2026-11-02 14:56 | nd1 | 2-1: takes the nearer ladder on floor 4 | ladder4=91, ladder4_top=112 | 2000000 | 1,000 | 91.1% (90.4% with fireballs) | 89.2% | 0.0% | 5,100 |
| 2026-11-02 15:04 | nd2 | 2-1: presses left in mid-air on floor 4, drawing barrels down | air_steer={[4]=1} | 2000000 | 1,000 | 89.9% (89.1% with fireballs) | 87.9% | 0.0% | 5,100 |
| 2026-11-02 15:11 | nd3 | 2-1: presses right in mid-air on floor 4 | air_steer={[4]=2} | 2000000 | 1,000 | 91.3% (90.5% with fireballs) | 89.4% | 0.0% | 5,100 |
| 2026-11-02 15:18 | nd4 | 2-1: presses left in mid-air on floor 3 | air_steer={[3]=1} | 2000000 | 1,000 | 92.3% (91.5% with fireballs) | 90.5% | 0.0% | 5,100 |
| 2026-11-02 15:41 | ex2 | Fresh test of 2-1: now letting go of the stick in mid-air on floor 5 |  | 2200000 | 3,000 | 90.9% (90.6% with fireballs) | 89.9% | 0.0% | 5,100 |
| 2026-11-02 16:04 | rg2 | Checking 1-1 hasn't got worse |  | 1400000 | 3,000 | 98.7% (97.3% with fireballs) | 98.2% | 0.0% | 4,200 |
| 2026-11-02 16:28 | oa1 | 1-1: tries letting go of the stick in mid-air on floor 5 | air_free={[5]=true} | 1400000 | 3,000 | 98.7% (97.4% with fireballs) | 98.2% | 0.0% | 4,100 |
| 2026-11-02 16:35 | ne1 | 2-1: waits further from the floor 4 ladder | standoff4=18 | 2000000 | 1,000 | 90.1% (89.3% with fireballs) | 88.1% | 0.0% | 5,100 |
| 2026-11-02 16:43 | ne2 | 2-1: waits a bit further from the floor 4 ladder | standoff4=14 | 2000000 | 1,000 | 91.7% (91.0% with fireballs) | 89.9% | 0.0% | 5,100 |
| 2026-11-02 17:00 | tn0 | 2-1: current best, as the yardstick on new games |  | 2400000 | 2,000 | 90.8% (90.3% with fireballs) | 89.5% | 0.0% | 5,200 |
| 2026-11-02 17:15 | tn1 | 2-1: second jump pressed 1 frame later, so it isn't lost | land_wait=7 | 2400000 | 2,000 | 91.1% (90.8% with fireballs) | 89.8% | 0.0% | 5,200 |
| 2026-11-02 17:30 | tn2 | 2-1: second jump pressed 2 frames later | land_wait=8 | 2400000 | 2,000 | 90.4% (89.9% with fireballs) | 89.1% | 0.0% | 5,200 |
| 2026-11-02 17:44 | tn3 | 2-1: second jump pressed 3 frames later | land_wait=9 | 2400000 | 2,000 | 89.8% (89.5% with fireballs) | 88.4% | 0.0% | 5,200 |
| 2026-11-02 17:57 | tp1 | 2-1: nearer ladder on floor 4, waiting on the far side so barrels roll away | ladder4=91, ladder4_top=112, arrive4=-1 | 2400000 | 2,000 | 93.0% (92.8% with fireballs) | 91.8% | 0.0% | 5,100 |
| 2026-11-02 18:10 | tp2 | 2-1: same, waiting closer to it | ladder4=91, ladder4_top=112, arrive4=-1, standoff4=6 | 2400000 | 2,000 | 86.1% (85.8% with fireballs) | 84.5% | 0.0% | 5,200 |
| 2026-11-02 18:21 | tp3 | 2-1: same, a little more clear time on that climb | ladder4=91, ladder4_top=112, arrive4=-1, levels={[2]={after_climb2=14,after_climb3=14,after_climb4=16,steer_off=10,steer_here={[5]=true},wild_after=72}} | 2400000 | 2,000 | 93.4% (93.2% with fireballs) | 92.3% | 0.0% | 5,100 |
| 2026-11-02 18:36 | ex3 | Fresh test of 2-1: nearer floor 4 ladder, waiting on the far side |  | 2200000 | 3,000 | 92.5% (92.3% with fireballs) | 91.6% | 0.0% | 5,100 |
| 2026-11-02 18:53 | rg3 | Checking 1-1 hasn't got worse |  | 1400000 | 3,000 | 98.7% (97.3% with fireballs) | 98.2% | 0.0% | 4,200 |
| 2026-11-02 19:01 | tq1 | 2-1: waits a bit further from the nearer ladder | levels={[2]={after_climb2=14,after_climb3=14,after_climb4=16,steer_off=10,steer_here={[5]=true},wild_after=72,ladder4=91,ladder4_top=112,arrive4=-1,standoff4=14}} | 2400000 | 2,000 | 92.4% (92.0% with fireballs) | 91.1% | 0.0% | 5,100 |
| 2026-11-02 19:10 | tq2 | 2-1: more clear time on the floor 4 climb | levels={[2]={after_climb2=14,after_climb3=14,after_climb4=24,steer_off=10,steer_here={[5]=true},wild_after=72,ladder4=91,ladder4_top=112,arrive4=-1,standoff4=10}} | 2400000 | 2,000 | 93.7% (93.4% with fireballs) | 92.5% | 0.0% | 5,100 |
| 2026-11-02 19:30 | gf1 | 2-1: can jump as soon as he knows he's off the ladder | guard_free=2 | 2400000 | 2,000 | 95.1% (94.8% with fireballs) | 94.1% | 0.0% | 5,100 |
| 2026-11-02 19:44 | gf2 | 2-1: same, a touch sooner | guard_free=0 | 2400000 | 2,000 | 93.2% (92.8% with fireballs) | 92.0% | 0.0% | 5,100 |
| 2026-11-02 19:57 | ex4 | Fresh test of 2-1: can jump as soon as he knows he's off the ladder |  | 2600000 | 3,000 | 94.0% (93.7% with fireballs) | 93.1% | 0.0% | 5,100 |
| 2026-11-02 20:10 | ex4b | Fresh test of 2-1: the version before that, for comparison | guard_free=nil, levels={[2]={after_climb2=14,after_climb3=14,steer_off=10,steer_here={[5]=true},wild_after=72,ladder4=91,ladder4_top=112,arrive4=-1}} | 2600000 | 3,000 | 92.7% (92.4% with fireballs) | 91.8% | 0.0% | 5,100 |
| 2026-11-02 20:27 | rg4 | Checking 1-1 hasn't got worse |  | 1400000 | 3,000 | 98.7% (97.3% with fireballs) | 98.2% | 0.0% | 4,200 |
| 2026-11-02 20:47 | oa2 | 1-1: tries jumping as soon as he knows he's off the ladder | guard_free=2 | 1400000 | 3,000 | 98.7% (97.3% with fireballs) | 98.2% | 0.0% | 4,200 |
| 2026-11-02 20:56 | nx1 | 2-1: plans a second jump at its true timing | seconds={9,16,30} | 2400000 | 2,000 | 91.1% (90.7% with fireballs) | 89.7% | 0.0% | 5,100 |
| 2026-11-02 21:06 | nx2 | 2-1: checks he can deal with the next barrel before he jumps | seconds={9,16,30}, w_no_next=150 | 2400000 | 2,000 | 96.0% (95.6% with fireballs) | 95.0% | 0.0% | 5,100 |
| 2026-11-02 21:16 | nx3 | 2-1: same, weighs it less heavily | seconds={9,16,30}, w_no_next=60 | 2400000 | 2,000 | 95.1% (94.7% with fireballs) | 94.0% | 0.0% | 5,100 |
| 2026-11-02 21:26 | ny1 | 2-1: checks the next barrel before jumping, usual second-jump plans | w_no_next=150 | 2400000 | 2,000 | 96.6% (96.3% with fireballs) | 95.7% | 0.0% | 5,100 |
| 2026-11-02 21:36 | ny2 | 2-1: checks the next barrel, weighs it more heavily | seconds={9,16,30}, w_no_next=300 | 2400000 | 2,000 | 96.0% (95.6% with fireballs) | 95.0% | 0.0% | 5,100 |
| 2026-11-02 21:47 | ny3 | 2-1: checks the next barrel, wants longer to stand where he lands | seconds={9,16,30}, w_no_next=150, next_tail=60 | 2400000 | 2,000 | 96.0% (95.7% with fireballs) | 95.1% | 0.0% | 5,100 |
| 2026-11-02 22:02 | ex5 | Fresh test of 2-1: checks he can deal with the next barrel before jumping |  | 2800000 | 3,000 | 95.0% (94.7% with fireballs) | 94.1% | 0.0% | 5,200 |
| 2026-11-02 22:17 | ex5k | Fresh test of 2-1: same, and times Kong's next barrel from his pose | kong_pose=true | 2800000 | 3,000 | 94.7% (94.4% with fireballs) | 93.8% | 0.0% | 5,200 |
| 2026-11-02 22:35 | rg5 | Checking 1-1 hasn't got worse |  | 1400000 | 3,000 | 98.7% (97.3% with fireballs) | 98.2% | 0.0% | 4,200 |
| 2026-11-02 22:40 | zf1 | Quick check of the new ladder settings | ladder_commit=true, retreat_top=8, w_under=60, thin_safe=30, next_risk=true | 3000000 | 16 | 87.5% (87.5% with fireballs) | 64.0% | 0.0% | 5,000 |
| 2026-11-02 22:50 | dv0 | 2-1: current best, as the yardstick on new games |  | 3000000 | 2,000 | 96.3% (95.9% with fireballs) | 95.4% | 0.0% | 5,100 |
| 2026-11-02 23:00 | dva | 2-1: decisive on ladders, knows when he's reached the bottom | ladder_commit=true | 3000000 | 2,000 | 94.4% (93.8% with fireballs) | 93.3% | 0.0% | 5,100 |
| 2026-11-02 23:11 | dvb | 2-1: same, and near the top he climbs on and jumps | ladder_commit=true, retreat_top=8 | 3000000 | 2,000 | 94.5% (93.8% with fireballs) | 93.4% | 0.0% | 5,100 |
| 2026-11-02 23:21 | dvc | 2-1: avoids jumping right under a ladder | w_under=60 | 3000000 | 2,000 | 96.2% (95.8% with fireballs) | 95.2% | 0.0% | 5,200 |
| 2026-11-02 23:32 | dvd | 2-1: with nothing comfortable left, takes the safest jump, not the forward one | thin_safe=30 | 3000000 | 2,000 | 95.8% (95.2% with fireballs) | 94.9% | 0.0% | 5,100 |
| 2026-11-02 23:44 | dve | 2-1: next-barrel check also counts barrels that may come down ladders | next_risk=true | 3000000 | 2,000 | 96.3% (95.8% with fireballs) | 95.4% | 0.0% | 5,200 |
| 2026-11-03 00:11 | dx1 | 2-1: presses for a second jump exactly when the game will take it | jump_ready=49 | 3000000 | 2,000 | 96.9% (96.5% with fireballs) | 96.0% | 0.0% | 5,100 |
| 2026-11-03 00:21 | dx2 | 2-1: same, one frame later to be sure | jump_ready=50 | 3000000 | 2,000 | 96.1% (95.7% with fireballs) | 95.1% | 0.0% | 5,100 |
| 2026-11-03 00:30 | dx3 | 2-1: same, planning second jumps at their real time | jump_ready=49, seconds={8,16,30} | 3000000 | 2,000 | 96.6% (96.2% with fireballs) | 95.8% | 0.0% | 5,100 |
| 2026-11-03 00:39 | dx4 | 2-1: one frame later, planning at the real time | jump_ready=50, seconds={9,16,30} | 3000000 | 2,000 | 96.1% (95.6% with fireballs) | 95.1% | 0.0% | 5,100 |
| 2026-11-03 00:48 | dx5 | 2-1: judges backing down a ladder at his real speed | ladder_true=4 | 3000000 | 2,000 | 95.8% (95.3% with fireballs) | 94.9% | 0.0% | 5,100 |
| 2026-11-03 01:07 | dy0 | 2-1: presses for a second jump one frame sooner | jump_ready=48 | 3000000 | 2,000 | 96.3% (95.9% with fireballs) | 95.4% | 0.0% | 5,100 |
| 2026-11-03 01:20 | dy1 | 2-1: right jump timing, climbs on when nearly at the top | jump_ready=49, retreat_top=8 | 3000000 | 2,000 | 96.6% (96.2% with fireballs) | 95.8% | 0.0% | 5,100 |
| 2026-11-03 01:32 | dy2 | 2-1: same, from further down | jump_ready=49, retreat_top=16 | 3000000 | 2,000 | 96.2% (95.8% with fireballs) | 95.3% | 0.0% | 5,200 |
| 2026-11-03 01:45 | dy3 | 2-1: right jump timing, never backs down a ladder | jump_ready=49, retreat_top=100 | 3000000 | 2,000 | 95.9% (95.5% with fireballs) | 94.9% | 0.0% | 5,200 |
| 2026-11-03 01:58 | dy4 | 2-1: right jump timing, knows he's on the ladder near the bottom | jump_ready=49, ladder_known=true | 3000000 | 2,000 | 97.0% (96.5% with fireballs) | 96.1% | 0.0% | 5,100 |
| 2026-11-03 02:11 | ea2 | 2-1: can stop on a ladder near the top and let barrels roll over | jump_ready=49, ladder_hold=16 | 3000000 | 2,000 | 96.0% (95.6% with fireballs) | 95.0% | 0.0% | 5,200 |
| 2026-11-03 02:24 | ea3 | 2-1: same, only very near the top | jump_ready=49, ladder_hold=12 | 3000000 | 2,000 | 96.6% (96.2% with fireballs) | 95.8% | 0.0% | 5,200 |
| 2026-11-03 02:37 | ea4 | 2-1: same, from further down | jump_ready=49, ladder_hold=24 | 3000000 | 2,000 | 95.6% (95.2% with fireballs) | 94.6% | 0.0% | 5,200 |
| 2026-11-03 02:49 | ea0 | 2-1: allows a frame for a press to become a jump | jump_ready=49, press_lag=1 | 3000000 | 2,000 | 96.5% (96.2% with fireballs) | 95.6% | 0.0% | 5,100 |
| 2026-11-03 03:01 | ea1 | 2-1: allows two frames for a press to become a jump | jump_ready=49, press_lag=2 | 3000000 | 2,000 | 97.0% (96.9% with fireballs) | 96.2% | 0.0% | 5,100 |
| 2026-11-03 03:20 | fb0 | 2-1 exam: right second-jump timing | jump_ready=49 | 3200000 | 3,000 | 96.7% (96.4% with fireballs) | 96.0% | 0.0% | 5,100 |
| 2026-11-03 03:38 | fb1 | 2-1 exam: same, allowing 2 frames for a press | jump_ready=49, press_lag=2 | 3200000 | 3,000 | 97.0% (96.7% with fireballs) | 96.3% | 0.0% | 5,100 |
| 2026-11-03 03:54 | fb2 | 2-1 exam: same, allowing 3 frames for a press | jump_ready=49, press_lag=3 | 3200000 | 3,000 | 95.5% (95.2% with fireballs) | 94.6% | 0.0% | 5,100 |
| 2026-11-03 04:13 | fb3 | 2-1 exam: previous best, for comparison |  | 3200000 | 3,000 | 96.3% (95.9% with fireballs) | 95.5% | 0.0% | 5,100 |
| 2026-11-03 04:25 | ea5 | 2-1: stops on a ladder only right at the safe spot | jump_ready=49, ladder_hold=9 | 3000000 | 2,000 | 96.9% (96.5% with fireballs) | 96.0% | 0.0% | 5,100 |
| 2026-11-03 04:55 | rg6 | Checking 1-1 hasn't got worse |  | 1400000 | 3,000 | 98.7% (97.3% with fireballs) | 98.2% | 0.0% | 4,200 |
| 2026-11-03 05:14 | ob1 | 1-1: right second-jump timing, allowing 2 frames for a press | jump_ready=49, press_lag=2 | 1400000 | 3,000 | 98.0% (96.8% with fireballs) | 97.4% | 0.0% | 4,100 |
| 2026-11-03 05:35 | ob2 | 1-1: right second-jump timing only | jump_ready=49 | 1400000 | 3,000 | 98.7% (97.3% with fireballs) | 98.2% | 0.0% | 4,200 |
| 2026-11-03 05:46 | ec1 | 2-1: stops on a ladder right at the safe spot | ladder_hold=10 | 3000000 | 2,000 | 96.9% (96.7% with fireballs) | 96.0% | 0.0% | 5,100 |
| 2026-11-03 05:56 | ec2 | 2-1: knows he's on the ladder near the bottom | ladder_known=true | 3000000 | 2,000 | 96.8% (96.7% with fireballs) | 95.9% | 0.0% | 5,100 |
| 2026-11-03 06:07 | ed1 | 2-1: lets go of the stick to steer only when nothing is pressing | steer_calm=true | 3000000 | 2,000 | 96.4% (96.2% with fireballs) | 95.5% | 0.0% | 5,100 |
| 2026-11-03 06:17 | ed2 | 2-1: knows how soon a second jump can really come | next_waits={7,9,14,20,28} | 3000000 | 2,000 | 96.9% (96.8% with fireballs) | 96.1% | 0.0% | 5,100 |
| 2026-11-03 06:27 | ed3 | 2-1: both | steer_calm=true, next_waits={7,9,14,20,28} | 3000000 | 2,000 | 96.4% (96.2% with fireballs) | 95.5% | 0.0% | 5,100 |
| 2026-11-03 06:37 | ee1 | 2-1: on a ladder, ignores wild barrels he only imagines | ladder_sure=true | 3000000 | 2,000 | 96.6% (96.5% with fireballs) | 95.8% | 0.0% | 5,100 |
| 2026-11-03 06:48 | ee2 | 2-1: on a ladder, a barrel Kong has not thrown yet does not turn him back | ladder_real=true | 3000000 | 2,000 | 96.6% (96.5% with fireballs) | 95.8% | 0.0% | 5,100 |
| 2026-11-03 06:58 | ee3 | 2-1: sets out to climb when a barrel will pass 8 below him | climb_ym=8 | 3000000 | 2,000 | 97.1% (97.0% with fireballs) | 96.3% | 0.0% | 5,100 |
| 2026-11-03 07:08 | ee4 | 2-1: same, 7 below | climb_ym=7 | 3000000 | 2,000 | 97.2% (97.1% with fireballs) | 96.4% | 0.0% | 5,100 |
| 2026-11-03 07:18 | ee5 | 2-1: plans around the top barrel taking the broken ladder | sure_ladders={[6]={[106]=true}} | 3000000 | 2,000 | 97.0% (96.9% with fireballs) | 96.2% | 0.0% | 5,100 |
| 2026-11-03 07:28 | ef1 | 2-1: keeps a planned move going when the ladder above is far off | steer_far=40 | 3000000 | 2,000 | 97.3% (97.1% with fireballs) | 96.5% | 0.0% | 5,100 |
| 2026-11-03 07:38 | ef2 | 2-1: floor 4 climb only needs to stay clear a little after the top | after_climb4=14 | 3000000 | 2,000 | 97.1% (97.0% with fireballs) | 96.3% | 0.0% | 5,100 |
| 2026-11-03 07:48 | ef3 | 2-1: same, a little longer | after_climb4=18 | 3000000 | 2,000 | 97.1% (97.0% with fireballs) | 96.3% | 0.0% | 5,100 |
| 2026-11-03 07:57 | ef4 | 2-1: floor 5 climb only needs to stay clear a little after the top | after_climb5=14 | 3000000 | 2,000 | 97.3% (97.2% with fireballs) | 96.5% | 0.0% | 5,100 |
| 2026-11-03 08:06 | ef5 | 2-1: sets out to climb with a tighter side margin | climb_xm=6 | 3000000 | 2,000 | 97.2% (97.0% with fireballs) | 96.4% | 0.0% | 5,100 |
| 2026-11-03 08:21 | rg7 | Checking 1-1 hasn't got worse |  | 1400000 | 3,000 | 98.7% (97.3% with fireballs) | 98.2% | 0.0% | 4,200 |
| 2026-11-03 08:34 | fg1 | 2-1 fresh exam: new best setting |  | 3400000 | 3,000 | 96.5% (96.0% with fireballs) | 95.8% | 0.0% | 5,100 |
| 2026-11-03 08:46 | fg0 | 2-1 fresh exam: the previous best on the same new games | climb_ym=9 | 3400000 | 3,000 | 96.5% (96.0% with fireballs) | 95.8% | 0.0% | 5,100 |
| 2026-11-03 09:00 | fg2 | 2-1 fresh exam: the previous best on the same new games (rerun, the first try was overridden) | climb_ym=9 | 3400000 | 3,000 | 96.1% (95.7% with fireballs) | 95.4% | 0.0% | 5,100 |
| 2026-11-03 11:27 | eg1 | 2-1: a barrel that only might take a ladder counts for less when choosing a jump | w_risk=250 | 3000000 | 2,000 | 97.4% (97.2% with fireballs) | 96.6% | 0.0% | 5,100 |
| 2026-11-03 11:36 | eg2 | 2-1: a barrel that only might take a ladder counts for less when choosing a jump | w_risk=120 | 3000000 | 2,000 | 97.2% (97.0% with fireballs) | 96.4% | 0.0% | 5,100 |
| 2026-11-03 11:44 | eg3 | 2-1: a barrel that only might take a ladder counts for less when choosing a jump | w_risk=60 | 3000000 | 2,000 | 96.1% (95.9% with fireballs) | 95.1% | 0.0% | 5,100 |
| 2026-11-03 11:53 | eh1 | 2-1: keeps climbing unless a real barrel threatens, with maybe-barrels weighed less | w_risk=250, ladder_real=true | 3000000 | 2,000 | 96.9% (96.8% with fireballs) | 96.0% | 0.0% | 5,100 |
| 2026-11-03 12:01 | eh2 | 2-1: maybe-barrels weighed a little more | w_risk=180 | 3000000 | 2,000 | 97.4% (97.3% with fireballs) | 96.7% | 0.0% | 5,100 |
| 2026-11-03 12:10 | eh3 | 2-1: a jump with no follow-up costs less | w_risk=250, w_no_next=100 | 3000000 | 2,000 | 97.4% (97.2% with fireballs) | 96.6% | 0.0% | 5,100 |
| 2026-11-03 12:18 | eh4 | 2-1: a tight squeeze costs less | w_risk=250, w_thin=50 | 3000000 | 2,000 | 97.2% (97.0% with fireballs) | 96.4% | 0.0% | 5,100 |
| 2026-11-03 12:26 | eh5 | 2-1: floor 5 prefers jumping sideways | w_risk=250, w_sideways5=-20 | 3000000 | 2,000 | 96.5% (96.3% with fireballs) | 95.6% | 0.0% | 5,100 |
| 2026-11-03 12:40 | ei1 | 2-1: expects Kong's next barrel down the broken ladder | next_drop={0} | 3000000 | 2,000 | 95.6% (95.5% with fireballs) | 94.6% | 0.0% | 5,100 |
| 2026-11-03 12:49 | ei2 | 2-1: same, allowing for it being thrown a little late | next_drop={0,16} | 3000000 | 2,000 | 95.6% (95.5% with fireballs) | 94.6% | 0.0% | 5,100 |
| 2026-11-03 12:58 | ei3 | 2-1: same, and keeps climbing unless a real barrel threatens | next_drop={0,16}, ladder_real=true | 3000000 | 2,000 | 95.4% (95.2% with fireballs) | 94.4% | 0.0% | 5,100 |
| 2026-11-03 13:14 | rg8 | Checking 1-1 hasn't got worse |  | 1400000 | 3,000 | 98.7% (97.3% with fireballs) | 98.2% | 0.0% | 4,200 |
| 2026-11-03 13:26 | fh1 | 2-1 fresh exam: new best setting |  | 3600000 | 3,000 | 96.4% (96.0% with fireballs) | 95.7% | 0.0% | 5,100 |
| 2026-11-03 13:39 | fh0 | 2-1 fresh exam: the setting before on the same new games | w_risk=500 | 3600000 | 3,000 | 96.4% (95.9% with fireballs) | 95.6% | 0.0% | 5,100 |
| 2026-11-03 13:48 | ej1 | 2-1: keeps climbing unless Kong's next barrel will reach the ladder top when he does | ladder_real=true, next_drop_climb={0} | 3000000 | 2,000 | 95.7% (95.4% with fireballs) | 94.7% | 0.0% | 5,100 |
| 2026-11-03 13:57 | ej2 | 2-1: same, allowing for a late throw | ladder_real=true, next_drop_climb={0,16} | 3000000 | 2,000 | 95.7% (95.4% with fireballs) | 94.7% | 0.0% | 5,100 |
| 2026-11-03 14:06 | ej3 | 2-1: same, allowing for a later throw still | ladder_real=true, next_drop_climb={0,16,32} | 3000000 | 2,000 | 95.7% (95.4% with fireballs) | 94.7% | 0.0% | 5,100 |
| 2026-11-03 16:12 | ek1 | 2-1: with a barrel close and coming at him, jumps the way it rolls | w_with=60 | 3000000 | 2,000 | 97.4% (97.2% with fireballs) | 96.7% | 0.0% | 5,100 |
| 2026-11-03 16:20 | ek2 | 2-1: same, stronger | w_with=120 | 3000000 | 2,000 | 97.4% (97.2% with fireballs) | 96.7% | 0.0% | 5,100 |
| 2026-11-03 16:29 | ek3 | 2-1: same, floor 5 only | w_with=60, with_floors={[5]=true} | 3000000 | 2,000 | 97.3% (97.2% with fireballs) | 96.5% | 0.0% | 5,100 |
| 2026-11-03 16:37 | ek4 | 2-1: same, stronger, floor 5 only | w_with=120, with_floors={[5]=true} | 3000000 | 2,000 | 97.3% (97.2% with fireballs) | 96.5% | 0.0% | 5,100 |
| 2026-11-03 16:37 | t0_3402727 | check one death | w_with=0 | 3402727 | 1 | 0.0% (0.0% with fireballs) | 0.0% | 0.0% | 0 |
| 2026-11-03 16:37 | t120_3402727 | check one death | w_with=120 | 3402727 | 1 | 0.0% (0.0% with fireballs) | 0.0% | 0.0% | 0 |
| 2026-11-03 16:37 | t0_3400020 | check one death | w_with=0 | 3400020 | 1 | 0.0% (0.0% with fireballs) | 0.0% | 0.0% | 0 |
| 2026-11-03 16:37 | t120_3400020 | check one death | w_with=120 | 3400020 | 1 | 0.0% (0.0% with fireballs) | 0.0% | 0.0% | 0 |
| 2026-11-03 16:37 | t0_3401055 | check one death | w_with=0 | 3401055 | 1 | 0.0% (0.0% with fireballs) | 0.0% | 0.0% | 0 |
| 2026-11-03 16:38 | t120_3401055 | check one death | w_with=120 | 3401055 | 1 | 0.0% (0.0% with fireballs) | 0.0% | 0.0% | 0 |
| 2026-11-03 16:38 | t0_3400001 | check one death | w_with=0 | 3400001 | 1 | 100.0% (100.0% with fireballs) | 20.7% | 0.0% | 5,200 |
| 2026-11-03 16:38 | t120_3400001 | check one death | w_with=120 | 3400001 | 1 | 0.0% (0.0% with fireballs) | 0.0% | 0.0% | 0 |
| 2026-11-03 16:38 | u0_3402727 | check one death | w_with=0, with_drop=true | 3402727 | 1 | 0.0% (0.0% with fireballs) | 0.0% | 0.0% | 0 |
| 2026-11-03 16:38 | u120_3402727 | check one death | w_with=120, with_drop=true | 3402727 | 1 | 100.0% (100.0% with fireballs) | 20.7% | 0.0% | 5,200 |
| 2026-11-03 16:48 | el1 | 2-1: with a barrel close and coming at him, even one still coming down a ladder, jumps the way it will roll | w_with=120, with_drop=true | 3000000 | 2,000 | 93.7% (93.2% with fireballs) | 92.6% | 0.0% | 5,100 |
| 2026-11-03 16:57 | el2 | 2-1: same, milder | w_with=60, with_drop=true | 3000000 | 2,000 | 95.1% (94.9% with fireballs) | 94.1% | 0.0% | 5,100 |
| 2026-11-03 17:06 | el3 | 2-1: same, only when it's very close | w_with=120, with_drop=true, with_x=12 | 3000000 | 2,000 | 94.4% (94.0% with fireballs) | 93.3% | 0.0% | 5,100 |
| 2026-11-03 17:15 | el4 | 2-1: same, a little further out | w_with=120, with_drop=true, with_x=22 | 3000000 | 2,000 | 92.7% (92.2% with fireballs) | 91.5% | 0.0% | 5,100 |
| 2026-11-03 17:16 | v120_3402727 | check one death | w_with=120, with_drop=true | 3402727 | 1 | 100.0% (100.0% with fireballs) | 20.7% | 0.0% | 5,200 |
| 2026-11-03 17:24 | em1 | 2-1: with a barrel close and coming at him, even one coming down a ladder beside him, jumps the way it will roll | w_with=120, with_drop=true | 3000000 | 2,000 | 97.2% (97.0% with fireballs) | 96.4% | 0.0% | 5,100 |
| 2026-11-03 17:32 | em2 | 2-1: same, milder | w_with=60, with_drop=true | 3000000 | 2,000 | 97.5% (97.3% with fireballs) | 96.7% | 0.0% | 5,100 |
| 2026-11-03 17:41 | em3 | 2-1: same, floor 5 only | w_with=120, with_drop=true, with_floors={[5]=true} | 3000000 | 2,000 | 97.1% (97.0% with fireballs) | 96.3% | 0.0% | 5,100 |
| 2026-11-03 17:50 | en1 | 2-1: back jump with a close barrel, only when he can deal with the next one too | w_with=60, with_drop=true, with_next=true | 3000000 | 2,000 | 97.5% (97.3% with fireballs) | 96.7% | 0.0% | 5,100 |
| 2026-11-03 17:58 | en2 | 2-1: same, stronger | w_with=120, with_drop=true, with_next=true | 3000000 | 2,000 | 97.2% (97.0% with fireballs) | 96.4% | 0.0% | 5,100 |
| 2026-11-03 18:07 | en3 | 2-1: same, milder | w_with=30, with_drop=true, with_next=true | 3000000 | 2,000 | 97.4% (97.2% with fireballs) | 96.6% | 0.0% | 5,100 |
| 2026-11-03 18:23 | fh2 | 2-1 fresh exam: back jump with a close barrel | w_with=60, with_drop=true | 3600000 | 3,000 | 96.3% (95.9% with fireballs) | 95.6% | 0.0% | 5,100 |
| 2026-11-03 18:32 | eo1 | 2-1: back jump with a close barrel, only when it clears comfortably | w_with=60, with_drop=true, with_cl=2 | 3000000 | 2,000 | 97.6% (97.4% with fireballs) | 96.8% | 0.0% | 5,100 |
| 2026-11-03 18:40 | eo2 | 2-1: same, needing more room | w_with=60, with_drop=true, with_cl=4 | 3000000 | 2,000 | 97.4% (97.2% with fireballs) | 96.6% | 0.0% | 5,100 |
| 2026-11-03 18:48 | eo3 | 2-1: same, stronger, needing more room | w_with=120, with_drop=true, with_cl=4 | 3000000 | 2,000 | 97.3% (97.2% with fireballs) | 96.5% | 0.0% | 5,100 |
| 2026-11-03 19:01 | fh3 | 2-1 fresh exam: back jump with a close barrel when it clears comfortably | w_with=60, with_drop=true, with_cl=2 | 3600000 | 3,000 | 96.6% (96.2% with fireballs) | 95.9% | 0.0% | 5,100 |
| 2026-11-03 19:32 | rg9 | Checking 1-1 hasn't got worse |  | 1400000 | 3,000 | 98.7% (97.3% with fireballs) | 98.2% | 0.0% | 4,200 |
| 2026-11-03 19:35 | fn1 | 2-1 on the native runner: must match the MAME exam fh3 game for game |  | 3600000 | 3,000 | 96.6% (96.2% with fireballs) | 95.9% | 0.0% | 5,100 |
| 2026-11-03 19:39 | ep1 | 2-1: back jump needing a little more room | with_cl=3 | 3000000 | 2,000 | 97.4% (97.2% with fireballs) | 96.6% | 0.0% | 5,100 |
| 2026-11-03 19:40 | eq1 | 2-1: back jump bonus milder | w_with=40 | 3000000 | 2,000 | 97.6% (97.4% with fireballs) | 96.8% | 0.0% | 5,100 |
| 2026-11-03 19:42 | eq2 | 2-1: back jump bonus stronger | w_with=90 | 3000000 | 2,000 | 97.4% (97.2% with fireballs) | 96.7% | 0.0% | 5,100 |
| 2026-11-03 19:44 | eq3 | 2-1: back jump only when the barrel is very close | with_x=12 | 3000000 | 2,000 | 97.4% (97.2% with fireballs) | 96.6% | 0.0% | 5,100 |
| 2026-11-03 19:45 | eq4 | 2-1: back jump from a little further out | with_x=20 | 3000000 | 2,000 | 97.2% (97.0% with fireballs) | 96.4% | 0.0% | 5,100 |
| 2026-11-03 19:47 | er1 | 2-1 retry on the new base: keeps climbing unless a real barrel threatens | ladder_real=true | 3000000 | 2,000 | 97.1% (96.9% with fireballs) | 96.3% | 0.0% | 5,100 |
| 2026-11-03 19:49 | er2 | 2-1 retry on the new base: keeps a planned move going when the ladder above is far off | steer_far=40 | 3000000 | 2,000 | 97.7% (97.5% with fireballs) | 97.0% | 0.0% | 5,100 |
| 2026-11-03 19:50 | er3 | 2-1 retry on the new base: lets go of the stick only when nothing is pressing | steer_calm=true | 3000000 | 2,000 | 97.1% (96.9% with fireballs) | 96.3% | 0.0% | 5,100 |
| 2026-11-03 19:52 | er4 | 2-1 retry on the new base: floor 5 prefers jumping sideways | w_sideways5=-20 | 3000000 | 2,000 | 96.6% (96.4% with fireballs) | 95.8% | 0.0% | 5,100 |
| 2026-11-03 21:02 | fh4 | 2-1 fresh exam: keeps a planned move going when the ladder above is far off | steer_far=40 | 3600000 | 3,000 | 96.5% (96.1% with fireballs) | 95.8% | 0.0% | 5,100 |
| 2026-11-03 21:04 | es1 | 2-1: keeps a planned move going when the ladder above is 30+ px away | steer_far=30 | 3000000 | 2,000 | 97.7% (97.5% with fireballs) | 97.0% | 0.0% | 5,100 |
| 2026-11-03 21:06 | es2 | 2-1: same, 50+ px away | steer_far=50 | 3000000 | 2,000 | 97.7% (97.5% with fireballs) | 97.0% | 0.0% | 5,100 |
| 2026-11-03 21:08 | et01 | 2-1 sweep: waits closer to a blocked ladder | standoff=7 | 3000000 | 2,000 | 95.8% (95.6% with fireballs) | 94.8% | 0.0% | 5,100 |
| 2026-11-03 21:10 | et02 | 2-1 sweep: waits further from a blocked ladder | standoff=14 | 3000000 | 2,000 | 97.1% (95.9% with fireballs) | 96.3% | 0.0% | 5,100 |
| 2026-11-03 21:11 | et03 | 2-1 sweep: a plan needs less room to count as safe | min_clear=3 | 3000000 | 2,000 | 97.7% (97.5% with fireballs) | 97.0% | 0.0% | 5,100 |
| 2026-11-03 21:13 | et04 | 2-1 sweep: a plan needs more room to count as safe | min_clear=5 | 3000000 | 2,000 | 96.9% (96.7% with fireballs) | 96.1% | 0.0% | 5,100 |
| 2026-11-03 21:15 | et05 | 2-1 sweep: extra room counts for less | clear_cap=4 | 3000000 | 2,000 | 96.9% (96.7% with fireballs) | 96.0% | 0.0% | 5,100 |
| 2026-11-03 21:17 | et06 | 2-1 sweep: extra room counts for more | clear_cap=8 | 3000000 | 2,000 | 97.1% (96.7% with fireballs) | 96.3% | 0.0% | 5,100 |
| 2026-11-03 21:19 | et07 | 2-1 sweep: progress matters less | w_prog=25 | 3000000 | 2,000 | 95.0% (94.2% with fireballs) | 93.9% | 0.0% | 5,100 |
| 2026-11-03 21:21 | et08 | 2-1 sweep: progress matters more | w_prog=60 | 3000000 | 2,000 | 96.0% (95.7% with fireballs) | 95.0% | 0.0% | 5,200 |
| 2026-11-03 21:23 | et09 | 2-1 sweep: each jump costs less | w_jump=5 | 3000000 | 2,000 | 96.5% (96.0% with fireballs) | 95.6% | 0.0% | 5,100 |
| 2026-11-03 21:24 | et10 | 2-1 sweep: each jump costs more | w_jump=30 | 3000000 | 2,000 | 97.8% (97.5% with fireballs) | 97.1% | 0.0% | 5,100 |
| 2026-11-03 21:26 | et11 | 2-1 sweep: a plan stays clear less long after its last move | plan_tail=14 | 3000000 | 2,000 | 95.9% (95.7% with fireballs) | 94.9% | 0.0% | 5,200 |
| 2026-11-03 21:28 | et12 | 2-1 sweep: a plan stays clear longer after its last move | plan_tail=28 | 3000000 | 2,000 | 89.9% (89.2% with fireballs) | 88.5% | 0.0% | 5,100 |
| 2026-11-03 21:31 | et13 | 2-1 sweep: less preference for moving later | w_later=0.2 | 3000000 | 2,000 | 96.9% (96.2% with fireballs) | 96.0% | 0.0% | 5,200 |
| 2026-11-03 21:38 | et14 | 2-1 sweep: more preference for moving later | w_later=0.9 | 3000000 | 2,000 | 87.8% (83.2% with fireballs) | 86.3% | 0.0% | 5,000 |
| 2026-11-03 21:46 | eu1 | 2-1: times Kong's next barrel from his pose | kong_pose=true | 3000000 | 2,000 | 96.5% (96.2% with fireballs) | 95.6% | 0.0% | 5,100 |
| 2026-11-03 21:48 | eu2 | 2-1: watches Kong: when he's about to throw, expects that barrel down the broken ladder | kong_pose=true, next_drop={0}, next_drop_pose=true | 3000000 | 2,000 | 95.9% (95.6% with fireballs) | 94.9% | 0.0% | 5,100 |
| 2026-11-03 21:49 | eu3 | 2-1: same, allowing for it a little late | kong_pose=true, next_drop={0,8}, next_drop_pose=true | 3000000 | 2,000 | 95.9% (95.6% with fireballs) | 94.9% | 0.0% | 5,100 |
| 2026-11-03 22:02 | fx1 | 2-1 big fresh exam, 10,000 new games: current best setting |  | 4000000 | 10,000 | 97.0% (96.6% with fireballs) | 96.7% | 0.0% | 5,100 |
| 2026-11-03 22:11 | fx2 | 2-1 big fresh exam, second set of 10,000 new games: current best setting |  | 4100000 | 10,000 | 97.1% (96.8% with fireballs) | 96.7% | 0.0% | 5,100 |
| 2026-11-03 22:16 | ga0m | 3-1 check: MAME |  | 5000000 | 200 | 75.6% (74.5% with fireballs) | 69.2% | 0.0% | 6,200 |
| 2026-11-03 22:19 | ga0 | 3-1 baseline: settings as for 1-1 |  | 5000000 | 3,000 | 76.2% (74.3% with fireballs) | 74.7% | 0.0% | 6,200 |
| 2026-11-03 22:22 | ga1 | 3-1 baseline: settings as for 2-1 |  | 5000000 | 3,000 | 75.5% (73.1% with fireballs) | 73.9% | 0.0% | 6,100 |
| 2026-11-03 22:25 | gb01 | 3-1: 2-1 settings without the back jump | w_with=nil | 5000000 | 3,000 | 76.0% (73.6% with fireballs) | 74.4% | 0.0% | 6,100 |
| 2026-11-03 22:28 | gb02 | 3-1: 2-1 settings without the halved risk penalty | w_risk=500 | 5000000 | 3,000 | 75.4% (73.0% with fireballs) | 73.8% | 0.0% | 6,100 |
| 2026-11-03 22:30 | gb03 | 3-1: 2-1 settings without the climb margin | climb_ym=9 | 5000000 | 3,000 | 75.1% (72.7% with fireballs) | 73.5% | 0.0% | 6,100 |
| 2026-11-03 22:33 | gb04 | 3-1: 2-1 settings without second-jump timing | jump_ready=nil | 5000000 | 3,000 | 75.2% (72.9% with fireballs) | 73.6% | 0.0% | 6,100 |
| 2026-11-03 22:36 | gb05 | 3-1: 2-1 settings without allowing for press lag | press_lag=nil | 5000000 | 3,000 | 81.0% (79.4% with fireballs) | 79.6% | 0.0% | 6,200 |
| 2026-11-03 22:38 | gb06 | 3-1: 2-1 settings, climbs on floors 2 and 3 as on 1-1 | after_climb2=nil, after_climb3=nil | 5000000 | 3,000 | 75.3% (72.5% with fireballs) | 73.7% | 0.0% | 6,100 |
| 2026-11-03 22:41 | gb07 | 3-1: 2-1 settings without letting go of the stick on floor 5 | steer_off=nil | 5000000 | 3,000 | 75.8% (73.6% with fireballs) | 74.3% | 0.0% | 6,100 |
| 2026-11-03 22:43 | gb08 | 3-1: 2-1 settings with Kong's wild timing as on 1-1 | wild_after=nil | 5000000 | 3,000 | 75.6% (73.2% with fireballs) | 74.0% | 0.0% | 6,100 |
| 2026-11-03 22:46 | gb09 | 3-1: 2-1 settings, climbing the usual floor 4 ladder | ladder4=nil, ladder4_top=nil, arrive4=nil | 5000000 | 3,000 | 72.6% (69.6% with fireballs) | 70.9% | 0.0% | 6,200 |
| 2026-11-03 22:49 | gb10 | 3-1: 2-1 settings without the guard after the top | guard_free=nil | 5000000 | 3,000 | 75.5% (73.1% with fireballs) | 73.9% | 0.0% | 6,100 |
| 2026-11-03 22:51 | gb11 | 3-1: 2-1 settings without the no-follow-up cost | w_no_next=nil | 5000000 | 3,000 | 71.2% (69.0% with fireballs) | 69.5% | 0.0% | 6,100 |
| 2026-11-03 22:55 | gc01 | 3-1: allows 1 frame for a press | press_lag=1 | 5000000 | 3,000 | 80.2% (78.3% with fireballs) | 78.7% | 0.0% | 6,100 |
| 2026-11-03 22:57 | gc02 | 3-1: without the back jump | w_with=nil | 5000000 | 3,000 | 79.6% (78.0% with fireballs) | 78.2% | 0.0% | 6,200 |
| 2026-11-03 23:00 | gc03 | 3-1: without letting go of the stick on floor 5 | steer_off=nil | 5000000 | 3,000 | 80.6% (79.0% with fireballs) | 79.2% | 0.0% | 6,200 |
| 2026-11-03 23:03 | gc04 | 3-1: wild barrels weighed more when deciding | kong_chance=1.5 | 5000000 | 3,000 | 80.8% (79.1% with fireballs) | 79.4% | 0.0% | 6,200 |
| 2026-11-03 23:06 | gc05 | 3-1: wild barrels weighed less when deciding | kong_chance=0.6 | 5000000 | 3,000 | 81.0% (79.3% with fireballs) | 79.5% | 0.0% | 6,200 |
| 2026-11-03 23:09 | gc06 | 3-1: a likely wild bounce blocks a ladder sooner | ray_block=0.25 | 5000000 | 3,000 | 81.0% (79.4% with fireballs) | 79.6% | 0.0% | 6,200 |
| 2026-11-03 23:11 | gc07 | 3-1: a likely wild bounce blocks a ladder later | ray_block=0.6 | 5000000 | 3,000 | 81.0% (79.4% with fireballs) | 79.6% | 0.0% | 6,200 |
| 2026-11-03 23:14 | gc08 | 3-1: looks further ahead for wild barrels | wild_tail=60 | 5000000 | 3,000 | 81.0% (79.4% with fireballs) | 79.6% | 0.0% | 6,200 |
| 2026-11-03 23:17 | gc09 | 3-1: wild meetings cost more | w_ray=2000 | 5000000 | 3,000 | 80.7% (79.0% with fireballs) | 79.2% | 0.0% | 6,200 |
| 2026-11-03 23:20 | gc10 | 3-1: wild meetings cost less | w_ray=500 | 5000000 | 3,000 | 81.2% (79.6% with fireballs) | 79.8% | 0.0% | 6,200 |
| 2026-11-03 23:32 | gd01 | 3-1: weighs where wild barrels may bounce by measured odds | wild_rays=true | 5000000 | 3,000 | 78.8% (77.4% with fireballs) | 77.3% | 0.0% | 6,200 |
| 2026-11-03 23:35 | gd02 | 3-1: on a ladder, only certain wild barrel paths count | ladder_sure=true | 5000000 | 3,000 | 81.5% (79.9% with fireballs) | 80.1% | 0.0% | 6,200 |
| 2026-11-03 23:38 | gd03 | 3-1: back jump bonus stronger | w_with=90 | 5000000 | 3,000 | 81.1% (79.4% with fireballs) | 79.7% | 0.0% | 6,200 |
| 2026-11-03 23:41 | gd04 | 3-1: back jump from a little further out | with_x=20 | 5000000 | 3,000 | 80.7% (79.0% with fireballs) | 79.2% | 0.0% | 6,200 |
| 2026-11-03 23:44 | ge01 | 3-1: after jumping past his waiting spot he has to walk back to it (model fix) | along_fix=true | 5000000 | 3,000 | 83.7% (82.0% with fireballs) | 82.3% | 0.0% | 6,200 |
| 2026-11-03 23:46 | ge02 | 2-1: same model fix | along_fix=true | 3000000 | 3,000 | 97.4% (97.2% with fireballs) | 96.7% | 0.0% | 5,100 |
| 2026-11-03 23:49 | ge00 | 2-1 reference on the practice games, current setting |  | 3000000 | 3,000 | 97.3% (97.1% with fireballs) | 96.6% | 0.0% | 5,100 |
| 2026-11-03 23:53 | gf00 | 3-1 reference: with the walk-back model fix |  | 5000000 | 3,000 | 83.7% (82.0% with fireballs) | 82.3% | 0.0% | 6,200 |
| 2026-11-03 23:56 | gf01 | 3-1: wild barrels leave Kong as measured on level 3 | kong_rays={{1,.71},{1.25,.07},{1.5,.12},{1.75,.05},{2,.06}} | 5000000 | 3,000 | 83.5% (81.8% with fireballs) | 82.1% | 0.0% | 6,200 |
| 2026-11-03 23:59 | gf02 | 3-1: same, and on a ladder only certain wild paths count | kong_rays={{1,.71},{1.25,.07},{1.5,.12},{1.75,.05},{2,.06}}, ladder_sure=true | 5000000 | 3,000 | 83.7% (82.1% with fireballs) | 82.3% | 0.0% | 6,200 |
| 2026-11-04 00:01 | gf03 | 3-1: on a ladder only certain wild paths count | ladder_sure=true | 5000000 | 3,000 | 84.0% (82.4% with fireballs) | 82.6% | 0.0% | 6,200 |
| 2026-11-04 00:06 | gg01 | 3-1: each time a wild barrel lands, it heads for Mario | wild_toward=true | 5000000 | 3,000 | 82.6% (80.9% with fireballs) | 81.2% | 0.0% | 6,200 |
| 2026-11-04 00:08 | gg02 | 3-1: same, at least 1 px a frame | wild_toward=true, wild_spd=1 | 5000000 | 3,000 | 83.0% (81.5% with fireballs) | 81.6% | 0.0% | 6,100 |
| 2026-11-04 00:11 | gg03 | 3-1: same, plus on a ladder only certain wild paths count | wild_toward=true, wild_spd=1, ladder_sure=true | 5000000 | 3,000 | 82.8% (81.3% with fireballs) | 81.4% | 0.0% | 6,200 |
| 2026-11-04 00:14 | gh01 | 3-1: wild barrels at least 1 px a frame after landing, either way | wild_spd=1 | 5000000 | 3,000 | 83.2% (81.8% with fireballs) | 81.8% | 0.0% | 6,200 |
| 2026-11-04 00:17 | gh02 | 3-1: wild barrels go left or right after landing, never stay | wild_sides={1,-1} | 5000000 | 3,000 | 83.4% (81.8% with fireballs) | 82.0% | 0.0% | 6,200 |
| 2026-11-04 00:20 | gh03 | 3-1: both | wild_spd=1, wild_sides={1,-1} | 5000000 | 3,000 | 82.0% (80.6% with fireballs) | 80.6% | 0.0% | 6,200 |
| 2026-11-04 00:24 | gh04 | 3-1: both, plus on a ladder only certain wild paths count | wild_spd=1, wild_sides={1,-1}, ladder_sure=true | 5000000 | 3,000 | 82.2% (80.7% with fireballs) | 80.7% | 0.0% | 6,200 |
| 2026-11-04 00:29 | gi01 | 3-1: measured wild speed for jumps and walking, old model on ladders | wild_split=true, wild_spd=1 | 5000000 | 3,000 | 83.7% (82.3% with fireballs) | 82.3% | 0.0% | 6,200 |
| 2026-11-04 00:33 | gi02 | 3-1: same, and never staying put | wild_split=true, wild_spd=1, wild_sides={1,-1} | 5000000 | 3,000 | 83.4% (81.8% with fireballs) | 82.0% | 0.0% | 6,200 |
| 2026-11-04 00:37 | gi03 | 3-1: heads for Mario for jumps and walking, old model on ladders | wild_split=true, wild_toward=true, wild_spd=1 | 5000000 | 3,000 | 83.6% (82.1% with fireballs) | 82.2% | 0.0% | 6,100 |
| 2026-11-04 00:40 | gi04 | 3-1: never staying put, for jumps and walking only | wild_split=true, wild_sides={1,-1} | 5000000 | 3,000 | 83.6% (81.9% with fireballs) | 82.3% | 0.0% | 6,200 |
| 2026-11-04 00:45 | gj01 | 3-1: watches for Kong's wild release from anywhere on the board, level-3 directions | kong_rays={{1,.71},{1.25,.07},{1.5,.12},{1.75,.05},{2,.06}}, kong_y=250 | 5000000 | 3,000 | 84.1% (82.7% with fireballs) | 82.7% | 0.0% | 6,200 |
| 2026-11-04 00:49 | gj02 | 3-1: same, from the 3rd girder up | kong_rays={{1,.71},{1.25,.07},{1.5,.12},{1.75,.05},{2,.06}}, kong_y=180 | 5000000 | 3,000 | 84.2% (82.7% with fireballs) | 82.9% | 0.0% | 6,200 |
| 2026-11-04 00:53 | gj03 | 3-1: watches for Kong's wild release from anywhere, 1-1 directions | kong_y=250 | 5000000 | 3,000 | 83.8% (82.1% with fireballs) | 82.4% | 0.0% | 6,200 |
| 2026-11-04 01:20 | gk01 | 3-1: wild barrels move with each plan, heading for Mario each time they land | wild_dynamic=true | 5000000 | 3,000 | 83.3% (81.6% with fireballs) | 81.9% | 0.0% | 6,200 |
| 2026-11-04 01:24 | gk02 | 3-1: same, at least 1 px a frame after landing | wild_dynamic=true, wild_spd=1 | 5000000 | 3,000 | 83.8% (82.1% with fireballs) | 82.4% | 0.0% | 6,100 |
| 2026-11-04 01:37 | gl00 | 3-1, 10,000 new games: current setting |  | 5100000 | 10,000 | 83.6% (82.0% with fireballs) | 82.9% | 0.0% | 6,200 |
| 2026-11-04 01:50 | gl01 | 3-1, 10,000 new games: all the small wild-barrel gains together | kong_rays={{1,.71},{1.25,.07},{1.5,.12},{1.75,.05},{2,.06}}, kong_y=180, ladder_sure=true, wild_dynamic=true, wild_spd=1 | 5100000 | 10,000 | 85.0% (83.3% with fireballs) | 84.3% | 0.0% | 6,200 |
| 2026-11-04 02:03 | gl02 | 3-1, 10,000 new games: watching Kong from the 3rd girder up, level-3 directions | kong_rays={{1,.71},{1.25,.07},{1.5,.12},{1.75,.05},{2,.06}}, kong_y=180 | 5100000 | 10,000 | 84.1% (82.4% with fireballs) | 83.4% | 0.0% | 6,200 |
| 2026-11-04 02:16 | gl03 | 3-1, 10,000 new games: wild barrels move with each plan | wild_dynamic=true, wild_spd=1 | 5100000 | 10,000 | 83.7% (82.1% with fireballs) | 83.0% | 0.0% | 6,100 |
| 2026-11-04 02:30 | gm00 | 3-1, 10,000 new games: new setting (reference) |  | 5100000 | 10,000 | 85.0% (83.3% with fireballs) | 84.3% | 0.0% | 6,200 |
| 2026-11-04 02:43 | gm01 | 3-1: keeps climbing unless a real barrel threatens | ladder_real=true | 5100000 | 10,000 | 85.0% (83.3% with fireballs) | 84.3% | 0.0% | 6,200 |
| 2026-11-04 02:56 | gm02 | 3-1: nearly at the top, climbs on and jumps it | retreat_top=8 | 5100000 | 10,000 | 84.9% (83.2% with fireballs) | 84.2% | 0.0% | 6,200 |
| 2026-11-04 03:09 | gm03 | 3-1: knows he's on the ladder near the bottom | ladder_known=true | 5100000 | 10,000 | 84.8% (83.2% with fireballs) | 84.1% | 0.0% | 6,200 |
| 2026-11-04 03:22 | gm04 | 3-1: holds just below the top while a barrel passes | ladder_hold=12 | 5100000 | 10,000 | 84.6% (83.0% with fireballs) | 83.9% | 0.0% | 6,200 |
| 2026-11-04 03:37 | gn01 | 3-1: no jumping where it grabs the lower hammer | ham_avoid2={160,186} | 5100000 | 10,000 | 82.2% (77.8% with fireballs) | 81.4% | 0.0% | 6,100 |
| 2026-11-04 03:51 | gn02 | 3-1: same, wider | ham_avoid2={155,192} | 5100000 | 10,000 | 83.5% (79.3% with fireballs) | 82.8% | 0.0% | 6,100 |
| 2026-11-04 04:05 | go01 | 3-1: maybe-barrels weighed less | w_risk=150 | 5100000 | 10,000 | 84.3% (82.7% with fireballs) | 83.6% | 0.0% | 6,200 |
| 2026-11-04 04:18 | go02 | 3-1: maybe-barrels weighed more | w_risk=400 | 5100000 | 10,000 | 84.9% (83.2% with fireballs) | 84.2% | 0.0% | 6,200 |
| 2026-11-04 04:31 | go03 | 3-1: a jump with no follow-up costs less | w_no_next=100 | 5100000 | 10,000 | 85.0% (83.3% with fireballs) | 84.3% | 0.0% | 6,200 |
| 2026-11-04 04:44 | go04 | 3-1: a jump with no follow-up costs more | w_no_next=220 | 5100000 | 10,000 | 84.8% (83.2% with fireballs) | 84.1% | 0.0% | 6,200 |
| 2026-11-04 04:57 | go05 | 3-1: a plan needs less room to count as safe | min_clear=3 | 5100000 | 10,000 | 81.6% (80.5% with fireballs) | 80.9% | 0.0% | 6,200 |
| 2026-11-04 05:10 | go06 | 3-1: each jump costs more | w_jump=30 | 5100000 | 10,000 | 85.3% (83.6% with fireballs) | 84.5% | 0.0% | 6,200 |
| 2026-11-04 05:23 | go07 | 3-1: without the back jump | w_with=nil | 5100000 | 10,000 | 83.3% (81.7% with fireballs) | 82.6% | 0.0% | 6,200 |
| 2026-11-04 05:36 | go08 | 3-1: the walk-back fix plus faster second jump check | next_waits={7,9,14,20,28} | 5100000 | 10,000 | 85.0% (83.3% with fireballs) | 84.3% | 0.0% | 6,200 |
| 2026-11-04 08:47 | gp00 | 3-1 live on the boards: current setting, more fresh games |  | 5300000 | 4,000 | 84.6% (82.9% with fireballs) | 83.5% | 0.0% | 6,200 |
| 2026-11-04 09:04 | gq01 | 3-1: before and during the climb at ladder 91, allows for Kong's next barrel, timed from his pose | kong_pose=true, next_drop_climb={0}, next_drop_pose=true, next_drop_approach=true | 5100000 | 10,000 | 84.1% (82.0% with fireballs) | 83.3% | 0.0% | 6,100 |
| 2026-11-04 09:15 | gq02 | 3-1: same, allowing for it a little late | kong_pose=true, next_drop_climb={0,8}, next_drop_pose=true, next_drop_approach=true | 5100000 | 10,000 | 84.1% (82.0% with fireballs) | 83.3% | 0.0% | 6,100 |
| 2026-11-04 09:28 | gq03 | 3-1: same, on the usual throw rhythm instead of his pose | next_drop_climb={0}, next_drop_approach=true | 5100000 | 10,000 | 76.5% (71.3% with fireballs) | 75.6% | 0.0% | 6,100 |
| 2026-11-04 09:37 | gr01 | 3-1: a landing wild barrel follows the stick (Matt's juke), and he plans with that | wild_stick=true | 5100000 | 10,000 | 83.8% (82.3% with fireballs) | 83.1% | 0.0% | 6,200 |
| 2026-11-04 09:47 | gr02 | 3-1: juke as measured: pressing right flings a landing wild barrel right, otherwise it heads for Mario | wild_stick=true | 5100000 | 10,000 | 84.7% (83.0% with fireballs) | 83.9% | 0.0% | 6,200 |
| 2026-11-04 09:48 | gs00m | check: wall bounce in MAME (Lua planner) | wall_jump=true | 3000000 | 200 | 98.5% (98.5% with fireballs) | 95.7% | 0.0% | 5,100 |
| 2026-11-04 09:48 | gs00n | check: wall bounce on the native runner | wall_jump=true | 3000000 | 200 | 98.5% (98.5% with fireballs) | 95.7% | 0.0% | 5,100 |
| 2026-11-04 09:58 | gs01 | 3-1: jumps bounce off the left wall, and he can use the space down to it | wall_jump=true | 5100000 | 10,000 | 85.0% (83.3% with fireballs) | 84.3% | 0.0% | 6,200 |
| 2026-11-04 10:08 | gt01 | 3-1: Matt's juke: may stand still and tap right as a wild barrel lands | wild_stick=true, juke=true | 5100000 | 10,000 | 84.8% (83.2% with fireballs) | 84.1% | 0.0% | 6,200 |
| 2026-11-04 10:18 | gt02 | 3-1: juke, tapping a little earlier | wild_stick=true, juke=true, juke_lead=5 | 5100000 | 10,000 | 84.8% (83.2% with fireballs) | 84.0% | 0.0% | 6,200 |
| 2026-11-04 10:32 | gu00 | 3-1 live on the boards, 10,000 new games: current setting (with the wall bounce) |  | 5600000 | 10,000 | 85.3% (83.3% with fireballs) | 84.6% | 0.0% | 6,200 |
| 2026-11-04 10:43 | gu01 | 3-1 live on the boards, 10,000 new games: current setting |  | 5700000 | 10,000 | 84.8% (83.4% with fireballs) | 84.1% | 0.0% | 6,200 |
| 2026-11-04 10:56 | gv01 | 3-1: wild bounces as the game does them: towards Mario's x, at the game's random speeds | wild_rom=true | 5100000 | 10,000 | 86.1% (84.3% with fireballs) | 85.4% | 0.0% | 6,200 |
| 2026-11-04 11:08 | gv02 | 3-1 fresh: game-accurate wild bounces | wild_rom=true | 5600000 | 10,000 | 86.6% (84.5% with fireballs) | 85.9% | 0.0% | 6,200 |
| 2026-11-04 11:20 | gw01 | 3-1: may go into the top-left corner by the hammer | ham_avoid=false | 5100000 | 10,000 | 85.7% (83.9% with fireballs) | 85.0% | 0.0% | 6,200 |
| 2026-11-04 11:31 | gw00 | 3-1 reference: game-accurate wild bounces adopted |  | 5100000 | 10,000 | 86.1% (84.3% with fireballs) | 85.4% | 0.0% | 6,200 |
| 2026-11-04 11:45 | gx01 | 3-1: back jump not on the 5th girder | with_floors={[2]=true,[3]=true,[4]=true} | 5100000 | 10,000 | 85.3% (83.4% with fireballs) | 84.6% | 0.0% | 6,200 |
| 2026-11-04 11:56 | gx02 | 3-1: back jump only on the 4th girder | with_floors={[4]=true} | 5100000 | 10,000 | 85.3% (83.5% with fireballs) | 84.6% | 0.0% | 6,200 |
| 2026-11-04 12:08 | gy00 | 3-1 live, 10,000 new games: current setting (game-accurate wild bounces) |  | 5800000 | 10,000 | 86.3% (84.5% with fireballs) | 85.6% | 0.0% | 6,200 |
| 2026-11-04 12:20 | gz01 | 3-1: no back-jump bonus for a jump landing left of x=60 | with_min_x=60 | 5100000 | 10,000 | 86.2% (84.3% with fireballs) | 85.5% | 0.0% | 6,200 |
| 2026-11-04 12:31 | gz02 | 3-1: same, left of x=75 | with_min_x=75 | 5100000 | 10,000 | 86.1% (84.3% with fireballs) | 85.4% | 0.0% | 6,200 |
| 2026-11-04 13:13 | gy01 | 3-1 live, 10,000 new games: current setting |  | 5900000 | 10,000 | 86.8% (85.0% with fireballs) | 86.2% | 0.0% | 6,200 |
| 2026-11-04 13:24 | ha01 | 3-1: waits a little further from ladder 91 | standoff4=16 | 5100000 | 10,000 | 85.7% (84.1% with fireballs) | 85.0% | 0.0% | 6,100 |
| 2026-11-04 13:36 | ha02 | 3-1: waits closer to ladder 91 | standoff4=6 | 5100000 | 10,000 | 81.4% (79.9% with fireballs) | 80.6% | 0.0% | 6,200 |
| 2026-11-04 13:48 | ha03 | 3-1: waits on the right of ladder 91 | arrive4=1 | 5100000 | 10,000 | 82.6% (80.2% with fireballs) | 81.8% | 0.0% | 6,200 |
| 2026-11-04 14:00 | gy02 | 3-1 live, 10,000 new games: current setting |  | 6000000 | 10,000 | 86.6% (85.0% with fireballs) | 85.9% | 0.0% | 6,200 |
| 2026-11-04 14:35 | gy03 | 3-1 live, 30,000 new games: current setting |  | 6100000 | 30,000 | 86.5% (84.7% with fireballs) | 86.1% | 0.0% | 6,200 |
| 2026-11-04 15:48 | gy04 | 3-1 live on the boards, 60,000 new games: current setting |  | 6200000 | 60,000 | 86.7% (84.9% with fireballs) | 86.4% | 0.0% | 6,200 |
| 2026-11-04 17:01 | gy05 | 3-1 live on the boards, 60,000 new games: current setting |  | 6300000 | 60,000 | 86.5% (84.7% with fireballs) | 86.3% | 0.0% | 6,200 |
| 2026-11-04 17:16 | hb01 | 3-1: Matt's steering: standing, taps towards ladders above on the side barrels roll away to | steer_pull=3 | 5100000 | 10,000 | 85.6% (84.6% with fireballs) | 84.9% | 0.0% | 6,100 |
| 2026-11-04 17:26 | hb02 | 3-1: same, tapping a little earlier | steer_pull=6 | 5100000 | 10,000 | 80.5% (79.4% with fireballs) | 79.8% | 0.0% | 6,100 |
| 2026-11-04 17:37 | hb03 | 3-1: same, only on the 4th girder (ladder 91) | steer_pull=3, pull_floors={[4]=true} | 5100000 | 10,000 | 85.8% (84.4% with fireballs) | 85.1% | 0.0% | 6,100 |
| 2026-11-04 17:49 | hc01 | 3-1: steering, only when a few steps that way are safe | steer_pull=3, pull_safe=true | 5100000 | 10,000 | 86.3% (84.7% with fireballs) | 85.6% | 0.0% | 6,200 |
| 2026-11-04 18:00 | hc02 | 3-1: same, checking a longer walk | steer_pull=3, pull_safe=true, pull_walk=12 | 5100000 | 10,000 | 86.3% (84.7% with fireballs) | 85.6% | 0.0% | 6,200 |
| 2026-11-04 18:12 | hc03 | 3-1: same, on the 4th girder only | steer_pull=3, pull_safe=true, pull_floors={[4]=true} | 5100000 | 10,000 | 86.3% (84.6% with fireballs) | 85.6% | 0.0% | 6,200 |
| 2026-11-04 18:34 | he01 | 3-1: steering, standing when a few steps that way are safe (fixed) | steer_pull=3, pull_safe=true | 5100000 | 10,000 | 86.5% (84.9% with fireballs) | 85.8% | 0.0% | 6,200 |
| 2026-11-04 18:46 | he02 | 3-1: steering in any jump, either way, judged from where he lands | steer_air=true | 5100000 | 10,000 | 87.0% (85.3% with fireballs) | 86.3% | 0.0% | 6,100 |
| 2026-11-04 18:57 | he03 | 3-1: both | steer_air=true, steer_pull=3, pull_safe=true | 5100000 | 10,000 | 87.3% (85.8% with fireballs) | 86.6% | 0.0% | 6,100 |
| 2026-11-04 19:08 | he04 | 3-1: both, and a straight jump to steer when steps aren't safe | steer_air=true, steer_pull=3, pull_safe=true, pull_jump=true | 5100000 | 10,000 | 86.7% (85.1% with fireballs) | 86.0% | 0.0% | 6,100 |
| 2026-11-04 19:20 | he05 | 3-1: steering only in straight jumps | steer_air="straight" | 5100000 | 10,000 | 86.7% (85.0% with fireballs) | 86.1% | 0.0% | 6,100 |
| 2026-11-04 19:32 | hf01 | 3-1 fresh: with Matt's steering |  | 6000000 | 10,000 | 87.4% (85.9% with fireballs) | 86.7% | 0.0% | 6,100 |
| 2026-11-04 19:50 | rg10 | Checking 1-1 hasn't got worse |  | 1400000 | 3,000 | 98.7% (97.3% with fireballs) | 98.2% | 0.0% | 4,200 |
| 2026-11-04 20:01 | hg01 | 3-1: steering taps a frame later | steer_pull=2 | 5100000 | 10,000 | 87.5% (85.8% with fireballs) | 86.9% | 0.0% | 6,100 |
| 2026-11-04 20:13 | hg02 | 3-1: steering taps a little earlier | steer_pull=5 | 5100000 | 10,000 | 87.3% (85.6% with fireballs) | 86.6% | 0.0% | 6,100 |
| 2026-11-04 20:24 | hg03 | 3-1: steering, standing check over a longer walk | pull_walk=12 | 5100000 | 10,000 | 87.3% (85.7% with fireballs) | 86.6% | 0.0% | 6,100 |
| 2026-11-04 21:01 | hh01 | 3-1: before and during the climb at ladder 91, allows for Kong's next barrel, timed from his pose | kong_pose=true, next_drop_climb={0}, next_drop_pose=true, next_drop_approach=true | 5100000 | 10,000 | 88.0% (86.1% with fireballs) | 87.3% | 0.0% | 6,100 |
| 2026-11-04 21:12 | hh02 | 3-1: needs a longer clear spell after the top before starting up ladder 91 | after_climb4=40 | 5100000 | 10,000 | 87.1% (85.3% with fireballs) | 86.4% | 0.0% | 6,100 |
| 2026-11-04 21:24 | hh03 | 3-1: nearly at the top, climbs on and jumps rather than backing down | retreat_top=10 | 5100000 | 10,000 | 87.1% (85.5% with fireballs) | 86.4% | 0.0% | 6,100 |
| 2026-11-04 21:35 | hi01 | 3-1 fresh: climb timing allowing for Kong's next barrel, from his pose | kong_pose=true, next_drop_climb={0}, next_drop_pose=true, next_drop_approach=true | 6000000 | 10,000 | 88.8% (86.9% with fireballs) | 88.2% | 0.0% | 6,100 |
| 2026-11-04 21:47 | hj00 | 3-1 reference: with climb timing |  | 5100000 | 10,000 | 88.0% (86.1% with fireballs) | 87.3% | 0.0% | 6,100 |
| 2026-11-04 21:58 | hj01 | 3-1: climb timing only on the ladder, not when deciding to start | next_drop_approach=nil | 5100000 | 10,000 | 88.6% (87.0% with fireballs) | 87.9% | 0.0% | 6,100 |
| 2026-11-04 22:10 | hj02 | 3-1: climb timing allowing for a slightly late throw | next_drop_climb={0,8} | 5100000 | 10,000 | 88.0% (86.1% with fireballs) | 87.3% | 0.0% | 6,100 |
| 2026-11-04 22:33 | hl01 | 3-1 fresh: climb timing only once on the ladder | next_drop_approach=nil | 6000000 | 10,000 | 88.6% (87.2% with fireballs) | 88.0% | 0.0% | 6,100 |
| 2026-11-04 22:33 | hk01 | 3-1: steers barrels on the two girders above | pull_up=2 | 5100000 | 10,000 | 87.8% (86.0% with fireballs) | 87.2% | 0.0% | 6,100 |
| 2026-11-04 22:45 | hk02 | 3-1: steers barrels on any girder above | pull_up=5 | 5100000 | 10,000 | 88.8% (86.9% with fireballs) | 88.2% | 0.0% | 6,100 |
| 2026-11-05 05:51 | hm01 | 3-1 fresh: steers barrels on any girder above | pull_up=5 | 6000000 | 10,000 | 87.5% (85.7% with fireballs) | 86.8% | 0.0% | 6,100 |
| 2026-11-05 05:53 | hn00m | check: right wall in MAME (Lua planner) | wall_jump=true, wall_right=true | 3000000 | 200 | 98.5% (98.0% with fireballs) | 95.7% | 0.0% | 5,100 |
| 2026-11-05 05:53 | hn00n | check: right wall natively | wall_jump=true, wall_right=true | 3000000 | 200 | 98.5% (98.0% with fireballs) | 95.7% | 0.0% | 5,100 |
| 2026-11-05 06:07 | hn01 | 3-1: the right wall too: jumps bounce off it, and he can use the space up to it | wall_right=true | 5100000 | 10,000 | 87.7% (85.8% with fireballs) | 87.1% | 0.0% | 6,100 |
| 2026-11-05 06:09 | ho00m | check: right wall on the 2nd girder in MAME | wall_jump=true, wall_right={[2]=true} | 3000000 | 200 | 98.5% (98.5% with fireballs) | 95.7% | 0.0% | 5,100 |
| 2026-11-05 06:09 | ho00n | check: right wall on the 2nd girder natively | wall_jump=true, wall_right={[2]=true} | 3000000 | 200 | 98.5% (98.5% with fireballs) | 95.7% | 0.0% | 5,100 |
| 2026-11-05 06:23 | ho01 | 3-1: right wall on the 2nd girder only | wall_right={[2]=true} | 5100000 | 10,000 | 88.3% (86.4% with fireballs) | 87.7% | 0.0% | 6,100 |
| 2026-11-05 06:25 | hp00m | check: right wall, standing limit, MAME | wall_jump=true, wall_right={[2]=true} | 3000000 | 200 | 98.5% (98.5% with fireballs) | 95.7% | 0.0% | 5,100 |
| 2026-11-05 06:25 | hp00n | check: right wall, standing limit, native | wall_jump=true, wall_right={[2]=true} | 3000000 | 200 | 98.5% (98.5% with fireballs) | 95.7% | 0.0% | 5,100 |
| 2026-11-05 06:40 | hp01 | 3-1: right wall on the 2nd girder, landing on the girder | wall_right={[2]=true} | 5100000 | 10,000 | 88.6% (86.6% with fireballs) | 87.9% | 0.0% | 6,100 |
| 2026-11-05 06:54 | hp02 | 3-1 fresh: right wall on the 2nd girder, landing on the girder | wall_right={[2]=true} | 6000000 | 10,000 | 88.9% (87.0% with fireballs) | 88.3% | 0.0% | 6,100 |
| 2026-11-05 07:12 | hq00 | 3-1 reference: right wall adopted |  | 5100000 | 10,000 | 88.6% (86.6% with fireballs) | 87.9% | 0.0% | 6,100 |
| 2026-11-05 07:25 | hq01 | 3-1: right wall, standing only up to x=220 | right_stand=220 | 5100000 | 10,000 | 87.9% (86.1% with fireballs) | 87.3% | 0.0% | 6,100 |
| 2026-11-05 07:36 | hq02 | 3-1: right wall, standing only up to x=216 | right_stand=216 | 5100000 | 10,000 | 87.8% (85.9% with fireballs) | 87.2% | 0.0% | 6,100 |
| 2026-11-05 07:38 | ia0m | 4-1 check: MAME |  | 7000000 | 200 | 76.5% (75.0% with fireballs) | 70.1% | 0.0% | 7,200 |
| 2026-11-05 07:48 | ia00 | 4-1 baseline: settings as for 1-1 |  | 7000000 | 10,000 | 86.9% (84.5% with fireballs) | 86.2% | 0.0% | 7,100 |
| 2026-11-05 07:50 | ic0m | 4-1 check: MAME, 3-1 settings minus the native-only wild model | wild_dynamic=false | 7000000 | 200 | 86.6% (84.0% with fireballs) | 81.1% | 0.0% | 7,100 |
| 2026-11-05 07:50 | ic0n | 4-1 check: native, same settings | wild_dynamic=false | 7000000 | 200 | 86.6% (84.0% with fireballs) | 81.1% | 0.0% | 7,100 |
| 2026-11-05 14:09 | id01 | 4-1: with no safe plan, prefer jumping left on the 4th and 5th girders and right on the 2nd | fallback_pref={[2]=1,[4]=-1,[5]=-1} | 7000000 | 10,000 | 84.2% (81.9% with fireballs) | 83.5% | 0.0% | 7,100 |
| 2026-11-05 14:19 | id02 | 4-1: same, preferring it even when it lasts less long | fallback_pref={[2]=1,[4]=-1,[5]=-1}, fallback_slack=20 | 7000000 | 10,000 | 84.2% (81.8% with fireballs) | 83.5% | 0.0% | 7,100 |
| 2026-11-05 14:29 | id03 | 4-1: preferring left on the 5th girder only | fallback_pref={[5]=-1} | 7000000 | 10,000 | 84.2% (81.9% with fireballs) | 83.5% | 0.0% | 7,100 |
| 2026-11-05 14:41 | ie01 | 4-1: no safe plan just off ladder 91's top (5th girder x 85-140): prefer jumping left | fallback_pref={{5,85,140,-1}} | 7000000 | 10,000 | 86.9% (84.5% with fireballs) | 86.2% | 0.0% | 7,100 |
| 2026-11-05 14:51 | ie02 | 4-1: same, plus at ladder 91's foot (4th girder x 70-100): prefer jumping left | fallback_pref={{5,85,140,-1},{4,70,100,-1}} | 7000000 | 10,000 | 86.9% (84.5% with fireballs) | 86.2% | 0.0% | 7,100 |
| 2026-11-05 15:02 | ie03 | 4-1: same, plus on the 2nd girder's right (x 180-224): prefer jumping right | fallback_pref={{5,85,140,-1},{4,70,100,-1},{2,180,224,1}} | 7000000 | 10,000 | 86.9% (84.5% with fireballs) | 86.2% | 0.0% | 7,100 |
| 2026-11-05 15:13 | if01 | 4-1: wild bounces checked at the middle speed only | wild_rom_us={0.5} | 7000000 | 10,000 | 87.8% (85.5% with fireballs) | 87.2% | 0.0% | 7,100 |
| 2026-11-05 15:23 | if02 | 4-1: wild bounces checked at two speeds | wild_rom_us={0.25,0.75} | 7000000 | 10,000 | 87.5% (85.2% with fireballs) | 86.8% | 0.0% | 7,100 |
| 2026-11-05 15:34 | if03 | 4-1: wild bounces checked at five speeds | wild_rom_us={0,0.25,0.5,0.75,0.99} | 7000000 | 10,000 | 86.7% (84.3% with fireballs) | 86.1% | 0.0% | 7,100 |
| 2026-11-05 15:44 | ig00 | 4-1 fresh: current setting |  | 7100000 | 10,000 | 86.8% (84.4% with fireballs) | 86.1% | 0.0% | 7,100 |
| 2026-11-05 15:54 | ig01 | 4-1 fresh: wild bounces checked at the middle speed only | wild_rom_us={0.5} | 7100000 | 10,000 | 88.3% (86.1% with fireballs) | 87.7% | 0.0% | 7,100 |
| 2026-11-05 16:05 | ih01 | 3-1 fresh: wild bounces checked at the middle speed only | wild_rom_us={0.5} | 6000000 | 10,000 | 89.6% (87.7% with fireballs) | 89.0% | 0.0% | 6,100 |
| 2026-11-05 20:04 | ij00 | 4-1 reference: current setting |  | 7000000 | 10,000 | 87.8% (85.5% with fireballs) | 87.2% | 0.0% | 7,100 |
| 2026-11-05 20:24 | ij01 | 4-1: no standing steer with a wild barrel above and near | pull_nowild=40 | 7000000 | 10,000 | 87.7% (85.4% with fireballs) | 87.0% | 0.0% | 7,100 |
| 2026-11-05 20:45 | ij02 | 4-1: back-jump bonus only when standing still isn't safe | with_needed=true | 7000000 | 10,000 | 87.8% (85.5% with fireballs) | 87.2% | 0.0% | 7,100 |
| 2026-11-05 21:06 | ij03 | 4-1: with the hammer, stop and face a barrel rolling at him | ham_stop=24 | 7000000 | 10,000 | 88.1% (85.8% with fireballs) | 87.5% | 0.0% | 7,100 |
| 2026-11-05 21:27 | ik01 | 4-1 fresh: with the hammer, stop and face a barrel rolling at him | ham_stop=24 | 7100000 | 10,000 | 88.6% (86.2% with fireballs) | 87.9% | 0.0% | 7,100 |
| 2026-11-05 21:48 | ik02 | 3-1 fresh: with the hammer, stop and face a barrel rolling at him | ham_stop=24 | 6000000 | 10,000 | 89.7% (87.8% with fireballs) | 89.1% | 0.0% | 6,100 |
| 2026-11-05 22:10 | il00 | 4-1 reference: hammer tip adopted |  | 7000000 | 10,000 | 88.1% (85.8% with fireballs) | 87.5% | 0.0% | 7,100 |
| 2026-11-05 22:30 | il01 | 4-1: a barrel coming down a ladder counts for the back jump only within 12 px of his girder | with_drop_h=12 | 7000000 | 10,000 | 88.1% (85.8% with fireballs) | 87.5% | 0.0% | 7,100 |
| 2026-11-05 22:51 | il02 | 4-1: same, within 20 px | with_drop_h=20 | 7000000 | 10,000 | 88.2% (85.8% with fireballs) | 87.5% | 0.0% | 7,100 |
| 2026-11-05 23:51 | im01 | 4-1: once he decides to back down a ladder, he goes all the way | ladder_commit=true | 7000000 | 10,000 | 88.2% (85.9% with fireballs) | 87.6% | 0.0% | 7,100 |
| 2026-11-06 00:01 | im02 | 4-1: same, and he knows when his feet are on the girder | ladder_commit=true, ladder_true=4 | 7000000 | 10,000 | 87.7% (85.2% with fireballs) | 87.0% | 0.0% | 7,100 |
| 2026-11-06 00:11 | im03 | 4-1: holds just below the top while a barrel passes | ladder_hold=12 | 7000000 | 10,000 | 88.1% (85.8% with fireballs) | 87.4% | 0.0% | 7,100 |
| 2026-11-06 00:22 | in01 | 4-1: on a ladder, a change of direction holds for 12 frames | lad_hyst=12 | 7000000 | 10,000 | 88.0% (85.7% with fireballs) | 87.3% | 0.0% | 7,100 |
| 2026-11-06 00:32 | in02 | 4-1: same, 24 frames | lad_hyst=24 | 7000000 | 10,000 | 87.5% (85.2% with fireballs) | 86.8% | 0.0% | 7,100 |
| 2026-11-06 00:42 | in03 | 4-1: same, 40 frames | lad_hyst=40 | 7000000 | 10,000 | 86.4% (84.1% with fireballs) | 85.7% | 0.0% | 7,100 |
| 2026-11-06 01:13 | io00 | 4-1 fresh exam, 30,000 new games: current setting |  | 7200000 | 30,000 | 88.4% (86.0% with fireballs) | 88.0% | 0.0% | 7,100 |
| 2026-11-06 01:44 | io01 | 3-1 fresh exam, 30,000 new games: current setting |  | 6500000 | 30,000 | 89.9% (87.7% with fireballs) | 89.5% | 0.0% | 6,100 |
| 2026-11-06 02:46 | io02 | 4-1 live on the boards, 60,000 new games: current setting |  | 7300000 | 60,000 | 88.4% (86.1% with fireballs) | 88.1% | 0.0% | 7,100 |
| 2026-11-06 04:53 | io03 | 4-1 live on the boards overnight: current setting |  | 7400000 | 120,000 | 88.3% (86.1% with fireballs) | 88.1% | 0.0% | 7,100 |
| 2026-11-06 07:00 | io04 | 4-1 live on the boards: current setting |  | 7600000 | 120,000 | 88.2% (85.9% with fireballs) | 88.0% | 0.0% | 7,100 |
| 2026-11-06 09:10 | io05 | 4-1 live on the boards: current setting |  | 7800000 | 120,000 | 88.3% (86.0% with fireballs) | 88.1% | 0.0% | 7,100 |
| 2026-11-06 09:22 | ip01 | 4-1: needs more room before he stops weighing his options | walk_clear=10 | 7000000 | 10,000 | 88.2% (85.9% with fireballs) | 87.5% | 0.0% | 7,100 |
| 2026-11-06 09:34 | ip02 | 4-1: needs even more room | walk_clear=16 | 7000000 | 10,000 | 88.0% (85.4% with fireballs) | 87.3% | 0.0% | 7,100 |
| 2026-11-06 09:45 | iq01 | 4-1: marks down plans that leave him with no safe way on | follow_check=true, w_no_follow=100 | 7000000 | 10,000 | 88.4% (86.0% with fireballs) | 87.8% | 0.0% | 7,100 |
| 2026-11-06 09:56 | iq02 | 4-1: same, marked down more | follow_check=true, w_no_follow=300 | 7000000 | 10,000 | 88.5% (86.1% with fireballs) | 87.8% | 0.0% | 7,100 |
| 2026-11-06 10:06 | iq03 | 4-1: same, the way on only has to last 20 steps | follow_check=true, w_no_follow=100, follow_steps=20 | 7000000 | 10,000 | 88.3% (86.0% with fireballs) | 87.7% | 0.0% | 7,100 |
| 2026-11-06 10:16 | iq04 | 4-1: plans with no safe way on all but ruled out | follow_check=true, w_no_follow=1000 | 7000000 | 10,000 | 88.5% (86.1% with fireballs) | 87.8% | 0.0% | 7,100 |
| 2026-11-06 10:27 | iq05 | 4-1: same, the way on has to last 40 steps | follow_check=true, w_no_follow=300, follow_steps=40 | 7000000 | 10,000 | 88.4% (86.0% with fireballs) | 87.7% | 0.0% | 7,100 |
| 2026-11-06 10:37 | iq06 | 4-1 fresh: plans with no safe way on marked down | follow_check=true, w_no_follow=300 | 7100000 | 10,000 | 88.6% (86.2% with fireballs) | 88.0% | 0.0% | 7,100 |
| 2026-11-06 11:42 | ja0m | 5-1 check: MAME (native-only wild model off) | wild_dynamic=false, follow_check=false | 8000000 | 200 | 90.0% (85.5% with fireballs) | 84.9% | 0.0% | 7,000 |
| 2026-11-06 11:42 | ja0n | 5-1 check: native, same settings | wild_dynamic=false, follow_check=false | 8000000 | 200 | 90.0% (85.5% with fireballs) | 84.9% | 0.0% | 7,000 |
| 2026-11-06 11:53 | jb00 | 5-1 baseline: settings as for 4-1 |  | 8000000 | 10,000 | 82.1% (77.4% with fireballs) | 81.3% | 0.0% | 7,100 |
| 2026-11-06 12:04 | jc01 | 5-1: wild bounces aimed at Mario, as the game does at difficulty 5 | wild_aim=true | 8000000 | 10,000 | 93.8% (88.2% with fireballs) | 93.3% | 0.0% | 7,000 |
| 2026-11-06 12:15 | jc02 | 5-1: same, and Kong's wild barrels leave aimed at him | wild_aim=true, kong_aim=1 | 8000000 | 10,000 | 94.3% (88.5% with fireballs) | 93.8% | 0.0% | 7,000 |
| 2026-11-06 12:24 | jc03 | 5-1: Kong's wild barrels leave aimed at him | kong_aim=1 | 8000000 | 10,000 | 82.6% (78.1% with fireballs) | 81.9% | 0.0% | 7,100 |
| 2026-11-06 12:35 | jd01 | 5-1 fresh: aimed wild barrels adopted |  | 8100000 | 10,000 | 94.6% (89.8% with fireballs) | 94.2% | 0.0% | 7,000 |
| 2026-11-06 16:22 | je00 | 5-1 reference: aimed wild barrels adopted |  | 8000000 | 10,000 | 94.3% (88.5% with fireballs) | 93.8% | 0.0% | 7,000 |
| 2026-11-06 16:33 | je01 | 5-1: with the hammer, steps away from a barrel coming down a ladder beside him | ham_ladder=16 | 8000000 | 10,000 | 94.4% (88.6% with fireballs) | 93.9% | 0.0% | 7,000 |
| 2026-11-06 16:43 | je02 | 5-1: same, from a little further | ham_ladder=24 | 8000000 | 10,000 | 94.4% (88.6% with fireballs) | 93.9% | 0.0% | 7,000 |
| 2026-11-06 16:55 | jf01 | 5-1: at ladder 91's foot he always weighs every plan | think_zones={{4,70,100}} | 8000000 | 10,000 | 95.6% (89.8% with fireballs) | 95.2% | 0.0% | 7,000 |
| 2026-11-06 17:08 | jf02 | 5-1: same, and just off its top | think_zones={{4,70,100},{5,85,140}} | 8000000 | 10,000 | 95.6% (90.0% with fireballs) | 95.2% | 0.0% | 7,000 |
| 2026-11-06 17:22 | jg01 | 5-1 fresh: always weighs every plan at ladder 91 |  | 8100000 | 10,000 | 95.5% (90.6% with fireballs) | 95.1% | 0.0% | 7,000 |
| 2026-11-06 17:46 | jg02 | 5-1: always weighs every plan, everywhere | think_zones={{1,0,255},{2,0,255},{3,0,255},{4,0,255},{5,0,255},{6,0,255}} | 8000000 | 10,000 | 93.8% (85.2% with fireballs) | 93.3% | 0.0% | 7,000 |
| 2026-11-06 18:00 | jh01 | 4-1 fresh: always weighs every plan at ladder 91 | think_zones={{4,70,100},{5,85,140}} | 7100000 | 10,000 | 89.4% (87.1% with fireballs) | 88.8% | 0.0% | 7,100 |
| 2026-11-06 18:14 | jh02 | 3-1 fresh: always weighs every plan at ladder 91 | think_zones={{4,70,100},{5,85,140}} | 6000000 | 10,000 | 90.0% (88.1% with fireballs) | 89.4% | 0.0% | 6,100 |
| 2026-11-06 18:32 | ji01 | 5-1: also always weighs every plan further along the 4th girder | think_zones={{4,70,160},{5,85,140}} | 8000000 | 10,000 | 95.1% (88.4% with fireballs) | 94.6% | 0.0% | 7,000 |
| 2026-11-06 18:48 | ji02 | 5-1: and on the 2nd girder | think_zones={{4,70,100},{5,85,140},{2,90,220}} | 8000000 | 10,000 | 95.7% (90.4% with fireballs) | 95.3% | 0.0% | 7,000 |
| 2026-11-06 19:03 | ji03 | 5-1: and on Kong's girder | think_zones={{4,70,100},{5,85,140},{6,0,255}} | 8000000 | 10,000 | 95.6% (89.8% with fireballs) | 95.2% | 0.0% | 7,000 |
| 2026-11-06 19:17 | jj01 | 5-1: keeps the moment of the jump he already planned as an option (no more late jumps) | keep_jump=true | 8000000 | 10,000 | 95.5% (90.8% with fireballs) | 95.1% | 0.0% | 7,000 |
| 2026-11-06 19:32 | jj02 | 5-1: same, and sticks to it unless something better comes up | keep_jump=true, w_keep=20 | 8000000 | 10,000 | 94.9% (89.6% with fireballs) | 94.4% | 0.0% | 7,000 |
| 2026-11-06 20:04 | jj03 | 5-1: same, sticks to it more firmly | keep_jump=true, w_keep=60 | 8000000 | 10,000 | 94.8% (89.1% with fireballs) | 94.3% | 0.0% | 7,000 |
| 2026-11-06 20:31 | jk01 | 5-1: commits to the climb, wild barrels can't hurt him going up (Matt) | climb_nowild=true | 8000000 | 10,000 | 95.9% (90.7% with fireballs) | 95.5% | 0.0% | 7,000 |
| 2026-11-06 21:00 | jl01 | 5-1: lets go of the stick in the air as a barrel above crosses a ladder on that side | air_off=10 | 8000000 | 10,000 | 95.7% (90.0% with fireballs) | 95.3% | 0.0% | 7,000 |
| 2026-11-06 21:25 | jm01 | 5-1 fresh: commits to climbs, lets go in the air near ladders |  | 8100000 | 10,000 | 95.9% (91.3% with fireballs) | 95.5% | 0.0% | 7,000 |
| 2026-11-06 21:54 | jn00 | 5-1 reference: with climb commit and letting go in the air |  | 8000000 | 10,000 | 96.0% (90.7% with fireballs) | 95.6% | 0.0% | 7,000 |
| 2026-11-06 22:08 | jn01 | 5-1: with a barrel chasing close behind on the 4th girder's right, jumps now | chase_zone={4,110,220}, chase_dir="any" | 8000000 | 10,000 | 95.8% (90.8% with fireballs) | 95.3% | 0.0% | 7,000 |
| 2026-11-06 22:31 | jo01 | 5-1: on Kong's girder, less sure Kong's next throw comes straight at him | kong_aim_top=0.3 | 8000000 | 10,000 | 96.0% (90.7% with fireballs) | 95.6% | 0.0% | 7,000 |
| 2026-11-07 01:39 | jp01 | 5-1: remembers 32 solved situations from past deaths | cases=/Users/matt/dkong-human/cases/l5_v2.lua | 8000000 | 0 | 0.0% (0.0% with fireballs) | 0.0% | 0.0% | 0 |
| 2026-11-07 02:11 | jp01 | 5-1: remembers 32 solved situations from past deaths | cases="/Users/matt/dkong-human/cases/l5_v2.lua" | 8000000 | 10,000 | 76.6% (72.7% with fireballs) | 75.8% | 0.0% | 7,000 |
| 2026-11-07 02:12 | jp02 | 5-1 check: which remembered situations fire | cases="/Users/matt/dkong-human/cases/l5_v2.lua" | 8000000 | 400 | 74.7% (70.2% with fireballs) | 70.1% | 0.0% | 7,000 |
| 2026-11-07 02:15 | jp03 | 5-1 check: which remembered situations fire (every barrel, within 4 px) | cases="/Users/matt/dkong-human/cases/l5_v3.lua", case_all=true, case_b=4, case_x=2 | 8000000 | 1,000 | 97.1% (92.3% with fireballs) | 95.8% | 0.0% | 7,000 |
| 2026-11-07 02:18 | jp03 | 5-1 check: which remembered situations fire (every barrel, within 2 px) | cases="/Users/matt/dkong-human/cases/l5_v3.lua", case_all=true, case_b=2, case_x=2 | 8000000 | 1,000 | 96.8% (91.9% with fireballs) | 95.5% | 0.0% | 7,000 |
| 2026-11-07 06:54 | jq01 | 5-1 exam: 30,000 fresh games as it stands |  | 8200000 | 30,000 | 95.7% (91.1% with fireballs) | 95.5% | 0.0% | 7,000 |
| 2026-11-07 07:21 | jr01 | 5-1: with the hammer, turns to face a barrel then waits for it | ham_tap=true | 8000000 | 10,000 | 96.0% (90.8% with fireballs) | 95.6% | 0.0% | 7,000 |
| 2026-11-07 07:49 | js01 | 5-1 fresh: with the hammer, faces a barrel then waits |  | 8100000 | 10,000 | 95.9% (91.3% with fireballs) | 95.5% | 0.0% | 7,000 |
| 2026-11-07 08:35 | jt01 | 4-1: with the hammer, faces a barrel then waits | ham_tap=true | 7100000 | 10,000 | 89.4% (87.1% with fireballs) | 88.8% | 0.0% | 7,100 |
| 2026-11-07 09:01 | jt02 | 3-1: with the hammer, faces a barrel then waits | ham_tap=true | 6000000 | 10,000 | 90.1% (88.1% with fireballs) | 89.5% | 0.0% | 6,100 |
| 2026-11-07 10:04 | ju01 | 5-1: barrels come down ladders at their real speed in his predictions | drop_rate=1.0 | 8000000 | 10,000 | 95.3% (90.4% with fireballs) | 94.9% | 0.0% | 7,000 |
| 2026-11-07 10:25 | jv01 | 5-1: wild barrels predicted from where they really are, and right at a fixed speed until the oil is lit | wild_catch1=true, wild_pre=0.91015625 | 8000000 | 10,000 | 95.5% (90.5% with fireballs) | 95.1% | 0.0% | 7,000 |
| 2026-11-07 10:41 | jw01 | 5-1: wild barrels carried one frame further ahead in his predictions | wild_lead=1 | 8000000 | 10,000 | 95.9% (91.0% with fireballs) | 95.4% | 0.0% | 7,000 |
| 2026-11-07 10:55 | jw02 | 5-1: barrels predicted a little slower down ladders | drop_rate=0.9 | 8000000 | 10,000 | 94.2% (89.6% with fireballs) | 93.8% | 0.0% | 7,000 |
| 2026-11-07 11:39 | jx01 | 5-1 exam: 30,000 fresh games with everything adopted so far |  | 8400000 | 30,000 | 95.8% (91.3% with fireballs) | 95.6% | 0.0% | 7,000 |
| 2026-11-07 12:55 | jy01 | 5-1: avoids jumping right under a ladder a barrel could come down | w_under=40 | 8000000 | 10,000 | 95.4% (90.1% with fireballs) | 94.9% | 0.0% | 7,000 |
| 2026-11-07 13:38 | jy02 | 5-1: avoids jumping right under the short ladder from Kong's girder | w_under=40, under_zones={{5,100,112}} | 8000000 | 10,000 | 95.9% (90.8% with fireballs) | 95.5% | 0.0% | 7,000 |
| 2026-11-07 14:08 | jz01 | 5-1 fresh: also avoids jumping under the short ladder from Kong's girder |  | 8100000 | 10,000 | 95.9% (91.2% with fireballs) | 95.5% | 0.0% | 7,000 |
| 2026-11-07 14:40 | ka01 | 5-1: he knows exactly where Mario is from his own presses | know_self=true | 8000000 | 10,000 | 96.5% (92.1% with fireballs) | 96.1% | 0.0% | 7,000 |
| 2026-11-07 14:56 | ka02 | 5-1: avoids being under a ladder only when a barrel could come down it | under_live=true | 8000000 | 10,000 | 95.8% (90.6% with fireballs) | 95.4% | 0.0% | 7,000 |
| 2026-11-07 15:12 | kb01 | 5-1 fresh: he knows exactly where Mario is |  | 8100000 | 10,000 | 96.2% (91.7% with fireballs) | 95.8% | 0.0% | 7,000 |
| 2026-11-07 15:32 | kc01 | 4-1: he knows exactly where Mario is | know_self=true | 7100000 | 10,000 | 90.0% (87.9% with fireballs) | 89.4% | 0.0% | 7,100 |
| 2026-11-07 15:46 | kc02 | 3-1: he knows exactly where Mario is | know_self=true | 6000000 | 10,000 | 91.4% (89.7% with fireballs) | 90.8% | 0.0% | 6,100 |
| 2026-11-07 15:55 | kc03 | 2-1 reference: as it stands |  | 4000000 | 10,000 | 97.0% (96.6% with fireballs) | 96.7% | 0.0% | 5,100 |
| 2026-11-07 16:04 | kc04 | 2-1: he knows exactly where Mario is | know_self=true | 4000000 | 10,000 | 97.7% (97.2% with fireballs) | 97.4% | 0.0% | 5,100 |
| 2026-11-07 16:08 | kd01 | 1-1 reference: as it stands |  | 1400000 | 3,000 | 98.7% (97.3% with fireballs) | 98.2% | 0.0% | 4,200 |
| 2026-11-07 16:12 | kd02 | 1-1: he knows exactly where Mario is | know_self=true | 1400000 | 3,000 | 98.6% (97.7% with fireballs) | 98.1% | 0.0% | 4,100 |
| 2026-11-07 16:21 | kd03 | 2-1 fresh: he knows exactly where Mario is |  | 4100000 | 10,000 | 97.6% (97.2% with fireballs) | 97.3% | 0.0% | 5,100 |
| 2026-11-07 16:36 | kd04 | 3-1 fresh: he knows exactly where Mario is |  | 6100000 | 10,000 | 91.1% (89.3% with fireballs) | 90.5% | 0.0% | 6,100 |
| 2026-11-07 16:51 | kd05 | 4-1 fresh: he knows exactly where Mario is |  | 7200000 | 10,000 | 90.3% (88.4% with fireballs) | 89.7% | 0.0% | 7,100 |
| 2026-11-07 17:37 | ke01 | 5-1 exam: 30,000 fresh games, he knows where Mario is |  | 8500000 | 30,000 | 96.3% (91.9% with fireballs) | 96.1% | 0.0% | 7,000 |
| 2026-11-07 19:51 | kf00 | 5-1 reference: as it stands |  | 8000000 | 10,000 | 96.5% (92.1% with fireballs) | 96.1% | 0.0% | 7,000 |
| 2026-11-07 20:05 | kf02 | 5-1: steers barrels down the right broken ladder, waiting up to 2.5 s on the middle ladder | ladder_steer={131,5,{188},3,150}, steer_zone={4,70,135,5,188,3} | 8000000 | 10,000 | 89.4% (84.7% with fireballs) | 88.8% | 0.0% | 6,900 |
| 2026-11-07 20:16 | kf03 | 5-1: steers barrels down the right broken ladder, waiting up to 4 s on the middle ladder | ladder_steer={131,5,{188},3,240}, steer_zone={4,70,135,5,188,3} | 8000000 | 10,000 | 44.4% (41.2% with fireballs) | 43.3% | 0.0% | 6,900 |
| 2026-11-07 20:30 | kf04 | 5-1: steers barrels down the right broken ladder from the middle ladder and the 4th girder, no waiting | ladder_steer={131,5,{188},3}, steer_zone={4,70,135,5,188,3} | 8000000 | 10,000 | 96.0% (92.4% with fireballs) | 95.6% | 0.0% | 7,000 |
| 2026-11-07 20:44 | kf05 | 5-1: steers barrels down the right broken ladder from the 4th girder | steer_zone={4,70,135,5,188,3} | 8000000 | 10,000 | 95.7% (92.1% with fireballs) | 95.3% | 0.0% | 7,000 |
| 2026-11-07 21:00 | kf06 | 5-1: steers barrels down the right broken ladder, only taps when standing anyway | ladder_steer={131,5,{188},3}, steer_zone={4,70,135,5,188,3,true} | 8000000 | 10,000 | 96.9% (92.7% with fireballs) | 96.6% | 0.0% | 7,000 |
| 2026-11-07 21:15 | kg01 | 5-1 fresh: steers barrels down the right broken ladder (Matt) |  | 8700000 | 10,000 | 96.7% (92.3% with fireballs) | 96.3% | 0.0% | 7,000 |
| 2026-11-07 21:31 | kg00 | 5-1 fresh reference: without the steer | ladder_steer=nil, steer_zone=nil | 8700000 | 10,000 | 96.4% (91.9% with fireballs) | 96.0% | 0.0% | 7,000 |
| 2026-11-07 21:44 | kh01 | 4-1: steers barrels down the right broken ladder (Matt's 5-1 steer) | ladder_steer={131,5,{188},3}, steer_zone={4,70,135,5,188,3,true} | 7100000 | 10,000 | 90.9% (89.0% with fireballs) | 90.3% | 0.0% | 7,100 |
| 2026-11-07 21:59 | kh02 | 3-1: steers barrels down the right broken ladder (Matt's 5-1 steer) | ladder_steer={131,5,{188},3}, steer_zone={4,70,135,5,188,3,true} | 6000000 | 10,000 | 91.6% (90.2% with fireballs) | 91.1% | 0.0% | 6,100 |
| 2026-11-07 22:13 | ki01 | 4-1 fresh: steers barrels down the right broken ladder |  | 7200000 | 10,000 | 90.3% (88.6% with fireballs) | 89.7% | 0.0% | 7,000 |
| 2026-11-07 22:26 | ki02 | 3-1 fresh: steers barrels down the right broken ladder |  | 6100000 | 10,000 | 91.1% (89.7% with fireballs) | 90.5% | 0.0% | 6,100 |
| 2026-11-07 23:09 | kj01 | 5-1 exam: 30,000 fresh games with the middle-ladder steer |  | 8800000 | 30,000 | 96.8% (92.9% with fireballs) | 96.6% | 0.0% | 7,000 |
| 2026-11-08 01:08 | kk01 | 5-1: plans during the jump just off ladder 91's top | air_plan={5,74,100,10} | 8000000 | 10,000 | 97.1% (92.9% with fireballs) | 96.7% | 0.0% | 7,000 |
| 2026-11-08 01:40 | kk02 | 5-1: plans during every jump | air_plan={0,0,255,10} | 8000000 | 10,000 | 94.8% (89.8% with fireballs) | 94.3% | 0.0% | 7,000 |
| 2026-11-08 03:11 | kk03 | 5-1: stops for a barrel chasing close behind on the 4th girder | chase_stop={4,90,135,16,30} | 8000000 | 10,000 | 96.0% (92.2% with fireballs) | 95.6% | 0.0% | 7,000 |
| 2026-11-08 03:43 | kk04 | 5-1: stops for a close chaser only when his jump keeps slipping | chase_stop={4,90,135,16,30,true} | 8000000 | 10,000 | 97.1% (92.9% with fireballs) | 96.7% | 0.0% | 7,000 |
| 2026-11-08 04:15 | kk04 | 5-1: stops for a close chaser only when his jump keeps slipping | chase_stop={4,90,135,16,30,true} | 8000000 | 10,000 | 96.0% (92.2% with fireballs) | 95.6% | 0.0% | 7,000 |
| 2026-11-08 05:07 | kl01 | 5-1 fresh: plans during the jump just off ladder 91's top |  | 8700000 | 10,000 | 97.3% (92.8% with fireballs) | 97.0% | 0.0% | 7,000 |
| 2026-11-08 11:39 | kn00 | 5-1 reference with the firing log (no new rules) |  | 8000000 | 10,000 | 97.1% (92.9% with fireballs) | 96.7% | 0.0% | 7,000 |
| 2026-11-08 11:54 | kn01 | 5-1: just up the middle ladder, holds his ground (Matt #2) | hold_ground={4,115,131,70} | 8000000 | 10,000 | 96.9% (92.6% with fireballs) | 96.5% | 0.0% | 7,000 |
| 2026-11-08 12:05 | kn02 | 5-1: steps in and back jumps a barrel just off ladder 91 (Matt #1) | back_jump={4,105,125,18,30,8} | 8000000 | 10,000 | 69.4% (67.0% with fireballs) | 68.5% | 0.0% | 7,000 |
| 2026-11-08 12:18 | kn03 | 5-1: back jumps a close barrel on the right of the 5th girder (Matt #3) | back_jump={5,140,200,18,24,0} | 8000000 | 10,000 | 68.5% (65.9% with fireballs) | 67.6% | 0.0% | 7,000 |
| 2026-11-08 12:32 | kn04 | 5-1: jumps a close barrel straight, early, on the 5th girder (Matt #4) | chase_jump={5,120,150,22,30} | 8000000 | 10,000 | 97.2% (93.1% with fireballs) | 96.9% | 0.0% | 7,000 |
| 2026-11-08 12:47 | ko01 | 5-1 fresh: jumps a close barrel straight, early, on the 5th girder (Matt #4) |  | 8700000 | 10,000 | 97.5% (93.0% with fireballs) | 97.1% | 0.0% | 7,000 |
| 2026-11-08 13:31 | kp_t3_6 | 5-1 check: how often banked solutions match (x 3, barrels 6, distance slack 0) | cases="/Users/matt/dkong-human/cases/bank_v1.lua", case_now=true, case_all=true, case_x=3, case_b=6, case_far=0 | 8000000 | 1,000 | 97.5% (93.2% with fireballs) | 96.3% | 0.0% | 7,000 |
| 2026-11-08 13:33 | kp_t4_8 | 5-1 check: how often banked solutions match (x 4, barrels 8, distance slack 0.05) | cases="/Users/matt/dkong-human/cases/bank_v1.lua", case_now=true, case_all=true, case_x=4, case_b=8, case_far=0.05 | 8000000 | 1,000 | 96.8% (92.8% with fireballs) | 95.4% | 0.0% | 7,000 |
| 2026-11-08 13:34 | kp_t5_10 | 5-1 check: how often banked solutions match (x 5, barrels 10, distance slack 0.1) | cases="/Users/matt/dkong-human/cases/bank_v1.lua", case_now=true, case_all=true, case_x=5, case_b=10, case_far=0.1 | 8000000 | 1,000 | 95.4% (91.5% with fireballs) | 93.9% | 0.0% | 7,000 |
| 2026-11-08 13:49 | kq01 | 5-1: all 196 banked solutions (barrels within 6 px, his spot within 3) | cases="/Users/matt/dkong-human/cases/bank_v1.lua", case_now=true, case_all=true, case_x=3, case_b=6 | 8000000 | 10,000 | 96.7% (92.8% with fireballs) | 96.3% | 0.0% | 7,000 |
| 2026-11-08 14:27 | kq02 | 5-1: banked solutions, minus those that lost more than they saved | cases="/Users/matt/dkong-human/cases/bank_v2.lua", case_now=true, case_all=true, case_x=3, case_b=6 | 8000000 | 10,000 | 97.3% (93.4% with fireballs) | 96.9% | 0.0% | 7,000 |
| 2026-11-08 14:36 | kr01 | 5-1 measurement only: reaction 5-6 frames (about 90 ms) instead of 8-9 |  | 8000000 | 10,000 | 97.8% (94.9% with fireballs) | 97.5% | 0.0% | 7,000 |
| 2026-11-08 14:51 | kr02 | 5-1 measurement only: reaction 6 frames (100 ms) instead of 8-9 |  | 8000000 | 10,000 | 97.4% (94.4% with fireballs) | 97.1% | 0.0% | 7,000 |
| 2026-11-08 15:06 | kr03 | 5-1 measurement only: reaction 2 frames (about 30 ms) instead of 8-9 |  | 8000000 | 10,000 | 97.7% (95.6% with fireballs) | 97.3% | 0.0% | 7,100 |
| 2026-11-08 15:46 | kt00 | 5-1 reaction sweep: 133-150 ms (8-9 frames), no bank | react={8,9}, cases=nil | 8000000 | 20,000 | 97.2% (93.1% with fireballs) | 97.0% | 0.0% | 7,000 |
| 2026-11-08 16:15 | kt01 | 5-1 reaction sweep: about 90 ms (5-6 frames), no bank | react={5,6}, cases=nil | 8000000 | 20,000 | 97.7% (94.8% with fireballs) | 97.5% | 0.0% | 7,000 |
| 2026-11-08 16:43 | kt02 | 5-1 reaction sweep: about 65 ms (4 frames), no bank | react={4,4}, cases=nil | 8000000 | 20,000 | 97.9% (95.2% with fireballs) | 97.7% | 0.0% | 7,100 |
| 2026-11-08 17:10 | kt03 | 5-1 reaction sweep: 50 ms (3 frames), no bank | react={3,3}, cases=nil | 8000000 | 20,000 | 97.3% (94.8% with fireballs) | 97.1% | 0.0% | 7,100 |
| 2026-11-08 17:40 | kt04 | 5-1 reaction sweep: 30 ms (2 frames), no bank | react={2,2}, cases=nil | 8000000 | 20,000 | 97.5% (95.3% with fireballs) | 97.3% | 0.0% | 7,100 |
| 2026-11-09 18:51 | kv00 | 5-1 reference for the strict bank: 65 ms, no bank | cases=nil | 8000000 | 10,000 | 97.9% (95.2% with fireballs) | 97.6% | 0.0% | 7,100 |
| 2026-11-09 19:05 | kv01 | 5-1: the strict bank (solutions that never failed in 1,000 replays) | cases="/Users/matt/dkong-human/cases/strict_kt02.lua", case_now=true, case_all=true, case_x=3, case_b=6, case_above=12 | 8000000 | 10,000 | 71.2% (69.4% with fireballs) | 70.3% | 0.0% | 7,100 |
| 2026-11-09 19:20 | kv02 | 5-1: the strict bank plus the earlier bank | cases="/Users/matt/dkong-human/cases/bank_plus_strict.lua", case_now=true, case_all=true, case_x=3, case_b=6, case_above=12 | 8000000 | 10,000 | 70.2% (68.3% with fireballs) | 69.3% | 0.0% | 7,100 |
| 2026-11-09 19:36 | kv03 | 5-1: the strict bank, matched on every barrel on the board | cases="/Users/matt/dkong-human/cases/strict_kt02.lua", case_now=true, case_all=true, case_x=3, case_b=6 | 8000000 | 10,000 | 97.2% (94.5% with fireballs) | 96.9% | 0.0% | 7,100 |
| 2026-11-09 19:52 | kv04 | 5-1: the strict bank, trimmed of solutions that lost | cases="/Users/matt/dkong-human/cases/strict_trim.lua", case_now=true, case_all=true, case_x=3, case_b=6 | 8000000 | 10,000 | 97.9% (95.1% with fireballs) | 97.6% | 0.0% | 7,100 |
| 2026-11-09 20:08 | kv05 | 5-1: the strict bank, matched tightly (Mario 1 px, barrels 3 px) | cases="/Users/matt/dkong-human/cases/strict_kt02.lua", case_now=true, case_all=true, case_x=1, case_b=3 | 8000000 | 10,000 | 98.0% (95.2% with fireballs) | 97.7% | 0.0% | 7,100 |
| 2026-11-09 20:31 | kw00 | 5-1 fresh reference: 65 ms, no bank | cases=nil | 8700000 | 10,000 | 97.9% (95.1% with fireballs) | 97.6% | 0.0% | 7,000 |
| 2026-11-09 20:31 | kw01 | 5-1 fresh: strict bank, matched on barrels, Kong's pose and Mario's walk step | cases="/Users/matt/dkong-human/cases/strict_fp.lua", case_now=true, case_all=true, case_x=3, case_b=6, case_best=true, case_kong=3, case_walk=true | 8700000 | 0 | 0.0% (0.0% with fireballs) | 0.0% | 0.0% | 0 |
| 2026-11-09 20:31 | kw02 | 5-1 fresh: the same, barrels matched tightly | cases="/Users/matt/dkong-human/cases/strict_fp.lua", case_now=true, case_all=true, case_x=1, case_b=3, case_best=true, case_kong=3, case_walk=true | 8700000 | 0 | 0.0% (0.0% with fireballs) | 0.0% | 0.0% | 0 |
| 2026-11-09 20:47 | kw01 | 5-1 fresh: strict bank, matched on barrels, Kong's pose and Mario's walk step | cases="/Users/matt/dkong-human/cases/strict_fp.lua", case_now=true, case_all=true, case_x=3, case_b=6, case_best=true, case_kong=3, case_walk=true | 8700000 | 10,000 | 97.2% (94.5% with fireballs) | 96.9% | 0.0% | 7,000 |
| 2026-11-09 21:03 | kw02 | 5-1 fresh: the same, barrels matched tightly | cases="/Users/matt/dkong-human/cases/strict_fp.lua", case_now=true, case_all=true, case_x=1, case_b=3, case_best=true, case_kong=3, case_walk=true | 8700000 | 10,000 | 97.7% (95.0% with fireballs) | 97.4% | 0.0% | 7,000 |
| 2026-11-09 21:19 | kw03 | 5-1 fresh: strict bank, fingerprint, ignoring barrels below Mario (Matt) | cases="/Users/matt/dkong-human/cases/strict_fp.lua", case_now=true, case_all=true, case_x=3, case_b=6, case_best=true, case_kong=3, case_walk=true, case_above=12 | 8700000 | 10,000 | 82.7% (80.4% with fireballs) | 81.9% | 0.0% | 7,100 |
| 2026-11-09 21:48 | kx00 | 5-1: collecting every time the Kong's-ladder setup comes up (changes nothing) | setups={{5,90,101,needs={{1,4,16,"e"}},detect=true,name="kong ladder"}} | 8800000 | 10,000 | 98.2% (95.2% with fireballs) | 97.9% | 0.0% | 7,000 |
| 2026-11-10 00:16 | ky00 | 5-1: logging every instance of the recurring setups (changes nothing) | setups={{5,92,98,needs={{1,8,16,"e"},{0,57,72,"L"}},detect=true,name="s1"},{5,150,157,needs={{0,14,23,"L"},{1,-34,-25,"R"}},detect=true,name="s2"},{5,87,94,needs={{0,20,28,"L"},{0,-72,-64,"e"}},detect=true,name="s3"},{5,57,74,needs={{0,14,22,"L"},{0,-35,-27,"L"}},detect=true,name="s4"},{5,93,102,needs={{1,4,15,"e"},{0,57,67,"L"}},detect=true,name="s5"},{5,90,101,needs={{1,4,16,"e"}},detect=true,name="kong ladder"}} | 8900000 | 10,000 | 98.0% (95.2% with fireballs) | 97.7% | 0.0% | 7,000 |
| 2026-11-10 02:49 | ky01 | 5-1 fresh reference for the setup rules |  | 9000000 | 10,000 | 97.9% (95.2% with fireballs) | 97.6% | 0.0% | 7,000 |
| 2026-11-10 03:09 | ky02 | 5-1 fresh: 2 recurring-setup rules | setups={{5,92,98,needs={{1,8,16,"e"},{0,57,72,"L"}},move={a=1,w=20,j1=nil,j2=nil,h=nil},name="s1"},{5,93,102,needs={{1,4,15,"e"},{0,57,67,"L"}},move={a=1,w=20,j1=nil,j2=nil,h=nil},name="s5"}} | 9000000 | 10,000 | 98.0% (95.2% with fireballs) | 97.7% | 0.0% | 7,000 |
| 2026-11-10 03:30 | ky03 | 5-1 fresh reference (second check of the setup rules) |  | 9100000 | 10,000 | 97.6% (94.8% with fireballs) | 97.2% | 0.0% | 7,100 |
| 2026-11-10 03:50 | ky04 | 5-1 fresh: setup rule s1 (walk left from Kong's ladder) and s3 (straight jump) | setups={{5,92,98,needs={{1,8,16,"e"},{0,57,72,"L"}},move={a=1,w=20,j1=nil,j2=nil,h=nil},name="s1"},{5,87,94,needs={{0,20,28,"L"},{0,-72,-64,"e"}},move={a=0,w=0,j1=0,j2=nil,h=1},name="s3"}} | 9100000 | 10,000 | 97.7% (94.9% with fireballs) | 97.3% | 0.0% | 7,100 |
| 2026-11-10 04:29 | kz00 | 5-1: logging every instance of the recurring setups (changes nothing) | setups={{5,92,98,needs={{1,8,16,"e"},{0,57,72,"L"}},move={a=1,w=20,j1=nil,j2=nil,h=nil},name="s1"},{5,87,94,needs={{0,20,28,"L"},{0,-72,-64,"e"}},move={a=0,w=0,j1=0,j2=nil,h=1},name="s3"},{5,93,102,needs={{1,4,15,"e"},{0,56,67,"L"}},detect=true,name="kzs1"},{5,69,78,needs={{0,14,22,"L"},{0,-35,-27,"L"}},detect=true,name="kzs2"},{4,94,106,needs={{1,-16,-2,"e"},{0,-25,-14,"R"}},detect=true,name="kzs3"},{4,118,126,needs={{1,-20,-10,"e"},{0,-27,-14,"R"}},detect=true,name="kzs4"},{4,79,86,needs={{1,-1,14,"L"},{0,-28,-12,"R"}},detect=true,name="kzs5"},{4,81,89,needs={{1,9,21,"L"},{0,-26,-18,"R"}},detect=true,name="kzs6"}} | 9200000 | 10,000 | 97.9% (95.2% with fireballs) | 97.6% | 0.0% | 7,100 |
| 2026-11-10 08:10 | ht_h60_70 | 5-1 hammer timing try: jump when the barrel is 60,70 px away | ham_top={36,60,70,240}, ham_avoid=false | 9600000 | 200 | 25.7% (24.5% with fireballs) | 20.0% | 0.0% | 8,300 |
| 2026-11-10 08:11 | ht_h70_80 | 5-1 hammer timing try: jump when the barrel is 70,80 px away | ham_top={36,70,80,240}, ham_avoid=false | 9600000 | 200 | 27.8% (26.0% with fireballs) | 21.9% | 0.0% | 8,300 |
| 2026-11-10 08:12 | ht_h80_90 | 5-1 hammer timing try: jump when the barrel is 80,90 px away | ham_top={36,80,90,240}, ham_avoid=false | 9600000 | 200 | 38.6% (36.5% with fireballs) | 32.0% | 0.0% | 8,400 |
| 2026-11-10 08:13 | ht_h90_105 | 5-1 hammer timing try: jump when the barrel is 90,105 px away | ham_top={36,90,105,240}, ham_avoid=false | 9600000 | 200 | 27.8% (26.0% with fireballs) | 21.9% | 0.0% | 8,200 |
| 2026-11-10 08:14 | ht_ref | 5-1 hammer timing reference |  | 9600000 | 200 | 95.9% (94.0% with fireballs) | 92.2% | 0.0% | 7,000 |
| 2026-11-10 08:17 | ht_f60_75 | 5-1 hammer try: jump for it when the barrel is 60,75 px away, turning to face barrels properly | ham_top={36,60,75,240}, ham_avoid=false, face_known=true | 9600000 | 200 | 53.8% (50.0% with fireballs) | 46.6% | 0.5% | 8,400 |
| 2026-11-10 08:18 | ht_f75_90 | 5-1 hammer try: jump for it when the barrel is 75,90 px away, turning to face barrels properly | ham_top={36,75,90,240}, ham_avoid=false, face_known=true | 9600000 | 200 | 54.1% (49.5% with fireballs) | 46.9% | 0.0% | 8,300 |
| 2026-11-10 08:19 | ht_f90_105 | 5-1 hammer try: jump for it when the barrel is 90,105 px away, turning to face barrels properly | ham_top={36,90,105,240}, ham_avoid=false, face_known=true | 9600000 | 200 | 56.4% (50.5% with fireballs) | 49.1% | 0.0% | 8,300 |
| 2026-11-10 08:20 | ht_fk | 5-1: no hammer, facing fix only | face_known=true | 9600000 | 200 | 96.9% (94.5% with fireballs) | 93.5% | 0.0% | 7,000 |
| 2026-11-10 08:31 | hm00 | 5-1 reference for the hammer |  | 9600000 | 1,000 | 97.1% (94.0% with fireballs) | 95.9% | 0.0% | 7,000 |
| 2026-11-10 08:35 | hammer5a | 5-1: Matt's top hammer, first working version | ham_top={36,90,110,300,48}, ham_avoid_x=47, face_known=true, ham_stop=50 | 9600000 | 1,000 | 68.4% (65.3% with fireballs) | 65.4% | 0.1% | 8,400 |
| 2026-11-10 08:38 | hammer5_70_95 | 5-1: top hammer, going in when the barrel is 70,95 px away | ham_top={36,70,95,300,48}, ham_avoid_x=47, face_known=true, ham_stop=50 | 9600000 | 300 | 64.6% (61.3% with fireballs) | 58.8% | 0.4% | 8,400 |
| 2026-11-10 08:39 | hammer5_60_85 | 5-1: top hammer, going in when the barrel is 60,85 px away | ham_top={36,60,85,300,48}, ham_avoid_x=47, face_known=true, ham_stop=50 | 9600000 | 300 | 54.3% (53.0% with fireballs) | 48.5% | 0.0% | 8,400 |
| 2026-11-10 08:48 | kz10 | 5-1 fresh exam, 30,000 games, with the s1 and s3 setup rules |  | 9400000 | 30,000 | 97.8% (95.1% with fireballs) | 97.6% | 0.0% | 7,100 |
| 2026-11-10 09:04 | lc00 | 5-1 fresh reference for Matt's ladder-91 climb rule |  | 9500000 | 10,000 | 97.7% (95.0% with fireballs) | 97.4% | 0.0% | 7,000 |
| 2026-11-10 09:19 | lc01 | 5-1: climbs ladder 91 only after Kong lets a barrel go or has it in front of him, with room, and once it has passed his short ladder (Matt) | climb_gate={91,60,60,true,true} | 9500000 | 10,000 | 97.1% (94.1% with fireballs) | 96.8% | 0.0% | 7,000 |
| 2026-11-10 09:34 | lc02 | 5-1: the same climb rule, without waiting for the barrel to pass Kong's short ladder | climb_gate={91,60,60,true,false} | 9500000 | 10,000 | 97.1% (94.1% with fireballs) | 96.8% | 0.0% | 7,000 |
| 2026-11-10 09:50 | lc03 | 5-1: Matt's ladder-91 climb rule, only while his own girder is quiet | climb_gate={91,60,60,true,false,60} | 9500000 | 10,000 | 97.7% (94.7% with fireballs) | 97.4% | 0.0% | 7,000 |
| 2026-11-10 10:05 | lc04 | 5-1: the climb rule's Kong part only (after a throw, not a wild), own girder quiet | climb_gate={91,60,0,true,false,60} | 9500000 | 10,000 | 97.7% (94.7% with fireballs) | 97.4% | 0.0% | 7,000 |
| 2026-11-10 10:19 | lc05 | 5-1: the climb rule's room part only (no barrel near the top), own girder quiet | climb_gate={91,99999,60,true,false,60} | 9500000 | 10,000 | 97.7% (95.0% with fireballs) | 97.4% | 0.0% | 7,000 |
| 2026-11-10 10:56 | hammer5b | 5-1: Matt's hammer routine (edge, jump as a barrel passes the broken ladder, stand left of ladder 91) | ham_top={33,70,80,400,48}, ham_avoid_x=47, face_known=true, ham_stop=50, ham_hold={84,650} | 9600000 | 1,000 | 59.6% (55.4% with fireballs) | 56.4% | 0.5% | 8,500 |
| 2026-11-10 11:13 | fk01 | 5-1: turning with the hammer by watching Mario's facing (lower hammer), no top hammer | face_known=true | 9500000 | 10,000 | 97.9% (95.5% with fireballs) | 97.6% | 0.0% | 7,000 |
| 2026-11-10 14:37 | hammer5c | 5-1: the top hammer the way barra does it (left ladder, jump from x=37 as a barrel passes the broken ladder, stand left of ladder 91) | ham_top={37,70,91,400,48,14}, ham_straight=true, ham_avoid_x=47, face_known=true, ham_stop=50, ham_hold={80,850}, ladder4=51, ladder4_top=114, arrive4=1 | 9600000 | 1,000 | 79.8% (76.9% with fireballs) | 77.1% | 0.0% | 8,400 |
| 2026-11-10 14:41 | hammer5d | 5-1: barra's hammer routine; at the edge any jump is straight up | ham_top={37,70,91,400,48,14}, ham_straight=true, ham_avoid_x=47, face_known=true, ham_stop=50, ham_hold={80,850}, ladder4=51, ladder4_top=114, arrive4=1 | 9600000 | 1,000 | 79.9% (76.8% with fireballs) | 77.3% | 0.2% | 8,400 |
| 2026-11-10 14:43 | hammer5e0 | 5-1: barra's hammer routine; steps onto the spot only with the next barrel far enough back (margin 0) | ham_top={37,70,91,400,48,14,0}, ham_avoid_x=47, face_known=true, ham_stop=50, ham_hold={80,850}, ladder4=51, ladder4_top=114, arrive4=1 | 9600000 | 1,000 | 74.3% (71.1% with fireballs) | 71.4% | 0.3% | 8,500 |
| 2026-11-10 14:45 | hammer5e15 | 5-1: barra's hammer routine; steps onto the spot only with the next barrel far enough back (margin 15) | ham_top={37,70,91,400,48,14,15}, ham_avoid_x=47, face_known=true, ham_stop=50, ham_hold={80,850}, ladder4=51, ladder4_top=114, arrive4=1 | 9600000 | 1,000 | 71.8% (68.7% with fireballs) | 68.9% | 0.3% | 8,400 |
| 2026-11-10 14:49 | hammer5f | 5-1: barra's hammer routine, jump timed so he lands with the barrel 30-40 px away like barra | ham_top={37,79,100,400,48,14}, ham_straight=true, ham_avoid_x=47, face_known=true, ham_stop=50, ham_hold={80,850}, ladder4=51, ladder4_top=114, arrive4=1 | 9600000 | 1,000 | 78.1% (75.2% with fireballs) | 75.4% | 0.0% | 8,400 |
| 2026-11-10 14:51 | hammer5g8 | 5-1: barra's hammer routine; a barrel too close at the edge is jumped to the right first (8 px short) | ham_top={37,79,100,400,48,14,30,8}, ham_straight=true, ham_avoid_x=47, face_known=true, ham_stop=50, ham_hold={80,850}, ladder4=51, ladder4_top=114, arrive4=1 | 9600000 | 1,000 | 68.9% (66.8% with fireballs) | 66.0% | 0.0% | 8,400 |
| 2026-11-10 14:53 | hammer5g20 | 5-1: barra's hammer routine; a barrel too close at the edge is jumped to the right first (20 px short) | ham_top={37,79,100,400,48,14,30,20}, ham_straight=true, ham_avoid_x=47, face_known=true, ham_stop=50, ham_hold={80,850}, ladder4=51, ladder4_top=114, arrive4=1 | 9600000 | 1,000 | 71.7% (69.4% with fireballs) | 68.8% | 0.0% | 8,400 |
| 2026-11-10 17:17 | ld00 | 5-1 fresh reference (facing fix on) |  | 9700000 | 10,000 | 97.9% (95.4% with fireballs) | 97.6% | 0.0% | 7,100 |
| 2026-11-10 17:31 | ld01 | 5-1: up the left ladder (x=51) to the 5th girder like barra, no hammer | ladder4=51, ladder4_top=114, arrive4=1 | 9700000 | 10,000 | 92.9% (90.4% with fireballs) | 92.4% | 0.0% | 7,100 |
| 2026-11-10 18:03 | xe00 | 5-1: logging every time the experts' four winning spots come up (changes nothing) | setups={{5,92,98,needs={{1,8,16,"e"},{0,57,72,"L"}},move={a=1,w=20,j1=nil,j2=nil,h=nil},name="s1"},{5,87,94,needs={{0,20,28,"L"},{0,-72,-64,"e"}},move={a=0,w=0,j1=0,j2=nil,h=1},name="s3"},{5,88,94,needs={{0,-31,-19,"L"},{0,18,30,"L"}},detect=true,name="x1"},{5,92,99,needs={{0,22,33,"L"},{1,7,16,"e"}},detect=true,name="x2"},{4,80,88,needs={{0,12,23,"R"},{1,12,24,"L"}},detect=true,name="x3"},{4,77,84,needs={{0,62,80,"R"},{1,14,24,"L"}},detect=true,name="x4"}} | 9800000 | 10,000 | 97.7% (95.2% with fireballs) | 97.4% | 0.0% | 7,000 |
| 2026-11-10 20:55 | xe01 | 5-1: logging every time KL's 2nd-girder waiting spots come up (changes nothing) | setups={{5,92,98,needs={{1,8,16,"e"},{0,57,72,"L"}},move={a=1,w=20,j1=nil,j2=nil,h=nil},name="s1"},{5,87,94,needs={{0,20,28,"L"},{0,-72,-64,"e"}},move={a=0,w=0,j1=0,j2=nil,h=1},name="s3"},{2,124,144,needs={{1,-4,4,"e"}},detect=true,name="x5"},{2,120,146,needs={{1,-66,-54,"L"}},detect=true,name="x6"}} | 9900000 | 10,000 | 97.9% (95.3% with fireballs) | 97.6% | 0.0% | 7,100 |
| 2026-11-10 23:03 | lp00 | 5-1 fresh reference for pulling barrels down like the experts |  | 10000000 | 10,000 | 98.0% (95.6% with fireballs) | 97.7% | 0.0% | 7,100 |
| 2026-11-10 23:17 | lp01 | 5-1: pulls barrels down a downstream ladder from 8 frames ahead (experts 81-85%, he 8%) | steer_pull=8 | 10000000 | 10,000 | 98.1% (95.6% with fireballs) | 97.8% | 0.0% | 7,100 |
| 2026-11-10 23:17 | lp02 | 5-1: the same, and while walking too | steer_pull=8, pull_walk=true | 10000000 | 0 | 0.0% (0.0% with fireballs) | 0.0% | 0.0% | 0 |
| 2026-11-10 23:32 | lp02 | 5-1: pulls barrels down a downstream ladder from 8 frames ahead, and while walking too | steer_pull=8, pull_moving=true | 10000000 | 10,000 | 98.5% (96.4% with fireballs) | 98.3% | 0.0% | 7,000 |
| 2026-11-10 23:48 | xc01 | 5-1 fresh: the experts' three spot rules (x1 walk left then jump; KL's x5 wait, x6 jump straight) | setups={{5,92,98,needs={{1,8,16,"e"},{0,57,72,"L"}},move={a=1,w=20,j1=nil,j2=nil,h=nil},name="s1"},{5,87,94,needs={{0,20,28,"L"},{0,-72,-64,"e"}},move={a=0,w=0,j1=0,j2=nil,h=1},name="s3"},{5,88,94,needs={{0,-31,-19,"L"},{0,18,30,"L"}},move={a=1,w=8,j1=0,j2=nil,h=0},name="x1"},{2,124,144,needs={{1,-4,4,"e"}},move={a=0,w=20,j1=nil,j2=nil,h=nil},name="x5"},{2,120,146,needs={{1,-66,-54,"L"}},move={a=0,w=0,j1=0,j2=nil,h=0},name="x6"}} | 10000000 | 10,000 | 97.8% (95.4% with fireballs) | 97.5% | 0.0% | 7,000 |
| 2026-11-11 00:04 | lp10 | 5-1 fresh reference (second check of pulling barrels down) |  | 10100000 | 10,000 | 97.9% (95.4% with fireballs) | 97.6% | 0.0% | 7,100 |
| 2026-11-11 00:17 | lp12 | 5-1 second check: pulling barrels down from 8 frames ahead, while walking too | steer_pull=8, pull_moving=true | 10100000 | 10,000 | 98.4% (96.2% with fireballs) | 98.1% | 0.0% | 7,100 |
| 2026-11-11 00:33 | pl40 | 4-1 fresh reference for pulling barrels down |  | 10200000 | 10,000 | 94.2% (93.2% with fireballs) | 93.7% | 0.0% | 7,100 |
| 2026-11-11 00:46 | pl41 | 4-1: pulls barrels down a downstream ladder from 8 frames ahead, while walking too | steer_pull=8, pull_moving=true | 10200000 | 10,000 | 94.8% (94.1% with fireballs) | 94.3% | 0.0% | 7,100 |
| 2026-11-11 01:00 | pl30 | 3-1 fresh reference for pulling barrels down |  | 10300000 | 10,000 | 95.2% (94.6% with fireballs) | 94.8% | 0.0% | 6,100 |
| 2026-11-11 01:14 | pl31 | 3-1: pulls barrels down a downstream ladder from 8 frames ahead, while walking too | steer_pull=8, pull_moving=true | 10300000 | 10,000 | 95.6% (95.0% with fireballs) | 95.2% | 0.0% | 6,100 |
| 2026-11-11 01:23 | pl20 | 2-1 fresh reference for pulling barrels down |  | 10400000 | 10,000 | 97.7% (97.6% with fireballs) | 97.4% | 0.0% | 5,200 |
| 2026-11-11 01:31 | pl21 | 2-1: pulls barrels down a downstream ladder from 8 frames ahead, while walking too | steer_pull=8, pull_moving=true | 10400000 | 10,000 | 86.0% (86.0% with fireballs) | 85.3% | 0.0% | 5,100 |
| 2026-11-11 01:42 | pl10 | 1-1 fresh reference for pulling barrels down |  | 10500000 | 10,000 | 98.9% (98.0% with fireballs) | 98.7% | 0.0% | 4,200 |
| 2026-11-11 01:53 | pl11 | 1-1: pulls barrels down a downstream ladder from 8 frames ahead, while walking too | steer_pull=8, pull_moving=true | 10500000 | 10,000 | 95.6% (94.2% with fireballs) | 95.2% | 0.0% | 4,100 |
| 2026-11-11 02:07 | pz00 | 5-1 fresh, today's settings: the deaths that are left |  | 10600000 | 10,000 | 98.4% (96.2% with fireballs) | 98.1% | 0.0% | 7,000 |
| 2026-11-11 02:27 | pl22 | 2-1: pulling barrels down with the safety check on (pull_safe), like 3-1 to 5-1 | steer_pull=8, pull_moving=true, pull_safe=true | 10200000 | 10,000 | 97.8% (97.7% with fireballs) | 97.5% | 0.0% | 5,200 |
| 2026-11-11 02:38 | pl12 | 1-1: pulling barrels down with the safety check on (pull_safe), like 3-1 to 5-1 | steer_pull=8, pull_moving=true, pull_safe=true | 10100000 | 10,000 | 99.0% (98.1% with fireballs) | 98.8% | 0.0% | 4,200 |
| 2026-11-11 02:47 | pl23 | 2-1: pulling barrels down with the safety check, on the reference's own games | steer_pull=8, pull_moving=true, pull_safe=true | 10400000 | 10,000 | 97.7% (97.7% with fireballs) | 97.4% | 0.0% | 5,200 |
| 2026-11-11 02:59 | pl13 | 1-1: pulling barrels down with the safety check, on the reference's own games | steer_pull=8, pull_moving=true, pull_safe=true | 10500000 | 10,000 | 98.8% (98.0% with fireballs) | 98.6% | 0.0% | 4,200 |
| 2026-11-11 03:13 | pu01 | 5-1: keeps off every ladder a barrel could come down (not just one zone), like the experts | under_zones=nil | 10600000 | 10,000 | 98.3% (96.3% with fireballs) | 98.0% | 0.0% | 7,000 |
| 2026-11-11 03:27 | pu02 | 5-1: the same, weighed twice as strongly | under_zones=nil, w_under=80 | 10600000 | 10,000 | 98.3% (96.3% with fireballs) | 98.1% | 0.0% | 7,000 |
| 2026-11-11 04:09 | pz10 | 5-1 fresh exam, 30,000 games, with the experts' steering (pulling barrels down) on |  | 10700000 | 30,000 | 98.4% (96.3% with fireballs) | 98.2% | 0.0% | 7,000 |
| 2026-11-11 04:49 | pe40 | 4-1 fresh exam, 30,000 games, with the experts' steering on |  | 14800000 | 30,000 | 94.9% (94.3% with fireballs) | 94.6% | 0.0% | 7,100 |
| 2026-11-11 05:29 | pe30 | 3-1 fresh exam, 30,000 games, with the experts' steering on |  | 13800000 | 30,000 | 95.5% (95.0% with fireballs) | 95.3% | 0.0% | 6,100 |
| 2026-11-11 19:00 | sj01 | 5-1: jumps last as long as the slope makes them (measured: a frame longer per pixel downhill) | slope_jump=true | 10600000 | 10,000 | 98.2% (96.0% with fireballs) | 98.0% | 0.0% | 7,000 |
| 2026-11-11 19:14 | sj02 | 5-1: a second jump can come 4 frames after landing (measured), not 6 | seconds={4,6,16,30} | 10600000 | 10,000 | 97.9% (95.8% with fireballs) | 97.6% | 0.0% | 7,100 |
| 2026-11-11 19:29 | sj03 | 5-1: both: slope-aware jumps and the quick second jump | slope_jump=true, seconds={4,6,16,30} | 10600000 | 10,000 | 96.1% (93.8% with fireballs) | 95.7% | 0.0% | 7,100 |
| 2026-11-11 19:43 | sj04 | 5-1: no bonus for jumping the way a barrel rolls (Matt: right jumps where a straight jump was the answer) | w_with=0 | 10600000 | 10,000 | 97.5% (95.4% with fireballs) | 97.1% | 0.0% | 7,100 |
| 2026-11-11 19:56 | sj05 | 5-1: half the bonus for jumping the way a barrel rolls | w_with=30 | 10600000 | 10,000 | 98.4% (96.3% with fireballs) | 98.1% | 0.0% | 7,000 |
| 2026-11-11 20:11 | sj06 | 5-1: no bonus for a sideways jump when a straight jump then is just as safe (Matt's review) | with_straight=true | 10600000 | 10,000 | 98.4% (96.2% with fireballs) | 98.1% | 0.0% | 7,000 |
| 2026-11-11 21:00 | sm00 | 5-1 fresh reference (second checks of small gains) |  | 11000000 | 10,000 | 98.4% (96.1% with fireballs) | 98.1% | 0.0% | 7,000 |
| 2026-11-11 21:13 | sm01 | 5-1 second check: KL's wait when a barrel comes down the ladder right above him on the 2nd girder (x5) | setups={{5,92,98,needs={{1,8,16,"e"},{0,57,72,"L"}},move={a=1,w=20,j1=nil,j2=nil,h=nil},name="s1"},{5,87,94,needs={{0,20,28,"L"},{0,-72,-64,"e"}},move={a=0,w=0,j1=0,j2=nil,h=1},name="s3"},{2,124,144,needs={{1,-4,4,"e"}},move={a=0,w=20,j1=nil,j2=nil,h=nil},name="x5"}} | 11000000 | 10,000 | 98.2% (96.0% with fireballs) | 97.9% | 0.0% | 7,000 |
| 2026-11-11 21:27 | sm02 | 5-1 second check: half the bonus for jumping the way a barrel rolls | w_with=30 | 11000000 | 10,000 | 98.4% (96.1% with fireballs) | 98.2% | 0.0% | 7,000 |
| 2026-11-11 22:09 | pl51 | 5-1: the planner allows 1 frame(s) for a jump press to take effect (his real jumps start later than it assumed) | press_lag=1 | 11000000 | 10,000 | 98.4% (96.4% with fireballs) | 98.2% | 0.0% | 7,000 |
| 2026-11-11 22:23 | pl52 | 5-1: the planner allows 2 frame(s) for a jump press to take effect (his real jumps start later than it assumed) | press_lag=2 | 11000000 | 10,000 | 97.0% (95.0% with fireballs) | 96.6% | 0.0% | 7,000 |
| 2026-11-11 22:36 | pl53 | 5-1: the planner allows 3 frame(s) for a jump press to take effect (his real jumps start later than it assumed) | press_lag=3 | 11000000 | 10,000 | 92.1% (90.4% with fireballs) | 91.5% | 0.0% | 7,000 |
| 2026-11-11 22:51 | pl60 | 5-1 fresh reference (second check of the 1-frame jump allowance) |  | 11100000 | 10,000 | 98.5% (96.6% with fireballs) | 98.2% | 0.0% | 7,000 |
| 2026-11-11 23:05 | pl61 | 5-1 second check: the planner allows 1 frame for a jump press to take effect | press_lag=1 | 11100000 | 10,000 | 98.7% (96.9% with fireballs) | 98.4% | 0.0% | 7,000 |
| 2026-11-11 23:47 | pz20 | 5-1 fresh exam, 30,000 games: pull, half bonus, 1-frame jump allowance |  | 11200000 | 30,000 | 98.4% (96.4% with fireballs) | 98.3% | 0.0% | 7,000 |
| 2026-11-12 00:02 | pj40 | 4-1 fresh reference for the 1-frame jump allowance |  | 11450000 | 10,000 | 94.7% (94.1% with fireballs) | 94.3% | 0.0% | 7,100 |
| 2026-11-12 00:15 | pj41 | 4-1: the planner allows 1 frame for a jump press to take effect | press_lag=1 | 11450000 | 10,000 | 95.4% (94.7% with fireballs) | 95.0% | 0.0% | 7,100 |
| 2026-11-12 00:33 | pj30 | 3-1 fresh reference for the 1-frame jump allowance |  | 11350000 | 10,000 | 96.0% (95.6% with fireballs) | 95.5% | 0.0% | 6,100 |
| 2026-11-12 00:52 | pj31 | 3-1: the planner allows 1 frame for a jump press to take effect | press_lag=1 | 11350000 | 10,000 | 95.7% (95.2% with fireballs) | 95.3% | 0.0% | 6,100 |
| 2026-11-12 01:05 | pj20 | 2-1 fresh reference for the 1-frame jump allowance |  | 11250000 | 10,000 | 97.6% (97.5% with fireballs) | 97.3% | 0.0% | 5,200 |
| 2026-11-12 01:18 | pj21 | 2-1: the planner allows 1 frame for a jump press to take effect | press_lag=1 | 11250000 | 10,000 | 98.6% (98.5% with fireballs) | 98.4% | 0.0% | 5,200 |
| 2026-11-12 01:34 | pj10 | 1-1 fresh reference for the 1-frame jump allowance |  | 11150000 | 10,000 | 99.0% (98.0% with fireballs) | 98.8% | 0.0% | 4,200 |
| 2026-11-12 01:51 | pj11 | 1-1: the planner allows 1 frame for a jump press to take effect | press_lag=1 | 11150000 | 10,000 | 99.0% (98.0% with fireballs) | 98.8% | 0.0% | 4,200 |
| 2026-11-12 02:10 | pk40 | 4-1 fresh reference (second check of the 1-frame jump allowance) |  | 11650000 | 10,000 | 95.0% (94.3% with fireballs) | 94.5% | 0.0% | 7,100 |
| 2026-11-12 02:29 | pk41 | 4-1 second check: the planner allows 1 frame for a jump press to take effect | press_lag=1 | 11650000 | 10,000 | 95.7% (94.9% with fireballs) | 95.3% | 0.0% | 7,100 |
| 2026-11-12 02:42 | pk20 | 2-1 fresh reference (second check of the 1-frame jump allowance) |  | 11750000 | 10,000 | 97.6% (97.4% with fireballs) | 97.2% | 0.0% | 5,200 |
| 2026-11-12 02:55 | pk21 | 2-1 second check: the planner allows 1 frame for a jump press to take effect | press_lag=1 | 11750000 | 10,000 | 98.4% (98.4% with fireballs) | 98.2% | 0.0% | 5,200 |
| 2026-11-12 03:35 | pe22 | 2-1 fresh exam, 30,000 games, with the 1-frame jump allowance |  | 12200000 | 30,000 | 98.5% (98.4% with fireballs) | 98.3% | 0.0% | 5,200 |
| 2026-11-12 04:32 | pe42 | 4-1 fresh exam, 30,000 games, with the 1-frame jump allowance |  | 12400000 | 30,000 | 95.5% (94.8% with fireballs) | 95.2% | 0.0% | 7,100 |
| 2026-11-12 08:53 | fw00 | 5-1 fresh reference (slipping jumps retest) |  | 11300000 | 10,000 | 98.3% (96.5% with fireballs) | 98.0% | 0.0% | 7,000 |
| 2026-11-12 09:14 | fw01 | 5-1: finer jump timing so a planned jump doesn't slip (retest on today's settings) | fine_waits=true | 11300000 | 10,000 | 98.5% (96.8% with fireballs) | 98.2% | 0.0% | 7,000 |
| 2026-11-12 09:28 | kj02 | 5-1: keeps weighing the jump he planned a moment ago (retest) | keep_jump=true, w_keep=20 | 11300000 | 10,000 | 98.1% (96.1% with fireballs) | 97.8% | 0.0% | 7,000 |
| 2026-11-12 09:42 | fw10 | 5-1 fresh reference (second check of finer jump timing) |  | 11400000 | 10,000 | 98.3% (96.2% with fireballs) | 98.0% | 0.0% | 7,000 |
| 2026-11-12 10:03 | fw11 | 5-1 second check: finer jump timing so a planned jump doesn't slip | fine_waits=true | 11400000 | 10,000 | 98.5% (96.8% with fireballs) | 98.3% | 0.0% | 7,000 |
| 2026-11-12 10:24 | ue01 | 5-1: keeps from standing under a ladder a barrel above will reach soon {10,40,60} (the experts' habit) | under_end={10,40,60} | 11400000 | 10,000 | 98.3% (96.7% with fireballs) | 98.0% | 0.0% | 7,000 |
| 2026-11-12 10:46 | ue02 | 5-1: keeps from standing under a ladder a barrel above will reach soon {12,80,60} (the experts' habit) | under_end={12,80,60} | 11400000 | 10,000 | 96.0% (93.7% with fireballs) | 95.6% | 0.0% | 7,000 |
| 2026-11-12 11:07 | ue03 | 5-1: keeps from standing under a ladder a barrel above will reach soon {8,40,90} (the experts' habit) | under_end={8,40,90} | 11400000 | 10,000 | 98.3% (96.7% with fireballs) | 98.0% | 0.0% | 7,000 |
| 2026-11-12 12:02 | wl01 | 5-1: a smaller preference for later jumps (w_later 0.25; Matt: jump earlier) | w_later=0.25 | 11400000 | 10,000 | 98.4% (96.7% with fireballs) | 98.1% | 0.0% | 7,000 |
| 2026-11-12 12:21 | wl02 | 5-1: a smaller preference for later jumps (w_later 0.1; Matt: jump earlier) | w_later=0.1 | 11400000 | 10,000 | 98.1% (96.4% with fireballs) | 97.8% | 0.0% | 7,000 |
| 2026-11-12 12:40 | wl03 | 5-1: a smaller preference for later jumps (w_later 0; Matt: jump earlier) | w_later=0 | 11400000 | 10,000 | 98.1% (96.5% with fireballs) | 97.8% | 0.0% | 7,000 |
| 2026-11-12 13:03 | wl04 | 5-1: a larger preference for later jumps (w_later 0.6) | w_later=0.6 | 11400000 | 10,000 | 97.5% (94.7% with fireballs) | 97.2% | 0.0% | 6,900 |
| 2026-11-12 13:37 | wl05 | 5-1: a larger preference for later jumps (w_later 0.8) | w_later=0.8 | 11400000 | 10,000 | 87.3% (72.4% with fireballs) | 86.6% | 0.0% | 6,900 |
| 2026-11-12 13:58 | rv00 | 5-1: logging every time the situations from Matt's reviewed deaths come up (changes nothing) | setups={{5,92,98,needs={{1,8,16,"e"},{0,57,72,"L"}},move={a=1,w=20,j1=nil,j2=nil,h=nil},name="s1"},{5,87,94,needs={{0,20,28,"L"},{0,-72,-64,"e"}},move={a=0,w=0,j1=0,j2=nil,h=1},name="s3"},{5,72,84,needs={{0,36,52,"L"},{0,14,30,"L"}},detect=true,name="r1"},{5,88,100,needs={{0,19,35,"L"},{0,-30,-14,"L"}},detect=true,name="r2"},{4,81,93,needs={{0,-37,-21,"R"},{1,-39,-23,"L"}},detect=true,name="r3"},{4,115,127,needs={{0,-22,-6,"R"},{1,-25,-9,"L"},{0,-44,-28,"R"}},detect=true,name="r4"},{4,109,121,needs={{0,-68,-52,"R"},{0,-32,-16,"e"}},detect=true,name="r5"},{5,82,94,needs={{0,-2,14,"L"},{0,47,63,"L"}},detect=true,name="r6"},{5,209,221,needs={{0,12,28,"e"}},detect=true,name="r7"},{4,108,120,needs={{0,29,45,"R"}},detect=true,name="r8"},{4,146,158,needs={{0,-20,-4,"R"},{0,-59,-43,"R"}},detect=true,name="r9"}} | 11500000 | 10,000 | 98.5% (96.8% with fireballs) | 98.2% | 0.0% | 7,000 |
| 2026-11-12 20:27 | rr00 | 5-1 fresh reference (rules from Matt's reviews) |  | 11600000 | 10,000 | 98.4% (96.7% with fireballs) | 98.2% | 0.0% | 7,000 |
| 2026-11-12 20:46 | rr01 | 5-1: three rules from Matt's reviewed deaths (r1, r2, r7) | setups={{5,92,98,needs={{1,8,16,"e"},{0,57,72,"L"}},move={a=1,w=20,j1=nil,j2=nil,h=nil},name="s1"},{5,87,94,needs={{0,20,28,"L"},{0,-72,-64,"e"}},move={a=0,w=0,j1=0,j2=nil,h=1},name="s3"},{5,72,84,needs={{0,36,52,"L"},{0,14,30,"L"}},move={a=1,w=8,j1=2,j2=nil,h=1},name="r1"},{5,88,100,needs={{0,19,35,"L"},{0,-30,-14,"L"}},move={a=1,w=8,j1=0,j2=nil,h=1},name="r2"},{5,209,221,needs={{0,12,28,"e"}},move={a=1,w=16,j1=2,j2=nil,h=1},name="r7"}} | 11600000 | 10,000 | 98.7% (97.0% with fireballs) | 98.4% | 0.0% | 7,000 |
| 2026-11-12 21:05 | rr10 | 5-1 fresh reference (second check of rules from Matt's reviews) |  | 11700000 | 10,000 | 98.7% (96.9% with fireballs) | 98.4% | 0.0% | 7,000 |
| 2026-11-12 21:24 | rr11 | 5-1 second check: rules r2 and r7 from Matt's reviewed deaths | setups={{5,92,98,needs={{1,8,16,"e"},{0,57,72,"L"}},move={a=1,w=20,j1=nil,j2=nil,h=nil},name="s1"},{5,87,94,needs={{0,20,28,"L"},{0,-72,-64,"e"}},move={a=0,w=0,j1=0,j2=nil,h=1},name="s3"},{5,88,100,needs={{0,19,35,"L"},{0,-30,-14,"L"}},move={a=1,w=8,j1=0,j2=nil,h=1},name="r2"},{5,209,221,needs={{0,12,28,"e"}},move={a=1,w=16,j1=2,j2=nil,h=1},name="r7"}} | 11700000 | 10,000 | 98.8% (97.1% with fireballs) | 98.5% | 0.0% | 7,000 |
| 2026-11-12 21:43 | ds01 | 5-1: without the old rule s1 (now even or behind) | setups={{5,87,94,needs={{0,20,28,"L"},{0,-72,-64,"e"}},move={a=0,w=0,j1=0,j2=nil,h=1},name="s3"},{5,88,100,needs={{0,19,35,"L"},{0,-30,-14,"L"}},move={a=1,w=8,j1=0,j2=nil,h=1},name="r2"},{5,209,221,needs={{0,12,28,"e"}},move={a=1,w=16,j1=2,j2=nil,h=1},name="r7"}} | 11700000 | 10,000 | 98.8% (97.2% with fireballs) | 98.6% | 0.0% | 7,000 |
| 2026-11-12 22:02 | ds02 | 5-1: without the old rules s1 and s3 | setups={{5,88,100,needs={{0,19,35,"L"},{0,-30,-14,"L"}},move={a=1,w=8,j1=0,j2=nil,h=1},name="r2"},{5,209,221,needs={{0,12,28,"e"}},move={a=1,w=16,j1=2,j2=nil,h=1},name="r7"}} | 11700000 | 10,000 | 98.9% (97.2% with fireballs) | 98.6% | 0.0% | 7,000 |
| 2026-11-12 22:21 | ds10 | 5-1 fresh reference, all rules (second check of dropping s1 and s3) |  | 11800000 | 10,000 | 98.6% (97.2% with fireballs) | 98.3% | 0.0% | 7,000 |
| 2026-11-12 22:39 | ds12 | 5-1 second check: without the old rules s1 and s3 | setups={{5,88,100,needs={{0,19,35,"L"},{0,-30,-14,"L"}},move={a=1,w=8,j1=0,j2=nil,h=1},name="r2"},{5,209,221,needs={{0,12,28,"e"}},move={a=1,w=16,j1=2,j2=nil,h=1},name="r7"}} | 11800000 | 10,000 | 98.7% (97.3% with fireballs) | 98.4% | 0.0% | 7,000 |
| 2026-11-12 23:36 | pz30 | 5-1 fresh exam, 30,000 games: finer timing, Matt's rules r2 and r7, old rules gone |  | 11900000 | 30,000 | 98.7% (97.2% with fireballs) | 98.5% | 0.0% | 7,000 |
| 2026-11-13 01:27 | on1r00 | 5-1: logging every time the situations from Matt's reviewed deaths come up (changes nothing) | setups={{5,92,98,needs={{1,8,16,"e"},{0,57,72,"L"}},move={a=1,w=20,j1=nil,j2=nil,h=nil},name="s1"},{5,87,94,needs={{0,20,28,"L"},{0,-72,-64,"e"}},move={a=0,w=0,j1=0,j2=nil,h=1},name="s3"},{4,95,107,needs={{0,-35,-19,"R"},{0,-58,-42,"e"}},detect=true,name="r1"},{4,122,134,needs={{0,51,67,"e"},{0,-22,-6,"R"},{0,-45,-29,"e"}},detect=true,name="r2"},{4,123,135,needs={{0,-27,-11,"R"},{0,-38,-22,"R"},{0,-67,-51,"R"}},detect=true,name="r3"},{5,86,98,needs={{0,14,30,"L"},{0,51,67,"L"}},detect=true,name="r4"},{5,96,108,needs={{0,51,67,"L"},{0,14,30,"L"}},detect=true,name="r5"},{5,77,89,needs={{1,47,63,"R"}},detect=true,name="r6"},{4,77,89,needs={{0,0,16,"e"},{0,-31,-15,"R"},{1,-37,-21,"L"}},detect=true,name="r7"},{5,84,96,needs={{0,-33,-17,"L"},{0,16,32,"L"}},detect=true,name="r8"},{5,76,88,needs={{0,-29,-13,"L"},{0,20,36,"L"}},detect=true,name="r9"},{5,92,104,needs={{1,-13,3,"R"},{0,10,26,"L"}},detect=true,name="r10"},{4,133,145,needs={{0,51,67,"R"},{0,-35,-19,"R"}},detect=true,name="r11"},{3,102,114,needs={{0,6,22,"L"},{0,-33,-17,"L"}},detect=true,name="r12"},{3,92,104,needs={{0,-16,0,"L"},{0,21,37,"L"},{1,-15,1,"e"}},detect=true,name="r13"},{3,90,102,needs={{0,25,41,"L"}},detect=true,name="r14"},{2,103,115,needs={{0,-58,-42,"R"},{1,8,24,"L"}},detect=true,name="r15"},{3,137,149,needs={{0,28,44,"L"},{1,-47,-31,"R"},{1,52,68,"e"},{1,-60,-44,"e"}},detect=true,name="r16"},{2,97,109,needs={{0,-49,-33,"R"},{1,-59,-43,"L"}},detect=true,name="r17"},{2,100,112,needs={{0,-58,-42,"R"},{1,14,30,"L"}},detect=true,name="r18"}} | 12000000 | 10,000 | 98.4% (96.9% with fireballs) | 98.2% | 0.0% | 7,000 |
| 2026-11-13 08:57 | on1c00 | 5-1 fresh reference (check 1 of overnight rules) |  | 12100000 | 10,000 | 98.8% (97.2% with fireballs) | 98.5% | 0.0% | 7,000 |
| 2026-11-13 09:16 | on1c01 | 5-1 check 1: overnight rules from ground deaths | setups={{5,88,100,name="r2",move={h=1,w=8,j1=0,a=1},needs={{0,19,35,"L"},{0,-30,-14,"L"}}},{5,209,221,name="r7",move={h=1,w=16,j1=2,a=1},needs={{0,12,28,"e"}}},{5,92,104,needs={{1,-13,3,"R"},{0,10,26,"L"}},move={a=1,w=4,j1=nil,j2=nil,h=nil},name="on1r10"},{2,103,115,needs={{0,-58,-42,"R"},{1,8,24,"L"}},move={a=1,w=10,j1=nil,j2=nil,h=nil},name="on1r15"},{2,97,109,needs={{0,-49,-33,"R"},{1,-59,-43,"L"}},move={a=2,w=10,j1=nil,j2=nil,h=nil},name="on1r17"},{2,100,112,needs={{0,-58,-42,"R"},{1,14,30,"L"}},move={a=1,w=4,j1=nil,j2=nil,h=nil},name="on1r18"}} | 12100000 | 10,000 | 98.7% (97.2% with fireballs) | 98.5% | 0.0% | 7,000 |
| 2026-11-13 10:29 | pz40 | 5-1 fresh exam, 30,000 games, after the overnight rules |  | 12500000 | 30,000 | 98.7% (97.2% with fireballs) | 98.6% | 0.0% | 7,000 |
| 2026-11-13 11:00 | r9c00 | 5-1 fresh reference (check of the r9 rule) |  | 12800000 | 10,000 | 98.6% (97.2% with fireballs) | 98.3% | 0.0% | 7,000 |
| 2026-11-13 11:31 | r9c01 | 5-1: rule r9 (tap left 4 between two barrels near the 5th girder's left ladder) | setups={{5,88,100,needs={{0,19,35,"L"},{0,-30,-14,"L"}},move={a=1,w=8,j1=0,j2=nil,h=1},name="r2"},{5,209,221,needs={{0,12,28,"e"}},move={a=1,w=16,j1=2,j2=nil,h=1},name="r7"},{5,76,88,needs={{0,-29,-13,"L"},{0,20,36,"L"}},move={a=1,w=4,j1=nil,j2=nil,h=nil},name="on1r9"}} | 12800000 | 10,000 | 98.5% (97.1% with fireballs) | 98.3% | 0.0% | 7,000 |
| 2026-11-13 11:52 | r9c10 | 5-1 fresh reference (check of the r9 rule) |  | 12900000 | 10,000 | 98.7% (97.2% with fireballs) | 98.5% | 0.0% | 7,000 |
| 2026-11-13 12:12 | r9c11 | 5-1: rule r9 (tap left 4 between two barrels near the 5th girder's left ladder) | setups={{5,88,100,needs={{0,19,35,"L"},{0,-30,-14,"L"}},move={a=1,w=8,j1=0,j2=nil,h=1},name="r2"},{5,209,221,needs={{0,12,28,"e"}},move={a=1,w=16,j1=2,j2=nil,h=1},name="r7"},{5,76,88,needs={{0,-29,-13,"L"},{0,20,36,"L"}},move={a=1,w=4,j1=nil,j2=nil,h=nil},name="on1r9"}} | 12900000 | 10,000 | 98.7% (97.1% with fireballs) | 98.4% | 0.0% | 7,000 |
| 2026-11-13 15:18 | ks00 | 5-1 fresh reference (Kong's wild barrels) |  | 13500000 | 10,000 | 98.6% (97.3% with fireballs) | 98.4% | 0.0% | 7,000 |
| 2026-11-13 15:29 | on2r00 | 5-1: logging every time the situations from Matt's reviewed deaths come up (changes nothing) | setups={{5,92,98,needs={{1,8,16,"e"},{0,57,72,"L"}},move={a=1,w=20,j1=nil,j2=nil,h=nil},name="s1"},{5,87,94,needs={{0,20,28,"L"},{0,-72,-64,"e"}},move={a=0,w=0,j1=0,j2=nil,h=1},name="s3"},{5,91,103,needs={{0,-34,-18,"L"},{0,3,19,"L"},{1,-4,12,"R"}},detect=true,name="r1"},{4,76,88,needs={{0,52,68,"R"},{1,17,33,"e"}},detect=true,name="r2"},{2,85,97,needs={{1,16,32,"e"},{1,38,54,"L"},{0,26,42,"R"},{0,-22,-6,"R"}},detect=true,name="r3"}} | 13000000 | 10,000 | 98.4% (96.6% with fireballs) | 98.2% | 0.0% | 7,000 |
| 2026-11-13 15:59 | ks01 | 5-1: Kong's wilds 81% aimed at Mario, 19% straight down (measured) | kong_aim=0.81, kong_straight=0.19 | 13500000 | 10,000 | 98.7% (97.3% with fireballs) | 98.4% | 0.0% | 7,000 |
| 2026-11-13 16:41 | ks02 | 5-1: Kong's wilds aimed, plus a 19% chance of straight down | kong_straight=0.19 | 13500000 | 10,000 | 98.6% (97.3% with fireballs) | 98.4% | 0.0% | 7,000 |
| 2026-11-13 17:27 | kw10 | 5-1 fresh reference (new wild barrels' straight drop) |  | 13600000 | 10,000 | 98.8% (97.2% with fireballs) | 98.5% | 0.0% | 7,000 |
| 2026-11-13 18:08 | kw11 | 5-1: a new wild he hasn't seen move yet may also drop straight down (Matt's review 3 #4) | kong_straight_seen=true | 13600000 | 10,000 | 98.8% (97.2% with fireballs) | 98.5% | 0.0% | 7,000 |
| 2026-11-13 18:24 | on2c00 | 5-1 fresh reference (check 1 of overnight rules) |  | 13100000 | 10,000 | 98.6% (97.0% with fireballs) | 98.3% | 0.0% | 7,000 |
| 2026-11-13 18:45 | on2c01 | 5-1 check 1: overnight rules from ground deaths | setups={{5,88,100,needs={{0,19,35,"L"},{0,-30,-14,"L"}},move={a=1,j1=0,w=8,h=1},name="r2"},{5,209,221,needs={{0,12,28,"e"}},move={a=1,j1=2,w=16,h=1},name="r7"},{5,91,103,needs={{0,-34,-18,"L"},{0,3,19,"L"},{1,-4,12,"R"}},move={a=1,w=4,j1=nil,j2=nil,h=nil},name="on2r1"}} | 13100000 | 10,000 | 98.6% (97.0% with fireballs) | 98.3% | 0.0% | 7,000 |
| 2026-11-13 19:05 | on2c10 | 5-1 fresh reference (check 2 of overnight rules) |  | 13200000 | 10,000 | 98.6% (97.1% with fireballs) | 98.4% | 0.0% | 7,000 |
| 2026-11-13 19:26 | on2c11 | 5-1 check 2: overnight rules from ground deaths | setups={{5,88,100,needs={{0,19,35,"L"},{0,-30,-14,"L"}},move={a=1,j1=0,w=8,h=1},name="r2"},{5,209,221,needs={{0,12,28,"e"}},move={a=1,j1=2,w=16,h=1},name="r7"},{5,91,103,needs={{0,-34,-18,"L"},{0,3,19,"L"},{1,-4,12,"R"}},move={a=1,w=4,j1=nil,j2=nil,h=nil},name="on2r1"}} | 13200000 | 10,000 | 98.6% (97.1% with fireballs) | 98.4% | 0.0% | 7,000 |
| 2026-11-13 20:56 | pz50 | 5-1 fresh exam, 30,000 games, with the new-wild fix |  | 14000000 | 30,000 | 98.6% (97.0% with fireballs) | 98.5% | 0.0% | 7,000 |
| 2026-11-13 21:03 | lr00 | 5-1: logging every time the situations from Matt's reviewed deaths come up (changes nothing) | setups={{5,88,100,move={w=8,h=1,a=1,j1=0},name="r2",needs={{0,19,35,"L"},{0,-30,-14,"L"}}},{5,209,221,move={w=16,h=1,a=1,j1=2},name="r7",needs={{0,12,28,"e"}}},{4,116,128,needs={{0,-82,-66,"R"},{0,-60,-44,"R"},{2,-24,-8,"R",106,-6,6},{1,-79,-63,"e"}},detect=true,name="r1"},{4,115,127,needs={{0,-66,-50,"R"},{2,-30,-14,"R",106,1,13},{0,-78,-62,"e"},{2,67,83,"R",202,0,12}},detect=true,name="r2"}} | 14100000 | 10,000 | 98.6% (97.3% with fireballs) | 98.4% | 0.0% | 7,000 |
| 2026-11-13 21:30 | pu10 | 5-1 fresh reference (pulling barrels down on the upstream side) |  | 14200000 | 10,000 | 98.6% (97.2% with fireballs) | 98.4% | 0.0% | 7,000 |
| 2026-11-13 21:56 | pu12 | 5-1: also pulls barrels down a ladder on the upstream side at least 30 px away (the experts do) | pull_upstream=30 | 14200000 | 10,000 | 96.1% (94.5% with fireballs) | 95.7% | 0.0% | 7,000 |
| 2026-11-13 22:17 | pu13 | 5-1: also pulls barrels down a ladder on the upstream side at least 45 px away (the experts do) | pull_upstream=45 | 14200000 | 10,000 | 96.1% (94.4% with fireballs) | 95.7% | 0.0% | 7,000 |
| 2026-11-13 22:42 | ct01 | 5-1: plans like a person who'll react when he sees a barrel's ladder choice (contingent) | contingent=true | 14200000 | 10,000 | 93.4% (92.2% with fireballs) | 92.9% | 0.0% | 7,000 |
| 2026-11-13 23:23 | ct02 | 5-1: contingent planning, with a smaller cost for real risks | contingent=true, w_risk=250 | 14200000 | 10,000 | 93.4% (92.2% with fireballs) | 92.9% | 0.0% | 7,000 |
| 2026-11-13 23:28 | fl00 | 5-1: logging situations every 4 frames to learn danger from his own games (changes nothing) |  | 14600000 | 10,000 | 98.7% (97.0% with fireballs) | 98.4% | 0.0% | 7,000 |
| 2026-11-14 00:05 | kl00 | 5-1: logging every time Mario is just up the middle ladder while Kong's barrel nears his short ladder (Matt's #6 / #9; changes nothing) | setups={{5,88,100,needs={{0,19,35,L},{0,-30,-14,L}},name=r2,move={a=1,j1=0,w=8,h=1}},{5,209,221,needs={{0,12,28,e}},name=r7,move={a=1,j1=2,w=16,h=1}},{4,112,132,needs={{2,-40,0,"R",106,0,16}},detect=true,name="k1"}} | 14300000 | 10,000 | 98.5% (96.7% with fireballs) | 98.3% | 0.0% | 7,000 |
| 2026-11-14 00:12 | ct03 | 5-1: contingent planning, the way out must dodge every barrel that might come down | contingent=2 | 14200000 | 10,000 | 93.4% (92.2% with fireballs) | 92.9% | 0.0% | 7,000 |
| 2026-11-14 01:02 | ct04 | 5-1: the same, with 8 frames' extra reaction | contingent=2, contingent_lag=8 | 14200000 | 10,000 | 98.1% (96.8% with fireballs) | 97.8% | 0.0% | 7,000 |
| 2026-11-14 02:03 | fl01 | 5-1: logging situations and the planner's score every 4 frames (changes nothing) |  | 14600000 | 10,000 | 98.7% (97.0% with fireballs) | 98.4% | 0.0% | 7,000 |
| 2026-11-14 03:11 | ct05 | 5-1: contingent planning with 16 frames' extra reaction | contingent=2, contingent_lag=16 | 14200000 | 10,000 | 98.2% (96.9% with fireballs) | 98.0% | 0.0% | 7,000 |
| 2026-11-14 04:26 | dg100 | 5-1: counts the learned danger of where a plan leaves him against it (weight 100) | danger=100 | 14200000 | 10,000 | 98.7% (97.2% with fireballs) | 98.4% | 0.0% | 7,000 |
| 2026-11-14 05:37 | dg300 | 5-1: counts the learned danger of where a plan leaves him against it (weight 300) | danger=300 | 14200000 | 10,000 | 98.7% (97.3% with fireballs) | 98.4% | 0.0% | 7,000 |
| 2026-11-14 06:00 | mb00 | 5-1 fresh reference (check 1 of Matt's scenario rules) |  | 14500000 | 10,000 | 98.8% (97.1% with fireballs) | 98.5% | 0.0% | 7,000 |
| 2026-11-14 06:36 | dh00 | 5-1 fresh reference (second check of the danger table) |  | 14700000 | 10,000 | 98.8% (97.1% with fireballs) | 98.6% | 0.0% | 7,000 |
| 2026-11-14 06:59 | mb01 | 5-1 check 1: Matt's confirmed fixes as tight scenario rules | setups={{5,88,100,needs={{0,19,35,"L"},{0,-30,-14,"L"}},name="r2",move={j1=0,h=1,a=1,w=8}},{5,209,221,needs={{0,12,28,"e"}},name="r7",move={j1=2,h=1,a=1,w=16}},{4,81,93,needs={{0,-37,-21,"R"},{1,-39,-23,"L"}},move={a=0,w=0,j1=0,j2=nil,h=0},name="m1"},{4,109,121,needs={{0,-68,-52,"R"},{0,-32,-16,"e"}},move={a=0,w=0,j1=0,j2=nil,h=0},name="m2"},{4,108,120,needs={{0,29,45,"R"}},move={a=2,w=10,j1=nil,j2=nil,h=nil},name="m3"},{4,116,128,needs={{0,-60,-44,"R"}},move={a=2,w=20,j1=nil,j2=nil,h=nil},name="m4"},{4,115,127,needs={{0,-66,-50,"R"}},move={a=0,w=20,j1=nil,j2=nil,h=nil},name="m5"}} | 14500000 | 10,000 | 94.3% (92.7% with fireballs) | 93.9% | 0.0% | 7,000 |
| 2026-11-14 07:48 | dh300 | 5-1 second check: learned danger of where a plan leaves him, weight 300 | danger=300 | 14700000 | 10,000 | 98.7% (96.9% with fireballs) | 98.4% | 0.0% | 7,000 |
| 2026-11-14 07:55 | mb10 | 5-1 fresh reference (check 2 of Matt's scenario rules) |  | 14600000 | 10,000 | 98.7% (97.0% with fireballs) | 98.4% | 0.0% | 7,000 |
| 2026-11-14 08:16 | mb11 | 5-1 check 2: Matt's confirmed fixes as tight scenario rules | setups={{5,88,100,needs={{0,19,35,"L"},{0,-30,-14,"L"}},name="r2",move={j1=0,h=1,a=1,w=8}},{5,209,221,needs={{0,12,28,"e"}},name="r7",move={j1=2,h=1,a=1,w=16}},{4,81,93,needs={{0,-37,-21,"R"},{1,-39,-23,"L"}},move={a=0,w=0,j1=0,j2=nil,h=0},name="m1"},{4,109,121,needs={{0,-68,-52,"R"},{0,-32,-16,"e"}},move={a=0,w=0,j1=0,j2=nil,h=0},name="m2"},{4,108,120,needs={{0,29,45,"R"}},move={a=2,w=10,j1=nil,j2=nil,h=nil},name="m3"},{4,116,128,needs={{0,-60,-44,"R"}},move={a=2,w=20,j1=nil,j2=nil,h=nil},name="m4"},{4,115,127,needs={{0,-66,-50,"R"}},move={a=0,w=20,j1=nil,j2=nil,h=nil},name="m5"}} | 14600000 | 10,000 | 94.6% (92.9% with fireballs) | 94.2% | 0.0% | 7,000 |
| 2026-11-14 08:43 | dh300 | 5-1 second check: learned danger of where a plan leaves him, weight 300 | danger=300 | 14700000 | 10,000 | 98.7% (96.9% with fireballs) | 98.4% | 0.0% | 7,000 |
| 2026-11-14 09:09 | dh600 | 5-1 second check: learned danger of where a plan leaves him, weight 600 | danger=600 | 14700000 | 10,000 | 98.7% (96.9% with fireballs) | 98.4% | 0.0% | 7,000 |
| 2026-11-14 09:30 | mc00 | 5-1 fresh reference (check 1 of Matt's scenario rules) |  | 14800000 | 10,000 | 98.8% (97.4% with fireballs) | 98.5% | 0.0% | 7,000 |
| 2026-11-14 09:51 | mc01 | 5-1 check 1: Matt's confirmed fixes as tight scenario rules | setups={{5,88,100,name="r2",needs={{0,19,35,"L"},{0,-30,-14,"L"}},move={h=1,a=1,w=8,j1=0}},{5,209,221,name="r7",needs={{0,12,28,"e"}},move={h=1,a=1,w=16,j1=2}},{4,81,93,needs={{0,-37,-21,"R"},{1,-39,-23,"L"}},move={a=0,w=0,j1=0,j2=nil,h=0},trouble=0,name="m1"},{4,109,121,needs={{0,-68,-52,"R"},{0,-32,-16,"e"}},move={a=0,w=0,j1=0,j2=nil,h=0},trouble=0,name="m2"},{4,108,120,needs={{0,29,45,"R"}},move={a=2,w=10,j1=nil,j2=nil,h=nil},trouble=0,name="m3"},{4,116,128,needs={{0,-60,-44,"R"}},move={a=2,w=20,j1=nil,j2=nil,h=nil},trouble=0,name="m4"},{4,115,127,needs={{0,-66,-50,"R"}},move={a=0,w=20,j1=nil,j2=nil,h=nil},trouble=0,name="m5"}} | 14800000 | 10,000 | 97.3% (95.9% with fireballs) | 97.0% | 0.0% | 7,000 |
| 2026-11-14 10:14 | tp00 | 5-1: no hammer (reference for the planned hammer) |  | 14950000 | 1,000 | 98.2% (97.0% with fireballs) | 97.1% | 0.0% | 7,000 |
| 2026-11-14 10:16 | tp01 | 5-1: the old scripted top hammer | ham_avoid=false, ham_top={33,60,85,200,51,14}, ham_straight=true, ham_hold={84,650} | 14950000 | 1,000 | 59.9% (57.4% with fireballs) | 56.8% | 0.0% | 8,200 |
| 2026-11-14 10:19 | tp02 | 5-1: the top hammer planned: the planner times the grab and knows the swing | ham_avoid=false, ham_top={33,60,85,200,51,14}, ham_straight=true, ham_hold={84,650}, ham_plan=true, ham_grab={30,42,100} | 14950000 | 1,000 | 70.0% (68.3% with fireballs) | 67.0% | 0.4% | 8,400 |
| 2026-11-14 12:01 | sx01 | 5-1, the all-knowing mode: only presses plans a copy of the game has played out and survived (search) |  | 14200000 | 10,000 | 100.0% (100.0% with fireballs) | 100.0% | 0.0% | 6,600 |
| 2026-11-14 12:23 | sx21 | 2-1, the all-knowing mode (search) |  | 15000000 | 10,000 | 100.0% (100.0% with fireballs) | 100.0% | 0.0% | 4,700 |
| 2026-11-14 12:40 | sx31 | 3-1, the all-knowing mode (search) |  | 15000000 | 10,000 | 100.0% (100.0% with fireballs) | 100.0% | 0.0% | 5,700 |
| 2026-11-14 13:00 | sx41 | 4-1, the all-knowing mode (search) |  | 15000000 | 10,000 | 100.0% (100.0% with fireballs) | 100.0% | 0.0% | 6,600 |
| 2026-11-14 17:09 | sp00 | 5-1 reference, the code as it is now (nothing new on) |  | 15100000 | 10,000 | 98.6% (97.0% with fireballs) | 98.3% | 0.0% | 7,000 |
| 2026-11-14 17:33 | sp01 | 5-1: also weighs step-then-stand and step-pause-jump plans (the oracle review: the saving moves he couldn't write) | stand_plans=true, step_pause={4,8} | 15100000 | 10,000 | 97.9% (96.3% with fireballs) | 97.6% | 0.0% | 7,000 |
| 2026-11-14 19:14 | ro01 | 5-1: the risk of a barrel that might take a ladder weighed by the game's real odds (3/4 with his stick at the ladder, 3/16 without) | risk_odds=true | 15100000 | 10,000 | 98.6% (97.0% with fireballs) | 98.3% | 0.0% | 7,000 |
| 2026-11-14 21:24 | lv30 | 3-1 reference (as now) |  | 15200000 | 10,000 | 95.2% (94.8% with fireballs) | 94.7% | 0.0% | 6,100 |
| 2026-11-14 21:45 | lv31 | 3-1: 5-1's general settings (finer jump timing, press timing, facing with the hammer, w_with 30) | fine_waits=true, press_lag=1, face_known=true, w_with=30 | 15200000 | 10,000 | 95.8% (95.3% with fireballs) | 95.4% | 0.0% | 6,100 |
| 2026-11-14 21:59 | lv40 | 4-1 reference (as now) |  | 15300000 | 10,000 | 95.1% (94.6% with fireballs) | 94.7% | 0.0% | 7,100 |
| 2026-11-14 22:19 | lv41 | 4-1: 5-1's general settings (finer jump timing, facing with the hammer, w_with 30) | fine_waits=true, face_known=true, w_with=30 | 15300000 | 10,000 | 94.6% (94.1% with fireballs) | 94.1% | 0.0% | 7,100 |
| 2026-11-14 22:34 | lv32 | 3-1: press timing only (press_lag 1) | press_lag=1 | 15200000 | 10,000 | 95.7% (95.2% with fireballs) | 95.3% | 0.0% | 6,100 |
| 2026-11-14 22:55 | lv42 | 4-1: fine_waits=true only | fine_waits=true | 15300000 | 10,000 | 94.2% (93.7% with fireballs) | 93.7% | 0.0% | 7,100 |
| 2026-11-14 23:09 | lv43 | 4-1: face_known=true only | face_known=true | 15300000 | 10,000 | 95.2% (94.6% with fireballs) | 94.7% | 0.0% | 7,100 |
| 2026-11-14 23:24 | lv44 | 4-1: w_with=30 only | w_with=30 | 15300000 | 10,000 | 95.2% (94.7% with fireballs) | 94.8% | 0.0% | 7,100 |
| 2026-11-14 23:39 | lw30 | 3-1 reference (second check) |  | 15400000 | 10,000 | 95.2% (94.8% with fireballs) | 94.8% | 0.0% | 6,100 |
| 2026-11-14 23:54 | lw32 | 3-1 second check: press_lag 1 | press_lag=1 | 15400000 | 10,000 | 95.4% (94.9% with fireballs) | 95.0% | 0.0% | 6,100 |
| 2026-11-15 00:14 | lw31 | 3-1 second check: press_lag 1 + fine_waits + face_known + w_with 30 | fine_waits=true, press_lag=1, face_known=true, w_with=30 | 15400000 | 10,000 | 95.9% (95.6% with fireballs) | 95.5% | 0.0% | 6,100 |
| 2026-11-15 00:29 | lw40 | 4-1 reference (second check) |  | 15500000 | 10,000 | 95.6% (94.9% with fireballs) | 95.1% | 0.0% | 7,100 |
| 2026-11-15 00:42 | lw44 | 4-1 second check: w_with 30 | w_with=30 | 15500000 | 10,000 | 95.8% (95.1% with fireballs) | 95.3% | 0.0% | 7,100 |
| 2026-11-15 07:35 | rv01 | 1-2 rivets: the first rivet player (1-1 played by the search, the rivets human-limited), 64 games |  | 0 | 64 | 0.0% (0.0% with fireballs) | 0.0% | 0.0% | 0 |
| 2026-11-15 07:57 | rv02 | 1-2 rivets: star order with both hammers (bottom for the 3rd-girder crossing, middle for the right half) |  | 0 | 64 | 72.0% (28.1% with fireballs) | 52.4% | 0.0% | 8,000 |
| 2026-11-15 10:06 | rv03 | 1-2 rivets: star order, bottom hammer for the 3rd girder, middle hammer unless the upper right is clear (512 games) |  | 1000 | 512 | 65.6% (20.1% with fireballs) | 57.9% | 4.5% | 8,100 |
| 2026-11-15 10:11 | rv10 | 1-2 rivets, starting on the board: star order, bottom hammer for the 3rd girder, middle hammer unless the upper right is clear |  | 2000 | 1,000 | 66.3% (19.7% with fireballs) | 60.8% | 0.3% | 4,600 |
| 2026-11-15 10:15 | rv11 | 1-2 rivets: Matt's star with his crossing directions, both hammers |  | 3000 | 1,000 | 83.6% (34.6% with fireballs) | 79.7% | 0.2% | 4,800 |
| 2026-11-15 10:28 | rv12 | 1-2 rivets: as rv11, plus jumps over pulled rivets in his routes (Matt) |  | 3000 | 1,000 | 89.8% (35.3% with fireballs) | 86.4% | 0.0% | 4,800 |
| 2026-11-15 10:30 | rv13 | 1-2 rivets: Matt's star with his crossing directions, both hammers, gap jumps (website: the real hammer drawn) |  | 4000 | 1,000 | 92.6% (38.7% with fireballs) | 89.7% | 0.0% | 4,800 |
| 2026-11-15 10:46 | rv14 | 1-2 rivets: + Matt's review: gap-jump escapes, the right side by cheapest safe route (top rivet when free) |  | 4000 | 1,000 | 32.8% (13.4% with fireballs) | 28.5% | 0.5% | 3,900 |
| 2026-11-15 10:49 | rv15 | 1-2 rivets: as rv14, the right-side target chosen once and kept |  | 4000 | 1,000 | 77.7% (31.4% with fireballs) | 73.4% | 0.2% | 4,700 |
| 2026-11-15 10:57 | rv16 | 1-2 rivets: rv15 variant: dynamic right side + maze |  | 4000 | 1,000 | 76.7% (32.6% with fireballs) | 72.5% | 0.2% | 4,600 |
| 2026-11-15 10:59 | rv17 | 1-2 rivets: maze + gap escapes, fixed right-side order (no dynamic choice) | riv_dynamic=false | 4000 | 1,000 | 90.8% (40.6% with fireballs) | 87.8% | 0.0% | 4,800 |
| 2026-11-15 11:01 | rv18 | 1-2 rivets: gap escapes only (no maze, no dynamic choice) | riv_dynamic=false, riv_maze=false | 4000 | 1,000 | 92.2% (41.4% with fireballs) | 89.4% | 0.0% | 4,700 |
| 2026-11-15 11:05 | rv19 | 1-2 rivets: + fireball heading (a fireball drifting away reaches back at 0.3 px a frame) |  | 4000 | 1,000 | 92.6% (45.0% with fireballs) | 89.9% | 0.2% | 4,800 |
| 2026-11-15 11:12 | rv20 | 1-2 rivets: as rv19 (fresh games), recording what he was doing at each death |  | 5000 | 1,000 | 92.0% (42.4% with fireballs) | 89.1% | 0.0% | 4,800 |
| 2026-11-15 11:14 | rv21 | 1-2 rivets: the gap jump as one of his options (no more waiting at the gap), judged by the full check |  | 5000 | 1,000 | 84.3% (42.3% with fireballs) | 80.8% | 0.0% | 4,800 |
| 2026-11-15 11:17 | rv22 | 1-2 rivets: everything so far (fresh games), recording which jump each in-air death was |  | 6000 | 1,000 | 85.0% (41.8% with fireballs) | 81.5% | 0.0% | 4,800 |
| 2026-11-15 11:19 | rvj_toward | 1-2 rivets: life-or-death fireball jumps toward | riv_jump_dir="toward" | 6000 | 500 | 91.2% (37.2% with fireballs) | 86.5% | 0.0% | 4,800 |
| 2026-11-15 11:20 | rvj_straight | 1-2 rivets: life-or-death fireball jumps straight | riv_jump_dir="straight" | 6000 | 500 | 91.3% (37.6% with fireballs) | 86.6% | 0.0% | 4,800 |
| 2026-11-15 11:21 | rvj_away | 1-2 rivets: life-or-death fireball jumps away | riv_jump_dir="away" | 6000 | 500 | 86.2% (41.4% with fireballs) | 81.3% | 0.0% | 4,800 |
| 2026-11-15 11:22 | rvj_none | 1-2 rivets: no life-or-death fireball jumps at all | riv_no_fire_jump=true | 6000 | 500 | 94.9% (37.2% with fireballs) | 90.9% | 0.0% | 4,900 |
| 2026-11-15 11:34 | rs00 | 1-2 rivets sweep:  |  | 7000 | 1,000 | 81.6% (42.0% with fireballs) | 78.0% | 0.0% | 4,800 |
| 2026-11-15 11:36 | rs01 | 1-2 rivets sweep: --set riv_reach=8 | riv_reach=8 | 7000 | 1,000 | 89.1% (46.4% with fireballs) | 86.1% | 0.4% | 4,800 |
| 2026-11-15 11:38 | rs02 | 1-2 rivets sweep: --set riv_reach=12 | riv_reach=12 | 7000 | 1,000 | 86.7% (34.6% with fireballs) | 83.0% | 0.0% | 5,000 |
| 2026-11-15 11:39 | rs03 | 1-2 rivets sweep: --set riv_h=36 | riv_h=36 | 7000 | 1,000 | 97.3% (46.7% with fireballs) | 95.4% | 0.0% | 4,900 |
| 2026-11-15 11:42 | rs04 | 1-2 rivets sweep: --set riv_h=64 | riv_h=64 | 7000 | 1,000 | 75.7% (34.9% with fireballs) | 71.6% | 0.2% | 4,700 |
| 2026-11-15 11:44 | rs05 | 1-2 rivets sweep: --set riv_vaway=0.2 | riv_vaway=0.2 | 7000 | 1,000 | 86.0% (41.0% with fireballs) | 82.5% | 0.0% | 4,900 |
| 2026-11-15 11:46 | rs06 | 1-2 rivets sweep: --set riv_vaway=0.4 | riv_vaway=0.4 | 7000 | 1,000 | 84.2% (40.9% with fireballs) | 80.6% | 0.0% | 4,800 |
| 2026-11-15 11:48 | rs07 | 1-2 rivets sweep: --set riv_jump=6 | riv_jump=6 | 7000 | 1,000 | 81.7% (42.0% with fireballs) | 78.1% | 0.0% | 4,800 |
| 2026-11-15 11:50 | rs08 | 1-2 rivets sweep: --set riv_jump=14 | riv_jump=14 | 7000 | 1,000 | 81.4% (42.1% with fireballs) | 77.9% | 0.0% | 4,800 |
| 2026-11-15 11:52 | rs09 | 1-2 rivets sweep: --set riv_skip_ham=60 | riv_skip_ham=60 | 7000 | 1,000 | 81.4% (41.9% with fireballs) | 77.8% | 0.0% | 4,800 |
| 2026-11-15 11:55 | rs10 | 1-2 rivets sweep: --set riv_skip_ham=160 | riv_skip_ham=160 | 7000 | 1,000 | 81.1% (41.7% with fireballs) | 77.5% | 0.0% | 4,800 |
| 2026-11-15 11:56 | rs11 | 1-2 rivets sweep: --set riv_maze=false | riv_maze=false | 7000 | 1,000 | 87.5% (45.0% with fireballs) | 84.4% | 0.4% | 4,700 |
| 2026-11-15 11:59 | rs12 | 1-2 rivets sweep: --set riv_reach=8 --set riv_h=36 | riv_reach=8, riv_h=36 | 7000 | 1,000 | 97.7% (51.3% with fireballs) | 96.0% | 0.0% | 4,900 |
| 2026-11-15 12:00 | rs13 | 1-2 rivets sweep: --set riv_reach=6 --set riv_h=36 | riv_reach=6, riv_h=36 | 7000 | 1,000 | 98.5% (53.1% with fireballs) | 97.1% | 0.0% | 4,800 |
| 2026-11-15 12:02 | rs14 | 1-2 rivets sweep: --set riv_reach=8 --set riv_h=28 | riv_reach=8, riv_h=28 | 7000 | 1,000 | 98.4% (48.5% with fireballs) | 96.8% | 0.0% | 4,900 |
| 2026-11-15 12:03 | rs15 | 1-2 rivets sweep: --set riv_reach=8 --set riv_h=36 --set riv_maze=false | riv_reach=8, riv_h=36, riv_maze=false | 7000 | 1,000 | 97.0% (52.6% with fireballs) | 95.3% | 0.2% | 4,800 |
| 2026-11-15 12:05 | rs16 | 1-2 rivets sweep: --set riv_reach=6 --set riv_h=28 | riv_reach=6, riv_h=28 | 7000 | 1,000 | 98.8% (51.2% with fireballs) | 97.5% | 0.0% | 4,900 |
| 2026-11-15 12:07 | rs17 | 1-2 rivets sweep: --set riv_reach=4 --set riv_h=36 | riv_reach=4, riv_h=36 | 7000 | 1,000 | 99.1% (56.7% with fireballs) | 98.0% | 0.0% | 4,800 |
| 2026-11-15 12:09 | rs18 | 1-2 rivets sweep: --set riv_reach=6 --set riv_h=42 | riv_reach=6, riv_h=42 | 7000 | 1,000 | 96.2% (47.9% with fireballs) | 94.1% | 0.0% | 4,800 |
| 2026-11-15 12:10 | rs19 | 1-2 rivets sweep: --set riv_reach=6 --set riv_h=32 | riv_reach=6, riv_h=32 | 7000 | 1,000 | 98.1% (52.7% with fireballs) | 96.6% | 0.0% | 5,000 |
| 2026-11-15 12:12 | rf11 | 1-2 rivets sweep: --set riv_reach=6 --set riv_h=36 --set riv_last=true | riv_reach=6, riv_h=36, riv_last=true | 7000 | 1,000 | 98.5% (54.2% with fireballs) | 97.2% | 0.0% | 4,800 |
| 2026-11-15 12:14 | rf12 | 1-2 rivets sweep: --set riv_reach=6 --set riv_h=36 --set riv_ladder_off=true | riv_reach=6, riv_h=36, riv_ladder_off=true | 7000 | 1,000 | 97.4% (57.1% with fireballs) | 95.8% | 0.0% | 4,800 |
| 2026-11-15 12:16 | rf13 | 1-2 rivets sweep: --set riv_reach=6 --set riv_h=36 --set riv_2r_later=true | riv_reach=6, riv_h=36, riv_2r_later=true | 7000 | 1,000 | 92.5% (45.9% with fireballs) | 89.9% | 0.0% | 4,900 |
| 2026-11-15 12:17 | rf14 | 1-2 rivets sweep: --set riv_reach=6 --set riv_h=36 --set riv_maze_edge=true | riv_reach=6, riv_h=36, riv_maze_edge=true | 7000 | 1,000 | 98.5% (53.1% with fireballs) | 97.1% | 0.0% | 4,800 |
| 2026-11-15 12:19 | rf15 | 1-2 rivets sweep: --set riv_reach=6 --set riv_h=36 --set riv_maze=false | riv_reach=6, riv_h=36, riv_maze=false | 7000 | 1,000 | 97.1% (53.9% with fireballs) | 95.4% | 0.0% | 4,800 |
| 2026-11-15 12:21 | rs20 | 1-2 rivets sweep: --set riv_reach=4 --set riv_h=36 --set riv_ladder_off=true --set riv_last=true | riv_reach=4, riv_h=36, riv_ladder_off=true, riv_last=true | 7000 | 1,000 | 99.2% (59.3% with fireballs) | 98.1% | 0.0% | 4,700 |
| 2026-11-15 12:23 | rs21 | 1-2 rivets sweep: --set riv_reach=2 --set riv_h=36 --set riv_ladder_off=true --set riv_last=true | riv_reach=2, riv_h=36, riv_ladder_off=true, riv_last=true | 7000 | 1,000 | 98.2% (53.4% with fireballs) | 96.6% | 0.0% | 4,700 |
| 2026-11-15 12:24 | rs22 | 1-2 rivets sweep: --set riv_reach=3 --set riv_h=36 --set riv_ladder_off=true --set riv_last=true | riv_reach=3, riv_h=36, riv_ladder_off=true, riv_last=true | 7000 | 1,000 | 97.7% (56.4% with fireballs) | 96.2% | 0.0% | 4,800 |
| 2026-11-15 12:26 | rs23 | 1-2 rivets sweep: --set riv_reach=4 --set riv_h=36 --set riv_ladder_off=true --set riv_last=true --set riv_maze_edge=true | riv_reach=4, riv_h=36, riv_ladder_off=true, riv_last=true, riv_maze_edge=true | 7000 | 1,000 | 99.2% (59.3% with fireballs) | 98.1% | 0.0% | 4,700 |
| 2026-11-15 12:28 | rs24 | 1-2 rivets sweep: --set riv_reach=4 --set riv_h=40 --set riv_ladder_off=true --set riv_last=true | riv_reach=4, riv_h=40, riv_ladder_off=true, riv_last=true | 7000 | 1,000 | 98.0% (57.7% with fireballs) | 96.5% | 0.2% | 4,800 |
| 2026-11-15 12:30 | rc00 | 1-2 rivets second check: the current defaults |  | 8000 | 1,000 | 83.4% (41.8% with fireballs) | 79.9% | 0.0% | 4,800 |
| 2026-11-15 12:32 | rc01 | 1-2 rivets second check: reach 4, look-ahead 36, getting off ladders, the last rivet's pull point, maze edge | riv_reach=4, riv_h=36, riv_ladder_off=true, riv_last=true, riv_maze_edge=true | 8000 | 1,000 | 99.1% (57.7% with fireballs) | 98.0% | 0.2% | 4,800 |
| 2026-11-15 12:34 | rc02 | 1-2 rivets: the new defaults (should match rc01) |  | 8000 | 1,000 | 99.1% (57.7% with fireballs) | 98.0% | 0.2% | 4,800 |
| 2026-11-15 12:36 | rs30 | 1-2 rivets sweep (new defaults):  |  | 7000 | 1,000 | 99.2% (59.3% with fireballs) | 98.1% | 0.0% | 4,700 |
| 2026-11-15 12:37 | rs31 | 1-2 rivets sweep (new defaults): --set riv_vr=0.5 --set riv_vl=0.38 --set riv_vd=0.5 --set riv_vu=0.19 | riv_vr=0.5, riv_vl=0.38, riv_vd=0.5, riv_vu=0.19 | 7000 | 1,000 | 100.0% (42.9% with fireballs) | 99.1% | 0.0% | 5,000 |
| 2026-11-15 12:39 | rs32 | 1-2 rivets sweep (new defaults): --set riv_vr=0.56 --set riv_vl=0.44 --set riv_vd=0.56 --set riv_vu=0.25 | riv_vr=0.56, riv_vl=0.44, riv_vd=0.56, riv_vu=0.25 | 7000 | 1,000 | 99.0% (49.0% with fireballs) | 97.7% | 0.0% | 4,800 |
| 2026-11-15 12:41 | rs33 | 1-2 rivets sweep (new defaults): --set riv_gapjump_cost=120 | riv_gapjump_cost=120 | 7000 | 1,000 | 95.9% (61.5% with fireballs) | 94.1% | 0.0% | 4,700 |
| 2026-11-15 12:43 | rs34 | 1-2 rivets sweep (new defaults): --set riv_gap_jump=false | riv_gap_jump=false | 7000 | 1,000 | 95.6% (60.8% with fireballs) | 93.7% | 0.2% | 4,700 |
| 2026-11-15 12:44 | rs35 | 1-2 rivets sweep (new defaults): --set riv_vaway=0.2 | riv_vaway=0.2 | 7000 | 1,000 | 98.8% (57.8% with fireballs) | 97.6% | 0.0% | 4,800 |
| 2026-11-15 12:46 | rs36 | 1-2 rivets sweep (new defaults): --set riv_vr=0.7 --set riv_vl=0.56 --set riv_vd=0.7 --set riv_vu=0.35 | riv_vr=0.7, riv_vl=0.56, riv_vd=0.7, riv_vu=0.35 | 7000 | 1,000 | 97.1% (60.9% with fireballs) | 95.5% | 0.0% | 4,700 |
| 2026-11-15 12:48 | rs37 | 1-2 rivets sweep (new defaults): --set riv_gapjump_cost=240 | riv_gapjump_cost=240 | 7000 | 1,000 | 95.5% (60.9% with fireballs) | 93.5% | 0.2% | 4,700 |
| 2026-11-15 12:50 | rs38 | 1-2 rivets sweep (new defaults): --set riv_gapjump_cost=120 --set riv_vr=0.7 --set riv_vl=0.56 --set riv_vd=0.7 --set riv_vu=0.35 | riv_gapjump_cost=120, riv_vr=0.7, riv_vl=0.56, riv_vd=0.7, riv_vu=0.35 | 7000 | 1,000 | 93.1% (62.5% with fireballs) | 91.0% | 0.4% | 4,700 |
| 2026-11-15 12:52 | rs39 | 1-2 rivets sweep (new defaults): --set riv_gapjump_cost=60 | riv_gapjump_cost=60 | 7000 | 1,000 | 95.9% (61.3% with fireballs) | 94.1% | 0.0% | 4,700 |
| 2026-11-15 12:54 | rs40 | 1-2 rivets sweep (new defaults): --set riv_gapjump_cost=120 --set riv_vr=0.8 --set riv_vl=0.64 --set riv_vd=0.8 --set riv_vu=0.4 | riv_gapjump_cost=120, riv_vr=0.8, riv_vl=0.64, riv_vd=0.8, riv_vu=0.4 | 7000 | 1,000 | 91.1% (59.7% with fireballs) | 88.7% | 0.0% | 4,700 |
| 2026-11-15 12:56 | rs41 | 1-2 rivets sweep (new defaults): --set riv_gapjump_cost=120 --set riv_vr=0.9 --set riv_vl=0.72 --set riv_vd=0.9 --set riv_vu=0.45 | riv_gapjump_cost=120, riv_vr=0.9, riv_vl=0.72, riv_vd=0.9, riv_vu=0.45 | 7000 | 1,000 | 90.8% (62.0% with fireballs) | 88.4% | 0.3% | 4,700 |
| 2026-11-15 12:58 | rc03 | 1-2 rivets second check: gap-jump cost 120, fireball speeds 0.7 / 0.56 / 0.7 / 0.35 (recording when each rivet comes out) | riv_gapjump_cost=120, riv_vr=0.7, riv_vl=0.56, riv_vd=0.7, riv_vu=0.35 | 8000 | 1,000 | 93.9% (61.5% with fireballs) | 91.8% | 0.0% | 4,700 |
| 2026-11-15 13:01 | rk6 | 1-2 rivets: commit to the current move (margin 6 frames) | riv_sticky=6 | 8000 | 1,000 | 87.6% (48.6% with fireballs) | 84.6% | 0.2% | 4,600 |
| 2026-11-15 13:03 | rk12 | 1-2 rivets: commit to the current move (margin 12 frames) | riv_sticky=12 | 8000 | 1,000 | 87.3% (48.3% with fireballs) | 84.3% | 0.2% | 4,600 |
| 2026-11-15 13:06 | rv30 | 1-2 rivets: all of today's improvements (fresh games) |  | 9000 | 1,000 | 94.2% (63.1% with fireballs) | 92.1% | 0.1% | 4,700 |
| 2026-11-15 13:16 | rp01 | 1-2 rivets: hammer parking (wait ~30 px short of the ladder facing it, as barra and player 3 do) |  | 9000 | 1,000 | 94.0% (63.1% with fireballs) | 92.0% | 0.0% | 4,700 |
| 2026-11-15 13:17 | rp02 | 1-2 rivets: hammer parking, keyed to the first climb in his route |  | 9000 | 1,000 | 0.0% (0.0% with fireballs) | 0.0% | 0.0% | 0 |
| 2026-11-15 13:18 | rp03 | 1-2 rivets: hammer parking (first climb in his route), carrying straight on across a new gap |  | 9000 | 1,000 | 0.0% (0.0% with fireballs) | 0.0% | 0.0% | 0 |
| 2026-11-15 13:21 | rp04 | 1-2 rivets: hammer parking; never stops or turns back inside a rivet's column |  | 9000 | 1,000 | 93.9% (63.0% with fireballs) | 91.8% | 0.1% | 4,800 |
| 2026-11-15 14:08 | mr1 | 1-2 rivets (Matt's review 2): --set riv_ladder_commit=8 | riv_ladder_commit=8 | 9000 | 1,000 | 92.8% (63.0% with fireballs) | 90.6% | 0.1% | 4,700 |
| 2026-11-15 14:10 | mr2 | 1-2 rivets (Matt's review 2): --set riv_ladder_commit=20 | riv_ladder_commit=20 | 9000 | 1,000 | 94.0% (62.6% with fireballs) | 91.9% | 0.2% | 4,700 |
| 2026-11-15 14:11 | mr3 | 1-2 rivets (Matt's review 2): --set riv_gap_reach=16 | riv_gap_reach=16 | 9000 | 1,000 | 96.4% (58.3% with fireballs) | 94.6% | 0.0% | 4,900 |
| 2026-11-15 14:13 | mr4 | 1-2 rivets (Matt's review 2): --set riv_gap_reach=16 --set riv_ladder_commit=8 | riv_gap_reach=16, riv_ladder_commit=8 | 9000 | 1,000 | 95.0% (58.8% with fireballs) | 93.0% | 0.0% | 4,800 |
| 2026-11-15 14:16 | mr5 | 1-2 rivets (Matt's review 2):  |  | 9000 | 1,000 | 93.0% (63.4% with fireballs) | 90.8% | 0.0% | 4,800 |
| 2026-11-15 14:18 | mr6 | 1-2 rivets (Matt's review 2): --set riv_gap_reach=16 | riv_gap_reach=16 | 9000 | 1,000 | 94.8% (59.9% with fireballs) | 92.8% | 0.0% | 4,900 |
| 2026-11-15 14:20 | mr7 | 1-2 rivets (Matt's review 2): --set riv_gap_reach=16 --set riv_ladder_commit=8 | riv_gap_reach=16, riv_ladder_commit=8 | 9000 | 1,000 | 93.2% (59.2% with fireballs) | 91.0% | 0.2% | 4,800 |
| 2026-11-15 14:22 | mr8 | 1-2 rivets (Matt's review 2): --set riv_gapjump_cost=30 --set riv_gap_reach=16 --set riv_ladder_commit=8 | riv_gapjump_cost=30, riv_gap_reach=16, riv_ladder_commit=8 | 9000 | 1,000 | 90.1% (58.1% with fireballs) | 87.5% | 0.0% | 4,800 |
| 2026-11-15 14:24 | mr9 | 1-2 rivets (Matt's review 2): --set riv_jump_safe=8 | riv_jump_safe=8 | 9000 | 1,000 | 92.7% (63.4% with fireballs) | 90.5% | 0.0% | 4,800 |
| 2026-11-15 14:26 | mr10 | 1-2 rivets (Matt's review 2): --set riv_jump_safe=16 | riv_jump_safe=16 | 9000 | 1,000 | 94.4% (59.5% with fireballs) | 92.4% | 0.0% | 4,800 |
| 2026-11-15 14:28 | mr11 | 1-2 rivets (Matt's review 2): --set riv_jump_safe=8 --set riv_gap_reach=16 | riv_jump_safe=8, riv_gap_reach=16 | 9000 | 1,000 | 93.9% (58.9% with fireballs) | 91.8% | 0.0% | 4,800 |
| 2026-11-15 14:30 | mr12 | 1-2 rivets (Matt's review 2): --set riv_jump_safe=16 --set riv_gap_reach=16 | riv_jump_safe=16, riv_gap_reach=16 | 9000 | 1,000 | 94.5% (54.9% with fireballs) | 92.3% | 0.0% | 4,900 |
| 2026-11-15 14:34 | me1 | 1-2 rivets, whole-board safety map: --set riv_escape=24 | riv_escape=24 | 9000 | 1,000 | 91.8% (61.8% with fireballs) | 89.5% | 0.0% | 4,800 |
| 2026-11-15 14:36 | me2 | 1-2 rivets, whole-board safety map: --set riv_escape=40 | riv_escape=40 | 9000 | 1,000 | 90.0% (61.1% with fireballs) | 87.5% | 0.0% | 4,800 |
| 2026-11-15 14:57 | fx01 | 1-2 rivets: logging Mario and every fireball every 4 frames (to check the safety map; changes nothing) |  | 10000 | 400 | 92.6% (63.0% with fireballs) | 88.9% | 0.0% | 4,700 |
| 2026-11-15 15:09 | me3 | 1-2 rivets, whole-board safety map (fixed: mid-ladder fireballs): --set riv_escape=24 | riv_escape=24 | 9000 | 1,000 | 91.7% (62.0% with fireballs) | 89.4% | 0.0% | 4,800 |
| 2026-11-15 15:11 | me4 | 1-2 rivets, whole-board safety map (fixed: mid-ladder fireballs): --set riv_escape=40 | riv_escape=40 | 9000 | 1,000 | 90.1% (61.2% with fireballs) | 87.7% | 0.0% | 4,800 |
| 2026-11-15 15:13 | me5 | 1-2 rivets, safety map, nearest safe spot: --set riv_escape=24 --set riv_escape_near=true | riv_escape=24, riv_escape_near=true | 9000 | 1,000 | 93.4% (61.2% with fireballs) | 91.3% | 0.0% | 4,800 |
| 2026-11-15 15:15 | me6 | 1-2 rivets, safety map, nearest safe spot: --set riv_escape=12 --set riv_escape_near=true | riv_escape=12, riv_escape_near=true | 9000 | 1,000 | 92.8% (63.2% with fireballs) | 90.6% | 0.0% | 4,800 |
| 2026-11-15 15:21 | sw1 | 1-2 rivets, safety map, safety of every move: --set riv_safe_w=1 | riv_safe_w=1 | 9000 | 1,000 | 94.6% (64.8% with fireballs) | 92.6% | 0.1% | 4,800 |
| 2026-11-15 15:28 | sw2 | 1-2 rivets, safety map, safety of every move: --set riv_safe_w=3 | riv_safe_w=3 | 9000 | 1,000 | 40.1% (14.0% with fireballs) | 35.1% | 0.9% | 3,300 |
| 2026-11-15 15:37 | sw3 | 1-2 rivets, safety map, safety of every move: --set riv_safe_w=6 | riv_safe_w=6 | 9000 | 1,000 | 7.8% (2.4% with fireballs) | 5.3% | 0.0% | 3,500 |
| 2026-11-15 16:17 | sw5 | 1-2 rivets: --set riv_safe_w=0.5 | riv_safe_w=0.5 | 9000 | 1,000 | 93.8% (62.4% with fireballs) | 91.7% | 0.0% | 4,800 |
| 2026-11-15 16:19 | pb1 | 1-2 rivets: --set riv_pullback=true | riv_pullback=true | 9000 | 1,000 | 93.3% (62.2% with fireballs) | 91.1% | 0.0% | 4,800 |
| 2026-11-15 16:23 | pb2 | 1-2 rivets: --set riv_pullback=true --set riv_safe_w=1 | riv_pullback=true, riv_safe_w=1 | 9000 | 1,000 | 95.6% (62.7% with fireballs) | 93.7% | 0.0% | 4,800 |
| 2026-11-15 16:25 | hu1 | 1-2 rivets: --set riv_hunt=true | riv_hunt=true | 9000 | 1,000 | 93.0% (65.2% with fireballs) | 90.9% | 0.0% | 4,800 |
| 2026-11-15 16:30 | hu2 | 1-2 rivets: --set riv_hunt=true --set riv_safe_w=1 | riv_hunt=true, riv_safe_w=1 | 9000 | 1,000 | 92.8% (62.3% with fireballs) | 90.6% | 0.3% | 4,900 |
| 2026-11-15 16:32 | hu3 | 1-2 rivets: --set riv_hunt=true --set riv_hunt_right=60 | riv_hunt=true, riv_hunt_right=60 | 9000 | 1,000 | 93.5% (65.7% with fireballs) | 91.4% | 0.0% | 4,800 |
| 2026-11-15 16:35 | fq0 | 1-2 rivets, fresh games:  |  | 12000 | 1,000 | 94.0% (64.3% with fireballs) | 92.0% | 0.3% | 4,800 |
| 2026-11-15 16:37 | fq1 | 1-2 rivets, fresh games: --set riv_hunt=true --set riv_hunt_right=60 | riv_hunt=true, riv_hunt_right=60 | 12000 | 1,000 | 93.8% (64.7% with fireballs) | 91.7% | 0.0% | 4,800 |
| 2026-11-15 16:39 | jh1 | 1-2 rivets: jumps held 3 frames: --set riv_jump_hold=true | riv_jump_hold=true | 9000 | 1,000 | 91.9% (70.3% with fireballs) | 89.7% | 0.0% | 4,700 |
| 2026-11-15 16:41 | jh2 | 1-2 rivets: jumps held 3 frames: --set riv_jump_hold=true --set riv_pullback=true | riv_jump_hold=true, riv_pullback=true | 9000 | 1,000 | 91.3% (68.9% with fireballs) | 89.0% | 0.0% | 4,800 |
| 2026-11-15 16:43 | jh3 | 1-2 rivets: jumps held 3 frames: --set riv_jump_hold=true --set riv_hunt=true --set riv_hunt_right=60 | riv_jump_hold=true, riv_hunt=true, riv_hunt_right=60 | 9000 | 1,000 | 91.6% (69.9% with fireballs) | 89.4% | 0.0% | 4,900 |
| 2026-11-15 16:45 | fj1 | 1-2 rivets, jumps held 3 frames: --set riv_jump_hold=true | riv_jump_hold=true | 12000 | 1,000 | 92.3% (68.1% with fireballs) | 90.1% | 0.1% | 4,700 |
| 2026-11-15 16:47 | jg1 | 1-2 rivets, jumps held 3 frames: --set riv_jump_hold=true --set riv_gap_reach=16 | riv_jump_hold=true, riv_gap_reach=16 | 9000 | 1,000 | 94.6% (72.4% with fireballs) | 92.8% | 0.0% | 4,700 |
| 2026-11-15 16:52 | jg2 | 1-2 rivets, jumps held 3 frames: --set riv_jump_hold=true --set riv_safe_w=1 | riv_jump_hold=true, riv_safe_w=1 | 9000 | 1,000 | 93.9% (75.5% with fireballs) | 92.0% | 0.0% | 4,700 |
| 2026-11-15 16:54 | jg3 | 1-2 rivets, jumps held 3 frames: --set riv_jump_hold=true --set riv_ladder_commit=8 | riv_jump_hold=true, riv_ladder_commit=8 | 9000 | 1,000 | 90.6% (69.1% with fireballs) | 88.3% | 0.3% | 4,700 |
| 2026-11-15 16:56 | jg4 | 1-2 rivets, jumps held 3 frames: --set riv_jump_hold=true --set riv_escape=12 --set riv_escape_near=true | riv_jump_hold=true, riv_escape=12, riv_escape_near=true | 9000 | 1,000 | 91.0% (69.8% with fireballs) | 88.8% | 0.0% | 4,700 |
| 2026-11-15 16:58 | jg5 | 1-2 rivets, jumps held 3 frames: --set riv_jump_hold=true --set riv_gapjump_cost=60 | riv_jump_hold=true, riv_gapjump_cost=60 | 9000 | 1,000 | 92.0% (70.4% with fireballs) | 89.9% | 0.1% | 4,700 |
| 2026-11-15 17:04 | fs1 | 1-2 rivets (jumps fixed): --set riv_safe_w=1 | riv_safe_w=1 | 12000 | 1,000 | 92.5% (72.6% with fireballs) | 90.4% | 0.4% | 4,700 |
| 2026-11-15 17:09 | js1 | 1-2 rivets (jumps fixed): --set riv_safe_w=1 --set riv_gap_reach=16 | riv_safe_w=1, riv_gap_reach=16 | 9000 | 1,000 | 93.1% (75.2% with fireballs) | 91.1% | 0.1% | 4,800 |
| 2026-11-15 17:15 | fs2 | 1-2 rivets (jumps fixed): --set riv_safe_w=1 --set riv_gap_reach=16 | riv_safe_w=1, riv_gap_reach=16 | 12000 | 1,000 | 92.6% (71.0% with fireballs) | 90.5% | 0.4% | 4,800 |
| 2026-11-15 17:20 | js2 | 1-2 rivets (jumps fixed): --set riv_safe_w=0.7 | riv_safe_w=0.7 | 9000 | 1,000 | 94.0% (73.4% with fireballs) | 92.1% | 0.1% | 4,700 |
| 2026-11-15 17:27 | js3 | 1-2 rivets (jumps fixed): --set riv_safe_w=1.5 | riv_safe_w=1.5 | 9000 | 1,000 | 77.8% (45.6% with fireballs) | 74.3% | 0.5% | 4,000 |
| 2026-11-15 17:33 | ft1 | 1-2 rivets: stuck-at-a-rivet timeout fixed  |  | 12000 | 1,000 | 97.6% (80.6% with fireballs) | 96.3% | 0.1% | 4,700 |
| 2026-11-15 17:37 | ft2 | 1-2 rivets: stuck-at-a-rivet timeout fixed  |  | 9000 | 1,000 | 97.5% (82.1% with fireballs) | 96.2% | 0.0% | 4,700 |
| 2026-11-15 17:45 | fk1 | 1-2 rivets: Kong is a wall on the top girder  |  | 12000 | 1,000 | 99.5% (82.1% with fireballs) | 98.8% | 0.1% | 4,700 |
| 2026-11-15 17:49 | fk2 | 1-2 rivets: Kong is a wall on the top girder  |  | 9000 | 1,000 | 99.6% (84.1% with fireballs) | 99.0% | 0.0% | 4,700 |
| 2026-11-15 17:55 | rk1 | 1-2 rivets: re-tuning caution now jumps work: --set riv_reach=3 | riv_reach=3 | 9000 | 1,000 | 99.8% (80.9% with fireballs) | 99.1% | 0.1% | 4,700 |
| 2026-11-15 17:59 | rk2 | 1-2 rivets: re-tuning caution now jumps work: --set riv_reach=6 | riv_reach=6 | 9000 | 1,000 | 99.6% (80.3% with fireballs) | 98.9% | 0.1% | 4,700 |
| 2026-11-15 18:04 | rk3 | 1-2 rivets: re-tuning caution now jumps work: --set riv_h=30 | riv_h=30 | 9000 | 1,000 | 99.9% (77.5% with fireballs) | 99.3% | 0.0% | 4,800 |
| 2026-11-15 18:09 | rk4 | 1-2 rivets: re-tuning caution now jumps work: --set riv_h=44 | riv_h=44 | 9000 | 1,000 | 97.7% (71.8% with fireballs) | 96.3% | 0.5% | 4,600 |
| 2026-11-15 18:15 | jd1 | 1-2 rivets: fireball jump direction, now jumps work: --set riv_jump_dir=toward | riv_jump_dir=toward | 9000 | 1,000 | 99.6% (84.1% with fireballs) | 99.0% | 0.0% | 4,700 |
| 2026-11-15 18:19 | jd2 | 1-2 rivets: fireball jump direction, now jumps work: --set riv_jump_dir=straight | riv_jump_dir=straight | 9000 | 1,000 | 99.6% (84.1% with fireballs) | 99.0% | 0.0% | 4,700 |
| 2026-11-15 18:24 | jd3 | 1-2 rivets: fireball jump direction, now jumps work: --set riv_jump_dir="toward" | riv_jump_dir="toward" | 9000 | 1,000 | 99.6% (83.1% with fireballs) | 98.9% | 0.0% | 4,700 |
| 2026-11-15 18:29 | jd4 | 1-2 rivets: fireball jump direction, now jumps work: --set riv_jump_dir="straight" | riv_jump_dir="straight" | 9000 | 1,000 | 99.6% (83.6% with fireballs) | 99.0% | 0.0% | 4,700 |
| 2026-11-15 18:34 | hk1 | 1-2 rivets: after the 2R and Kong fixes: --set riv_hunt=true --set riv_hunt_right=60 | riv_hunt=true, riv_hunt_right=60 | 9000 | 1,000 | 99.4% (82.6% with fireballs) | 98.6% | 0.0% | 4,800 |
| 2026-11-15 18:38 | sk1 | 1-2 rivets: after the 2R and Kong fixes: --set riv_skip_ham=140 | riv_skip_ham=140 | 9000 | 1,000 | 99.5% (83.3% with fireballs) | 98.8% | 0.0% | 4,700 |
| 2026-11-15 18:43 | sk2 | 1-2 rivets: after the 2R and Kong fixes: --set riv_skip_ham=999 | riv_skip_ham=999 | 9000 | 1,000 | 99.2% (71.9% with fireballs) | 98.2% | 0.1% | 4,600 |
| 2026-11-15 18:56 | hd1 | 1-2 rivets: the current player on 3,000 new games (headline) |  | 20000 | 3,000 | 99.5% (80.3% with fireballs) | 99.1% | 0.1% | 4,700 |
| 2026-11-15 18:59 | bb1 | 1-1 barrels: checking today's rivet work changed nothing here |  | 0 | 2,000 | 98.9% (98.2% with fireballs) | 98.3% | 0.0% | 4,100 |
| 2026-11-15 19:31 | fz1 | 1-2 rivets: Matt's review 3, free pass up the right: --set riv_free_zone=40 | riv_free_zone=40 | 9000 | 1,000 | 99.8% (81.0% with fireballs) | 99.1% | 0.1% | 4,700 |
| 2026-11-15 19:32 | fz2 | 1-2 rivets: Matt's review 3, free pass up the right: --set riv_free_zone=40 --set riv_pullback=true | riv_free_zone=40, riv_pullback=true | 9000 | 124 | 100.0% (79.8% with fireballs) | 96.3% | 0.0% | 4,700 |
| 2026-11-15 19:46 | xa1 | 1-2 rivets, 3,000 games: --set riv_free_zone=40 | riv_free_zone=40 | 20000 | 3,000 | 99.2% (78.7% with fireballs) | 98.8% | 0.0% | 4,700 |
| 2026-11-15 19:59 | xa2 | 1-2 rivets, 3,000 games: --set riv_free_zone=40 --set riv_pullback=true | riv_free_zone=40, riv_pullback=true | 20000 | 3,000 | 99.3% (78.9% with fireballs) | 98.9% | 0.0% | 4,700 |
| 2026-11-15 20:13 | xa3 | 1-2 rivets, 3,000 games: --set riv_free_zone=70 | riv_free_zone=70 | 20000 | 3,000 | 99.3% (79.9% with fireballs) | 98.9% | 0.0% | 4,700 |
| 2026-11-15 20:27 | xb1 | 1-2 rivets, 3,000 games: --set riv_ladder_busy=true | riv_ladder_busy=true | 20000 | 3,000 | 99.3% (80.7% with fireballs) | 98.9% | 0.1% | 4,700 |
| 2026-11-15 20:40 | xb2 | 1-2 rivets, 3,000 games: --set riv_ladder_busy=true --set riv_ladder_commit=8 | riv_ladder_busy=true, riv_ladder_commit=8 | 20000 | 3,000 | 99.0% (81.8% with fireballs) | 98.5% | 0.0% | 4,600 |
| 2026-11-15 20:57 | xc1 | 1-2 rivets, 3,000 games: --set riv_far_h=60 | riv_far_h=60 | 20000 | 3,000 | 98.4% (78.2% with fireballs) | 97.8% | 0.1% | 4,600 |
| 2026-11-15 21:19 | xc2 | 1-2 rivets, 3,000 games: --set riv_far_h=90 | riv_far_h=90 | 20000 | 3,000 | 89.9% (64.1% with fireballs) | 88.6% | 0.6% | 4,200 |
| 2026-11-15 21:47 | xc3 | 1-2 rivets, 3,000 games: --set riv_far_h=120 | riv_far_h=120 | 20000 | 3,000 | 78.6% (48.3% with fireballs) | 76.6% | 0.9% | 4,000 |
| 2026-11-15 22:12 | xc4 | 1-2 rivets, 3,000 games: --set riv_far_h=90 --set riv_far_spread=0.3 | riv_far_h=90, riv_far_spread=0.3 | 20000 | 3,000 | 84.6% (56.4% with fireballs) | 82.9% | 0.6% | 4,000 |
| 2026-11-15 22:27 | xd1 | 1-2 rivets, 3,000 games: --set riv_stay_right=300 | riv_stay_right=300 | 20000 | 3,000 | 99.5% (80.4% with fireballs) | 99.1% | 0.1% | 4,700 |
| 2026-11-15 22:41 | xd2 | 1-2 rivets, 3,000 games: --set riv_stay_right=150 | riv_stay_right=150 | 20000 | 3,000 | 99.5% (80.4% with fireballs) | 99.1% | 0.1% | 4,700 |
| 2026-11-15 22:55 | xd3 | 1-2 rivets, 3,000 games: --set riv_stay_right=300 --set riv_spawn_clock=2 | riv_stay_right=300, riv_spawn_clock=2 | 20000 | 3,000 | 99.5% (80.6% with fireballs) | 99.1% | 0.1% | 4,700 |
| 2026-11-15 23:09 | xe0 | 1-2 rivets, fresh check, 3,000 new games:  |  | 30000 | 3,000 | 99.7% (81.4% with fireballs) | 99.4% | 0.0% | 4,700 |
| 2026-11-15 23:22 | xe1 | 1-2 rivets, fresh check, 3,000 new games: --set riv_ladder_busy=true --set riv_ladder_commit=8 | riv_ladder_busy=true, riv_ladder_commit=8 | 30000 | 3,000 | 99.4% (82.7% with fireballs) | 99.1% | 0.2% | 4,700 |
| 2026-11-15 23:35 | xa4 | 1-2 rivets, 3,000 games: --set riv_free_zone=40 --set riv_free_where=true | riv_free_zone=40, riv_free_where=true | 20000 | 3,000 | 99.5% (81.5% with fireballs) | 99.1% | 0.0% | 4,700 |
| 2026-11-15 23:49 | hd2 | 1-2 rivets: the new reference (busy ladders and ladder commitment now on), 3,000 games |  | 20000 | 3,000 | 99.0% (81.8% with fireballs) | 98.5% | 0.0% | 4,600 |
| 2026-11-16 00:02 | xi1 | 1-2 rivets, fresh check: free pass up the right (only from the right), on top of the ladder pair | riv_free_zone=40, riv_free_where=true | 30000 | 3,000 | 99.4% (83.5% with fireballs) | 99.1% | 0.2% | 4,700 |
| 2026-11-16 01:24 | xf1 | 1-2 rivets, 3,000 games: --set riv_mc=1 | riv_mc=1 | 20000 | 3,000 | 98.8% (83.4% with fireballs) | 98.3% | 0.2% | 4,700 |
| 2026-11-16 01:41 | xf2 | 1-2 rivets, 3,000 games: --set riv_mc=3 | riv_mc=3 | 20000 | 3,000 | 96.8% (79.8% with fireballs) | 96.0% | 0.1% | 4,600 |
| 2026-11-16 01:58 | xg1 | 1-2 rivets, 3,000 games: --set riv_right={reach=3} | riv_right={reach=3} | 20000 | 3,000 | 99.2% (83.2% with fireballs) | 98.8% | 0.0% | 4,700 |
| 2026-11-16 02:15 | xg2 | 1-2 rivets, 3,000 games: --set riv_right={reach=5} | riv_right={reach=5} | 20000 | 3,000 | 99.0% (81.2% with fireballs) | 98.6% | 0.1% | 4,700 |
| 2026-11-16 02:31 | xg3 | 1-2 rivets, 3,000 games: --set riv_right={h=30} | riv_right={h=30} | 20000 | 3,000 | 99.6% (79.3% with fireballs) | 99.3% | 0.0% | 4,700 |
| 2026-11-16 02:49 | xg4 | 1-2 rivets, 3,000 games: --set riv_right={h=42} | riv_right={h=42} | 20000 | 3,000 | 97.8% (75.7% with fireballs) | 97.2% | 0.1% | 4,600 |
| 2026-11-16 03:07 | xg5 | 1-2 rivets, 3,000 games: --set riv_right={safe_w=0.7} | riv_right={safe_w=0.7} | 20000 | 3,000 | 99.0% (82.6% with fireballs) | 98.5% | 0.0% | 4,700 |
| 2026-11-16 03:24 | xg6 | 1-2 rivets, 3,000 games: --set riv_right={safe_w=1.3} | riv_right={safe_w=1.3} | 20000 | 3,000 | 98.7% (82.1% with fireballs) | 98.1% | 0.0% | 4,600 |
| 2026-11-16 03:42 | xh1 | 1-2 rivets, 3,000 games: --set riv_diff=true | riv_diff=true | 20000 | 3,000 | 99.2% (81.9% with fireballs) | 98.7% | 0.2% | 4,700 |
| 2026-11-16 04:00 | hd3 | 1-2 rivets: new reference (ladder pair and free pass on), 3,000 games |  | 20000 | 3,000 | 98.9% (82.5% with fireballs) | 98.4% | 0.0% | 4,700 |
| 2026-11-16 04:22 | xj1 | 1-2 rivets, fresh check: imagined futures (fireball model, weight 1) | riv_mc=1 | 30000 | 3,000 | 99.0% (83.9% with fireballs) | 98.6% | 0.1% | 4,700 |
| 2026-11-16 04:40 | xk1 | 1-2 rivets, 3,000 games: --set riv_gap_reach_3r=40 | riv_gap_reach_3r=40 | 20000 | 3,000 | 99.0% (81.6% with fireballs) | 98.5% | 0.1% | 4,700 |
| 2026-11-16 04:57 | xk2 | 1-2 rivets, 3,000 games: --set riv_gap_reach_3r=40 --set riv_right={reach=3} | riv_gap_reach_3r=40, riv_right={reach=3} | 20000 | 3,000 | 99.2% (82.9% with fireballs) | 98.7% | 0.2% | 4,700 |
| 2026-11-16 05:32 | yb0 | 1-2 rivets: the current player on 6,000 new games (reference) |  | 40000 | 6,000 | 99.1% (82.2% with fireballs) | 98.8% | 0.1% | 4,700 |
| 2026-11-16 06:16 | yb1 | 1-2 rivets, 6,000 new games: imagined futures 1 + tighter fireball margin on the right half | riv_mc=1, riv_right={reach=3} | 40000 | 6,000 | 99.1% (83.4% with fireballs) | 98.8% | 0.1% | 4,600 |
| 2026-11-16 06:38 | hd4 | 1-2 rivets: new reference (futures 1 + right reach 3 on), 3,000 games |  | 20000 | 3,000 | 99.2% (82.8% with fireballs) | 98.8% | 0.1% | 4,700 |
| 2026-11-16 07:00 | xm1 | 1-2 rivets, tuning the imagined futures: --set riv_mc=0.5 | riv_mc=0.5 | 20000 | 3,000 | 99.4% (83.3% with fireballs) | 99.1% | 0.1% | 4,700 |
| 2026-11-16 07:22 | xm2 | 1-2 rivets, tuning the imagined futures: --set riv_mc=1.7 | riv_mc=1.7 | 20000 | 3,000 | 99.0% (82.6% with fireballs) | 98.6% | 0.0% | 4,600 |
| 2026-11-16 07:43 | xm3 | 1-2 rivets, tuning the imagined futures: --set riv_mc_t=60 | riv_mc_t=60 | 20000 | 3,000 | 99.2% (83.5% with fireballs) | 98.8% | 0.1% | 4,700 |
| 2026-11-16 08:06 | xm4 | 1-2 rivets, tuning the imagined futures: --set riv_mc_t=130 | riv_mc_t=130 | 20000 | 3,000 | 99.3% (84.0% with fireballs) | 98.9% | 0.0% | 4,700 |
| 2026-11-16 08:32 | xm5 | 1-2 rivets, tuning the imagined futures: --set riv_mc_n=96 | riv_mc_n=96 | 20000 | 3,000 | 99.1% (83.4% with fireballs) | 98.6% | 0.2% | 4,700 |
| 2026-11-16 09:20 | yc0 | 1-2 rivets: the current player on 6,000 new games (reference) |  | 46000 | 6,000 | 99.0% (83.1% with fireballs) | 98.6% | 0.1% | 4,700 |
| 2026-11-16 10:23 | yc1 | 1-2 rivets, 6,000 new games: imagined futures looking 2 s ahead, 96 futures | riv_mc_t=130, riv_mc_n=96 | 46000 | 6,000 | 99.0% (83.0% with fireballs) | 98.7% | 0.1% | 4,700 |
| 2026-11-16 12:55 | xn1 | 1-2 rivets: when he jumps a fireball (only when every move meets one): --set riv_fire_jump_at=8 | riv_fire_jump_at=8 | 20000 | 3,000 | 99.2% (82.7% with fireballs) | 98.8% | 0.1% | 4,700 |
| 2026-11-16 13:18 | xn2 | 1-2 rivets: when he jumps a fireball (only when every move meets one): --set riv_fire_jump_at=12 | riv_fire_jump_at=12 | 20000 | 3,000 | 99.2% (82.4% with fireballs) | 98.8% | 0.1% | 4,700 |
| 2026-11-16 13:40 | xn3 | 1-2 rivets: when he jumps a fireball (only when every move meets one): --set riv_fire_jump_at=16 | riv_fire_jump_at=16 | 20000 | 3,000 | 99.2% (82.2% with fireballs) | 98.7% | 0.1% | 4,700 |
| 2026-11-16 13:44 | bb2 | 1-1 barrels: checking the rebuilt runner (rivet simulator added) plays exactly as before |  | 0 | 2,000 | 98.9% (98.2% with fireballs) | 98.3% | 0.0% | 4,100 |
| 2026-11-16 15:26 | xp1 | 1-2 rivets: a planned jump over one fireball coming straight at him (limited): --set riv_plan_jump=true | riv_plan_jump=true | 20000 | 3,000 | 99.8% (60.4% with fireballs) | 99.4% | 0.1% | 4,900 |
| 2026-11-16 21:21 | hd5 | 1-2 rivets: the current player on 10,000 new games (reference) |  | 60000 | 10,000 | 99.0% (83.0% with fireballs) | 98.8% | 0.1% | 4,600 |
| 2026-11-16 22:17 | zq1 | 1-2 rivets, 10,000 games (Matt's review 4): --set riv_lod_dy=4 | riv_lod_dy=4 | 60000 | 10,000 | 99.0% (83.2% with fireballs) | 98.7% | 0.1% | 4,600 |
| 2026-11-16 23:15 | zq2 | 1-2 rivets, 10,000 games (Matt's review 4): --set riv_hurry_bonus=3 | riv_hurry_bonus=3 | 60000 | 10,000 | 99.6% (83.1% with fireballs) | 99.4% | 0.0% | 4,600 |
| 2026-11-17 00:11 | zq3 | 1-2 rivets, 10,000 games (Matt's review 4): --set riv_hurry_bonus=3 --set riv_hurry_pmax=0.5 | riv_hurry_bonus=3, riv_hurry_pmax=0.5 | 60000 | 10,000 | 99.1% (83.1% with fireballs) | 98.9% | 0.1% | 4,600 |
| 2026-11-17 02:08 | zr1 | 1-2 rivets, 10,000 games: --set riv_under_ladder=12 | riv_under_ladder=12 | 60000 | 10,000 | 94.4% (79.5% with fireballs) | 93.9% | 0.1% | 4,600 |
| 2026-11-17 03:26 | zr2 | 1-2 rivets, 10,000 games: --set riv_under_ladder=24 | riv_under_ladder=24 | 60000 | 10,000 | 94.3% (77.9% with fireballs) | 93.8% | 0.1% | 4,600 |
| 2026-11-17 04:44 | zr3 | 1-2 rivets, 10,000 games: --set riv_under_ladder=12 | riv_under_ladder=12 | 60000 | 10,000 | 98.5% (83.0% with fireballs) | 98.2% | 0.2% | 4,600 |
| 2026-11-17 06:04 | zr4 | 1-2 rivets, 10,000 games: --set riv_under_ladder=24 | riv_under_ladder=24 | 60000 | 10,000 | 98.3% (82.6% with fireballs) | 98.0% | 0.1% | 4,600 |
| 2026-11-17 07:14 | zr5 | 1-2 rivets, 10,000 games: --set riv_under_ladder=12 | riv_under_ladder=12 | 60000 | 10,000 | 98.8% (82.8% with fireballs) | 98.5% | 0.1% | 4,600 |
| 2026-11-17 08:22 | zp1 | 1-2 rivets, 10,000 games: --set riv_plan2=0.1 | riv_plan2=0.1 | 60000 | 10,000 | 98.6% (84.0% with fireballs) | 98.3% | 0.2% | 4,600 |
| 2026-11-17 09:27 | zp2 | 1-2 rivets, 10,000 games: --set riv_plan2=0.2 | riv_plan2=0.2 | 60000 | 10,000 | 98.5% (83.2% with fireballs) | 98.3% | 0.1% | 4,600 |
| 2026-11-17 10:32 | zp3 | 1-2 rivets, 10,000 games: --set riv_plan2=0.05 | riv_plan2=0.05 | 60000 | 10,000 | 98.4% (83.5% with fireballs) | 98.1% | 0.1% | 4,600 |
| 2026-11-17 11:39 | zp4 | 1-2 rivets, 10,000 games: --set riv_plan2=0 | riv_plan2=0 | 60000 | 10,000 | 98.4% (83.6% with fireballs) | 98.1% | 0.1% | 4,600 |
| 2026-11-17 12:38 | hd6 | 1-2 rivets: the current player on 10,000 new games (reference for fresh checks) |  | 70000 | 10,000 | 98.9% (83.4% with fireballs) | 98.6% | 0.1% | 4,700 |
| 2026-11-17 13:45 | zg1 | 1-2 rivets, fresh check: two-step planner (10%) | riv_plan2=0.1 | 70000 | 10,000 | 98.6% (83.7% with fireballs) | 98.3% | 0.1% | 4,600 |
| 2026-11-17 14:52 | zh1 | 1-2 rivets, 10,000 games: --set riv_ham_stuck=60 | riv_ham_stuck=60 | 60000 | 10,000 | 98.6% (84.0% with fireballs) | 98.3% | 0.2% | 4,600 |
| 2026-11-17 15:59 | zh2 | 1-2 rivets, 10,000 games: --set riv_ham_stuck=120 | riv_ham_stuck=120 | 60000 | 10,000 | 98.5% (83.9% with fireballs) | 98.3% | 0.2% | 4,600 |
| 2026-11-17 17:08 | zs1 | 1-2 rivets, 10,000 games: --set riv_lham_smart=0 --set riv_lham_anywhere=true --set riv_lham_max=120 | riv_lham_smart=0, riv_lham_anywhere=true, riv_lham_max=120 | 60000 | 10,000 | 98.1% (80.5% with fireballs) | 97.7% | 0.2% | 4,600 |
| 2026-11-17 18:24 | zs2 | 1-2 rivets, 10,000 games: --set riv_lham_smart=0 --set riv_lham_anywhere=true --set riv_lham_max=180 | riv_lham_smart=0, riv_lham_anywhere=true, riv_lham_max=180 | 60000 | 10,000 | 97.9% (78.6% with fireballs) | 97.6% | 0.2% | 4,600 |
| 2026-11-17 19:35 | zs3 | 1-2 rivets, 10,000 games: --set riv_lham_smart=24 --set riv_lham_anywhere=true --set riv_lham_max=180 | riv_lham_smart=24, riv_lham_anywhere=true, riv_lham_max=180 | 60000 | 10,000 | 98.3% (80.4% with fireballs) | 98.0% | 0.2% | 4,600 |
| 2026-11-17 21:00 | pt3a | 1-2 rivets, 10,000 games: --set riv_plan3=8 | riv_plan3=8 | 60000 | 10,000 | 98.1% (83.4% with fireballs) | 97.8% | 0.1% | 4,600 |
| 2026-11-17 22:24 | pt3b | 1-2 rivets, 10,000 games: --set riv_plan3=8 --set riv_plan3_t=120 | riv_plan3=8, riv_plan3_t=120 | 60000 | 10,000 | 98.4% (83.6% with fireballs) | 98.1% | 0.2% | 4,600 |
| 2026-11-17 23:32 | lw1 | 1-2 rivets, 10,000 games: --set riv_lham_smart=0 --set riv_lham_anywhere=true --set riv_lham_max=30 | riv_lham_smart=0, riv_lham_anywhere=true, riv_lham_max=30 | 60000 | 10,000 | 98.5% (82.7% with fireballs) | 98.2% | 0.1% | 4,600 |
| 2026-11-18 00:39 | fm1 | 1-2 rivets, 10,000 games: --set riv_free_mid=true | riv_free_mid=true | 60000 | 10,000 | 98.5% (83.8% with fireballs) | 98.2% | 0.2% | 4,600 |
| 2026-11-18 02:11 | gc0 | 1-2 rivets, 10,000 games: --set riv_gapjump_cost=0 | riv_gapjump_cost=0 | 60000 | 10,000 | 98.2% (78.7% with fireballs) | 97.9% | 0.1% | 4,600 |
| 2026-11-18 03:42 | gp1 | 1-2 rivets, 10,000 games: --set riv_plan_gap=true | riv_plan_gap=true | 60000 | 10,000 | 98.6% (83.6% with fireballs) | 98.4% | 0.1% | 4,600 |
| 2026-11-18 05:13 | sp1 | 1-2 rivets, 10,000 games: --set riv_spawn_mc=true | riv_spawn_mc=true | 60000 | 10,000 | 98.6% (84.0% with fireballs) | 98.3% | 0.2% | 4,600 |
| 2026-11-18 06:45 | gs1 | 1-2 rivets, 10,000 games: --set riv_plan_gap=true --set riv_spawn_mc=true | riv_plan_gap=true, riv_spawn_mc=true | 60000 | 10,000 | 98.6% (83.7% with fireballs) | 98.4% | 0.2% | 4,600 |
| 2026-11-18 07:12 | dl1 | 1-2 rivets: recording Mario and every fireball every 4 frames, to learn which situations are dangerous (changes nothing about his play) |  | 90000 | 3,000 | 98.6% (83.9% with fireballs) | 98.0% | 0.1% | 4,600 |
| 2026-11-18 08:29 | cm1 | 1-2 rivets, 10,000 games: --set riv_choice_mc=0.05 | riv_choice_mc=0.05 | 60000 | 10,000 | 98.6% (84.7% with fireballs) | 98.4% | 0.1% | 4,600 |
| 2026-11-18 09:38 | cm2 | 1-2 rivets, 10,000 games: --set riv_choice_mc=0.1 | riv_choice_mc=0.1 | 60000 | 10,000 | 98.7% (84.8% with fireballs) | 98.4% | 0.2% | 4,600 |
| 2026-11-18 10:50 | dw1 | 1-2 rivets, 10,000 games: --set riv_danger_w=1 | riv_danger_w=1 | 60000 | 10,000 | 98.5% (83.9% with fireballs) | 98.3% | 0.1% | 4,600 |
| 2026-11-18 12:03 | dw2 | 1-2 rivets, 10,000 games: --set riv_danger_w=3 | riv_danger_w=3 | 60000 | 10,000 | 98.7% (83.8% with fireballs) | 98.4% | 0.1% | 4,600 |
| 2026-11-18 13:48 | dw3 | 1-2 rivets, 10,000 games: --set riv_danger_w=8 | riv_danger_w=8 | 60000 | 10,000 | 98.3% (82.7% with fireballs) | 98.1% | 0.1% | 4,600 |
| 2026-11-18 15:04 | cf1 | 1-2 rivets, fresh check: middle hammer or rivets by the imagined futures |  | 70000 | 10,000 | 98.7% (84.8% with fireballs) | 98.5% | 0.1% | 4,600 |
| 2026-11-18 16:17 | kw1 | 1-2 rivets, 10,000 games: --set riv_kong_wait=600 | riv_kong_wait=600 | 60000 | 10,000 | 98.5% (83.1% with fireballs) | 98.2% | 0.1% | 4,600 |
| 2026-11-18 17:36 | kw2 | 1-2 rivets, 10,000 games: --set riv_kong_wait=600 --set riv_kong_jump=true | riv_kong_wait=600, riv_kong_jump=true | 60000 | 10,000 | 98.4% (81.7% with fireballs) | 98.1% | 0.2% | 4,800 |
| 2026-11-18 18:48 | kw3 | 1-2 rivets, 10,000 games: --set riv_kong_wait=300 --set riv_kong_jump=true | riv_kong_wait=300, riv_kong_jump=true | 60000 | 10,000 | 98.4% (81.7% with fireballs) | 98.1% | 0.2% | 4,800 |
| 2026-11-18 19:56 | fa1 | 1-2 rivets, 10,000 games: --set riv_farm=60 | riv_farm=60 | 60000 | 10,000 | 98.6% (79.8% with fireballs) | 98.3% | 0.1% | 4,700 |
| 2026-11-18 21:07 | fa2 | 1-2 rivets, 10,000 games: --set riv_farm=30 | riv_farm=30 | 60000 | 10,000 | 98.6% (79.5% with fireballs) | 98.3% | 0.2% | 4,600 |
| 2026-11-18 22:42 | fa3 | 1-2 rivets, 10,000 games: --set riv_farm=60 --set riv_farm_x=150 | riv_farm=60, riv_farm_x=150 | 60000 | 10,000 | 98.5% (84.3% with fireballs) | 98.2% | 0.1% | 4,600 |
| 2026-11-19 00:27 | fa4 | 1-2 rivets, 10,000 games: --set riv_farm=150 --set riv_farm_x=150 | riv_farm=150, riv_farm_x=150 | 60000 | 10,000 | 98.6% (84.0% with fireballs) | 98.3% | 0.1% | 4,700 |
| 2026-11-19 02:37 | fa5 | 1-2 rivets, 10,000 games: --set riv_farm=60 --set riv_farm_x=140 | riv_farm=60, riv_farm_x=140 | 60000 | 10,000 | 98.3% (83.0% with fireballs) | 98.0% | 0.1% | 4,600 |
| 2026-11-19 07:49 | hd7 | 1-2 rivets: the current player on 30,000 new games (headline) |  | 100000 | 30,000 | 98.7% (84.8% with fireballs) | 98.6% | 0.1% | 4,600 |
| 2026-11-19 09:06 | dm1 | 1-2 rivets, 10,000 games: --set riv_down_mc=0.05 | riv_down_mc=0.05 | 60000 | 10,000 | 98.7% (86.1% with fireballs) | 98.5% | 0.1% | 4,700 |
| 2026-11-19 10:21 | dm2 | 1-2 rivets, 10,000 games: --set riv_down_mc=0.15 | riv_down_mc=0.15 | 60000 | 10,000 | 98.8% (86.3% with fireballs) | 98.5% | 0.1% | 4,700 |
| 2026-11-19 14:04 | df1 | 1-2 rivets, fresh check: the way down to 2R by the imagined futures |  | 70000 | 10,000 | 98.7% (86.6% with fireballs) | 98.5% | 0.1% | 4,700 |
| 2026-11-19 15:31 | cv1 | 1-2 rivets: the way up after 2R, by the imagined futures (through the middle / up the right as well) | riv_choice_via=true | 60000 | 10,000 | 96.4% (84.2% with fireballs) | 96.0% | 0.3% | 4,600 |
| 2026-11-19 16:51 | cv2 | 1-2 rivets: the way up after 2R, through the middle as well (by the imagined futures) | riv_choice_via="mid" | 60000 | 10,000 | 98.5% (86.7% with fireballs) | 98.2% | 0.2% | 4,600 |
| 2026-11-19 18:11 | cvf | 1-2 rivets, fresh check: the way up after 2R through the middle as well | riv_choice_via="mid" | 70000 | 10,000 | 98.4% (86.9% with fireballs) | 98.1% | 0.1% | 4,600 |
| 2026-11-19 20:16 | rm1 | 1-2 rivets, 10,000 games: general route choice by the imagined futures: --set riv_route_mc=0.2 | riv_route_mc=0.2 | 60000 | 10,000 | 95.1% (78.6% with fireballs) | 94.7% | 0.2% | 4,300 |
| 2026-11-19 22:03 | rm2 | 1-2 rivets, 10,000 games: general route choice by the imagined futures: --set riv_route_mc=0.3 | riv_route_mc=0.3 | 60000 | 10,000 | 95.2% (78.9% with fireballs) | 94.7% | 0.2% | 4,300 |
| 2026-11-19 23:26 | frz1 | 1-2 rivets, 10,000 games: the 2nd and 4th fireballs' long freezes: --set riv_freeze=120 | riv_freeze=120 | 60000 | 10,000 | 98.5% (86.6% with fireballs) | 98.2% | 0.1% | 4,600 |
| 2026-11-20 00:49 | frz2 | 1-2 rivets, 10,000 games: the 2nd and 4th fireballs' long freezes: --set riv_freeze=100 | riv_freeze=100 | 60000 | 10,000 | 98.5% (86.5% with fireballs) | 98.2% | 0.1% | 4,600 |
| 2026-11-20 02:37 | frz3 | 1-2 rivets, 10,000 games: the 2nd and 4th fireballs' long freezes: --set riv_freeze=120 --set riv_freeze_short=16 | riv_freeze=120, riv_freeze_short=16 | 60000 | 10,000 | 98.6% (86.9% with fireballs) | 98.3% | 0.2% | 4,600 |
| 2026-11-20 04:43 | lm1 | 1-2 rivets, 10,000 games: --set riv_last_mc=0.1 | riv_last_mc=0.1 | 60000 | 10,000 | 97.9% (80.7% with fireballs) | 97.6% | 0.2% | 4,500 |
| 2026-11-20 06:48 | lm2 | 1-2 rivets, 10,000 games: --set riv_last_mc=0.2 | riv_last_mc=0.2 | 60000 | 10,000 | 98.0% (81.5% with fireballs) | 97.7% | 0.1% | 4,500 |
| 2026-11-20 09:33 | sm1 | 1-2 rivets, tuning the fireball simulator (affects every choice it makes): --set riv_sim_rx=10 | riv_sim_rx=10 | 60000 | 10,000 | 98.5% (86.8% with fireballs) | 98.2% | 0.1% | 4,600 |
| 2026-11-20 11:15 | sm2 | 1-2 rivets, tuning the fireball simulator (affects every choice it makes): --set riv_sim_rx=6 | riv_sim_rx=6 | 60000 | 10,000 | 98.3% (86.8% with fireballs) | 98.0% | 0.1% | 4,700 |
| 2026-11-20 13:17 | sm3 | 1-2 rivets, tuning the fireball simulator (affects every choice it makes): --set riv_sim_ry=12 | riv_sim_ry=12 | 60000 | 10,000 | 98.8% (86.6% with fireballs) | 98.5% | 0.1% | 4,700 |
| 2026-11-20 14:51 | sm4 | 1-2 rivets, tuning the fireball simulator (affects every choice it makes): --set riv_sim_turn=0.08 | riv_sim_turn=0.08 | 60000 | 10,000 | 98.4% (86.1% with fireballs) | 98.1% | 0.2% | 4,600 |
| 2026-11-20 19:17 | np1 | 1-2 rivets, 10,000 games: --set riv_park=false | riv_park=false | 60000 | 10,000 | 98.7% (83.3% with fireballs) | 98.4% | 0.1% | 4,600 |
| 2026-11-20 20:52 | om1 | 1-2 rivets, 10,000 games: --set riv_order_mc=0.1 | riv_order_mc=0.1 | 60000 | 10,000 | 97.3% (81.1% with fireballs) | 96.9% | 0.2% | 4,500 |
| 2026-11-20 22:35 | om2 | 1-2 rivets, 10,000 games: --set riv_order_mc=0.2 | riv_order_mc=0.2 | 60000 | 10,000 | 97.9% (82.2% with fireballs) | 97.5% | 0.2% | 4,500 |
| 2026-11-21 00:12 | gd1 | 1-2 rivets, 10,000 games: --set riv_gap_dyn=20 | riv_gap_dyn=20 | 60000 | 10,000 | 98.6% (86.9% with fireballs) | 98.3% | 0.1% | 4,600 |
| 2026-11-21 02:09 | gd2 | 1-2 rivets, 10,000 games: --set riv_gap_dyn=50 | riv_gap_dyn=50 | 60000 | 10,000 | 98.6% (86.7% with fireballs) | 98.4% | 0.1% | 4,600 |
| 2026-11-21 04:11 | hp1 | 1-2 rivets, 10,000 games: --set riv_choice_hop=true | riv_choice_hop=true | 60000 | 10,000 | 98.4% (87.2% with fireballs) | 98.2% | 0.2% | 4,700 |
| 2026-11-21 06:21 | lu1 | 1-2 rivets, 10,000 games: --set riv_lad_flee_up=true | riv_lad_flee_up=true | 60000 | 10,000 | 98.2% (85.3% with fireballs) | 98.0% | 0.2% | 4,600 |
| 2026-11-21 06:23 | rs1 | 1-2 rivets, option 3: the all-knowing search (a teacher, not human-limited), first 64 games (STALLED) |  | 60000 | 0 | 0.0% (0.0% with fireballs) | 0.0% | 0.0% | 0 |
| 2026-11-21 07:50 | rs1 | 1-2 rivets, option 3: the all-knowing search (a teacher, not human-limited), first 64 games |  | 60000 | 64 | 39.0% (35.9% with fireballs) | 27.6% | 3.4% | 3,800 |
| 2026-11-21 08:53 | rs2 | 1-2 rivets, option 3: the all-knowing search, falls counted as death at once (64 games) |  | 60000 | 64 | 6.2% (3.1% with fireballs) | 1.7% | 0.0% | 2,900 |
| 2026-11-21 10:30 | sr5 | 1-2 rivets, option 5: managing the fireball count (with a hammer left of the middle after the left sweep, avoid fireballs rather than smash them: they'd come back on the right) | riv_smash_right=true | 60000 | 10,000 | 98.4% (86.7% with fireballs) | 98.1% | 0.2% | 4,700 |
