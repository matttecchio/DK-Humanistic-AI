#!/usr/bin/env python3
"""rivet_learn.py BATCH --n 1500 [--trials 2] [--seed 1]: option 2 (Matt, 2026-11-20): learn the best choice from replays of ordinary
moments, not only deaths. Picks N random moments on the right half (after 3R) from BATCH's games (cleared and not), and from each
replays 6 choices (his own play; left / right / still for 30 frames; up / down for 40), then he plays on; TRIALS times each (trial 0
the game's dice, later ones new dice he can't know). Records the board at each moment (Mario, each fireball with its heading, the
rivets gone). runs/BATCH/learn/data.json: [{"id", "f", "take", "res": {choice: [outcomes]}}]."""
import argparse, json, os, random, shutil, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import stats
from scenario_test import run_rows, H
L, R, U, D = 1, 2, 4, 8
CH = {"own": None, "left": (L, 30), "right": (R, 30), "still": (0, 30), "up": (U, 40), "down": (D, 40)}
ap = argparse.ArgumentParser(); ap.add_argument("batch"); ap.add_argument("--n", type=int, default=1500)
ap.add_argument("--trials", type=int, default=2); ap.add_argument("--seed", type=int, default=1)
a = ap.parse_args()
stats.use_starts(a.batch)
stats.ensure_ram(); grid = stats.grid_dir(); shutil.rmtree(grid, ignore_errors=True); os.makedirs(grid, exist_ok=True); os.environ["SHOW_GRID"] = grid
os.environ["DICE"] = "1"
out = f"{H}/runs/{a.batch}/learn"; os.makedirs(out, exist_ok=True)
rng = random.Random(a.seed)
games = [g for g in stats.load(a.batch, inputs=True)]
rng.shuffle(games)
moments = []
for g in games:
    pulled = dict(e.split("@") for e in (g.get("pulled") or "").split())
    if "3R" not in pulled: continue
    f0 = int(pulled["3R"]); f1 = g["frames"] - 30
    if f1 - f0 < 60: continue
    moments.append((g, rng.randrange(f0 + 20, f1)))
    if len(moments) >= a.n: break
rows, keys = [], []
for mi, (g, f) in enumerate(moments):
    for name, ch in CH.items():
        for t in range(a.trials):
            rows.append((g["id"], f, t, g["inp"] + (f" R:{ch[0]}:{ch[1]}:-" if ch else ""))); keys.append((mi, name, t))
print(f"{len(moments)} moments, {len(rows)} replays", flush=True)
data = [{"id": g["id"], "f": f, "take": None, "res": {}} for g, f in moments]
CHK = 3000
for i in range(0, len(rows), CHK):
    part = run_rows(rows[i:i + CHK], 1, prefix="r1_", full=True)
    for (mi, name, t), o in zip(keys[i:i + CHK], part):
        d = data[mi]
        d["res"].setdefault(name, []).append(o["outcome"] if o else None)
        if name == "own" and t == 0 and o: d["take"] = o.get("take")
    json.dump(data, open(f"{out}/data.json", "w"))
    print(f"{min(i + CHK, len(rows))} of {len(rows)} done", flush=True)
