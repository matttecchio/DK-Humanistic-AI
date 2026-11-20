#!/usr/bin/env python3
"""review_rules.py SPEC NAME FIRST: Matt's confirmed review fixes as narrow setup rules, tested where they apply (2026-11-12;
Matt: rare-situation fixes are judged by the games where they act). SPEC lines: "BATCH ID | frames before the death | move |
label" (the moment and move where his fix lived and his own play died, from grind_review.py). For each: the situation at that
moment from the death's trace (his girder and x within 6 px; every barrel on his girder or the one above within 60 px, same way
of rolling or on a ladder, within 8 px) becomes a detector; one fresh 5-1 batch (10,000 games from FIRST) logs every time each
comes up; then setup_moves.py tries every move (Matt's among them) at every instance. Results in runs/<NAME>00/setup_*.txt."""
import os, subprocess, sys
H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
lv = lambda y: 6 if y < 95 else 5 if y < 125 else 4 if y < 160 else 3 if y < 195 else 2 if y < 225 else 1
spec, name, first = sys.argv[1], sys.argv[2], sys.argv[3]
import json, glob
dets = []
ladder_dets = set()
for l in open(spec):
    if not l.strip() or l.startswith("#"): continue
    batch, gid, back, move, label = (x.strip() for x in l.split("|"))
    tr = f"{H}/runs/{batch}/autopsy/{gid}.trace"
    if not os.path.exists(tr):
        subprocess.run([sys.executable, f"{H}/tools/autopsy.py", batch, "--ids", gid], env=dict(os.environ, TRACE_ONLY="1"),
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    games = {json.loads(x)["id"]: json.loads(x) for p in glob.glob(f"{H}/runs/{batch}/games_*.jsonl") for x in open(p)}
    s = games[int(gid)]["frames"] - int(back)
    row = None
    for x in open(tr):
        p = x.rstrip("\n").split("|")
        if int(p[0].split()[1]) == s: row = p; break
    if not row: print(f"{gid}: no trace row at {s}"); continue
    hd = row[0].split(); mx, my = int(hd[2]), int(hd[3]); fl = lv(my)
    on_lad = hd[4] != "0"
    DROPS = {6: [106, 202], 5: [52, 92, 188], 4: [82, 130, 202], 3: [52, 116], 2: [99, 203]}
    needs = []
    for q in row[1:]:
        if not q.startswith("B"): continue
        _, bx, by, bd, bc = q.split(); bx, by, bd = int(bx), int(by), int(bd)
        off = lv(by) - fl
        # (2026-11-13, wider: Matt's #6 / #9 hang on barrels further off and higher up) up to 90 px, up to two girders up
        if bc != "0" or off not in (0, 1, 2) or abs(bx - mx) > 90: continue
        dr = "R" if bd == 2 else "L" if bd == 4 else "e"
        need = f'{{{off},{bx - mx - 8},{bx - mx + 8},"{dr}"'
        # rolling on a girder above towards a ladder of it within 40 px: how far short of that ladder (the moment steering decides)
        if off >= 1 and dr in "LR":
            side = 1 if dr == "R" else -1
            ahead = [d for d in DROPS.get(lv(by), []) if 0 <= (d - bx) * side <= 40]
            if ahead:
                d = min(ahead, key=lambda d: (d - bx) * side)
                need += f',{d},{(d - bx) * side - 6},{(d - bx) * side + 6}'
        needs.append(need + "}")
    if not needs: print(f"{gid}: no barrels near; skipped"); continue
    nm = f"r{len(dets) + 1}"
    lad = f",lad={{{my - 8},{my + 8}}}" if on_lad else ""
    dets.append(f'{{{fl},{mx - (4 if on_lad else 6)},{mx + (4 if on_lad else 6)},needs={{{",".join(needs)}}}{lad},detect=true,name="{nm}"}}')
    if on_lad: ladder_dets.add(nm)
    print(f"{nm} = {label} (game {gid}, {back} before, move {move}): {dets[-1]}", flush=True)
# the rules on now (levels[5].setups), so the trials see the same play as a real game (they were last week's s1 and s3 by mistake)
_ser = ("local p = dofile('%s/lua/params.lua'); local function ser(v) if type(v) == 'table' then local t = {}; for k, x in pairs(v) do "
        "if type(k) == 'number' then t[#t + 1] = ser(x) else t[#t + 1] = k .. '=' .. ser(x) end end; return '{' .. table.concat(t, ',') .. '}' "
        "elseif type(v) == 'string' then return string.format('%%q', v) else return tostring(v) end end; local s = {}; "
        "for _, x in ipairs(p.levels[5].setups or {}) do s[#s + 1] = ser(x) end; print(table.concat(s, ','))") % H
B = subprocess.run(["lua", "-e", _ser], capture_output=True, text=True).stdout.strip()
det = f"{name}00"
subprocess.run([sys.executable, "tools/run_batch.py", det, "--level", "5", "--games", "10000", "--first", first, "--native", "--note",
                "5-1: logging every time the situations from Matt's reviewed deaths come up (changes nothing)", "--set", "setups={" + B + "," + ",".join(dets) + "}"],
               cwd=H, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL)
for i in range(1, len(dets) + 1):
    nm = f"r{i}"
    with open(f"{H}/runs/{det}/setup_{nm}.txt", "w") as f:
        subprocess.run([sys.executable, "tools/setup_moves.py", det, nm, "--level", "5", "--seeds", "2"] + (["--ladder"] if nm in ladder_dets else []),
                       cwd=H, stdout=f, stderr=subprocess.STDOUT)
    print(f"== {nm}", flush=True); print("".join(open(f"{H}/runs/{det}/setup_{nm}.txt").readlines()[:8]), flush=True)
