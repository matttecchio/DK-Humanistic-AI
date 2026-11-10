#!/usr/bin/env python3
"""escape_check.py BATCH [N]: for ground-out deaths, asks the planner about the escape grinding found.
For each death: the latest surviving one-jump plan a person could start in time (20+ frames before), then at that frame,
what did the planner think of the same move? "model said hit" (his prediction is wrong), "rated it lower" (his scoring),
or "not among his plans". Needs runs/BATCH/plans_*.txt (grind.py) and autopsy traces."""
import collections, glob, json, os, re, subprocess, sys

H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
b = sys.argv[1]
n_max = int(sys.argv[2]) if len(sys.argv) > 2 else 40
games = {json.loads(l)["id"]: json.loads(l) for p in glob.glob(f"{H}/runs/{b}/games_*.jsonl") for l in open(p)}
labels = {int(l.split(None, 1)[0]): l.split(None, 1)[1].strip() for l in open(f"{H}/runs/{b}/grind_labels.txt") if l.strip()}
ACT = {"0": 0, "1": -1, "2": 1}
out = collections.Counter()
per_label = collections.defaultdict(collections.Counter)
done = 0
for gid, lab in labels.items():
    if done >= n_max:
        break
    p = f"{H}/runs/{b}/plans_{gid}.txt"
    if not os.path.exists(p) or not os.path.exists(f"{H}/runs/{b}/autopsy/{gid}.trace"):
        continue
    death = games[gid]["frames"]
    ok = [r.split() for r in open(p) if not r.startswith("check") and " ok " in r]
    # one-jump escapes with the stick held as the jump goes (what his own plans look like)
    cands = [r for r in ok if r[4] == "nil" and r[3] != "nil" and (len(r) < 10 or r[9] in ("nil", r[3])) and death - int(r[0]) >= 20]
    if not cands:
        continue
    t = min(death - int(r[0]) for r in cands)
    r = next(r for r in cands if death - int(r[0]) == t)
    frame, act, w, j1 = int(r[0]), ACT[r[1]], int(r[2]), ACT[r[3]]
    res = subprocess.run([sys.executable, f"{H}/tools/why_plan.py", b, str(gid), str(frame - 1), str(frame + 1)], capture_output=True, text=True, timeout=600).stdout
    # he only weighs plans every other frame: use the frame nearest the escape where he did
    by_f = collections.defaultdict(list)
    for l in res.split("\n"):
        m = re.match(r"  f=(\d+) ", l)
        if m and "j2=nil" in l:
            by_f[int(m.group(1))].append(l)
    fr = min(by_f, key=lambda k: abs(k - frame)) if by_f else None
    lines = by_f.get(fr, [])
    chosen = [l for l in res.split("\n") if l.startswith("f=")]
    best_v = max((float(m.group(1)) for l in lines for m in [re.search(r" v=(-?\d+)", l)] if m), default=None)
    same = [l for l in lines if f"act={act} " in l and f"j1={j1} " in l and abs(int(re.search(r"w1=(\d+)", l).group(1)) - w) <= 6]
    if not lines:
        verdict = "not weighing plans then"
    elif not same:
        verdict = "not among his plans"
    elif all("HIT" in l for l in same):
        verdict = "model said hit"
    else:
        v = max(float(re.search(r" v=(-?\d+)", l).group(1)) for l in same if " v=" in l)
        verdict = "rated it lower" if best_v is not None and v < best_v else "rated it best (but did otherwise)"
    out[verdict] += 1
    per_label[lab][verdict] += 1
    done += 1
    print(f"{gid} {lab}: escape {t} frames before death = stick {act} for {w}, jump {j1} -> {verdict}", flush=True)
print("\nOverall:", dict(out))
for lab, c in per_label.items():
    print(f"  {lab}: {dict(c)}")
