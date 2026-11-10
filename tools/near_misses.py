#!/usr/bin/env python3
"""near_misses.py STRICT_LOG BATCH OUT.lua [min, default 990]: the solutions that came close (Matt: keep a record of those).
From strict_solve's log: for each death that wasn't banked, its best move if it cleared at least `min` of 1000. Written in the
bank's format (via bank.py, view as old as the reaction: SEEN env) but kept apart and not used, plus a readable list OUT.txt."""
import os, re, subprocess, sys

log, batch, out = sys.argv[1], sys.argv[2], sys.argv[3]
lo = int(sys.argv[4]) if len(sys.argv) > 4 else 990
best, banked = {}, set()
for l in open(log):
    m = re.match(r"(\d+): (\d+) frames before, move (.+): (\d+)/(\d+)(\s+BANKED)?", l.strip())
    if not m:
        continue
    gid, w, n = m.group(1), int(m.group(4)), int(m.group(5))
    if m.group(6):
        banked.add(gid)
    if gid not in best or w > best[gid][0]:
        best[gid] = (w, n, m.group(2), m.group(3))
near = {g: v for g, v in best.items() if g not in banked and v[0] >= lo}
txt = out.rsplit(".", 1)[0] + ".txt"
with open(txt, "w") as f:
    for g, (w, n, early, move) in sorted(near.items(), key=lambda kv: -kv[1][0]):
        f.write(f"  {g}: {early} frames before, move {move}: {w}/{n}\n")
subprocess.run([sys.executable, os.path.join(os.path.dirname(os.path.abspath(__file__)), "bank.py"), out, f"{batch}:{txt}"])
print(f"{len(near)} near misses ({lo}+ of 1000, not banked) -> {txt}")
