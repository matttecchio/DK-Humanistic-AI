#!/usr/bin/env python3
"""expert_match.py BATCH [--trials 6] [--before 60,45,30,20]: what the experts did where he died, tried in his games.
(Matt, 2026-11-10: use top players' recordings to add to what he's learned.) For each of BATCH's traced barrel deaths, at
several moments before it (Mario on a girder), find moments in the expert traces (inps/*.trace, barrel boards from level 5,
without the hammer) with Mario on the same girder within 6 px and the same nearby barrels (his girder and the one above,
within 80 px: same girder, same way of rolling or on a ladder, each within 10 px). What the expert did next (stick, then a
jump which way, holding which way) becomes a move; it's tried from that moment in his game `trials` times against making no
move (scenario takeover, each try with its own human timing). Prints every match and the totals; results in
runs/BATCH/expert_match.txt."""
import argparse, collections, glob, json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from scenario_test import run_rows, H

fl = lambda y: 1 if y >= 220 else 2 if y >= 190 else 3 if y >= 155 else 4 if y >= 120 else 5 if y >= 101 else 6
lv = lambda y: 6 if y < 95 else 5 if y < 125 else 4 if y < 160 else 3 if y < 195 else 2 if y < 225 else 1
REACH, MX, BX = 80, 6, 10


def kind(d):
    return "R" if d == 2 else "L" if d == 4 else "e"


def near(x, y, bs):
    f0 = fl(y); out = []
    for bx, by, bd, bc in bs:
        off = lv(by) - f0
        if bc == 0 and off in (0, 1) and abs(bx - x) <= REACH:
            out.append((off, kind(bd), bx - x))
    return sorted(out)


def load_experts():
    idx = collections.defaultdict(list)          # girder -> [(x, near, future inputs, source)]
    for tp in glob.glob(f"{H}/inps/*.trace"):
        rows, cur = [], None
        for l in open(tp):
            if l[0] in "sbe" and (l.startswith("start") or l.startswith("board") or l.startswith("end")):
                if rows: rows.append(None)
                continue
            p = l.rstrip("\n").split("|"); hd = [int(v) for v in p[0].split()]
            bs = [tuple(int(v) for v in q.split()[1:5]) for q in p[1:] if q[0] == "B"]
            rows.append((hd, bs))
        for i, r in enumerate(rows):
            if r is None: continue
            hd, bs = r
            if hd[4] or hd[5] or hd[6]: continue       # on a ladder, in the air, or holding the hammer
            fut = []
            for k in range(i, min(i + 50, len(rows))):
                if rows[k] is None: break
                fut.append((rows[k][0][8], rows[k][0][5]))
            if len(fut) < 50: continue
            idx[fl(hd[3])].append((hd[2], near(hd[2], hd[3], bs), fut, f"{os.path.basename(tp)}:{hd[1]}"))
    return idx


def similar(a, b):
    if len(a) != len(b): return None
    used, err = set(), 0
    for off, k, dx in a:
        best = None
        for j, (o2, k2, d2) in enumerate(b):
            if j in used or o2 != off or k2 != k or abs(d2 - dx) > BX: continue
            if best is None or abs(d2 - dx) < abs(b[best][2] - dx): best = j
        if best is None: return None
        used.add(best); err += abs(b[best][2] - dx)
    return err


def to_move(fut):
    """The expert's next 50 frames as a move: stick (a, 1 left / 2 right) for w frames, then a jump (j1: 0 straight, 1 left,
    2 right) holding h; or just the stick for w frames. IN0: bit 0 right, bit 1 left, bit 4 jump."""
    stick = lambda v: 2 if v & 1 else 1 if v & 2 else 0
    a = stick(fut[0][0]); w = 0
    for v, jmp in fut:
        if v & 0x10 or jmp: break
        if stick(v) != a: break
        w += 1
    if w < len(fut) and (fut[w][0] & 0x10 or fut[w][1]):
        j1 = stick(fut[w][0]); h = stick(fut[min(w + 8, len(fut) - 1)][0])
        return f"{a} {w} {j1} nil {h}"
    return f"{a} {max(w, 4)} nil nil nil" if a else "0 20 nil nil nil"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("batch"); ap.add_argument("--trials", type=int, default=6)
    ap.add_argument("--before", default="60,45,30,20"); ap.add_argument("--level", type=int, default=5)
    a = ap.parse_args()
    idx = load_experts()
    print(f"expert moments on the ground, by girder: { {k: len(v) for k, v in sorted(idx.items())} }", flush=True)
    games = {json.loads(l)["id"]: json.loads(l) for p in glob.glob(f"{H}/runs/{a.batch}/games_*.jsonl") for l in open(p)}
    tries, info = [], {}
    for tp in glob.glob(f"{H}/runs/{a.batch}/autopsy/*.trace"):
        gid = int(os.path.basename(tp)[:-6]); g = games.get(gid)
        if not g: continue
        T = {}
        for l in open(tp):
            p = l.rstrip("\n").split("|"); hd = p[0].split()
            T[int(hd[1])] = (hd, [tuple(int(v) for v in q.split()[1:5]) for q in p[1:] if q.startswith("B")])
        for back in (int(b) for b in a.before.split(",")):
            s = g["frames"] - back
            if s not in T or T[s][0][4] != "0" or T[s][0][5] != "0": continue
            hd, bs = T[s]; x, y = int(hd[2]), int(hd[3])
            mine = near(x, y, bs)
            if not mine: continue
            cands = []
            for ex, en, fut, src in idx.get(fl(y), []):
                if abs(ex - x) > MX: continue
                e = similar(mine, en)
                if e is not None: cands.append((e + abs(ex - x), src, to_move(fut)))
            if not cands: continue
            cands.sort()
            votes = collections.Counter(m for _, _, m in cands[:10])
            move = votes.most_common(1)[0][0]
            info[(gid, s)] = (back, fl(y), x, mine, len(cands), cands[0][1], move, votes.most_common(3))
            for t in range(a.trials):
                tries.append((gid, s, t, g["inp"], ""))
                tries.append((gid, s, t, g["inp"], move))
            break                                        # the latest moment with a match is the one tried
    print(f"{len(info)} deaths with an expert moment to match; {len(tries)} tries", flush=True)
    res = run_rows(tries, a.level, sets=["cases=nil"])
    won = collections.defaultdict(lambda: [0, 0, 0, 0])
    for r, o in zip(tries, res):
        k = (r[0], r[1]); i = 0 if r[4] == "" else 2
        won[k][i + 1] += 1; won[k][i] += o == "clear"
    out = open(f"{H}/runs/{a.batch}/expert_match.txt", "w")
    tot = [0, 0, 0, 0]
    for k, (back, f0, x, mine, n, src, move, top) in sorted(info.items()):
        w = won[k]
        line = (f"{k[0]} {back} frames before, girder {f0} x={x}, barrels {mine}: {n} expert moments ({src}); "
                f"expert move {move} {top}: no move {w[0]}/{w[1]}, expert {w[2]}/{w[3]}")
        print(line); print(line, file=out)
        for i in range(4): tot[i] += w[i]
    line = f"TOTAL: no move cleared {tot[0]}/{tot[1]}, the experts' move {tot[2]}/{tot[3]}"
    print(line); print(line, file=out)


if __name__ == "__main__":
    main()
