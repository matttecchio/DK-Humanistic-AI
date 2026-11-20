#!/usr/bin/env python3
"""rivet_scen.py BATCH --min-frames F --backs 900,600 --trials 4 --set-a k=v ... : a change tested on the very moments it's for
(Matt, 2026-11-16: "test a set of scenarios with risk vs timer"): each death of BATCH after frame F is played back to BACK frames before
its end, and from there he plays it himself under each setting, TRIALS times (trial 0 the game's own dice, later ones new dice he can't
know, DICE). Prints the clears per setting. Settings: --cfg "name:k=v,k=v" (repeatable; "base:" for none)."""
import argparse, json, os, shutil, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import stats
from scenario_test import run_rows, H
ap = argparse.ArgumentParser()
ap.add_argument("batch"); ap.add_argument("--min-frames", type=int, default=4800); ap.add_argument("--backs", default="900,600")
ap.add_argument("--trials", type=int, default=4); ap.add_argument("--cfg", action="append", default=[])
ap.add_argument("--timer-only", action="store_true", help="only deaths that weren't fireballs (the timer)")
a = ap.parse_args()
stats.use_starts(a.batch)
stats.ensure_ram(); grid = stats.grid_dir(); shutil.rmtree(grid, ignore_errors=True); os.makedirs(grid, exist_ok=True); os.environ["SHOW_GRID"] = grid
os.environ["DICE"] = "1"
deaths = [g for g in stats.load(a.batch, inputs=True) if g["outcome"] == "died" and g["frames"] > a.min_frames and (not a.timer_only or g["cause"] != "fireball")]
backs = [int(b) for b in a.backs.split(",")]
rows = [(g["id"], g["frames"] - b, t, g["inp"]) for g in deaths for b in backs if g["frames"] > b + 5 for t in range(a.trials)]
print(f"{len(deaths)} deaths after frame {a.min_frames}; {len(rows)} takeovers per setting", flush=True)
for cfg in a.cfg:
    name, _, kv = cfg.partition(":")
    sets = [s for s in kv.split(",") if s]
    full = run_rows(rows, 1, sets=sets, prefix="r1_", full=True)
    out = [f and f["outcome"] for f in full]
    ends = {}
    for f in full:
        k = "cleared" if f and f["outcome"] == "clear" else ("fireball" if f and f.get("cause") == "fireball" else "timer / other")
        ends[k] = ends.get(k, 0) + 1
    n = sum(1 for o in out if o == "clear")
    per = {b: sum(1 for r, o in zip(rows, out) if o == "clear" and next(g["frames"] for g in deaths if g["id"] == r[0]) - r[1] == b) for b in backs}
    print(f"{name:28s} cleared {n} of {len(rows)} ({100*n/len(rows):.1f}%)  by takeover: " + ", ".join(f"{b // 60} s before: {per[b]}" for b in backs) + f"  | how they ended: {ends}", flush=True)
