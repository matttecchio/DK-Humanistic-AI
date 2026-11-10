#!/usr/bin/env python3
"""Checks that 1-1 hasn't got worse: regress_1_1.py NAME [--games N]
Plays the current player on the baseline's games and compares game by game. Zero games played differently
means 1-1 is untouched. Otherwise it reports how many games each version alone lost; those changes need a fresh exam."""
import argparse, json, os, subprocess, sys
H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, f"{H}/tools")
import stats
BASE, FIRST = "t1c", 1400000

ap = argparse.ArgumentParser()
ap.add_argument("name")
ap.add_argument("--games", type=int, default=3000)
a = ap.parse_args()
subprocess.run([sys.executable, f"{H}/tools/run_batch.py", a.name, "--games", str(a.games), "--first", str(FIRST), "--note", "Checking 1-1 hasn't got worse"], stdout=subprocess.DEVNULL, check=True)
old = {g["id"]: g for g in stats.load(BASE)}
new = {g["id"]: g for g in stats.load(a.name)}
ids = [i for i in new if i in old]
same = lambda x, y: all(x[k] == y[k] for k in ("outcome", "frames", "hash", "cause", "score"))
diff = [i for i in ids if not same(old[i], new[i])]
lost = [i for i in ids if old[i]["outcome"] == "clear" and new[i]["outcome"] != "clear"]
saved = [i for i in ids if old[i]["outcome"] != "clear" and new[i]["outcome"] == "clear"]
print(json.dumps({"games": len(ids), "played_differently": len(diff), "newly_lost": len(lost), "newly_saved": len(saved)}))
sys.exit(1 if len(lost) > len(saved) else 0)
