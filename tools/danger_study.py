#!/usr/bin/env python3
"""danger_study.py BATCH: can a danger table learned from his own games see barrel deaths coming earlier than his planner? (Matt,
2026-11-13: idea #3, any gain is good.) Uses BATCH's FEATLOG rows (runs/BATCH_feat): every 4 frames, Mario, the barrels, his planner's
best score. Label: a barrel death within the next 120 frames. Each moment is described simply (girder, x in 16 px steps, on the
ground / jumping / ladder, the two nearest barrels on his girder rolling at him in 12 px steps, a barrel above heading for a ladder
within 24 px of him, a wild barrel near); the table is the death rate per description, learned on the even games and tested on the
odd ones against his planner's own score. Prints how well each ranks the dangerous moments (AUC) and, for deaths, how far ahead each
first flags them."""
import collections, glob, json, os, sys
import numpy as np

H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
b = sys.argv[1]
fl = lambda y: 1 if y >= 220 else 2 if y >= 190 else 3 if y >= 155 else 4 if y >= 120 else 5 if y >= 101 else 6
lv = lambda y: 6 if y < 95 else 5 if y < 125 else 4 if y < 160 else 3 if y < 195 else 2 if y < 225 else 1
DROPS = {6: [106, 202], 5: [52, 92, 188], 4: [82, 130, 202], 3: [52, 116], 2: [99, 203]}
games = {json.loads(l)["id"]: json.loads(l) for p in glob.glob(f"{H}/runs/{b}/games_*.jsonl") for l in open(p)}
death = {g: v["frames"] for g, v in games.items() if v["outcome"] == "died" and "barrel" in v["cause"]}


def describe(x, y, lad, jmp, bs):
    f = fl(y); st = "l" if lad else "j" if jmp else "g"
    at = []
    for bx, by, bd, bc in bs:
        if bc == 0 and lv(by) == f and ((bd == 2 and bx < x) or (bd == 4 and bx > x)):
            at.append(min(abs(bx - x) // 12, 5))
    at = tuple(sorted(at)[:2])
    above = 0
    for bx, by, bd, bc in bs:
        if bc == 0 and lv(by) == f + 1 and bd in (2, 4):
            side = 1 if bd == 2 else -1
            for d in DROPS.get(f + 1, []):
                if 0 <= (d - bx) * side <= 30 and abs(d - x) <= 24: above = 1 if abs(d - x) <= 8 else max(above, 2) if above != 1 else 1
    wild = int(any(bc and abs(bx - x) <= 60 and by < y for bx, by, bd, bc in bs))
    return (f, x // 16, st, at, above, wild)


rows = []   # (game, frame, desc, planner score or None, label)
for p in glob.glob(f"{H}/runs/{b}_feat/*.txt"):
    for l in open(p):
        parts = l.rstrip("\n").split("|"); hd = parts[0].split()
        gid, f, x, y, lad, jmp, ham = (int(v) for v in hd[:7]); sc = hd[7]
        if ham or gid not in games: continue
        bs = [tuple(int(v) for v in q.split()) for q in parts[1:] if q]
        d = death.get(gid); label = 1 if d is not None and 0 < d - f <= 120 else 0
        rows.append((gid, f, describe(x, y, lad, jmp, bs), None if sc == "x" else int(sc), label))
print(f"{len(rows)} moments from {len(games)} games, {sum(r[4] for r in rows)} within 2 s of a barrel death")
train = [r for r in rows if r[0] % 2 == 0]; test = [r for r in rows if r[0] % 2 == 1]
cnt = collections.defaultdict(lambda: [0, 0])
for r in train: cnt[r[2]][0] += r[4]; cnt[r[2]][1] += 1
base = sum(r[4] for r in train) / len(train)
rate = lambda dsc: (cnt[dsc][0] + base * 20) / (cnt[dsc][1] + 20)        # shrunk towards the average for rare descriptions


def auc(scores, labels):
    s = np.array(scores, float); y = np.array(labels)
    order = s.argsort(); ranks = np.empty(len(s)); ranks[order] = np.arange(1, len(s) + 1)
    pos = y == 1; n1 = pos.sum(); n0 = len(y) - n1
    return (ranks[pos].sum() - n1 * (n1 + 1) / 2) / (n1 * n0) if n1 and n0 else float("nan")


tt = [r for r in test if r[3] is not None]
print(f"ranking the moments within 2 s of a death (AUC, 0.5 = no better than chance), {len(tt)} test moments with a planner score:")
print(f"  danger table: {auc([rate(r[2]) for r in tt], [r[4] for r in tt]):.3f}   his planner's score (lower = worse): {auc([-r[3] for r in tt], [r[4] for r in tt]):.3f}")
print(f"  both (table rank + planner rank): {auc(np.argsort(np.argsort([rate(r[2]) for r in tt])) + np.argsort(np.argsort([-r[3] for r in tt])), [r[4] for r in tt]):.3f}")
# how far ahead each first flags a death: the table above its top-5% level, the planner below 0
thr = np.percentile([rate(r[2]) for r in tt], 95)
byg = collections.defaultdict(list)
for r in test: byg[r[0]].append(r)
lead_t, lead_p = [], []
for gid, rs in byg.items():
    d = death.get(gid)
    if d is None: continue
    rs.sort(key=lambda r: r[1])
    def first(flag):
        run = None
        for r in rs:
            if d - r[1] > 240 or r[1] > d: continue
            if flag(r): run = run if run is not None else d - r[1]
            else: run = None
        return run
    lead_t.append(first(lambda r: rate(r[2]) >= thr)); lead_p.append(first(lambda r: r[3] is not None and r[3] < 0))
fmt = lambda v: f"{sum(1 for x in v if x is not None)} of {len(v)} flagged; median {np.median([x for x in v if x is not None]):.0f} frames ahead" if any(x is not None for x in v) else "none"
print(f"barrel deaths in the test games: the table {fmt(lead_t)}; his planner {fmt(lead_p)}")
earlier = sum(1 for a, p in zip(lead_t, lead_p) if a is not None and (p is None or a > p + 20))
print(f"  the table flags it 20+ frames earlier than his planner (or he never does) in {earlier} of {len(lead_t)}")
print("most dangerous descriptions (train):")
for dsc, (dd, n) in sorted(cnt.items(), key=lambda kv: -(kv[1][0] + base * 20) / (kv[1][1] + 20))[:10]:
    print(f"  {dsc}: {dd}/{n} = {100 * dd / n:.1f}%")

# the table for the planner (lua: cases/danger.lua): every description seen 20+ times, rate shrunk towards the average, all games
allc = collections.defaultdict(lambda: [0, 0])
for r in rows: allc[r[2]][0] += r[4]; allc[r[2]][1] += 1
ab = sum(r[4] for r in rows) / len(rows)
with open(f"{H}/cases/danger.lua", "w") as fo:
    fo.write(f"-- danger of a moment: chance of a barrel death within 2 s, by description (tools/danger_study.py {b})\nreturn {{base = {ab:.5f}, t = {{\n")
    for d, (dd, n) in allc.items():
        if n >= 20:
            key = f"{d[0]}|{d[1]}|{d[2]}|{','.join(str(v) for v in d[3])}|{d[4]}|{d[5]}"
            fo.write(f'  ["{key}"] = {(dd + ab * 20) / (n + 20):.5f},\n')
    fo.write("}}\n")
print("table for the planner: cases/danger.lua")
