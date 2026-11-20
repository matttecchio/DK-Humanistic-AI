#!/usr/bin/env python3
"""danger_rivets.py LOGRUN: the learnt danger table for the rivet board (Matt, 2026-11-17: "go ahead with all 4"). From a FIRELOG run
(runs/LOGRUN_fire, every 4 frames: Mario, each fireball, the rivets in) and its games: for each logged moment and each fireball, the
situation (Mario on a girder or a ladder; the fireball on his girder / 1-2 girders above or below / on a ladder, by its height
relative to him in 8 px; its x relative to him in 8 px, clamped to +-64; heading towards him, away, or still; a pulled rivet's gap
between them on the same girder) and whether that fireball killed him within 90 frames (the fireball nearest him at the death).
Writes lua/danger_rivets.lua: {[key] = rate} with at least 30 cases each."""
import collections, glob, json, os, sys
H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
run = sys.argv[1]
FY = [240, 200, 160, 120, 80]
RIVC = {(2, 0): 75.5, (2, 1): 179.5, (3, 0): 75.5, (3, 1): 179.5, (4, 0): 75.5, (4, 1): 179.5, (5, 0): 75.5, (5, 1): 179.5}
ORDER = [(2, 0), (2, 1), (3, 0), (3, 1), (4, 0), (4, 1), (5, 0), (5, 1)]
games = {(x := json.loads(l))["id"]: x for p in glob.glob(f"{H}/runs/{run}/games_*.jsonl") for l in open(p)}
def gir(y):
    for i, g in enumerate(FY):
        if abs(y - g) <= 3: return i + 1
    return 0
def key(mx, my, fx, fy, head, rv):
    mg = gir(my); fg = gir(fy)
    mm = f"g{mg}" if mg else "L"
    if fg and mg:
        rel = f"G{fg - mg}"
    else:
        rel = "Y%d" % max(-8, min(8, round((fy - my) / 8)))
    dx = max(-8, min(8, round((fx - mx) / 8)))
    wall = 0
    if fg and mg and fg == mg:
        for j, (g, s) in enumerate(ORDER):
            if g == mg and rv[j] == "0" and (mx < RIVC[(g, s)]) != (fx < RIVC[(g, s)]): wall = 1
    return f"{mm}|{rel}|{dx}|{head}|{wall}"
rows = collections.defaultdict(list)
for p in glob.glob(f"{H}/runs/{run}_fire/*.txt"):
    for l in open(p):
        parts = l.rstrip("\n").split("|"); h = list(map(int, parts[0].split()))
        fires = {int(q.split()[0]): tuple(map(int, q.split()[1:])) for q in parts[2:]}
        rows[h[0]].append((h[1], h[2], h[3], parts[1], fires))
n = collections.Counter(); k_ = collections.Counter()
for gid, rs in rows.items():
    g = games.get(gid)
    if not g: continue
    rs.sort()
    died = g["outcome"] != "clear" and g.get("cause") == "fireball"
    killer = None
    if died:
        last = [r for r in rs if r[0] <= g["frames"]]
        if last:
            f, mx, my, rv, fires = last[-1]
            if fires: killer = min(fires, key=lambda k: abs(fires[k][0] - mx) + abs(fires[k][1] - my))
    prev = {}
    for f, mx, my, rv, fires in rs:
        for k, (fx, fy) in fires.items():
            p0 = prev.get(k)
            if p0 and abs(p0[0] - fx) < 10 and abs(p0[1] - fy) < 10:
                d0 = abs(p0[0] - mx) + abs(p0[1] - my); d1 = abs(fx - mx) + abs(fy - my)
                head = "T" if d1 < d0 - 0.5 else ("A" if d1 > d0 + 0.5 else "S")
            else: head = "S"
            kk = key(mx, my, fx, fy, head, rv)
            n[kk] += 1
            if died and k == killer and 0 <= g["frames"] - f <= 90: k_[kk] += 1
        prev = fires
table = {kk: k_[kk] / n[kk] for kk in n if n[kk] >= 30}
tot = sum(n.values()); print(f"{len(rows)} games, {tot} fireball-moments, {len(n)} situations, {len(table)} with 30+ cases; killing moments {sum(k_.values())}")
top = sorted(table.items(), key=lambda kv: -kv[1])[:12]
for kk, v in top: print(f"  {kk:22s} {v:.3f}  ({n[kk]} cases)")
with open(f"{H}/lua/danger_rivets.lua", "w") as o:
    o.write("-- learnt danger table for the rivet board (tools/danger_rivets.py %s): situation -> share where that fireball killed him within 90 frames\nreturn {\n" % run)
    for kk, v in sorted(table.items()):
        if v > 0: o.write(f'  ["{kk}"] = {v:.4f},\n')
    o.write("}\n")
print("wrote lua/danger_rivets.lua")
