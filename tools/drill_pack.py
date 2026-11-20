#!/usr/bin/env python3
"""drill_pack.py BATCH N OUT [BEFORE]: a pack of N scenarios for Matt to play (lua/drill.lua): barrel deaths while jumping from
BATCH, one from each of the N commonest spots, starting BEFORE frames (default 210, 3.5 s) before the death. Prints the command."""
import collections, os, random, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import stats
H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
b, n, out = sys.argv[1], int(sys.argv[2]), sys.argv[3]; before = int(sys.argv[4]) if len(sys.argv) > 4 else 210
gs = [g for g in stats.load(b, inputs=True) if g["outcome"] == "died" and "barrel" in g["cause"] and g["doing"].startswith("jumping")]
by = collections.defaultdict(list)
for g in gs: by[(g["floor"], g["x"] // 20)].append(g)
rng = random.Random(3); pick = [rng.choice(v) for k, v in sorted(by.items(), key=lambda kv: -len(kv[1]))[:n]]
with open(out, "w") as f:
    for g in pick:
        f.write(f"{g['id']} {g['start']} {g['frames'] - before} {g['frames']} {g['inp'][:g['frames'] + 5]} girder {g['floor']} x={g['x']}\n")
print(f"{len(pick)} scenarios -> {out}")
