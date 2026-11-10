#!/usr/bin/env python3
"""steer_study.py TRACE...: how a player steers barrels (Matt, 2026-11-10: the experts make sure the 'bad luck' doesn't happen by
steering the barrels above them). For every moment a barrel rolling on a girder reaches one of its ladders (DROPS) with Mario on
the girder below it (on the ground, no hammer): which way the stick points relative to that ladder (towards / away / neither),
whether the ladder is towards Mario or not, how far away he is, and whether the barrel came down. Works on INP traces (real
inputs), the video trace (stick read from his movement) and our own autopsy traces (his inputs)."""
import collections, sys

DROPS = {6: [106, 202], 5: [52, 92, 188], 4: [82, 130, 202], 3: [52, 116], 2: [99, 203]}
fl = lambda y: 1 if y >= 220 else 2 if y >= 190 else 3 if y >= 155 else 4 if y >= 120 else 5 if y >= 101 else 6
lv = lambda y: 6 if y < 95 else 5 if y < 125 else 4 if y < 160 else 3 if y < 195 else 2 if y < 225 else 1


def frames(path, ours):
    """(frame, x, y, ground, stick (-1 left, 1 right, 0), [(k, x, y, d)]) per frame; None between boards."""
    for l in open(path):
        if not l[0].isdigit():
            yield None; continue
        p = l.rstrip("\n").split("|"); hd = p[0].split()
        if ours:     # autopsy: id f x y lad jmp ham cur why
            x, y, lad, jmp, ham, cur = int(hd[2]), int(hd[3]), hd[4], hd[5], hd[6], int(hd[7])
            stick = -1 if cur & 1 else 1 if cur & 2 else 0
        else:        # inp / video: id f x y lad jmp ham face in0
            x, y, lad, jmp, ham, cur = int(hd[2]), int(hd[3]), hd[4], hd[5], hd[6], int(hd[8])
            stick = 1 if cur & 1 else -1 if cur & 2 else 0
        bs = []
        for q in p[1:]:
            if q.startswith("B"):
                v = q.split(); bs.append((v[0], int(v[1]), int(v[2]), int(v[3])))
        yield (int(hd[1]), x, y, lad == "0" and jmp == "0" and ham == "0", stick, bs)


def study(path, ours=False):
    seq = list(frames(path, ours))
    res = collections.Counter()
    for i, r in enumerate(seq):
        if r is None or not r[3]: continue
        f, x, y, ground, stick, bs = r
        mf = fl(y)
        for k, bx, by, d in bs:
            L = lv(by)
            if L != mf + 1 or d not in (2, 4): continue
            step = 1 if d == 2 else -1
            for lx in DROPS.get(L, []):
                if (lx - bx) * step in (0, 1):                     # it's at the ladder's top now
                    # did it come down? look 20 frames on for it below
                    down = None
                    for j in range(i + 1, min(i + 25, len(seq))):
                        if seq[j] is None: break
                        for k2, bx2, by2, d2 in seq[j][5]:
                            if k2 == k and abs(bx2 - lx) <= 3 and lv(by2) <= L - 1 + 0 or (k2 == k and by2 > by + 6):
                                down = True
                        if down: break
                    if down is None: down = False
                    side = 1 if lx > x else -1                      # where the ladder is from him
                    rel = "towards" if stick == side else "away" if stick == -side else "neither"
                    near = "under" if abs(lx - x) <= 16 else "near" if abs(lx - x) <= 48 else "far"
                    gdir = 1 if mf in (2, 4) else -1 if mf in (1, 3, 5) else 1   # which way barrels on his own girder roll
                    res[(near, rel, down)] += 1
                    res[("ds" if (lx - x) * gdir > 0 else "us", near, rel)] += 1
    return res


for path in sys.argv[1:]:
    ours = "/autopsy/" in path or path.endswith(".atrace")
    r = collections.Counter()
    import glob
    for p in sorted(glob.glob(path)):
        r += study(p, ours=ours or "/autopsy/" in p)
    print(f"== {path}")
    for near in ("under", "near", "far"):
        row = []
        for rel in ("towards", "away", "neither"):
            n = r[(near, rel, True)] + r[(near, rel, False)]
            row.append(f"{rel} {n} (came down {100 * r[(near, rel, True)] / max(n, 1):.0f}%)")
        tot = sum(r[(near, a, b)] for a in ("towards", "away", "neither") for b in (True, False))
        print(f"  ladder {near:5s} ({tot}): " + "; ".join(row))
    for near in ("under", "near"):
        for side, name in (("ds", "downstream (his girder's barrels roll away to it)"), ("us", "upstream")):
            t = sum(r[(side, near, rel)] for rel in ("towards", "away", "neither"))
            print(f"    {near} {name}: {t}, towards {100 * r[(side, near, 'towards')] / max(t, 1):.0f}%, away {100 * r[(side, near, 'away')] / max(t, 1):.0f}%")
