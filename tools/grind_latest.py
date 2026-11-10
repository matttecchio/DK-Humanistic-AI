#!/usr/bin/env python3
"""grind_latest.py BATCH: from a finished grind, for each kind of death, the latest moment a move still worked
(20+ frames before the death, so a person could start it) and which moves worked then."""
import collections, glob, json, os, sys
H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
b = sys.argv[1]
games = {json.loads(l)["id"]: json.loads(l) for p in glob.glob(f"{H}/runs/{b}/games_*.jsonl") for l in open(p)}
labels = {int(l.split(None, 1)[0]): l.split(None, 1)[1].strip() for l in open(f"{H}/runs/{b}/grind_labels.txt") if l.strip()}
STICK = {"0": "stand", "1": "left", "2": "right", "4": "climb"}
D = {"0": "straight", "1": "left", "2": "right", "nil": "none"}
by = collections.defaultdict(list)
for gid, lab in labels.items():
    p = f"{H}/runs/{b}/plans_{gid}.txt"
    if not os.path.exists(p):
        continue
    death = games[gid]["frames"]
    ok = [r.split() for r in open(p) if not r.startswith("check") and " ok " in r]
    ts = [death - int(r[0]) for r in ok if death - int(r[0]) >= 20]
    if not ts:
        by[lab].append((None, set()))
        continue
    latest = min(ts)
    fams = set()
    for r in ok:
        t = death - int(r[0])
        if latest <= t <= latest + 8:
            h = "" if len(r) < 10 or r[9] in ("nil", r[3]) else " holding " + D[r[9]]
            fams.add((STICK[r[1]] if r[2] != "0" else "now", D[r[3]] + h))
    by[lab].append((latest, fams))
for lab, ds in sorted(by.items(), key=lambda kv: -len(kv[1])):
    lat = sorted(t for t, _ in ds if t is not None)
    c = collections.Counter(f for _, fs in ds for f in fs)
    none = sum(1 for t, _ in ds if t is None)
    print(f"\n== {lab}: {len(ds)} deaths ({none} with no way out a person could start in time); latest working move, median {lat[len(lat) // 2] if lat else '-'} frames before death")
    for (a, j), n in c.most_common(5):
        print(f"   {n:3d}: {a} then jump {j}")
