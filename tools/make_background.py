#!/usr/bin/env python3
"""Builds the empty board: the most common colour of each pixel across many game frames, so anything moving vanishes.
Also works out where a RAM position lands on the upright picture by lining frames up on Mario."""
import collections, json, os, struct, subprocess, sys, tempfile, time, zlib
H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, f"{H}/tools")
import stats
W, Ht = 256, 224


def upright(raw):
    return [raw[(y * W + x) * 4:(y * W + x) * 4 + 3] for x in range(W - 1, -1, -1) for y in range(Ht)]   # 224 wide, 256 tall


games = [g for g in stats.load(sys.argv[1], inputs=True) if g["frames"] > 700][:12]
samples = []
with tempfile.TemporaryDirectory() as td:
    for g in games:
        rp = f"{td}/r.txt"
        open(rp, "w").write(f"{g['id']}\n{g['start']}\n{g['inp']}\n")
        env = dict(os.environ, DKH=H, MODE="replay", REPLAY=rp, LIVE=td)
        p = subprocess.Popen([f"{H}/tools/mame.sh", "-samplerate", "1000", "-speed", "10", "-state_directory", f"{H}/starts", "-autoboot_script", f"{H}/lua/agent.lua"],
                             env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        while p.poll() is None:
            time.sleep(0.25)
            try:
                s1 = json.load(open(f"{td}/state.json")); raw = open(f"{td}/frame.raw", "rb").read(); s2 = json.load(open(f"{td}/state.json"))
            except (OSError, ValueError):
                continue
            if len(raw) == W * Ht * 4 and s1["frame"] == s2["frame"] and s1["frame"] > 60:
                samples.append((s1, upright(raw)))
print("frames", len(samples))
counts = [collections.Counter() for _ in range(224 * 256)]
for _, px in samples:
    for i, c in enumerate(px):
        counts[i][c] += 1
bg = [c.most_common(1)[0][0] for c in counts]
rows = []
for y in range(256):
    rows.append(b"\0" + b"".join(bg[y * 224 + x][::-1] for x in range(224)))
def ch(t, d): return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d))
open(f"{H}/web/bg.png", "wb").write(b"\x89PNG\r\n\x1a\n" + ch(b"IHDR", struct.pack(">IIBBBBB", 224, 256, 8, 2, 0, 0, 0)) + ch(b"IDAT", zlib.compress(b"".join(rows))) + ch(b"IEND", b""))
# anything Mario-shaped that stays at a fixed offset from his RAM position shows up strongly
rel = collections.Counter()
for s, px in samples:
    for i, c in enumerate(px):
        if c != bg[i]:
            y, x = divmod(i, 224)
            if abs(x - s["x"]) < 32 and abs(y - s["y"]) < 32:
                rel[(x - s["x"], y - s["y"])] += 1
top = [k for k, v in rel.items() if v > 0.5 * len(samples)]
print("mario pixels relative to RAM x,y: x", min(k[0] for k in top), max(k[0] for k in top), "y", min(k[1] for k in top), max(k[1] for k in top))
