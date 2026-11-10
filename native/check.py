#!/usr/bin/env python3
"""check.py REF FIRST GAMES LEVEL: plays games on dkh with the current lua/ on all 8 cores, times it,
and checks every game against batch REF (same outcome, frames, score, positions and every input)."""
import glob, json, os, subprocess, sys, time
H = os.path.expanduser("~/dkong-human"); N = os.path.dirname(os.path.abspath(__file__))
ref_name, first, games, level = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4])
out = f"{N}/out"; os.makedirs(out, exist_ok=True)
for p in glob.glob(f"{out}/*.jsonl"): os.remove(p)
env0 = dict(os.environ, DKX_ROMS=os.path.expanduser("~/dkx-build/DK-x86-AI/dkx/roms"), DKH_STATES=f"{N}/starts", DKH=H, MODE="batch",
            LEVEL=str(level), START_PREFIX="s" if level == 1 else f"l{level}_", STEP="8", LAST=str(first + games - 1))
t = time.time()
procs = [subprocess.Popen([f"{N}/build/dkh", f"{H}/lua/agent.lua"], env=dict(env0, START_ID=str(first + w), OUT=f"{out}/{w}.jsonl")) for w in range(8)]
for p in procs: p.wait()
dt = time.time() - t
ref = {}
for p in glob.glob(f"{H}/runs/{ref_name}/games_*.jsonl"):
    for l in open(p): g = json.loads(l); ref[g["id"]] = g
same = diff = frames = 0
for p in glob.glob(f"{out}/*.jsonl"):
    for l in open(p):
        g = json.loads(l); r = ref[g["id"]]; frames += g["frames"]
        if all(g[k] == r[k] for k in ("outcome", "frames", "score", "hash", "x", "y", "inp")): same += 1
        else:
            diff += 1
            if diff <= 3: print("different:", g["id"], g["outcome"], r["outcome"], g["frames"], r["frames"])
print(f"{same} identical, {diff} different; {frames} frames in {dt:.1f} s = {frames / dt:.0f} frames/s on 8 cores")
