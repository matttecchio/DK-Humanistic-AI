#!/usr/bin/env python3
"""strict_solve.py OUT.lua BATCH --level N [--ids ...] [--react a,b] [--back 180] [--step 12] [--final 1000]: solutions that never fail.
Matt (2026-11-08): play each barrel death through with different options from about 3 seconds before (jumps, steers ...);
when one works, play it back a thousand times; it has to work every single time, then bank it.
For each death: from every `step` frames between `back` and 20 frames before it (standing or walking on a girder), each move
once (taps and walks either way, which steer barrels; jumps each way holding each way, after 0-16 frames standing or walking),
then he plays on to the end of the board. Moves that cleared: 30 more tries (each with its own human timing) - all must clear;
then `final` tries - all must clear. The first that does is banked (Mario's real position, every barrel as he saw it then,
the move). Deaths are done 50 at a time and OUT is rewritten after each lot, so whatever's done is kept."""
import argparse, collections, glob, json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from scenario_test import run_rows, H
from solve import floor

MOVES = [(a, w, None, None, None) for a in (1, 2) for w in (4, 10, 20)] + \
        [(a, w, j1, None, h) for a, w in ((0, 0), (0, 8), (1, 8), (2, 8), (1, 16), (2, 16)) for j1 in (0, 1, 2) for h in (0, 1, 2)]
ms = lambda m: " ".join("nil" if v is None else str(v) for v in m)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("out"); ap.add_argument("batch")
    ap.add_argument("--level", type=int, required=True)
    ap.add_argument("--ids"); ap.add_argument("--react", default="8,9")
    ap.add_argument("--back", type=int, default=180); ap.add_argument("--step", type=int, default=12)
    ap.add_argument("--final", type=int, default=1000); ap.add_argument("--lot", type=int, default=50)
    a = ap.parse_args()
    r0, r1 = (int(x) for x in a.react.split(","))
    seen = r1                                   # how many frames old his view of the barrels is
    sets = [f"react={{{r0},{r1}}}", "cases=nil"]
    games = {json.loads(l)["id"]: json.loads(l) for p in glob.glob(f"{H}/runs/{a.batch}/games_*.jsonl") for l in open(p)}
    ids = [int(x) for x in a.ids.split(",")] if a.ids else [i for i, g in games.items() if g["outcome"] == "died" and "barrel" in g["cause"]]
    banked, log = [], open(a.out + ".log", "a")
    import stats, shutil, subprocess
    stats.ensure_ram(); grid = stats.grid_dir()
    shutil.rmtree(grid, ignore_errors=True); os.makedirs(grid, exist_ok=True)
    os.environ["SHOW_GRID"] = grid
    say = lambda t: subprocess.run([sys.executable, f"{H}/tools/say.py", t])
    for lot in range(0, len(ids), a.lot):
        part = ids[lot:lot + a.lot]
        say(f"Solving barrel deaths: {lot + 1}-{lot + len(part)} of {len(ids)}, trying jumps and steers from up to 3 seconds before each; "
            f"a solution is kept only if it works {a.final} times out of {a.final}. {len(banked)} banked so far")
        traces = {}
        for i in part:
            tp = f"{H}/runs/{a.batch}/autopsy/{i}.trace"
            if not os.path.exists(tp):
                continue
            rows = {}
            for l in open(tp):
                p = l.rstrip("\n").split("|"); hd = p[0].split()
                rows[int(hd[1])] = (hd, p[1:])
            traces[i] = rows
        # 1. every move once from every moment
        rows = []
        for i, tr in traces.items():
            d = games[i]["frames"]
            for s in range(d - a.back, d - 19, a.step):
                hd = tr.get(s, (None,))[0]
                if s > 40 and hd and hd[4] == "0" and hd[5] == "0" and s - seen in tr:
                    rows += [(i, s, 0, games[i]["inp"], ms(m)) for m in MOVES]
        res = run_rows(rows, a.level, sets=sets)
        cand = collections.defaultdict(list)
        for r, o in zip(rows, res):
            if o == "clear":
                cand[r[0]].append((r[1], r[4]))
        # 2. 30 tries each, all must clear (up to 8 candidates per death, latest first)
        rows2, keys = [], []
        for i, cs in cand.items():
            for s, m in sorted(cs, reverse=True)[:8]:
                for t in range(1, 31):
                    rows2.append((i, s, t, games[i]["inp"], m)); keys.append((i, s, m))
        res2 = run_rows(rows2, a.level, sets=sets)
        ok30 = collections.defaultdict(lambda: [0, 0])
        for k, o in zip(keys, res2):
            ok30[k][1] += 1; ok30[k][0] += o == "clear"
        passed = collections.defaultdict(list)
        for (i, s, m), (w, n) in ok30.items():
            if w == n:
                passed[i].append((s, m))
        # 3. `final` tries, all must clear (up to 2 per death)
        rows3, keys3 = [], []
        for i, cs in passed.items():
            for s, m in sorted(cs, reverse=True)[:2]:
                for t in range(100, 100 + a.final):
                    rows3.append((i, s, t, games[i]["inp"], m)); keys3.append((i, s, m))
        res3 = run_rows(rows3, a.level, sets=sets) if rows3 else []
        okf = collections.defaultdict(lambda: [0, 0])
        for k, o in zip(keys3, res3):
            okf[k][1] += 1; okf[k][0] += o == "clear"
        done = set()
        for (i, s, m), (w, n) in sorted(okf.items(), key=lambda kv: -kv[0][1]):
            print(f"{i}: {games[i]['frames'] - s} frames before, move {m}: {w}/{n}" + ("  BANKED" if w == n and i not in done else ""), file=log, flush=True)
            if w != n or i in done:
                continue
            done.add(i)
            hd = traces[i][s][0]
            x, y, ham = int(hd[2]), int(hd[3]), 1 if hd[6] != "0" else 0
            bs = []
            for q in traces[i][s - seen][1]:
                if q.startswith("B"):
                    _, bx, by, bd, bc = q.split()
                    bs.append((int(bx) - x, int(by) - y, {"2": 2, "4": 4}.get(bd, 0), 1 if bc != "0" else 0))
            if not bs:
                continue
            pa, pw, pj1, pj2, ph = m.split()
            banked.append(f"  {{src = {i}, fl = {floor(y)}, x = {x}, ham = {ham}, b = {{" + ", ".join(f"{{{dx}, {dy}, {dd}, {c}}}" for dx, dy, dd, c in sorted(bs))
                          + f"}}, plan = {{a = {pa}, w = {pw}, j1 = {pj1}, j2 = {pj2}, h = {ph}}}, early = {games[i]['frames'] - s}}},")
        open(a.out, "w").write(f"-- solutions that cleared {a.final}/{a.final} (tools/strict_solve.py {a.batch}, reaction {a.react})\nreturn {{\n" + "\n".join(banked) + "\n}\n")
        print(f"lot {lot // a.lot + 1}: {len(part)} deaths, {len(cand)} with a move that cleared once, {len(passed)} passed 30/30, "
              f"{len(done)} passed {a.final}/{a.final}; {len(banked)} banked so far", file=log, flush=True)
    print(f"{len(banked)} of {len(ids)} deaths banked -> {a.out}")


if __name__ == "__main__":
    main()
