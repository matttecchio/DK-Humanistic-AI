#!/usr/bin/env python3
"""bank.py OUT.lua BATCH:deep_solve_output [BATCH:file ...]: banks solved deaths as remembered situations (Matt: solve
individual deaths and bank them as solutions for when all the barrels on the board are in roughly those positions).
For each "ID: N frames before, move a w j1 j2 h" line: Mario's real position when the move starts (frame s, from the trace),
every barrel on the board as he saw it then (frame s - SEEN), and the move. policy.lua matches them with params.cases +
params.case_now (his real position, every barrel, slack growing with distance)."""
import glob, json, os, re, sys

H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SEEN = int(os.environ.get("SEEN", 9))   # frames old his view is (his reaction: 9, or 2 at 30 ms)


def floor(y):
    return 1 if y >= 220 else 2 if y >= 190 else 3 if y >= 155 else 4 if y >= 120 else 5 if y >= 101 else 6


lines, n = [], 0
for arg in sys.argv[2:]:
    b, path = arg.split(":", 1)
    games = {json.loads(l)["id"]: json.loads(l) for p in glob.glob(f"{H}/runs/{b}/games_*.jsonl") for l in open(p)}
    for l in open(path):
        m = re.match(r"\s*(\d+): (\d+) frames before, move (\S+) (\S+) (\S+) (\S+) (\S+): (\d+)/(\d+)", l)
        if m and os.environ.get("ONLY_BANKED") and "BANKED" not in l:
            continue
        if not m:
            continue
        gid, early = int(m.group(1)), int(m.group(2))
        a, w, j1, j2, h = m.group(3, 4, 5, 6, 7)
        tp = f"{H}/runs/{b}/autopsy/{gid}.trace"
        if gid not in games or not os.path.exists(tp):
            continue
        s = games[gid]["frames"] - early
        rows = {}
        for t in open(tp):
            parts = t.rstrip("\n").split("|"); hd = parts[0].split()
            rows[int(hd[1])] = (hd, parts[1:])
        if s not in rows or s - SEEN not in rows:
            continue
        hd, _ = rows[s]
        if hd[4] != "0" or hd[5] != "0":
            continue   # banked moves start from standing or walking on a girder
        x, y, ham = int(hd[2]), int(hd[3]), 1 if hd[6] != "0" else 0
        kong = kage = fc = None
        for q in rows[s - SEEN][1]:
            if q.startswith("K "):
                _, kong, kage, _ = q.split()
        for q in rows[s][1]:
            if q.startswith("K "):
                fc = q.split()[3]
        bs = []
        for q in rows[s - SEEN][1]:
            if q.startswith("B"):
                _, bx, by, bd, bc = q.split()
                bs.append((int(bx) - x, int(by) - y, {"2": 2, "4": 4}.get(bd, 0), 1 if bc != "0" else 0))
        if not bs:
            continue
        n += 1
        lines.append(f"  {{src = {gid}, fl = {floor(y)}, x = {x}, ham = {ham}, b = {{" + ", ".join(f"{{{dx}, {dy}, {d}, {c}}}" for dx, dy, d, c in sorted(bs))
                     + f"}}, plan = {{a = {a}, w = {w}, j1 = {j1}, j2 = {j2}, h = {h}}}, early = {early}"
                     + (f", kong = {kong}, kage = {kage}, fc = {fc}" if kong is not None else "") + "},")
open(sys.argv[1], "w").write("-- banked solutions (tools/bank.py)\nreturn {\n" + "\n".join(lines) + "\n}\n")
print(f"{n} solutions banked -> {sys.argv[1]}")
