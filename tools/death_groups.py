#!/usr/bin/env python3
"""death_groups.py BATCH...: sorts each batch's non-fireball deaths into situations (floor, part of the girder, what killed him),
writing runs/BATCH/groups.txt ("game_id group" per line) for scenario_test.py --groups."""
import collections, glob, json, os, sys

H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def floor(y):
    return 1 if y >= 220 else 2 if y >= 190 else 3 if y >= 155 else 4 if y >= 120 else 5 if y >= 101 else 6


AREAS = {2: [(0, 90, "left"), (90, 130, "under the hammer ladder"), (130, 256, "right")],
         4: [(0, 70, "left"), (70, 100, "ladder 91 foot"), (100, 130, "middle"), (130, 256, "right")],
         5: [(0, 85, "left"), (85, 140, "ladder 91 top"), (140, 256, "right")]}


def group(g):
    fl = floor(g["y"])
    area = next((n for lo, hi, n in AREAS.get(fl, []) if lo <= g["x"] < hi), "all")
    what = "wild" if "wild" in g["cause"] else ("on a ladder" if "ladder" in g["doing"] else "barrel")
    return f"5-1 girder {fl} {area}: {what}"


for b in sys.argv[1:]:
    gs = [json.loads(l) for p in glob.glob(f"{H}/runs/{b}/games_*.jsonl") for l in open(p)]
    d = [g for g in gs if g["outcome"] == "died" and g["cause"] != "fireball"]
    with open(f"{H}/runs/{b}/groups.txt", "w") as f:
        for g in d:
            f.write(f"{g['id']} {group(g)}\n")
    print(b, collections.Counter(group(g) for g in d).most_common())
