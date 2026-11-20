#!/usr/bin/env python3
"""setup_moves.py BATCH NAME --level N [--seeds 3] [--offsets 0]: which move wins most often across every instance of a setup
(Matt: one bespoke solution for a recurring scenario, from many games, not one).
Instances are the "seen NAME@frame:x" entries a `detect = true` setup logged in BATCH's games. At each instance (plus each
offset in frames), he takes over and makes each move (or none), then plays on to the end of the board, `seeds` times each with
its own human timing. Prints, per move, how often he cleared, against making no move."""
import argparse, collections, glob, json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from scenario_test import run_rows, H
from strict_solve import MOVES, ms


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("batch"); ap.add_argument("name")
    ap.add_argument("--level", type=int, required=True)
    ap.add_argument("--seeds", type=int, default=3)
    ap.add_argument("--offsets", default="0")
    ap.add_argument("--set", action="append", default=[])
    ap.add_argument("--ladder", action="store_true", help="on a ladder: climb / climb steering left or right / stop and steer / back down")
    a = ap.parse_args()
    # on the website's live boards, like every test (Matt: viewers watch them), with a status line
    import stats, shutil, subprocess
    stats.ensure_ram(); grid = stats.grid_dir()
    shutil.rmtree(grid, ignore_errors=True); os.makedirs(grid, exist_ok=True)
    os.environ["SHOW_GRID"] = grid
    say = lambda t: subprocess.run([sys.executable, f"{H}/tools/say.py", t])
    games = {json.loads(l)["id"]: json.loads(l) for p in glob.glob(f"{H}/runs/{a.batch}/games_*.jsonl") for l in open(p)}
    inst = []
    for gid, g in games.items():
        for e in (g.get("rules") or "").split(";"):
            if e.startswith(f"seen {a.name}@"):
                inst.append((gid, int(e.split("@")[1].split(":")[0])))
    moves = [""] + [ms(m) for m in MOVES] + ["0 20 nil nil nil", "0 40 nil nil nil"]
    if a.ladder:   # stick masks: 4 up, 5 up+left, 6 up+right, 8 down, 9 down+left, 10 down+right, 1 / 2 stop and steer, 0 stop
        moves = [""] + [f"{m} {w} nil nil nil" for m in (4, 5, 6, 8, 9, 10, 1, 2, 0) for w in (10, 20, 40)]
    offs = [int(x) for x in a.offsets.split(",")]
    # 1. no move at every instance: which ones matter (no move sometimes dies)?
    rows0 = [(gid, f + off, t, games[gid]["inp"], "") for gid, f in inst for off in offs for t in range(a.seeds)]
    say(f"Trying the experts' spot {a.name}: first, every time it came up ({len(inst)}) with no move, to find the moments that matter")
    res0 = run_rows(rows0, a.level, sets=a.set)
    dies = collections.Counter(); seen0 = collections.Counter()
    for r, o in zip(rows0, res0):
        seen0[(r[0], r[1])] += 1; dies[(r[0], r[1])] += o != "clear"
    hardk = [k for k in seen0 if dies[k] > 0]
    import random
    easyk = random.Random(1).sample([k for k in seen0 if dies[k] == 0], min(150, sum(1 for k in seen0 if dies[k] == 0)))
    print(f"{len(inst)} instances of {a.name}: no move dies at least once in {len(hardk)} of {len(seen0)} (instance, offset) moments", flush=True)
    # 2. every move where it matters, and on a sample of the rest to check it doesn't break them
    # fresh human timing (seeds 10+) so "no move" here isn't the very tries that picked these moments
    rows = [(gid, f, t, games[gid]["inp"], m) for gid, f in hardk + easyk for m in moves for t in range(10, 10 + a.seeds)]
    print(f"{len(moves)} moves, {len(rows)} tries", flush=True)
    say(f"Trying the experts' spot {a.name}: {len(moves)} moves at {len(hardk)} moments where doing nothing sometimes dies, and at {len(easyk)} where it doesn't")
    res = run_rows(rows, a.level, sets=a.set)
    won = collections.defaultdict(lambda: [0, 0])
    per = collections.defaultdict(lambda: collections.defaultdict(lambda: [0, 0]))
    for r, o in zip(rows, res):
        won[r[4]][1] += 1; won[r[4]][0] += o == "clear"
        per[(r[0], r[1])][r[4]][1] += 1; per[(r[0], r[1])][r[4]][0] += o == "clear"
    base = won[""][0] / max(won[""][1], 1)
    # the instances where making no move often dies are the ones that matter
    hard = [k for k in per if k in set(hardk)]
    hw = collections.defaultdict(lambda: [0, 0])
    for k in hard:
        for m, (w, n) in per[k].items():
            hw[m][0] += w; hw[m][1] += n
    ew = collections.defaultdict(lambda: [0, 0])
    for k in easyk:
        for m, (w, n) in per[k].items():
            ew[m][0] += w; ew[m][1] += n
    print(f"where no move sometimes dies ({len(hardk)} moments): no move {100 * hw[''][0] / max(hw[''][1], 1):.1f}%; "
          f"sample where it always lives ({len(easyk)}): no move {100 * ew[''][0] / max(ew[''][1], 1):.1f}%")
    for m, (w, n) in sorted(hw.items(), key=lambda kv: -kv[1][0] / max(kv[1][1], 1))[:12]:
        e = ew[m]
        print(f"  {m or 'no move':24s} {100 * w / n:5.1f}% where it matters   {100 * e[0] / max(e[1], 1):5.1f}% where no move always lives")
    json.dump({"hard": {m: v for m, v in hw.items()}, "easy": {m: v for m, v in ew.items()}, "moments": len(hardk), "instances": len(inst), "all_moments": len(seen0)},
              open(f"{H}/runs/{a.batch}/setup_{a.name.replace(' ', '_')}.json", "w"))


if __name__ == "__main__":
    main()
