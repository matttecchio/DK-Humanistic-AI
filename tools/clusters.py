#!/usr/bin/env python3
"""clusters.py BATCH [N] [BEFORE]: the recurring setups behind BATCH's barrel deaths (traced with autopsy.py).
For each death, the situation BEFORE frames earlier (Mario standing or walking): his girder and spot, and the two nearest
barrels on his girder or the one above (which girder, where, which way). Deaths are grouped by girder, spot (12 px) and those
barrels (12 px, direction); the N biggest groups are printed as `setups` detector entries (ranges from the members, plus slack)."""
import collections, glob, json, os, sys

H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
b = sys.argv[1]; N = int(sys.argv[2]) if len(sys.argv) > 2 else 6; BEFORE = int(sys.argv[3]) if len(sys.argv) > 3 else 45
fl = lambda y: 1 if y >= 220 else 2 if y >= 190 else 3 if y >= 155 else 4 if y >= 120 else 5 if y >= 101 else 6
lv = lambda y: 6 if y < 95 else 5 if y < 125 else 4 if y < 160 else 3 if y < 195 else 2 if y < 225 else 1
games = {json.loads(l)["id"]: json.loads(l) for p in glob.glob(f"{H}/runs/{b}/games_*.jsonl") for l in open(p)}
groups = collections.defaultdict(list)
for tp in glob.glob(f"{H}/runs/{b}/autopsy/*.trace"):
    gid = int(os.path.basename(tp)[:-6]); g = games.get(gid)
    if not g or "barrel" not in g["cause"]:
        continue
    rows = {}
    for l in open(tp):
        p = l.rstrip("\n").split("|"); hd = p[0].split(); rows[int(hd[1])] = (hd, p[1:])
    for back in range(BEFORE, BEFORE + 30, 3):           # the nearest moment at least BEFORE back with him on a girder
        r = rows.get(g["frames"] - back)
        if r and r[0][4] == "0" and r[0][5] == "0":
            break
    else:
        continue
    hd, objs = r; x, y = int(hd[2]), int(hd[3]); f0 = fl(y)
    bs = []
    for q in objs:
        if q.startswith("B"):
            _, bx, by, bd, bc = q.split(); bx, by = int(bx), int(by)
            off = lv(by) - f0
            if bc == "0" and off in (0, 1) and abs(bx - x) <= 70:
                bs.append((abs(bx - x), off, bx - x, {"2": "R", "4": "L"}.get(bd, "e")))
    bs = sorted(bs)[:2]
    if not bs:
        continue
    key = (f0, x // 12) + tuple((o, dx // 12, d) for _, o, dx, d in bs)
    groups[key].append((x, [(o, dx, d) for _, o, dx, d in bs]))
print(f"{sum(len(v) for v in groups.values())} deaths in {len(groups)} setups; biggest:")
for i, (k, mem) in enumerate(sorted(groups.items(), key=lambda kv: -len(kv[1]))[:N]):
    xs = [m[0] for m in mem]
    needs = []
    for j in range(len(mem[0][1])):
        dxs = [m[1][j][1] for m in mem]
        needs.append(f'{{{mem[0][1][j][0]},{min(dxs) - 4},{max(dxs) + 4},"{mem[0][1][j][2]}"}}')
    print(f'{len(mem)}\t{{{k[0]},{min(xs) - 3},{max(xs) + 3},needs={{{",".join(needs)}}},detect=true,name="s{i + 1}"}}')
