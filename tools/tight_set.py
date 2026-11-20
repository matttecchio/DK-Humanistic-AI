#!/usr/bin/env python3
"""tight_set.py build | eval [--set k=v ...] (2026-11-14, from the oracle review): a test set of tight ordinary moments, not just
deaths. `build`: from fl01 (10,000 5-1 games logged every 4 frames with his planner's best score, FEATLOG), up to N moments where
the score was below 0 or there was no safe plan, on a girder (not jumping, not on a ladder), at most one per game per 120 frames,
from cleared and lost games alike; saved to runs/fl01/tight.json. `eval`: from each, he plays on with new dice (DICE: the board as
it was, 0x6018 reset), K times; prints how many cleared. A change is judged on hundreds of tight spots, most of which he normally
survives, instead of on the deaths alone."""
import argparse, glob, json, os, random, shutil, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import stats
from scenario_test import run_rows, H

B = "fl01"


def build(a):
    games = {json.loads(l)["id"]: json.loads(l) for p in glob.glob(f"{H}/runs/{B}/games_*.jsonl") for l in open(p)}
    cand = []
    for p in glob.glob(f"{H}/runs/{B}_feat/*.txt"):
        last = {}
        for l in open(p):
            h = l.split("|")[0].split()
            gid, f, x, y, lad, jmp, ham, sc = int(h[0]), int(h[1]), int(h[2]), int(h[3]), int(h[4]), int(h[5]), int(h[6]), h[7]
            if sc == "x" or lad or jmp or ham or int(sc) >= 0 or f < 200 or y < 100 or y > 225: continue
            g = games.get(gid)
            if not g or f > g["frames"] - 10 or f - last.get(gid, -999) < 120: continue
            last[gid] = f; cand.append((gid, f))
    random.Random(1).shuffle(cand)
    cand = cand[:a.n]
    died = sum(1 for gid, f in cand if games[gid]["outcome"] == "died")
    json.dump(cand, open(f"{H}/runs/{B}/tight.json", "w"))
    print(f"{len(cand)} tight moments ({died} from games he lost) -> runs/{B}/tight.json")


def evaluate(a):
    os.environ["DICE"] = "1"; os.environ.pop("SEARCH", None)
    stats.use_starts(B)
    stats.ensure_ram(); grid = stats.grid_dir(); shutil.rmtree(grid, ignore_errors=True); os.makedirs(grid, exist_ok=True)
    os.environ["SHOW_GRID"] = grid   # on the website's live boards (Matt: viewers watch the tests)
    games = {g["id"]: g for g in stats.load(B, inputs=True)}
    cand = json.load(open(f"{H}/runs/{B}/tight.json"))
    rows = [(gid, f, k, games[gid]["inp"]) for gid, f in cand for k in range(300, 300 + a.k)]
    out = run_rows(rows, 5, sets=tuple(a.set))
    n = sum(o == "clear" for o in out)
    print(f"{' '.join(a.set) or 'as now'}: {n} of {len(out)} cleared ({100 * n / len(out):.2f}%)", flush=True)
    if a.save:
        json.dump([[r[0], r[1], r[2], o] for r, o in zip(rows, out)], open(a.save, "w"))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("step", choices=["build", "eval"])
    ap.add_argument("--n", type=int, default=1500)
    ap.add_argument("--k", type=int, default=4)
    ap.add_argument("--set", action="append", default=[])
    ap.add_argument("--save")
    a = ap.parse_args()
    {"build": build, "eval": evaluate}[a.step](a)


if __name__ == "__main__":
    main()
