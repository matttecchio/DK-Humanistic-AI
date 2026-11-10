#!/usr/bin/env python3
"""Replays recorded games from their inputs alone and checks each one ends the same way."""
import json, os, subprocess, sys, tempfile
H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, f"{H}/tools")
import stats

name, count = sys.argv[1], int(sys.argv[2]) if len(sys.argv) > 2 else 16
stats.use_starts(name)
games = stats.load(name, inputs=True)
step = max(1, len(games) // count)
games = games[::step][:count]
ok = bad = 0
with tempfile.TemporaryDirectory() as td:
    for i in range(0, len(games), 8):
        procs = []
        for g in games[i:i + 8]:
            rp, out = f"{td}/r{g['id']}.txt", f"{td}/o{g['id']}.jsonl"
            open(rp, "w").write(f"{g['id']}\n{g['start']}\n{g['inp']}\n")
            env = dict(os.environ, DKH=H, MODE="replay", REPLAY=rp, OUT=out)
            procs.append((g, out, subprocess.Popen([f"{H}/tools/mame.sh", "-nothrottle", "-samplerate", "1000", "-state_directory", f"{H}/starts", "-autoboot_script", f"{H}/lua/agent.lua"],
                                                   env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)))
        for g, out, p in procs:
            p.wait()
            r = json.loads(open(out).read())
            same = all(r[k] == g[k] for k in ("outcome", "score", "frames", "x", "y"))
            ok += same
            bad += not same
            if not same:
                print("DIFFERENT", {k: (g[k], r[k]) for k in ("id", "outcome", "score", "frames", "x", "y")})
print(f"replayed {ok + bad}: identical {ok}, different {bad}")
