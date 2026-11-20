#!/usr/bin/env python3
"""rivet_review_states.py BATCH: for the review's moments with a real answer (his own play died every trial, another choice cleared
every trial), replays each once to the takeover and records what the board looked like there (Mario, each fireball with its heading
as he'd seen it, the rivets gone, the hammer). runs/BATCH/rivet_review/states.json: {"id back": {"take": ..., "answers": [...]}}"""
import collections, json, os, shutil, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import stats
from scenario_test import run_rows, H
batch = sys.argv[1]
stats.use_starts(batch)
stats.ensure_ram(); grid = stats.grid_dir(); shutil.rmtree(grid, ignore_errors=True); os.makedirs(grid, exist_ok=True); os.environ["SHOW_GRID"] = grid
res = json.load(open(f"{H}/runs/{batch}/rivet_review/results.json"))
by = collections.defaultdict(dict)
for k, v in res.items():
    gid, b, c = k.split(); by[(int(gid), int(b))][c] = v
games = {g["id"]: g for g in stats.load(batch, inputs=True)}
moments = []
for (gid, b), r in by.items():
    own = r.get("own") or []
    if not own or any(o == "clear" for o in own): continue
    ok = [c for c, v in r.items() if c != "own" and v and all(o == "clear" for o in v)]
    if ok: moments.append((gid, b, ok))
rows = [(gid, games[gid]["frames"] - b, 0, games[gid]["inp"]) for gid, b, ok in moments]
out = run_rows(rows, 1, prefix="r1_", full=True)
states = {f"{gid} {b}": {"take": o.get("take") if o else None, "answers": ok, "outcome": o and o.get("outcome")} for (gid, b, ok), o in zip(moments, out)}
json.dump(states, open(f"{H}/runs/{batch}/rivet_review/states.json", "w"), indent=0)
print(len(states), "moments recorded")
