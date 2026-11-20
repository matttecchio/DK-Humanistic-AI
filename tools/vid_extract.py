#!/usr/bin/env python3
"""vid_extract.py VIDEO FIRST LAST: read barrel boards FIRST..LAST of the barrel-board video (board cuts in boards.npy next to
it, from the 10 fps scan) at full frame rate. Per board: a background (median of frames 2 s apart), then every frame's objects
(tools/vid_objects.py) at game resolution, written to <video dir>/raw/<board>.txt as "frame|kind x y w h|...". Levels come from
reading the boards' "L=" numbers (levels.txt: board level)."""
import os, subprocess, sys
import numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from vid_objects import objects

VID = sys.argv[1]; D = os.path.dirname(os.path.abspath(VID))
_b = np.load(f"{D}/boards.npy")
if _b.ndim == 2:     # (start, end) pairs, in 10 fps scan frames (a video with other boards between the barrel boards)
    cuts, ends = [int(x) for x in _b[:, 0]], [int(x) for x in _b[:, 1]]
else:
    cuts, ends = list(_b), None
cuts = cuts + [None]
VF = f"crop={os.environ.get('VCROP', '634:712:339:0')},scale=256:256:flags=area"   # VCROP: w:h:x:y of the playfield, 1 game unit = 1 px after scaling
os.makedirs(f"{D}/raw", exist_ok=True)


def frames(t0, dur, fps=None):
    vf = VF if not fps else f"fps={fps}," + VF
    p = subprocess.Popen(["ffmpeg", "-v", "error", "-ss", str(t0), "-t", str(dur), "-i", VID, "-vf", vf, "-pix_fmt", "rgb24",
                          "-f", "rawvideo", "-"], stdout=subprocess.PIPE)
    n = 256 * 256 * 3
    while True:
        b = p.stdout.read(n)
        if len(b) < n: break
        yield np.frombuffer(b, np.uint8).reshape(256, 256, 3)


for bi in range(int(sys.argv[2]), int(sys.argv[3]) + 1):
    t0 = cuts[bi] / 10 + 0.5
    t1 = (ends[bi] / 10 - 0.5) if ends else ((cuts[bi + 1] / 10 - 0.5) if cuts[bi + 1] is not None else t0 + 300)
    bg = np.median(np.stack(list(frames(t0, t1 - t0, fps=0.5))), axis=0).astype(np.uint8)
    out = open(f"{D}/raw/{bi:02d}.txt.part", "w")
    for i, f in enumerate(frames(t0, t1 - t0)):
        obs = objects(f, bg)
        out.write(f"{i}|" + "|".join(f"{k} {x} {y} {w} {h}" for k, x, y, w, h in obs) + "\n")
    out.close(); os.replace(f"{D}/raw/{bi:02d}.txt.part", f"{D}/raw/{bi:02d}.txt")
    print(f"board {bi} done ({i + 1} frames)", flush=True)
