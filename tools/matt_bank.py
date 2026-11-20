#!/usr/bin/env python3
"""matt_bank.py SPEC TAG FIRST: Matt's confirmed fixes as tight scenario rules (2026-11-13; Matt: "my solutions have been correct for
the scenarios"). Each fix's scenario at its moment (from the death's trace: Mario's girder and x within 6 px, every barrel within 60 px on
his girder or the one above, each within 8 px and going the same way: tight, so it fires only in that scenario) gets Matt's move. Two
fresh checks with all of them on; a rule stays if, over both, it saved at least as many games as it lost where it fired (a rare
scenario can't show a big overall gain). Kept rules are added to levels[5].setups. Log runs/matt_bank_TAG.txt."""
import collections, glob, json, os, re, subprocess, sys
H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
spec, TAG, FIRST = sys.argv[1], sys.argv[2], int(sys.argv[3])
lv = lambda y: 6 if y < 95 else 5 if y < 125 else 4 if y < 160 else 3 if y < 195 else 2 if y < 225 else 1
out = open(f"{H}/runs/matt_bank_{TAG}.txt", "a")
def log(t): print(t, file=out, flush=True); print(t, flush=True)
def sh(c): return subprocess.run(c, shell=True, capture_output=True, text=True, cwd=H).stdout
rules = []
for l in open(spec):
    if not l.strip() or l.startswith("#"): continue
    batch, gid, back, move, label = (x.strip() for x in l.split("|"))
    tr = f"{H}/runs/{batch}/autopsy/{gid}.trace"
    if not os.path.exists(tr):
        subprocess.run([sys.executable, f"{H}/tools/autopsy.py", batch, "--ids", gid], env=dict(os.environ, TRACE_ONLY="1"), stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    games = {json.loads(x)["id"]: json.loads(x) for p in glob.glob(f"{H}/runs/{batch}/games_*.jsonl") for x in open(p)}
    s = games[int(gid)]["frames"] - int(back)
    row = next((x.rstrip("\n").split("|") for x in open(tr) if int(x.split("|")[0].split()[1]) == s), None)
    if not row: log(f"{label}: no trace row"); continue
    hd = row[0].split(); mx, my = int(hd[2]), int(hd[3]); fl = lv(my)
    if hd[4] != "0" or hd[5] != "0": log(f"{label}: not on a girder at that moment; skipped"); continue
    needs = []
    for q in row[1:]:
        if not q.startswith("B"): continue
        _, bx, by, bd, bc = q.split(); bx, by, bd = int(bx), int(by), int(bd)
        off = lv(by) - fl
        if bc != "0" or off not in (0, 1) or abs(bx - mx) > 60: continue
        dr = "R" if bd == 2 else "L" if bd == 4 else "e"
        needs.append(f'{{{off},{bx - mx - 8},{bx - mx + 8},"{dr}"}}')
    if not needs: log(f"{label}: no barrels near; skipped"); continue
    a, w, j1, j2, h = move.split()
    nm = f"m{len(rules) + 1}"
    tr_gate = os.environ.get("TROUBLE")   # only when his planner is struggling (best score below this)
    rules.append((nm, label, f'{{{fl},{mx - 6},{mx + 6},needs={{{",".join(needs)}}},move={{a={a},w={w},j1={j1},j2={j2},h={h}}}' + (f',trouble={tr_gate}' if tr_gate else '') + f',name="{nm}"}}'))
    log(f"{nm} = {label}: {rules[-1][2]}")
ser = ("local p = dofile('%s/lua/params.lua'); local function ser(v) if type(v) == 'table' then local t = {}; for k, x in pairs(v) do "
       "if type(k) == 'number' then t[#t + 1] = ser(x) else t[#t + 1] = k .. '=' .. ser(x) end end; return '{' .. table.concat(t, ',') .. '}' "
       "elseif type(v) == 'string' then return string.format('%%q', v) else return tostring(v) end end; local s = {}; "
       "for _, x in ipairs(p.levels[5].setups or {}) do s[#s + 1] = ser(x) end; print(table.concat(s, ','))") % H
base = subprocess.run(["lua", "-e", ser], capture_output=True, text=True).stdout.strip()
tally = collections.defaultdict(lambda: [0, 0, 0])
for k, first in enumerate((FIRST, FIRST + 100000)):
    sets = "setups={" + ",".join(([base] if base else []) + [r for _, _, r in rules]) + "}"
    subprocess.run([sys.executable, "tools/run_batch.py", f"{TAG}{k}0", "--level", "5", "--games", "10000", "--first", str(first), "--native", "--note", f"5-1 fresh reference (check {k + 1} of Matt's scenario rules)"], cwd=H, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL)
    subprocess.run([sys.executable, "tools/run_batch.py", f"{TAG}{k}1", "--level", "5", "--games", "10000", "--first", str(first), "--native", "--note", f"5-1 check {k + 1}: Matt's confirmed fixes as tight scenario rules", "--set", sets], cwd=H, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL)
    log(sh(f"python3 tools/compare.py {TAG}{k}0 {TAG}{k}1 | grep -E '^{TAG}|saved' | cut -c1-170"))
    rep = sh(f"python3 tools/rule_report.py {TAG}{k}0 {TAG}{k}1 0 | grep remembers"); log(rep)
    for m in re.finditer(r"remembers (m\d+): in (\d+) games.*?saved (\d+), lost (\d+)", rep):
        t = tally[m.group(1)]; t[0] += int(m.group(3)); t[1] += int(m.group(4)); t[2] += int(m.group(2))
keep = [(nm, lab, r) for nm, lab, r in rules if tally[nm][2] > 0 and tally[nm][0] >= tally[nm][1]]
for nm, lab, r in rules:
    t = tally[nm]; log(f"{nm} ({lab}): fired in {t[2]} games over both checks, saved {t[0]}, lost {t[1]} -> {'kept' if (nm, lab, r) in keep else 'not kept'}")
if keep:
    p = f"{H}/lua/params.lua"; s = open(p).read(); old = s
    a = '{5,209,221,needs={{0,12,28,"e"}},move={a=1,w=16,j1=2,j2=nil,h=1},name="r7"}},'
    if a in s:
        add = "".join(f"\n                -- Matt's fix ({lab}); two fresh checks where it fired: {tally[nm][0]} saved / {tally[nm][1]} lost\n                {r.replace(f'name=\"{nm}\"', f'name=\"{TAG}{nm}\"')}," for nm, lab, r in keep)
        s = s.replace(a, a[:-2] + "," + add.rstrip(",") + "},", 1); open(p, "w").write(s)
        if subprocess.run(["luac", "-p", p]).returncode != 0: open(p, "w").write(old); log("params didn't parse; put back")
        else: log("added: " + ", ".join(lab for _, lab, _ in keep))
    else: log("couldn't find the end of levels[5].setups")
