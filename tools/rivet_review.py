#!/usr/bin/env python3
"""rivet_review.py BATCH [--n 300] [--backs 120,240] [--trials 2]: the computer's own review of rivet deaths (Matt, 2026-11-15:
"you may do all of those"; like his video reviews, for every death). For each death: the recorded game played back to BACK frames
before it, and from there each of a set of choices (his own; hold left / right / up / down / still for half a second; jump left /
right / straight; skip / take the middle hammer), then he plays on as usual. Trial 0 is the game's own dice; later trials set the
random number (0x6018, which no player sees) to something new (DICE), so a choice that clears in every trial is a real answer, not
luck. Results: runs/BATCH/rivet_review/results.json, one entry per (death, back, choice): cleared trials."""
import argparse, collections, json, os, random, shutil, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import stats
from scenario_test import run_rows, H

L, R, U, D, J = 1, 2, 4, 8, 16
CHOICES = {"own": None, "left": (L, 30, "-"), "right": (R, 30, "-"), "up": (U, 40, "-"), "down": (D, 40, "-"), "still": (0, 30, "-"),
           "jump_left": (J | L, 46, "-"), "jump_right": (J | R, 46, "-"), "jump": (J, 46, "-"), "noham": (0, 1, "noham"), "ham": (0, 1, "ham")}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("batch")
    ap.add_argument("--n", type=int, default=300)
    ap.add_argument("--backs", default="120,240")
    ap.add_argument("--trials", type=int, default=2)
    ap.add_argument("--seed", type=int, default=1)
    a = ap.parse_args()
    stats.use_starts(a.batch)
    stats.ensure_ram(); grid = stats.grid_dir()   # on the website's live boards, like every test (Matt: viewers watch them)
    shutil.rmtree(grid, ignore_errors=True); os.makedirs(grid, exist_ok=True)
    os.environ["SHOW_GRID"] = grid
    os.environ["DICE"] = "1"
    out = f"{H}/runs/{a.batch}/rivet_review"; os.makedirs(out, exist_ok=True)
    deaths = [g for g in stats.load(a.batch, inputs=True) if g["outcome"] == "died"]
    random.Random(a.seed).shuffle(deaths)
    deaths = deaths[:a.n]
    backs = [int(b) for b in a.backs.split(",")]
    rows, keys = [], []
    for g in deaths:
        for b in backs:
            if g["frames"] <= b + 5: continue
            for name, ch in CHOICES.items():
                for t in range(a.trials):
                    extra = f"R:{ch[0]}:{ch[1]}:{ch[2]}" if ch else ""
                    rows.append((g["id"], g["frames"] - b, t, g["inp"], None, extra))
                    keys.append((g["id"], b, name, t))
    print(f"{len(deaths)} deaths, {len(rows)} takeovers", flush=True)
    res = {}
    CH = 4000
    for i in range(0, len(rows), CH):
        part = rows[i:i + CH]
        o = run_rows([(r[0], r[1], r[2], r[3] + (" " + r[5] if r[5] else "")) for r in part], 1, prefix="r1_")
        for k, oc in zip(keys[i:i + CH], o):
            res.setdefault(f"{k[0]} {k[1]} {k[2]}", []).append(oc)
        json.dump(res, open(f"{out}/results.json", "w"))
        print(f"{min(i + CH, len(rows))} of {len(rows)} done", flush=True)
    # summary: per death and back, which choices clear every trial
    best = collections.Counter(); own_ok = 0; any_ok = 0; n = 0
    for g in deaths:
        for b in backs:
            r = {c: res.get(f"{g['id']} {b} {c}") for c in CHOICES}
            if not r["own"]: continue
            n += 1
            ok = [c for c, v in r.items() if v and all(x == "clear" for x in v)]
            if "own" in ok: own_ok += 1
            if ok: any_ok += 1
            for c in ok: best[c] += 1
    print(f"{n} moments: a choice clears in every trial at {any_ok} ({own_ok} with his own play, i.e. luck)")
    print("choices that clear in every trial:", best.most_common())


if __name__ == "__main__":
    main()
