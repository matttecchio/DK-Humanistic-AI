#!/usr/bin/env python3
"""vid_trace.py VIDEO_DIR OUT.trace: turn vid_extract.py's per-frame objects into the same trace layout as tools/inp_trace.lua
(so tools/expert_match.py can use a video like an INP). Per frame: Mario's game position (the blob's centre, shifted onto the
girder heights the game uses), whether he's on a girder, jumping (off the girder and back on the same one within 45 frames) or
on a ladder, holding the hammer (a much bigger blob), his stick and jump inferred from how he moves; every barrel, followed
from frame to frame, with which way it rolls (2 right, 4 left, 3 down a ladder or over an end)."""
import collections, glob, os, sys

D, OUT = sys.argv[1], sys.argv[2]
LEVEL = {6: (74.6, 0.036), 5: (118.5, -0.0626), 4: (135.5, 0.0626), 3: (184.5, -0.0626), 2: (201.5, 0.0626), 1: (246.3, -0.0433)}
lv = lambda y: 6 if y < 95 else 5 if y < 125 else 4 if y < 160 else 3 if y < 195 else 2 if y < 225 else 1
gy = lambda l, x: LEVEL[l][0] + LEVEL[l][1] * x
levels = {int(a): int(b) for a, b in (l.split() for l in open(f"{D}/levels.txt"))}


def standing(x, y):
    """The girder he'd be standing on (the nearest girder height at or below him) and its height."""
    best = None
    for l in LEVEL:
        g = gy(l, x)
        if g >= y - 3 and (best is None or g < best[1]): best = (l, g)
    return best or (1, gy(1, x))


out = open(OUT, "w"); kept = 0
for fp in sorted(glob.glob(f"{D}/raw/*.txt")):
    bi = int(os.path.basename(fp)[:2]); level = levels.get(bi, 0)
    if level < 5 or level >= 22: continue
    fr = []
    for l in open(fp):
        p = l.rstrip("\n").split("|"); i = int(p[0]); obs = []
        for q in p[1:]:
            if not q: continue
            k, x, y, w, h = q.split(); obs.append((k, float(x), float(y), int(w), int(h)))
        fr.append((i, obs))
    # Mario's offset from the blob's centre to the game's y: the commonest gap to the girder below him
    offs = collections.Counter()
    for i, obs in fr:
        ms = [o for o in obs if o[0] == "mario" and o[3] < 22 and o[4] < 22]
        if len(ms) == 1:
            k, x, y, w, h = ms[0]; l, g = standing(x, y + 4)
            if 0 <= g - y <= 9: offs[round(g - y)] += 1
    if not offs: continue
    off = offs.most_common(1)[0][0]
    # per frame: Mario, then barrels
    rows, prev = [], None
    for i, obs in fr:
        if any(o[3] > 60 or o[4] > 60 for o in obs):
            rows.append(None); continue
        ms = sorted((o for o in obs if o[0] == "mario"), key=lambda o: -o[3] * o[4])
        if not ms and prev is not None:
            # merged with a barrel or the points text: the nearest blob to where he just was, if close
            near = [o for o in obs if (o[1] - prev[0]) ** 2 + (o[2] - prev[1]) ** 2 <= 49]
            near.sort(key=lambda o: (o[1] - prev[0]) ** 2 + (o[2] - prev[1]) ** 2)
            ms = near[:1]
        if not ms:
            rows.append(None); prev = None; continue
        k, x, y, w, h = ms[0]
        prev = (x, y)
        ham = 1 if (w >= 22 or h >= 22) else 0
        my = y + off if not ham else None
        bs = [(o[1], o[2]) for o in obs if o[0] in ("barrel", "blue")]
        rows.append({"x": x, "y": my, "ham": ham, "b": bs})
    # fill a hammer frame's y from his last known one; ground or air
    lasty = None
    for r in rows:
        if r is None: lasty = None; continue
        if r["y"] is None: r["y"] = lasty if lasty is not None else gy(5, r["x"])
        lasty = r["y"]
    n = len(rows)
    for i, r in enumerate(rows):
        if r is None: continue
        l, g = standing(r["x"], r["y"]); r["gl"] = l; r["up"] = g - r["y"]
        if r["ham"]: r["up"] = 0                    # with the hammer he's on the girder (its swing moves the blob)
    # off-girder stretches: a jump if he's back on the same girder within 45 frames, else a ladder
    i = 0
    while i < n:
        r = rows[i]
        if r is None or r["up"] <= 2.5:
            if r is not None: r["state"] = "g"
            i += 1; continue
        j = i
        while j < n and rows[j] is not None and rows[j]["up"] > 2.5: j += 1
        before = rows[i - 1] if i > 0 and rows[i - 1] is not None else None
        after = rows[j] if j < n and rows[j] is not None else None
        # a climb goes straight up or down and ends on another girder; anything that comes back down to the same girder is a
        # jump, however long (grabbing the hammer slows the fall)
        jump = bool(before and after and after["gl"] == before["gl"])
        if not before or not after:
            xs = [rows[k]["x"] for k in range(i, j)]
            jump = (max(xs) - min(xs) > 4) and j - i <= 60
        for k in range(i, j): rows[k]["state"] = "j" if jump else "l"
        if jump:
            dx = rows[j - 1]["x"] - rows[i]["x"]
            rows[i]["jumpdir"] = 1 if dx > 6 else 2 if dx < -6 else 0
        i = j
    # barrels: follow each from frame to frame (nearest within 6 px), direction from the last few frames
    tracks, nid, last = {}, 0, []
    for r in rows:
        if r is None: continue
        cur = []
        for bx, by in r["b"]:
            best = min(last, key=lambda t: (t[1] - bx) ** 2 + (t[2] - by) ** 2, default=None)
            if best and (best[1] - bx) ** 2 + (best[2] - by) ** 2 <= 36:
                tid = best[0]; last = [t for t in last if t[0] != tid]
            else:
                tid = nid; nid += 1
            h = tracks.setdefault(tid, collections.deque(maxlen=6)); h.append((bx, by))
            dx = h[-1][0] - h[0][0]; dy = h[-1][1] - h[0][1]
            d = 2 if dx > 1.5 else 4 if dx < -1.5 else 3 if dy > 1 else 0
            cur.append((tid, bx, by, d))
        last = cur; r["bt"] = cur
    # write
    out.write(f"board {bi} level {level} frame 0\n")
    for i, r in enumerate(rows):
        if r is None or "state" not in r:
            out.write("end\n"); continue
        nx = rows[i + 1] if i + 1 < n and rows[i + 1] is not None else None
        stick = 0
        if nx and r["state"] == "g":
            stick = 1 if nx["x"] - r["x"] > 0.3 else 2 if nx["x"] - r["x"] < -0.3 else 0
        if "jumpdir" in r: stick = 0x10 | (1 if r["jumpdir"] == 1 else 2 if r["jumpdir"] == 2 else 0)
        lad = 1 if r["state"] == "l" else 0; jmp = 1 if r["state"] == "j" else 0
        p = [f"{bi} {i} {round(r['x'])} {round(r['y'])} {lad} {jmp} {r['ham']} 0 {stick}"]
        p += [f"B{t % 1000} {round(bx)} {round(by)} {d} 0" for t, bx, by, d in r.get("bt", [])]
        out.write("|".join(p) + "\n"); kept += 1
    out.write("end\n")
print(f"{kept} frames written to {OUT}")
