#!/usr/bin/env python3
"""rule_report.py BASE NEW: where each rule fired in NEW, and what it did there (Matt: if a rule from his answer lowers the
numbers, it fired too widely or its setup never came up; look at where it fired).
For every rule logged in NEW's games ("rules" field): how many games it fired in, and against the same games in BASE how many
it saved (died there, cleared here) and lost (cleared there, died here); for lost games, the firings and how long after the
last one he died, so the trigger can be narrowed."""
import collections, glob, json, os, sys

H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
load = lambda b: {json.loads(l)["id"]: json.loads(l) for p in glob.glob(f"{H}/runs/{b}/games_*.jsonl") for l in open(p)}
base, new = load(sys.argv[1]), load(sys.argv[2])
show = int(sys.argv[3]) if len(sys.argv) > 3 else 8
by = collections.defaultdict(lambda: {"games": 0, "fires": 0, "saved": [], "lost": [], "same_clear": 0, "same_died": 0})
for gid, g in new.items():
    if gid not in base or not g.get("rules"):
        continue
    fired = collections.defaultdict(list)
    for e in g["rules"].split(";"):
        name, rest = e.split("@")
        fr, x = rest.split(":")
        fired[name].append((int(fr), int(x)))
    b_ok, n_ok = base[gid]["outcome"] == "clear", g["outcome"] == "clear"
    for name, fs in fired.items():
        r = by[name]
        r["games"] += 1; r["fires"] += len(fs)
        if n_ok and not b_ok: r["saved"].append(gid)
        elif b_ok and not n_ok: r["lost"].append((gid, fs, g["frames"], g["cause"], g["x"], g["y"]))
        elif n_ok: r["same_clear"] += 1
        else: r["same_died"] += 1
print(f"{sys.argv[2]} against {sys.argv[1]}: rules that acted")
for name, r in sorted(by.items(), key=lambda kv: -kv[1]["games"]):
    print(f"  {name}: in {r['games']} games ({r['fires']} times): saved {len(r['saved'])}, lost {len(r['lost'])}, same {r['same_clear']} cleared / {r['same_died']} died")
    for gid, fs, death, cause, x, y in r["lost"][:show]:
        last = max(f for f, _ in fs if f <= death) if any(f <= death for f, _ in fs) else None
        print(f"      lost {gid}: fired at {', '.join(f'{f} (x={x})' for f, x in fs[:4])}; died at {death} ({cause}, x={x} y={y})" + (f", {death - last} frames after the last firing" if last else ""))
