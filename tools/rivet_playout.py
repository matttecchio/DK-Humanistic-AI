#!/usr/bin/env python3
"""rivet_playout.py BATCH ID[,ID...] [--span 720] [--every 60]: plays out a death (Matt, 2026-11-16: "play this one out and learn"):
from every EVERY frames over the last SPAN frames before it, each two-step sequence of moves (left, right, up, down, jump left, jump
right, still; each step 20 or 45 frames; a jump is pressed then held off while in the air), then he plays on himself. Prints, for
each death, the moments and sequences that clear. Results: runs/BATCH/playout_ID.json"""
import argparse, collections, itertools, json, os, shutil, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import stats
from scenario_test import run_rows, H
L, R, U, D, J = 1, 2, 4, 8, 16
MOVES = {"left": L, "right": R, "up": U, "down": D, "jump left": J | L, "jump right": J | R, "still": 0}
ap = argparse.ArgumentParser(); ap.add_argument("batch"); ap.add_argument("ids"); ap.add_argument("--span", type=int, default=720); ap.add_argument("--every", type=int, default=60)
a = ap.parse_args()
stats.use_starts(a.batch)
stats.ensure_ram(); grid = stats.grid_dir(); shutil.rmtree(grid, ignore_errors=True); os.makedirs(grid, exist_ok=True); os.environ["SHOW_GRID"] = grid
games = {g["id"]: g for g in stats.load(a.batch, inputs=True)}
for gid in map(int, a.ids.split(",")):
    g = games[gid]
    rows, keys = [], []
    for back in range(a.every, a.span + 1, a.every):
        take = g["frames"] - back
        rows.append((gid, take, 0, g["inp"])); keys.append((back, "his own play"))
        for (n1, m1), (n2, m2) in itertools.product(MOVES.items(), repeat=2):
            for d1 in (20, 45):
                l1 = 46 if m1 & J else d1; l2 = 46 if m2 & J else 30
                rows.append((gid, take, 0, g["inp"] + f" S:{m1}:{l1},{m2}:{l2}:x")); keys.append((back, f"{n1} {l1 if not m1 & J else ''}, then {n2}".replace("  ", " ")))
    out = run_rows(rows, 1, prefix="r1_")
    ok = collections.defaultdict(list)
    for (back, name), o in zip(keys, out):
        if o == "clear": ok[back].append(name)
    json.dump({str(k): v for k, v in ok.items()}, open(f"{H}/runs/{a.batch}/playout_{gid}.json", "w"), indent=0)
    print(f"game {gid} ({len(rows)} tries):")
    for back in sorted(ok): print(f"  {back / 60:.1f} s before the death: {len(ok[back])} clear: {', '.join(sorted(set(ok[back]))[:8])}{' ...' if len(set(ok[back])) > 8 else ''}")
    if not ok: print("  nothing clears")
