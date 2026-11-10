#!/usr/bin/env python3
"""Grinds out many deaths at once and sums up, per kind of death, what would have worked.
grind.py BATCH LABELS_FILE [--workers 8] [--back 160]
LABELS_FILE has one "GAME_ID label words..." per line. Each death is tried with thousands of plans (probe_plans.py --native),
then for each label: how many deaths had a way out that a person could still have started in time, and which kinds of move
worked most often."""
import argparse, collections, concurrent.futures as cf, json, os, subprocess, sys

H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
STICK = {0: "stand", 1: "left", 2: "right", 4: "climb"}
DIR = {"0": "straight", "1": "left", "2": "right", "nil": "none"}
REACT = 20          # frames before the death a move must start to count as one a person could make


def grind(batch, gid, back):
    rep = f"{H}/runs/{batch}/plans_{gid}.txt"
    if not os.path.exists(rep):
        subprocess.run([sys.executable, f"{H}/tools/probe_plans.py", batch, str(gid), str(back), "--native", "--steer"], env=dict(os.environ, PSTEP="6"),
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=3000)
    return gid, rep


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("batch")
    ap.add_argument("labels")
    ap.add_argument("--workers", type=int, default=8)
    ap.add_argument("--back", type=int, default=240)
    a = ap.parse_args()
    games = {}
    for p in __import__("glob").glob(f"{H}/runs/{a.batch}/games_*.jsonl"):
        for l in open(p):
            g = json.loads(l)
            games[g["id"]] = g
    labels = {}
    for l in open(a.labels):
        if l.strip():
            gid, lab = l.split(None, 1)
            labels[int(gid)] = lab.strip()
    with cf.ThreadPoolExecutor(a.workers) as ex:
        reports = list(ex.map(lambda gid: grind(a.batch, gid, a.back), labels))
    by = collections.defaultdict(list)
    for gid, rep in reports:
        if not os.path.exists(rep):
            continue
        death = games[gid]["frames"]
        ok = [l.split() for l in open(rep) if not l.startswith("check") and " ok " in l]
        # each surviving plan: how long before the death it started, and what it was
        moves = [(death - int(r[0]), STICK.get(int(r[1]), r[1]), int(r[2]), DIR[r[3]] + ("" if len(r) < 10 or r[9] in ("nil", r[3]) else " holding " + DIR[r[9]]), DIR[r[4]]) for r in ok]
        by[labels[gid]].append((gid, moves))
    for lab, deaths in sorted(by.items(), key=lambda kv: -len(kv[1])):
        n = len(deaths)
        savable = sum(1 for _, m in deaths if any(t >= REACT for t, *_ in m))
        fam = collections.Counter()
        latest = collections.defaultdict(list)
        for _, m in deaths:
            seen = set()
            for t, stick, w, j1, j2 in m:
                if t < REACT:
                    continue
                k = (stick if w else "now", j1, j2)
                if k not in seen:
                    seen.add(k)
                    fam[k] += 1
                    latest[k].append(t)
        print(f"\n== {lab}: {n} deaths, {savable} had a way out starting {REACT}+ frames before the death")
        for k, c in fam.most_common(8):
            ts = sorted(latest[k])
            print(f"   {c:3d} of {n}: {k[0]:5s} then jump {k[1]:22s} then {k[2]:8s}  (latest start, median {ts[len(ts) // 2]} frames before death)")


if __name__ == "__main__":
    main()
