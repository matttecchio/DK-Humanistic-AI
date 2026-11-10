#!/usr/bin/env python3
"""compare.py BASE OTHER...: clear rate, causes and floors of batches, and games saved/lost against BASE (same games only)."""
import collections
import glob
import json
import math
import os
import sys

H = os.path.expanduser("~/dkong-human")


def load(name):
    games = {}
    for path in glob.glob(f"{H}/runs/{name}/games_*.jsonl"):
        for line in open(path):
            g = json.loads(line)
            games[g["id"]] = g
    return games


def fireball(g):
    return g["cause"] == "fireball"


def floor_of(g):
    y = g["y"]
    return 1 if y >= 220 else 2 if y >= 190 else 3 if y >= 155 else 4 if y >= 120 else 5 if y >= 101 else 6


def show(name, games, base):
    n = len(games)
    fires = sum(1 for g in games.values() if g["outcome"] != "clear" and fireball(g))
    clears = sum(1 for g in games.values() if g["outcome"] == "clear")
    # Headline leaves games ended by a fireball out altogether; the allfire figure counts them.
    m = n - fires
    p = clears / m
    low = p - 1.96 * math.sqrt(p * (1 - p) / m)
    dead = [g for g in games.values() if g["outcome"] != "clear"]
    causes = collections.Counter(g["cause"] for g in dead)
    floors = sorted(collections.Counter(floor_of(g) for g in dead).items())
    doing = collections.Counter(g["doing"] for g in dead)
    print(f"{name} {n} {100 * p:.2f}% low {100 * low:.1f}% allfire {100 * clears / n:.2f}% {dict(causes)} {floors} {dict(doing)}")
    if base is not None:
        same = [i for i in games if i in base]
        saved = sum(1 for i in same if games[i]["outcome"] == "clear" and base[i]["outcome"] != "clear" and not fireball(base[i]))
        lost = sum(1 for i in same if games[i]["outcome"] != "clear" and not fireball(games[i]) and base[i]["outcome"] == "clear")
        print(f"   {saved} saved {lost} lost, on {len(same)} shared games")
    for fl in (4, 5):
        xs = collections.Counter(g["x"] // 10 * 10 for g in dead if floor_of(g) == fl and not fireball(g))
        print(f"   fl {fl} {sorted(xs.items())}")


names = sys.argv[1:]
base = load(names[0])
show(names[0], base, None)
for name in names[1:]:
    show(name, load(name), base)
