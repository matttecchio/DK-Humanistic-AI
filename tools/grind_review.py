#!/usr/bin/env python3
"""grind_review.py BATCH SPEC [--seeds 8] [--back 120] [--step 4]: try Matt's fix for each reviewed death in its own game.
SPEC lines: "ID | note | move; move; ..." (moves as "a w j1 j2 h": a 0 stand / 1 left / 2 right for w frames, then a jump j1
0 straight / 1 left / 2 right, j2 a second jump straight after landing, h the stick held in the air; "nil" for none). Every
move is tried at every `step` frames from `back` frames before the death, `seeds` times each with its own human timing, then he
plays on. Prints, per death, the best moments and moves (how many of the tries cleared), and makes the website show it."""
import argparse, collections, json, os, subprocess, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from scenario_test import run_rows, H
import stats


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("batch"); ap.add_argument("spec")
    ap.add_argument("--seeds", type=int, default=8); ap.add_argument("--back", type=int, default=120)
    ap.add_argument("--step", type=int, default=4); ap.add_argument("--level", type=int, default=5)
    a = ap.parse_args()
    games = {g["id"]: g for g in stats.load(a.batch, inputs=True)}
    spec = []
    for l in open(a.spec):
        if not l.strip() or l.startswith("#"): continue
        gid, note, moves = (x.strip() for x in l.split("|"))
        spec.append((int(gid), note, [m.strip() for m in moves.split(";") if m.strip()]))
    grid = stats.grid_dir(); os.makedirs(grid, exist_ok=True); os.environ["SHOW_GRID"] = grid
    subprocess.run([sys.executable, f"{H}/tools/say.py", f"Grinding Matt's fixes for {len(spec)} reviewed deaths: each fix tried at every moment from 2 seconds before, {a.seeds} times"])
    rows = []
    for gid, note, moves in spec:
        g = games[gid]; d = g["frames"]
        for s in range(d - a.back, d - 7, a.step):
            for m in [""] + moves:
                for t in range(a.seeds):
                    rows.append((gid, s, t, g["inp"], m))
    res = run_rows(rows, a.level, sets=["cases=nil"])
    won = collections.defaultdict(lambda: [0, 0])
    for r, o in zip(rows, res):
        won[(r[0], r[1], r[4])][1] += 1; won[(r[0], r[1], r[4])][0] += o == "clear"
    json.dump({f"{k[0]} {k[1]} {k[2]}": v for k, v in won.items()}, open(a.spec + ".json", "w"))
    out = open(a.spec + ".out", "w")
    for gid, note, moves in spec:
        d = games[gid]["frames"]
        # the moments that count: his own play from there mostly still dies (a takeover reshuffles the game's luck, so
        # earlier on he usually lives anyway); there, which of Matt's moves live
        lines = []
        for s_ in range(d - a.back, d - 7, a.step):
            bw, bn = won.get((gid, s_, ""), [0, 0])
            if not bn or bw / bn > 0.25: continue
            ok = sorted(((won[(gid, s_, m)][0], m) for m in moves if (gid, s_, m) in won), reverse=True)
            lines.append(f"    {d - s_} frames before: his own {bw}/{bn}; " + ", ".join(f"{m} {w}/{won[(gid, s_, m)][1]}" for w, m in ok[:3]))
        line = f"{gid} ({note}): " + (f"{len(lines)} moments where his own play mostly dies" if lines else "his own play mostly lives from every moment tried")
        print(line); print(line, file=out)
        for l in lines[:6]:
            print(l); print(l, file=out)

if __name__ == "__main__":
    main()
