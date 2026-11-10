#!/usr/bin/env python3
"""solve.py OUT.lua BATCH [BATCH...]: turns ground-out deaths into remembered situations ("cases") for policy.lua (params.cases).
For each death with runs/BATCH/plans_ID.txt (grind.py) and an autopsy trace: the latest move a person could start in time
(REACT+ frames before the death) that also works started STEP frames later (so his reaction delay can't spoil it).
The case is what he'd see as he has to start it (the frame SEEN before): his girder and x, and every barrel near him."""
import glob, json, os, sys

H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REACT, STEP, SEEN = 20, 6, 9
WX, UP, DOWN = 64, 50, 16          # which barrels count: this far either side, above, below him


def floor(y):
    return 1 if y >= 220 else 2 if y >= 190 else 3 if y >= 155 else 4 if y >= 120 else 5 if y >= 101 else 6


def solve(batch, gid, games):
    p, tp = f"{H}/runs/{batch}/plans_{gid}.txt", f"{H}/runs/{batch}/autopsy/{gid}.trace"
    if not (os.path.exists(p) and os.path.exists(tp)):
        return None
    death = games[gid]["frames"]
    ok = set()
    for l in open(p):
        r = l.split()
        if l.startswith("check") or r[5] != "ok":
            continue
        ok.add((int(r[0]), r[1], r[2], r[3], r[4], r[9]))
    rows = {}
    for l in open(tp):
        parts = l.rstrip("\n").split("|")
        hd = parts[0].split()
        rows[int(hd[1])] = (hd, parts[1:])
    cands = []
    for (s, a, w, j1, j2, h) in ok:
        if death - s < REACT or (s + STEP, a, w, j1, j2, h) not in ok:
            continue
        cands.append(((s, -(j2 != "nil"), -(j1 != "nil")), s, a, w, j1, j2, h))   # latest first, then fewer jumps
    # the latest one he can start from standing or walking on a girder (not mid-jump or on a ladder)
    for _, s, a, w, j1, j2, h in sorted(cands, reverse=True):
        if s - SEEN in rows:
            hd, objs = rows[s - SEEN]
            if int(hd[4]) == 0 and int(hd[5]) == 0 and int(hd[4 + 0]) == 0:
                break
    else:
        return None
    x, y, ham = int(hd[2]), int(hd[3]), int(hd[6])
    bs = []
    for q in objs:
        if not q.startswith("B"):
            continue
        _, bx, by, bd, bc = q.split()
        dx, dy = int(bx) - x, int(by) - y
        if abs(dx) <= WX and -UP <= dy <= DOWN:
            bs.append((dx, dy, {"2": 2, "4": 4}.get(bd, 0), 1 if bc != "0" else 0))
    nil = lambda v: "nil" if v == "nil" else v
    return (f"  {{src = {gid}, fl = {floor(y)}, x = {x}, ham = {1 if ham else 0}, b = {{"
            + ", ".join(f"{{{dx}, {dy}, {d}, {c}}}" for dx, dy, d, c in sorted(bs)) + "}, "
            + f"plan = {{a = {a}, w = {w}, j1 = {nil(j1)}, j2 = {nil(j2)}, h = {nil(h)}}}}},")


def main():
    out, batches = sys.argv[1], sys.argv[2:]
    lines, tried = [], 0
    for b in batches:
        games = {json.loads(l)["id"]: json.loads(l) for p in glob.glob(f"{H}/runs/{b}/games_*.jsonl") for l in open(p)}
        for p in glob.glob(f"{H}/runs/{b}/plans_*.txt"):
            gid = int(os.path.basename(p)[6:-4])
            if gid in games:
                tried += 1
                c = solve(b, gid, games)
                if c:
                    lines.append(c)
    open(out, "w").write("-- remembered situations (tools/solve.py " + " ".join(batches) + ")\nreturn {\n" + "\n".join(lines) + "\n}\n")
    print(f"{len(lines)} cases from {tried} ground-out deaths -> {out}")


if __name__ == "__main__":
    main()
