# DK Humanistic AI

A program that plays Donkey Kong under human limits. It sees the game a few frames late, its presses land a frame late, it can't see the game's upcoming random numbers, and it plans ahead like a person. It plays the barrel boards 1-1 to 5-1 (from level 5 the barrel board stops getting harder, so 5-1 is the main barrel target: every barrel death gone, with fireball deaths counted separately), and since 2026-11-15 the rivet board 1-2.

It's game AI in the classic sense, not machine learning: every frame it looks (late, like a person), lists what it could do, scores each option (a worst-case check, a whole-board safety map, and a simulator that imagines dozens of futures of the fireballs from odds measured in its own games), and picks the best, with the expert's rules on top. It learns between games: measurements, large paired tests, and Matt's reviews.

- [PLAYBOOK.md](PLAYBOOK.md): every test in order, with its numbers and what was adopted. The working log.
- [FINDINGS.md](FINDINGS.md): what we've learned, including what didn't work, measured facts about the game, and lessons about testing.
- [RESULTS_LOG.md](RESULTS_LOG.md): every batch's result, added automatically.
- [HANDOFF.md](HANDOFF.md): the whole project in one place (every board, the rules, what worked and didn't), for picking it up fresh.
- [RIVETS_HANDOFF.md](RIVETS_HANDOFF.md): the rivet board in full.

## Where it stands (fresh 30,000-game exams, fireball deaths left out)

| Board | Cleared | Counting fireballs | Exam |
|---|---|---|---|
| 1-1 | 98.68% | | 2026-11-07 |
| 2-1 | 98.47% | 98.39% | `pe22`, 2026-11-12 |
| 3-1 | 95.49% | 94.98% | `pe30`, 2026-11-11; since then +0.7 on fresh 10,000-game checks |
| 4-1 | 95.45% | 94.76% | `pe42`, 2026-11-12; since then +0.1–0.2 on fresh checks |
| 5-1 | 98.69% | 97.21% | `pz40`, 2026-11-13 |
| **1-2 (rivets)** | **~87.2%** (fireballs counted: rivet deaths are nearly all fireballs) | | `hp1` 8,722 / 10,000, 2026-11-21; 30,000-game headline before the last gains: `hd7` 84.81%. Handover: [RIVETS_HANDOFF.md](RIVETS_HANDOFF.md) |

**All-knowing mode** (`SEARCH=1`, a separate record, not human-limited): it only presses inputs a copy of the game has played out and survived. 100% on every barrel board, fireballs included. See FINDINGS.md, "The all-knowing mode".

## Running it

You need your own `dkong` ROM (not included). Batches run on the native runner: the dkx emulator with the compiled planner, about 5 times faster than MAME, and game for game the same. MAME 0.264 is used for the website's replays and for top players' recordings.

```sh
(cd native && make)                                                       # build native/build/dkh
python3 web/server.py                                                     # website on port 8765, live boards
python3 tools/run_batch.py my_test --level 5 --games 10000 --first 9000000 --native --note "…"   # a batch
python3 tools/compare.py ref my_test                                      # results, and saved / lost on the same games
```

`lua/agent.lua` holds the fixed human limits. `lua/policy.lua` (with `native/plan.cpp`, the compiled planner) holds the barrel rules, `lua/rivets.lua` (with `native/rivsim.cpp`, the fireball simulator) the rivet player, and `lua/params.lua` the settings, per level under `levels[N]` (rivet settings are `riv_*`). `--set key=value` overrides a setting for one batch (a Lua value: text needs quotes, `--set 'riv_choice_via="mid"'`).

Rivet batches: `python3 tools/run_batch.py NAME --level 1 --board 4 --games 10000 --first 60000 --native --note "…"` (starts `native/starts/r1_*`). Each run copies `lua/` when it starts (its defaults are in `runs/NAME/lua/params_base.lua` or `params.lua`), so later edits don't affect a running test.

## Tools

| Tool | What it does |
|---|---|
| `tools/autopsy.py` | traces deaths frame by frame and tries simple moves from save states (`TRACE_ONLY=1`: any game, trace only) |
| `tools/death_video.py` | a video of deaths, for review |
| `tools/grind_review.py` | tries a reviewer's fixes in each death's own game, at the moments where his own play still dies |
| `tools/review_rules.py`, `tools/setup_moves.py` | turns a fix into a narrow situation rule, finds every instance in fresh games and tries every move there |
| `tools/overnight_rules.py` | the whole review-to-rule cycle, unattended |
| `tools/rule_report.py` | what each rule did in the games where it acted: saved, lost |
| `tools/why_plan.py`, `tools/pred_vs_real.py`, `tools/collapse_check.py` | what the planner predicted, against what really happened |
| `tools/inp_check.py`, `tools/inp_trace.lua`, `tools/inp_study.py` | top players' MAME recordings: sync check, frame-by-frame trace, study |
| `tools/vid_extract.py`, `tools/vid_trace.py` | reads a video of a top player into the same trace format |
| `tools/expert_match.py`, `tools/steer_study.py` | compares his decisions and his barrel steering with the experts' |
| `tools/oracle_review.py` | the all-knowing mode on his deaths: when each was sealed, what killed him, and dice-proof human answers (new dice at the takeover) |
| `tools/oracle_why.py` | what his real planner made of each dice-proof answer, replaying the game exactly |
| `tools/tight_set.py` | 1,500 tight ordinary moments, each played on with new dice: a sensitive test for changes |
| `tools/pair_video.py` | a death, then the same game taken over by the all-knowing mode |
| `tools/danger_study.py` | a danger table learned from his own games |
| `tools/rivet_review.py` | rivets: the computer's own review of deaths: from 2 and 4 s before each, 11 choices, with new dice |
| `tools/rivet_review_states.py` | rivets: the board (fireballs and their headings) at the review's moments that have a real answer |
| `tools/rivet_playout.py` | rivets: plays a death out: every two-step move sequence from every second of the last 12 |
| `tools/rivet_scen.py` | rivets: a setting tested on chosen moments only (e.g. the deaths with the timer low) |
| `tools/danger_rivets.py` | rivets: the learnt danger table (tested, not used) |
| `tools/death_video.py --review FILE` | a review video of chosen deaths (`REVIEW_BEFORE` frames of lead-in) |
