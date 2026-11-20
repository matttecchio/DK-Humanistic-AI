"""vid_objects.py: find Mario, barrels and fireballs in a frame of the barrel-board video, at game resolution (256x256,
1 px = 1 game unit: crop x 339-973, y 0-712 of the 1280x720 video, scaled by area). Moving things are what differs from
the board's empty background (a median over the board's frames); each blob is classified by size and colour."""
import os
import numpy as np
RED_BARRELS = bool(os.environ.get("RED_BARRELS"))
import scipy.ndimage as nd

# score line; bonus box; Kong, his barrel stack and the barrel he's holding; Pauline; the oil drum's flames
IGNORE = [(0, 0, 256, 40), (175, 40, 256, 72), (0, 40, 98, 93), (100, 36, 126, 62), (24, 210, 54, 238)] + \
         ([(237, 0, 256, 256)] if os.environ.get("RIGHT_OVERLAY") else [])   # a stream's chat over the right edge


def objects(f, bg, thr=60):
    d = np.abs(f.astype(int) - bg.astype(int)).sum(axis=2)
    m = d > thr
    for x0, y0, x1, y1 in IGNORE:
        m[y0:y1, x0:x1] = False
    m = nd.binary_opening(m, iterations=1)
    lab, n = nd.label(m)
    out = []
    for i, sl in enumerate(nd.find_objects(lab), 1):
        ys, xs = sl
        h, w = ys.stop - ys.start, xs.stop - xs.start
        if h * w < 12:
            continue
        px = f[sl][lab[sl] == i].astype(int)
        px = px[px.sum(axis=1) > 120]
        if len(px) < 8:
            continue
        r, g, b = px.mean(axis=0)
        g90 = np.percentile(px[:, 1], 90)
        cy, cx = nd.center_of_mass(lab == i)
        if 85 < b < 165 and g < 62 and r > 80:
            k = "mario"                                   # his red and blue blur to purple on the arcade screen
        elif b >= 165 and b > r + 40:
            k = "blue"
        elif abs(r - g) < 30 and abs(g - b) < 30:
            continue                                      # white points text
        elif g90 >= 150 and r > 140:
            k = "fire"
        elif 95 < r < 180 and 45 < g < 115 and b < 90:
            k = "barrel"
        elif RED_BARRELS and r > 140 and g < 110 and b < 85:
            k = "barrel"                                  # some captures draw the barrels red
        else:
            k = "?"
        n_b = int(round(w / 13)) if k == "barrel" and w >= 19 and h <= 15 else 1   # barrels side by side merge
        for j in range(n_b):
            out.append((k, round(xs.start + (j + 0.5) * w / n_b, 1) if n_b > 1 else round(cx, 1), round(cy, 1), w // n_b, h))
    return out
