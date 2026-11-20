-- Rules the program may tune. The human limits in agent.lua are not in here on purpose.
return {
  -- Settings that apply on one level only, so that changes for later boards leave earlier ones exactly as they were.
  levels = {
    [1] = {react = {4, 4}},   -- Matt (2026-11-08): 30 ms reactions on the barrel boards
    [2] = {react = {4, 4}, know_self = true, w_with = 60, with_drop = true, with_cl = 2, w_risk = 250, climb_ym = 7, jump_ready = 49, press_lag = 1, after_climb2 = 14, after_climb3 = 14, steer_off = 10, steer_here = {[5] = true}, wild_after = 72, ladder4 = 91, ladder4_top = 112, arrive4 = -1, guard_free = 2, w_no_next = 150},
    -- 3-1 starts from what worked on 2-1 (same board, faster and wilder barrels)
    [3] = {press_lag = 1, fine_waits = true, face_known = true,  -- (2026-11-15, two fresh checks: 95.16 -> 95.83, 95.23 -> 95.90)
           react = {4, 4}, ladder_steer = {131, 5, {188}, 3}, steer_zone = {4, 70, 135, 5, 188, 3, true}, know_self = true, ham_tap = true, think_zones = {{4, 70, 100}, {5, 85, 140}}, ham_stop = 24, wild_rom_us = {0.5}, wall_right = {[2] = true}, kong_pose = true, next_drop_climb = {0}, next_drop_pose = true, next_drop_approach = true, steer_air = true, steer_pull = 8, pull_moving = true, pull_safe = true, wild_rom = true, wall_jump = true, kong_rays = {{1, .71}, {1.25, .07}, {1.5, .12}, {1.75, .05}, {2, .06}}, kong_y = 180, ladder_sure = true, wild_dynamic = true, wild_spd = 1, along_fix = true, w_with = 30, with_drop = true, with_cl = 2, w_risk = 250, climb_ym = 7, jump_ready = 49, after_climb2 = 14, after_climb3 = 14, steer_off = 10, steer_here = {[5] = true}, wild_after = 72, ladder4 = 91, ladder4_top = 112, arrive4 = -1, guard_free = 2, w_no_next = 150},
    -- 4-1 starts from what worked on 3-1 (level 3 and later barrel boards share the same wild-barrel rules)
    [4] = {press_lag = 1, react = {4, 4}, ladder_steer = {131, 5, {188}, 3}, steer_zone = {4, 70, 135, 5, 188, 3, true}, know_self = true, ham_tap = true, think_zones = {{4, 70, 100}, {5, 85, 140}}, ham_stop = 24, wild_rom_us = {0.5}, wall_right = {[2] = true}, kong_pose = true, next_drop_climb = {0}, next_drop_pose = true, next_drop_approach = true, steer_air = true, steer_pull = 8, pull_moving = true, pull_safe = true, wild_rom = true, wall_jump = true, kong_rays = {{1, .71}, {1.25, .07}, {1.5, .12}, {1.75, .05}, {2, .06}}, kong_y = 180, ladder_sure = true, wild_dynamic = true, wild_spd = 1, along_fix = true, w_with = 30   --[[ 2026-11-15, two fresh checks: 95.13 -> 95.22, 95.56 -> 95.76 ]], with_drop = true, with_cl = 2, w_risk = 250, climb_ym = 7, jump_ready = 49, after_climb2 = 14, after_climb3 = 14, steer_off = 10, steer_here = {[5] = true}, wild_after = 72, ladder4 = 91, ladder4_top = 112, arrive4 = -1, guard_free = 2, w_no_next = 150},
    -- 5-1 starts from what worked on 4-1 (from level 5 the barrel boards stop changing)
    [5] = {
      fine_waits = true,   -- finer jump timing so planned jumps don't slip (2026-11-12; fresh 98.27 -> 98.50 / 98.29 -> 98.52; jumping barrel deaths 112 -> 86 / 104 -> 82)
      press_lag = 1,   -- the planner allows a frame for a jump press to take effect (2026-11-11; fresh 98.43 -> 98.45 / 98.48 -> 98.68, counting fireballs +0.33 / +0.25)
      -- recurring setups (tools/overnight_setups.py, 2026-11-10; fresh checks 97.90 -> 97.95 and 97.56 -> 97.66, saved 20 lost 5):
      -- s1: just off ladder 91, a barrel on Kong's short ladder to his right and one rolling at him 57-72 px away: walk left 20 frames;
      -- s3: a barrel rolling at him 20-28 px away and one going over the end 64-72 px behind: straight jump holding left at once
      face_known = true,   -- with the hammer, press until Mario really faces the barrel (2026-11-10, fresh 97.72 -> 97.86, saved 23 lost 8)
      setups = {-- from Matt's reviewed deaths (2026-11-12), every instance tried, two fresh checks where they acted:
                -- r2 (review 1 #3, near ladder 91's top between barrels): walk left 8, straight jump; 85 saved / 54 lost
                -- r7 (review 2 #5, by the right ladder with a barrel going over the end): walk left 16, jump right; 79 / 20
                {5,88,100,needs={{0,19,35,"L"},{0,-30,-14,"L"}},move={a=1,w=8,j1=0,j2=nil,h=1},name="r2"},
                {5,209,221,needs={{0,12,28,"e"}},move={a=1,w=16,j1=2,j2=nil,h=1},name="r7"}},react = {4, 4}, chase_jump = {5, 120, 150, 22, 30}, air_plan = {5, 74, 100, 10}, ladder_steer = {131, 5, {188}, 3}, steer_zone = {4, 70, 135, 5, 188, 3, true}, know_self = true, under_live = "rolling", w_under = 40, under_zones = {{5, 100, 112}}, ham_tap = true, air_off = 10, climb_nowild = true, think_zones = {{4, 70, 100}, {5, 85, 140}}, ham_ladder = 16, wild_aim = true, kong_aim = 0.81, kong_straight = 0.19, kong_straight_seen = true, ham_stop = 24, wild_rom_us = {0.5}, wall_right = {[2] = true}, kong_pose = true, next_drop_climb = {0}, next_drop_pose = true, next_drop_approach = true, steer_air = true, steer_pull = 8, pull_moving = true, pull_safe = true, wild_rom = true, wall_jump = true, kong_rays = {{1, .71}, {1.25, .07}, {1.5, .12}, {1.75, .05}, {2, .06}}, kong_y = 180, ladder_sure = true, wild_dynamic = true, wild_spd = 1, along_fix = true, w_with = 30, with_drop = true, with_cl = 2, w_risk = 250, climb_ym = 7, jump_ready = 49, after_climb2 = 14, after_climb3 = 14, steer_off = 10, steer_here = {[5] = true}, wild_after = 72, ladder4 = 91, ladder4_top = 112, arrive4 = -1, guard_free = 2, w_no_next = 150},
  },
  wild_model = true,  -- uses the measured way wild barrels rest and fall between girders
  along_fix = false,   -- after a jump past his waiting spot he has to walk back to it, not appear there
  ladder_top_fix = true, -- a barrel just entering a ladder lands on the girder below, not the one it's leaving
  double_tap = true,  -- taps jump twice in case the first came too soon after landing
  above_ok = false,    -- a barrel rolling on the girder above isn't a near miss
  first_straight = true, -- the board's first wild barrel falls straight down
  wild_tail = 60,      -- how far ahead he checks walking and waiting when a wild barrel is about
  wild_soft = false,   -- where a wild barrel goes after its next bounce counts as a chance, not a certainty
  odds_risk = true,   -- a barrel that might come down only counts as a risk if he couldn't react in time
  see_lag = 9,         -- frames before he sees a barrel commit
  respond = 14,        -- frames from starting a jump to being clear of a barrel
  arc_timed = true,   -- barrels leaving a girder end are timed from when they went over the edge
  ladder_real = false, -- on a ladder, a barrel Kong hasn't thrown yet doesn't turn him back
  climb_xm = nil,      -- and how far to the side
  climb_ym = nil,      -- how far above a passing barrel he must be when setting out to climb (nil = usual margin)
  next_drop_pose = nil, -- expect that barrel only when Kong's pose shows he's about to throw (needs kong_pose)
  next_drop_approach = nil, -- next_drop_climb also counts at the foot of ladder 91, when deciding whether to start up
  next_drop_climb = nil, -- on a ladder, the same expected barrel decides whether to keep climbing, {0, 16}
  w_with = nil,        -- bonus for jumping the way a close barrel rolls, when it's within with_x px and coming at him
  with_x = 16,
  with_cl = nil,
  with_drop_h = nil,   -- a barrel coming down a ladder counts for the back jump only within this many px of his girder (default 34)
  with_needed = nil,   -- back-jump bonus only when standing still wouldn't be safe (Matt's 4-1 death 6)
  with_min_x = nil,    -- no back-jump bonus for a jump that lands left of this x (the corner trap on 3-1's 5th girder)       -- and only when the jump clears it comfortably, by this much
  with_next = nil,     -- only when he can deal with the barrel after it too
  with_drop = nil,     -- also counts a barrel coming down a ladder beside him
  with_floors = nil,   -- only on these floors, {[floor] = true}
  next_drop = nil,     -- expects Kong's next barrel down the broken ladder, this many frames after the soonest it could be thrown, {0, 16}
  ladder_sure = false, -- on a ladder, only where a wild barrel is certainly going counts
  wild_rays = false,   -- weighs where wild barrels may go after a bounce by measured odds
  ray_clear = 1,       -- pixels that count as meeting a possible wild barrel
  kong_watch = true,  -- weighs the moment Kong could let go of a wild barrel
  wild_toward = nil,   -- each time a wild barrel lands it heads for Mario (measured on 3-1)
  wild_spd = nil,
  wild_sides = nil,
  wild_stick = nil,    -- (with wild_dynamic) a landing wild barrel goes the way the stick is pressed, else towards Mario
  fallback_pref = nil, -- {{floor, from x, to x, jump direction}, ...}: with no safe plan there, prefer that jump (from grinding) if it lasts nearly as long
  fallback_slack = 6,
  juke = nil,          -- (with wild_dynamic, wild_stick) may stand still and tap right as a wild barrel lands, to fling it away
  juke_lead = 3,       -- frames before a landing the tap starts
  wild_lead = nil,     -- (native) frames further ahead to carry a wild barrel before planning
  wild_catch1 = nil,   -- (native) catch a wild barrel up one frame less (measured: the handed-over state was a frame ahead)
  wild_pre = nil,      -- (native) until the oil is lit, wild barrels land and go right at this speed (0xE9/256 = 0.91 from level 3)
  wild_aim = nil,      -- (native, difficulty 5) each wild bounce is aimed at Mario: (his x - its x) / 64 px a frame
  kong_straight_seen = nil, -- a wild just out of Kong, way not seen yet: also allow for a straight drop at x=59 (first fall only)
  kong_straight = nil, -- with kong_aim: the chance a wild from Kong drops straight down instead (measured 0.19)
  kong_aim = nil,
  kong_aim_top = nil,  -- the same, on Kong's girder only      -- (difficulty 5) Kong's wild barrels leave aimed at Mario; the value is how often he throws one at that moment
  follow_check = nil,  -- (native) for each plan, check there's still a simple safe move from where it leaves him
  follow_steps = 30,   -- how many steps (2 frames each) that move has to stay clear
  w_no_follow = nil,   -- cost of a plan that leaves him with no way on
  wild_rom_us = nil,   -- the random part of a bounce's speed to check each plan against (default {0, 0.5, 0.99})
  wild_rom = nil,      -- (with wild_dynamic) bounce speeds as the game sets them: 1-2 px a frame going right, 0-1 going left, checked at three speeds
  wild_dynamic = nil,  -- (native only) wild barrels move in step with each plan, heading for Mario each time they land    -- the ways a wild barrel may go after landing, default {1, 0, -1}      -- and at least this fast afterwards
  kong_rays = nil,     -- how wild barrels leave Kong on this level, {{speed, share}, ...}; nil = as measured on 1-1
  kong_chance = 0.1,   -- how often he does at that moment (measured)
  w_commit = 20,        -- value of carrying on with what he's doing rather than changing his mind
  odds_fallback = true, -- with no clean option left, plays the measured odds of a wild bounce
  top_guard = true,   -- never presses jump on the last rungs of a ladder
  ham_face = true,    -- with a hammer: no jumps, turns to face the nearest barrel
  wall_jump = nil,
  right_stand = nil,   -- (with wall_right) furthest right he may stand on those girders (default 224, the girder's end)
  wall_right = nil,    -- (with wall_jump) {[floor] = true}: the right wall too, at x=233, and the space up to it, on girders that reach it     -- jumps bounce off the left wall at x=22 and he can use the space down to it (measured)
  ham_ladder = nil,    -- px: holding the hammer, step away from a barrel coming down a ladder this close beside him
  think_zones = nil,   -- {{floor, from x, to x}, ...}: there he always weighs every plan, never just walks on (the quick check misses what comes a second later)
  ham_tap = nil,       -- with the hammer: turn to face the nearest barrel with one press, then stand (not walk into it)
  jitter = nil,        -- frames: also check each jump pressed this much later
  w_jitter = 100,      -- cost of a jump that fails when pressed that late
  step_with = nil,     -- {floor, from x, to x, nearest, furthest, frames}: a short step with a barrel rolling at him this close, first
  cases = nil,         -- file of remembered situations (tools/solve.py): in a close match he makes the move that worked there
  case_x = 3,          -- px: how close his x must be
  case_b = 6,
  case_all = nil,
  case_now = nil,
  case_best = nil,
  case_kong = nil,     -- frames: banked solutions also need Kong in the same pose, held this close to as long
  case_walk = nil,     -- banked solutions also need Mario at the same step of his walk     -- when several banked solutions match, use the closest match (not the first)
  case_above = nil,    -- px: only barrels no further than this below him are compared (Matt: not those on lower girders)      -- match cases from his real position (know_self)
  case_far = nil,      -- extra slack per px of a barrel's distance from him      -- match on every barrel on screen, not just those near him          -- px: how close each barrel must be
  chase_zone = nil,    -- {floor, from x, to x}: where a barrel chasing close behind him should be jumped now
  chase_x = 30,        -- px: how close behind
  chase_w = 60,        -- bonus for that jump
  chase_dir = "back",  -- "back": jump back over it; "any": any jump
  chase_now = 6,       -- frames: how soon the jump must start
  air_off = nil,       -- px: in the air, let go of the stick as a barrel above comes this close to crossing a ladder on the side he's holding
  pull_gap = nil,      -- px: don't steer a barrel down a ladder that drops it on his own girder closer ahead than this
  climb_nowild = nil,  -- on a ladder going up, ignore wild barrels (Matt: at difficulty 5 they can't hurt him there)
  keep_jump = nil,     -- also weigh the jump he planned a moment ago, at the same moment (stops a planned jump slipping later)
  w_keep = nil,        -- bonus for sticking to it
  ham_stop = nil,      -- px: holding the hammer, stop and face a barrel rolling at him from this close (Matt's pro tip)
  ham_avoid2 = nil,    -- {from, to}: no jumping where it grabs the hammer on the 2nd girder
  ham_avoid = true,   -- keeps away from the top hammer for now
  arc_snap = true,    -- barrels go over a girder end at exactly the measured spot and time
  kong_y = 125,        -- how far down the board he still weighs Kong's next wild barrel
  wild_smooth = true, -- judges a wild barrel by its motion since its last bounce
  air_free = false,    -- lets go of the stick in mid-air, since pressing towards a ladder draws barrels down it; true or {[floor] = true}
  air_steer = nil,     -- what he presses in mid-air on a floor, to draw barrels down ladders that way, {[floor] = 1 left or 2 right}
  guard_free = nil,    -- knows he's off the ladder this many pixels past the top, before he sees it, so he can jump straight away
  w_no_next = nil,     -- cost of a jump that leaves him unable to deal with the next barrel
  next_tail = 45,      -- how long he'd have to be able to stand where he lands, for that not to matter
  next_waits = {9, 14, 20, 28}, -- how soon after landing a second jump could go, for that check
  kong_pose = nil,     -- times Kong's next barrel from his pose, which anyone watching him can see
  lad_hyst = nil,      -- frames: on a ladder, a change of direction holds at least this long (no flip-flopping)
  ladder_commit = nil, -- knows when he's reached the bottom backing down, and doesn't dither on a ladder
  retreat_top = nil,   -- within this many pixels of the top he climbs on and jumps, rather than backing down
  w_under = nil,       -- cost of taking off or landing right under a ladder
  under_x = 6,
  under_zones = nil,
  fine_waits = nil,    -- weigh jumps at finer waits (2-frame steps when soon), so a planned jump doesn't keep slipping
  trail_w = nil,       -- cost per frame short of trail_need before the trailing barrel reaches where a jump lands
  trail_need = 30,     -- frames he wants after landing before the second barrel arrives
  trail_gap = 45,      -- px: the second barrel this close behind the first counts
  trail_near = 40,     -- px: and the first this close to him
  trail_group = nil,   -- px: (Matt) barrels this close together count as a group jumped as one; the rule needs a group of 2+ and a third behind it
  face_known = nil,   -- he sees which way Mario faces: hammer turns press until Mario faces the barrel
  ham_hold = nil,     -- {x, frames}: with the top hammer, stand at x till held that long, then head right (Matt)
  ham_top = nil,      -- {hammer x, gap from, gap to, most frames to wait}: fetch the top hammer and time the jump for it (Matt); needs ham_avoid = false
  climb_gate = nil,   -- {ladder x, window, room px, pose 172 ok, wait for the barrel to pass Kong's short ladder}: when to start up ladder 91 (Matt)
  setups = nil,        -- {{floor, x from, x to, needs = {{girder up, dx from, dx to, dir, [ladder x, short from, short to]}, ...}, move = {a, w, j1, h}, name}}
  hold_ground = nil,   -- {floor, from x, to x, range}: don't walk towards barrels rolling at him within range there; stand and jump them
  back_jump = nil,     -- {floor, from x, to x, nearest, furthest, step}: step towards a barrel this close, then jump the way it's going
  low_roof = nil,      -- {floor, from x, to x, nearest, furthest, overhead, frames}: under a close girder with a barrel coming and one above: walk left first
  foot_dodge = nil,    -- {floor, from x, to x, dx from, dx to, frames}: a barrel coming down a ladder up to his right: step left
  chase_jump = nil,    -- {floor, from x, to x, nearest, furthest}: a barrel this close behind: jump it straight now, once
  chase_stop = nil,    -- {floor, from x, to x, nearest, furthest}: walking away from a barrel this close behind, stop and let it come
  air_plan = nil,
  air_plan2 = nil,     -- a second setup for air_plan      -- {floor (0 = any), x from, x to, frames}: that far into a jump there, plan again instead of coasting
  air_tap = nil,       -- {floor, x from, x to, nearest, furthest, from frame, to frame, dir}: in a straight jump there, hold dir those frames
  steer_zone = nil,    -- {floor, from x, to x, girder above, ladder x, window}: there, tap towards that ladder as a barrel above reaches it
  ladder_steer = nil,  -- {ladder x, girder above, {ladders up there}, window, wait}: on that ladder, tap towards those ladders as a barrel above reaches one
  under_live = nil,    -- w_under only for a ladder a barrel could come down right now (one of its predicted paths takes it, or it's on it)
  know_self = nil,     -- he knows where Mario is now (his own presses), not from his delayed view
  left_zone = nil,
  train_zone = nil,    -- {floor, from x, to x, nearest, furthest, gap, bonus}: with two barrels close together coming, jump the first early     -- {floor, from x, to x, cost}: a cost for left jumps there   -- {{floor, ladder x from, to}, ...}: w_under only for these ladders         -- how close counts as under it
  thin_safe = nil,     -- with nothing comfortable left, how much extra each pixel of clearance is worth (progress then counts for nothing)
  next_risk = nil,     -- the next-barrel check also counts barrels that may come down a ladder
  stick_odds = nil,    -- chance a barrel takes a ladder when he isn't pressing towards it, instead of treating it like any other
  steer_off = nil,     -- stops pressing towards a ladder this many pixels before a barrel above crosses it
  steer_floors = 1,    -- how many floors above him that matters
  steer_here = nil,    -- only on these floors, {[floor] = true}
  sure_ladders = nil,  -- ladders barrels take often enough on this level to plan around, {[floor] = {[x] = true}}
  drop_rate = nil,     -- how fast barrels come down ladders, if not the usual estimate
  first_drift = true, -- a wild barrel's sideways speed as it leaves Kong is timed from when it starts moving
  w_ray = 1000,        -- cost of a certain meeting
  ray_discount = 0.3,  -- share of that cost if he'd have time to see it and react
  ray_block = 0.4,     -- chance of meeting one that stops him using a ladder
  ray_ok = 0.05,       -- below this chance he doesn't think twice
  kong_fix = false,    -- Kong's next barrel is predicted rolling, not as a wild barrel
  ladder_fix = true,  -- a barrel on a ladder is predicted straight down, even in its first moments there
  tail_stay = true,   -- plans can land and stand still, rather than always walking on
  under_end = nil,    -- {px, cost, soon frames}: a cost for plans that leave him standing under a ladder a barrel above will reach soon
  with_straight = nil, -- no w_with bonus for a sideways jump when a straight jump then is as safe (Matt)
  slope_jump = nil,   -- the planner's jumps last a frame longer per pixel he lands lower (downhill), one less landing higher (measured)
  second_straight = true, -- a second jump can go straight up
  land_stall2 = true, -- no walking for the moment after landing, before a second jump
  seconds = {6, 16, 30},  -- frames after landing before a second jump
  only_needed_jumps = false, -- never jump just because a barrel might take a ladder
  w_sideways3 = 25,    -- prefers straight jumps on floors 3 and 4 (expert advice); hurts near the top
  w_sideways4 = 25,
  w_sideways = 0,      -- cost of jumping sideways instead of straight up
  steer_top = false,   -- on floor 5, press back towards the broken ladder as top-girder barrels pass over it
  anticipate_top = true, -- knows when he has reached the top of a ladder before seeing it
  exact_arc = true,   -- uses the measured arc for barrels falling off girder ends
  ladder3 = 131,       -- the shorter way up from floor 3, which also shortens floor 4
  arrive3 = 1,
  arrive5 = 1,         -- waiting past this ladder lets barrels coming down it roll away from him
  horizon = 130,       -- frames ahead it plans
  decide_every = 2,    -- frames between decisions
  -- jumps to try for, best first: sideways clearance, frames clear after landing, ignore "might" barrels
  -- (contact is within 5 sideways; he needs about 25 frames after landing to see it and jump again)
  jump_tries = {{10, 28, false}, {8, 28, false}, {8, 16, true}, {7, 8, true}},
  jump_within = 20,    -- only consider a jump when a barrel will reach him within this many frames
  maybe_within = 40,   -- hold back from a barrel that might drop onto him this soon
  hold_clear = 24,     -- standing still or backing off has to stay clear this long
  defer = 8,           -- frames it may hold off a jump that would still work
  must_act = 14,       -- frames before a predicted hit when it stops deferring
  wild_after = nil,    -- frames after a throw that Kong can let go of a wild barrel, if not the usual 80
  throw_every = 80,    -- Kong's soonest usual next barrel, in frames
  standoff = 10,       -- how far past a ladder to wait
  look_ahead = 50,     -- how far ahead it checks the way it's walking
  after_climb = 24,    -- a climb has to stay clear this long after reaching the top
  clear_x = 8,         -- keep this far from a barrel sideways (contact is within 5)
  clear_y = 9,         -- and this far vertically (contact is within 7)
  land_wait = 6,       -- frames after a jump before he can jump again
  jump_ready = nil,    -- frames after pressing jump before the game will accept another press; his plans and presses keep to it
  ladder_hold = nil,   -- this close to the top of a ladder he can stop and let barrels roll over
  hold_y = 7.5,        -- how far below a barrel he can hold (contact is within 7)
  hold_for = 40,       -- holding has to stay clear this long
  riv_jump_hold = true,  -- rivets: hold each jump 3 frames; if still on the girder 6 frames after, decide again (jh1 703 vs 634; fresh fj1 681 vs 643)
  riv_safe_w = 1,  -- rivets: the whole-board safety map's time to spare where each move leaves him (jg2 755 vs 703; fresh fs1 726 vs 681; 1.5 collapses: 456)
  riv_ladder_busy = true, riv_ladder_commit = 8,  -- rivets (Matt's review 3): never walk to a ladder a fireball is on; no holding mid-ladder (3,000 games: 2,453 vs 2,408; fresh xe1 2,480 vs 2,442)
  riv_free_zone = 40, riv_free_where = true,  -- rivets (Matt's review 3): with him on the right and the right side free, skip the middle hammer, up the right to 4R/5R (xa4 2,445 vs 2,408, 42 / 5; fresh xi1 2,504 vs 2,480, 31 / 7; experts: 6 / 6)
  riv_mc = 1, riv_right = {reach = 3},  -- rivets: imagined futures (the fireball model, native/rivsim.cpp) as a tie-break among safe moves; fireball allowance 3 px after the left sweep (6,000 new games: 5,006 vs 4,933, saved 705 / lost 632)
  riv_lod_dy = 4,  -- rivets (Matt's review 4, #8): the life-or-death jump only for a fireball at his girder's height, not one coming up the ladder below (10,000 games: 8,325 vs 8,304, saved 34 / lost 13)
  riv_plan2 = 0.1,  -- rivets: two-step plans by the imagined futures when stuck or in danger (10,000 games: 8,400 vs 8,325; fresh 8,368 vs 8,335; 0.05 / 0: +30 / +34)
  riv_choice_mc = 0.1,  -- rivets: middle hammer or the rivets, by playing both of his routes forward in the imagined futures (10,000 games: 8,481 vs 8,400, saved 221 / lost 140; 0.05: 8,473)
  riv_down_mc = 0.15,  -- rivets: after 3R, down the right ladder or back over 3R's gap and down the middle, by the imagined futures (10,000 games: 8,626 vs 8,481, saved 734 / lost 589; 0.05: 8,613)
  riv_choice_via = "mid",  -- rivets: the hammer choice also weighs the rivets through girder 3's middle (10,000 games: 8,666 vs 8,626; fresh 8,690 vs 8,661)
  riv_freeze = 120, riv_freeze_short = 16,  -- rivets (Matt): the 2nd / 4th fireballs' own freezes (long at ladder tops ~336 frames; short stops in ~56-frame steps) held still (frz3 8,686 vs 8,666, 190 / 170; kept: Matt, "don't throw away a gain")
  riv_choice_hop = true,  -- rivets (Matt): in girder 2's middle with 2R out, the hammer choice also weighs hopping right over 2R's gap and up the right (hp1 8,722 vs 8,686, 384 / 348)
  riv_skip_ham = 100,  -- rivets (Matt): skip the middle hammer when no fireball is in the upper right (y <= 170, x >= this)
  risk_odds = nil,    -- scale the "might come down" penalty by the game's odds (ladder rule 0x2186): 3/4 with his stick at the ladder, 3/16 without
  extra_last = nil,   -- with no safe plan, also weigh step-then-stand and step-pause-jump (last resort)
  stand_plans = nil,  -- also weigh "step this way a moment, then stand" (the oracle review: the saving move he couldn't write)
  ham_plan = nil,     -- holding the hammer, the planner models its swing and smashes (from the ROM) instead of the hammer rules
  danger = nil,       -- weight: count the learned danger (cases/danger.lua) of the spot a plan leaves him in against it
  contingent = nil,   -- a barrel that might come down is a risk only if, once he'd see it commit, he couldn't get away from it
  pull_upstream = nil, -- px: also pull a barrel down a ladder on the upstream side at least this far from him (the experts do)
  pull_moving = nil,   -- steer_pull also while walking (the experts pull barrels down while on the move)
  steer_pull = nil,    -- frames ahead: standing, tap towards a ladder above that a barrel is about to cross, on the side his girder's barrels roll away to
  steer_air = nil,     -- also steer during a straight jump, when the stick can't move him
  pull_nowild = nil,   -- px: no standing steer with a wild barrel above him this close sideways
  pull_up = nil,       -- steer barrels on this many girders above (default 1, the one directly above)
  pull_floors = nil,
  pull_jump = nil,     -- when a few steps aren't safe but a straight jump is, jump straight and steer from the air
  pull_safe = nil,     -- only steer if his planner says a few steps that way (pull_walk frames) are clear
  pull_walk = 6,   -- only on these floors, {[floor] = true}
  steer_far = nil,     -- a ladder this far off isn't worth breaking off a planned move for
  steer_calm = nil,    -- only lets go of the stick to keep barrels off a ladder when nothing is pressing; a move his plan depends on comes first
  press_lag = nil,     -- frames a jump plan allows for the press to become a jump
  ladder_known = nil,  -- knows he's on a ladder near its bottom, even while what he sees still shows him on the girder
  ladder_true = nil,   -- backing down a ladder is judged at his real speed, to the real girder, plus this many frames to step aside
  plan_tail = 20,      -- a plan must stay clear this long after its last move, to leave time to react
  need_clear = 3,      -- pixels of clearance that count as close to a "might" barrel
  walk_clear = 6,      -- with this much room there is nothing to think about
  min_clear = 4,       -- a plan needs at least this much clearance to count as safe
  w_later = 0.45,       -- slight preference for moving later, when more is known
  w_thin = 100,        -- cost of a plan with less than min_clear
  clear_cap = 6,       -- extra clearance beyond this earns nothing
  w_clear = 10,        -- value of each pixel of clearance
  w_prog = 40,         -- value of moving towards the goal
  w_jump = 15,         -- cost of each jump
  w_risk = 500,        -- cost of going near a barrel that might take a ladder
  fire_horizon = 30,   -- fireballs wander, so don't predict them far ahead
  fire_x = 6,          -- contact box, measured
  fire_y = 8,
  fire_spread = 0.1,   -- how much a fireball's possible position grows per frame
}
