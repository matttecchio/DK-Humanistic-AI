#!/usr/bin/env python3
"""deep_solve.py OUT.lua BATCH --level N [--ids ...] [--back 480] [--from 60]: finds, for each death, a move that heads it off,
going back as far as --back frames, then makes sure it isn't a fluke.
Search: from each moment (every 24 frames, standing or walking on a girder), each move once: a tap or a walk either way
(steering barrels at ladders), a jump each way (holding each way), then he plays on himself to the end of the board.
Confirm: the latest few moves that cleared are played 10 times from 6 frames early, on time and 6 frames late, each with
its own human timing; one is kept if it clears 80%+ of those. Kept moves are written as cases (as solve.py's)."""
import argparse, collections, glob, json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from scenario_test import run_rows, H
from solve import floor, WX, UP, DOWN

SEEN = 9
MOVES = [(a, w, None, None, None) for a in (1, 2) for w in (4, 10, 20)] + \
        [(a, w, j1, None, h) for a, w in ((0, 0), (0, 8), (1, 8), (2, 8), (1, 16), (2, 16)) for j1 in (0, 1, 2) for h in (0, 1, 2)]


def mv_str(m):
    return " ".join("nil" if v is None else str(v) for v in m)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("out"); ap.add_argument("batch")
    ap.add_argument("--level", type=int, required=True)
    ap.add_argument("--ids"); ap.add_argument("--frm", type=int, default=20)
    ap.add_argument("--keep", type=float, default=0.8)
    ap.add_argument("--margin", type=float, default=0.3, help="how much better than no move it must clear")
    a = ap.parse_args()
    games = {json.loads(l)["id"]: json.loads(l) for p in glob.glob(f"{H}/runs/{a.batch}/games_*.jsonl") for l in open(p)}
    ids = [int(x) for x in a.ids.split(",")] if a.ids else [i for i, g in games.items() if g["outcome"] == "died" and g["cause"] != "fireball"]
    traces = {}
    for i in ids:
        tp = f"{H}/runs/{a.batch}/autopsy/{i}.trace"
        if os.path.exists(tp):
            rows = {}
            for l in open(tp):
                parts = l.rstrip("\n").split("|"); hd = parts[0].split()
                rows[int(hd[1])] = (hd, parts[1:])
            traces[i] = rows
    ids = [i for i in ids if i in traces]
    # where it turns: with no move, from how far back does he still usually get through? (going back until he does)
    BACKS = [30, 45, 60, 75, 90, 120, 150, 180, 240, 300, 360, 480, 600, 720, 900]
    brows = [(i, games[i]["frames"] - b, t, games[i]["inp"]) for i in ids for b in BACKS if games[i]["frames"] - b > 40 for t in range(6)]
    bres = run_rows(brows, a.level)
    base = collections.defaultdict(lambda: [0, 0])
    for r, o in zip(brows, bres):
        base[(r[0], games[r[0]]["frames"] - r[1])][1] += 1; base[(r[0], games[r[0]]["frames"] - r[1])][0] += o == "clear"
    window = {}
    for i in ids:
        ok_b = next((b for b in BACKS if base[(i, b)][1] and base[(i, b)][0] >= 0.7 * base[(i, b)][1]), None)
        if ok_b:
            window[i] = ok_b
        print(f"  {i}: " + " ".join(f"{b}:{base[(i, b)][0]}/{base[(i, b)][1]}" for b in BACKS if base[(i, b)][1]) + f"  -> still fine from {ok_b} back" if ok_b else f"  {i}: doomed as far back as {BACKS[-1]}", flush=True)
    # search: from where it's still fine up to 20 frames before the death
    rows = []
    for i in ids:
        if i not in window:
            continue
        g, tr = games[i], traces[i]
        for s in range(g["frames"] - window[i], g["frames"] - a.frm + 1, 12):
            hd = tr.get(s - SEEN, (None,))[0]
            if s < 40 or not hd or hd[4] != "0" or hd[5] != "0":
                continue
            for m in MOVES:
                rows.append((i, s, 0, g["inp"], mv_str(m)))
    print(f"search: {len(ids)} deaths, {len(rows)} tries", flush=True)
    res = run_rows(rows, a.level)
    won = collections.defaultdict(list)
    for r, o in zip(rows, res):
        if o == "clear":
            won[r[0]].append((r[1], r[4]))
    # confirm: the latest 3 per death
    rows2, keys = [], []
    for i, ws in won.items():
        # the moves that worked from several neighbouring moments are the least likely to be luck; then the latest
        wins = set(ws)
        support = lambda s, m: sum((s + d, m) in wins for d in (-24, -12, 12, 24))
        for s, m in sorted(ws, key=lambda sm: (support(*sm), sm[0]), reverse=True)[:6]:
            for off in (-6, 0, 6):
                for t in range(1, 11):
                    rows2.append((i, s + off, t, games[i]["inp"], m)); keys.append((i, s, m))
                    rows2.append((i, s + off, t, games[i]["inp"], "")); keys.append((i, s, None))   # the same moment with no move: what he does anyway
    # (rows2 is twice the size: moves and no-move baselines)
    print(f"confirm: {len(won)} deaths with a move that cleared once, {len(rows2)} tries", flush=True)
    res2 = run_rows(rows2, a.level)
    score = collections.defaultdict(lambda: [0, 0])
    for k, o in zip(keys, res2):
        score[k][1] += 1; score[k][0] += o == "clear"
    lines, kept = [], {}
    for (i, s, m), (w, n) in sorted(score.items(), key=lambda kv: (kv[0][0], -kv[0][1])):
        if m is None:
            continue
        bw, bn = score[(i, s, None)]
        if i in kept or w < a.keep * n or w / n < bw / max(bn, 1) + a.margin:   # must clearly beat playing on as he would
            continue
        hd, objs = traces[i][s - SEEN]
        x, y, ham = int(hd[2]), int(hd[3]), int(hd[6])
        bs = []
        for q in objs:
            if q.startswith("B"):
                _, bx, by, bd, bc = q.split()
                dx, dy = int(bx) - x, int(by) - y
                if abs(dx) <= WX and -UP <= dy <= DOWN:
                    bs.append((dx, dy, {"2": 2, "4": 4}.get(bd, 0), 1 if bc != "0" else 0))
        if not bs:
            continue   # nothing near him to recognise the moment by
        pa, pw, pj1, pj2, ph = m.split()
        kept[i] = (s, m, w, n, bw, bn)
        lines.append(f"  {{src = {i}, fl = {floor(y)}, x = {x}, ham = {1 if ham else 0}, b = {{" + ", ".join(f"{{{dx}, {dy}, {d}, {c}}}" for dx, dy, d, c in sorted(bs))
                     + f"}}, plan = {{a = {pa}, w = {pw}, j1 = {pj1}, j2 = {pj2}, h = {ph}}}, ok = {w / n:.2f}, early = {games[i]['frames'] - s}}},")
    open(a.out, "w").write(f"-- remembered situations (tools/deep_solve.py {a.batch}): each move cleared {a.keep:.0%}+ of 30 tries\nreturn {{\n" + "\n".join(lines) + "\n}\n")
    print(f"{len(kept)} of {len(ids)} deaths solved (kept moves cleared {a.keep:.0%}+ of 30 tries) -> {a.out}")
    for i in ids:
        if i in kept:
            s, m, w, n, bw, bn = kept[i]
            print(f"  {i}: {games[i]['frames'] - s} frames before, move {m}: {w}/{n} (no move {bw}/{bn})")
        else:
            near = sorted(((w / n, s, m, w, n) for (j, s, m), (w, n) in score.items() if j == i and m), reverse=True)[:2]
            print(f"  {i}: no solution yet; closest: " + "; ".join(f"{games[i]['frames'] - s} before, {m}: {w}/{n} (no move {score[(i, s, None)][0]}/{score[(i, s, None)][1]})" for _, s, m, w, n in near))


if __name__ == "__main__":
    main()
