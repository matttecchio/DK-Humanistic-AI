#!/usr/bin/env python3
"""inp_study.py TRACE: what a top player does on barrel boards from level 5 (tools/inp_trace.lua's output).
Per board: died or cleared; the top hammer: where Mario stood when he jumped for it, which way he faced, how far away the nearest
barrel coming at him on the 5th girder was then, how long he held it, where he spent that time, and where he was when he set off
right; and the climb up ladder 91: Kong's pose and the nearest barrel to the ladder top when he started up."""
import collections, sys

fl = lambda y: 1 if y >= 220 else 2 if y >= 190 else 3 if y >= 155 else 4 if y >= 120 else 5 if y >= 101 else 6
lv = lambda y: 6 if y < 95 else 5 if y < 125 else 4 if y < 160 else 3 if y < 195 else 2 if y < 225 else 1
boards, starts, cur = {}, [], None
for l in open(sys.argv[1]):
    if l.startswith("start "):
        p = l.split(); starts.append({"level": int(p[2]), "board": int(p[4]), "lives": int(p[6]), "frame": int(p[10])}); continue
    if l.startswith("board "):
        p = l.split(); cur = int(p[1]); boards[cur] = {"level": int(p[3]), "frame": int(p[7]), "rows": [], "si": len(starts) - 1}; continue
    if l.startswith("end "):
        continue
    p = l.rstrip("\n").split("|"); hd = [int(v) for v in p[0].split()]
    o = {"f": hd[1], "x": hd[2], "y": hd[3], "lad": hd[4], "jmp": hd[5], "ham": hd[6], "face": hd[7], "in": hd[8], "b": [], "fb": []}
    for q in p[1:]:
        v = q.split()
        if q[0] == "B": o["b"].append((int(v[1]), int(v[2]), int(v[3]), int(v[4])))
        elif q[0] == "F": o["fb"].append((int(v[1]), int(v[2])))
        elif q[0] == "K": o["kong"], o["kage"] = int(v[1]), int(v[2])
        elif q[0] == "H": o["htop"], o["htaken"] = int(v[1]), int(v[2])
    boards[hd[0]]["rows"].append(o)
for bid, b in boards.items():
    nxt = starts[b["si"] + 1] if b["si"] + 1 < len(starts) else None
    b["died"] = nxt is None or nxt["lives"] < starts[b["si"]]["lives"]
print(f"{len(boards)} barrel boards at level 5+: {sum(not b['died'] for b in boards.values())} cleared, {sum(b['died'] for b in boards.values())} died")
grabs = []
for bid, b in boards.items():
    rows = b["rows"]
    for i in range(1, len(rows)):
        if rows[i]["ham"] and not rows[i - 1]["ham"] and fl(rows[i]["y"]) == 5:
            # back to the jump that took it
            k = i - 1
            while k > 0 and not rows[k]["jmp"]: k -= 1          # the flag comes on a few frames after he lands
            land = rows[k + 1]
            j = k
            while j > 0 and rows[j - 1]["jmp"]: j -= 1
            s = rows[max(j - 1, 0)]
            gaps = sorted(bx - s["x"] for bx, by, bd, bc in s["b"] if bc == 0 and lv(by) == 5 and bx > s["x"] - 4)
            lgaps = sorted(bx - land["x"] for bx, by, bd, bc in land["b"] if bc == 0 and lv(by) == 5 and bx > land["x"] - 4)
            ahead = sorted(bx for bx, by, bd, bc in s["b"] if bc == 0 and lv(by) == 5 and bx > s["x"])
            # how he got there: frames standing at the spot before jumping, and where he came from
            st = j - 1
            while st > 0 and abs(rows[st - 1]["x"] - s["x"]) <= 1 and not rows[st - 1]["jmp"]: st -= 1
            came = rows[max(st - 60, 0)]["x"]
            held = next((k for k in range(i, len(rows)) if not rows[k]["ham"]), len(rows)) - i
            xs = [r["x"] for r in rows[i:i + held]]
            grabs.append((bid, b["level"], s["x"], s["face"], gaps[:2], lgaps[:1], ahead[:1], j - 1 - st, came, held, b["died"], k + 1 - j))
print(f"top hammer taken on {len(grabs)} of {len(boards)} boards")
for g in grabs:
    print(f"  board {g[0]} (level {g[1]}): stood {g[7]} frames at x={g[2]} facing {'right' if g[3] > 0 else 'left'} (from x={g[8]} a second before), "
          f"jumped with barrels {g[4]} px away (nearest at x={g[6]}); landed after {g[11]} frames with the nearest {g[5]} px away; held {g[9]}; {'died' if g[10] else 'cleared'}")
import statistics as S
ok = [g for g in grabs if g[4]]
print("jump spot x:", collections.Counter(g[2] for g in grabs).most_common(6))
print("facing right:", sum(g[3] > 0 for g in grabs), "of", len(grabs))
print("nearest barrel's x when he jumped:", sorted(g[6][0] for g in grabs if g[6]))
print("nearest gap on landing:", sorted(g[5][0] for g in grabs if g[5]))
print("frames standing at the spot first:", sorted(g[7] for g in grabs))
