#!/usr/bin/env python3
"""overnight_rules.py SOURCE TAG FIRST: the review-to-rule cycle, unattended (Matt, 2026-11-12: keep increasing the % overnight).
1. SOURCE's barrel deaths while jumping (a fresh 5-1 run with today's settings), one from each of the biggest spots (girder, 20 px).
2. Each is ground in its own game (grind_review.py) with a general set of moves at every moment where his own play mostly dies;
   the move that lives there most (6/8 or better) is its fix.
3. Each fix becomes a narrow situation rule (review_rules.py): every instance in 10,000 fresh games, every move tried; kept if the
   best move gains where it matters and costs under 2 points where he lives anyway, with a positive net.
4. Kept rules: two fresh checks with today's settings plus them; a rule stays only if it saves more than it loses where it acted
   in both; those are added to levels[5].setups. Log: runs/overnight_rules_TAG.txt; status on the website."""
import collections, glob, json, os, re, subprocess, sys

H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC, TAG, FIRST = sys.argv[1], sys.argv[2], int(sys.argv[3])
out = open(f"{H}/runs/overnight_rules_{TAG}.txt", "a")
MOVES = ["0 0 0 nil 0", "0 4 0 nil 0", "0 0 2 nil 2", "0 0 1 nil 1", "0 4 2 nil 2", "0 4 1 nil 1",
         "1 8 0 nil 1", "1 8 2 nil 1", "1 16 2 nil 1", "2 8 0 nil 2", "2 8 1 nil 2", "0 20 nil nil nil", "1 8 nil nil nil", "2 8 nil nil nil"]


def log(t):
    print(t, file=out, flush=True); print(t, flush=True)


def say(t):
    subprocess.run([sys.executable, f"{H}/tools/say.py", t])


def sh(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, cwd=H).stdout


def batch(name, first, note, sets=()):
    subprocess.run([sys.executable, "tools/run_batch.py", name, "--level", "5", "--games", "10000", "--first", str(first), "--native",
                    "--note", note, *sets], cwd=H, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL)


def current_setups():
    """levels[5].setups as Lua text, read from params.lua"""
    lua = f"local p = dofile('{H}/lua/params.lua'); local function ser(v) if type(v) == 'table' then local t = {{}}; for k, x in pairs(v) do if type(k) == 'number' then t[#t + 1] = ser(x) else t[#t + 1] = k .. '=' .. ser(x) end end; return '{{' .. table.concat(t, ',') .. '}}' elseif type(v) == 'string' then return string.format('%q', v) else return tostring(v) end end; local s = {{}}; for _, x in ipairs(p.levels[5].setups or {{}}) do s[#s + 1] = ser(x) end; print(table.concat(s, ','))"
    open(f"{H}/runs/.ser.lua", "w").write(lua)
    return subprocess.run([os.path.expanduser("~/mame-0264-lto/3rdparty/lua/src/lua") if os.path.exists(os.path.expanduser("~/mame-0264-lto/3rdparty/lua/src/lua")) else "lua", f"{H}/runs/.ser.lua"],
                          capture_output=True, text=True).stdout.strip()


def main():
    games = [json.loads(l) for p in glob.glob(f"{H}/runs/{SRC}/games_*.jsonl") for l in open(p)]
    d = [g for g in games if g["outcome"] == "died" and "barrel" in g["cause"] and g["doing"].startswith("jumping")]
    by = collections.defaultdict(list)
    for g in d: by[(g["floor"], g["x"] // 20)].append(g)
    spec = f"{H}/runs/{SRC}/auto_{TAG}.spec"
    if len(sys.argv) > 4:
        # Matt's review: his fixes for these deaths (SPEC lines "ID | note | moves"), not a general list
        spec = sys.argv[4]
        log(f"grinding Matt's fixes from {spec}"); say("Grinding Matt's fixes for his reviewed deaths, each in its own game")
    else:
        pick = []
        for k, v in sorted(by.items(), key=lambda kv: -len(kv[1]))[:12]:
            v.sort(key=lambda g: g["id"]); pick += v[:2]                       # two from each of the 12 biggest spots
        log(f"{len(d)} barrel deaths while jumping in {SRC}; grinding {len(pick)} from the 12 biggest spots")
        say(f"Overnight: grinding {len(pick)} jumping deaths from the 12 most common spots, to find what saves each")
        open(spec, "w").write("".join(f"{g['id']} | girder {g['floor']} x={g['x']} | {'; '.join(MOVES)}\n" for g in pick))
    subprocess.run([sys.executable, "tools/grind_review.py", SRC, spec, "--seeds", "8", "--back", "72", "--step", "4"], cwd=H,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    fixes = []
    cur = None
    for l in open(spec + ".out"):
        m = re.match(r"(\d+) \(", l)
        if m: cur = m.group(1); best = None; continue
        m = re.match(r"\s+(\d+) frames before: his own (\d+)/(\d+); (.*)", l)
        if m and cur:
            back = int(m.group(1))
            for mv, w, n in re.findall(r"(\d+ \d+ \S+ nil \S+) (\d+)/(\d+)", m.group(4)):
                if int(w) >= 6 and int(m.group(2)) <= 2 and not any(f[1] == cur for f in fixes):
                    fixes.append((SRC, cur, back, mv))
    log(f"fixes found: {len(fixes)}: " + "; ".join(f"{g} {b} before: {m}" for _, g, b, m in fixes))
    if not fixes:
        say("Overnight: no fix found for these deaths"); return
    rspec = f"{H}/runs/review_rules_{TAG}.spec"
    open(rspec, "w").write("".join(f"{b} | {g} | {back} | {mv} | auto\n" for b, g, back, mv in fixes))
    say(f"Overnight: turning {len(fixes)} fixes into rules for their situations and trying every move at every instance")
    det = f"{TAG}r"
    r = subprocess.run([sys.executable, "tools/review_rules.py", rspec, det, str(FIRST)], cwd=H, capture_output=True, text=True)
    open(f"{H}/runs/review_rules_{TAG}.log", "w").write(r.stdout + r.stderr)
    dets = {m.group(1): m.group(2) for m in re.finditer(r'^(r\d+) = .*?: (\{.*detect=true,name="r\d+"\})$', r.stdout, re.M)}
    cands = []
    for nm, dt in dets.items():
        jf = f"{H}/runs/{det}00/setup_{nm}.json"
        if not os.path.exists(jf): continue
        j = json.load(open(jf)); hard, easy = j["hard"], j["easy"]
        rate = lambda dd, m: dd.get(m, [0, 0])[0] / max(dd.get(m, [0, 1])[1], 1)
        ph = j["moments"] / max(j.get("all_moments", j["instances"]), 1)
        nh, ne = rate(hard, ""), rate(easy, "")
        best = max((m for m in hard if m), key=lambda m: ph * (rate(hard, m) - nh) + (1 - ph) * (rate(easy, m) - ne), default=None)
        if not best: continue
        net = ph * (rate(hard, best) - nh) + (1 - ph) * (rate(easy, best) - ne)
        log(f"{nm}: {j['instances']} instances, {j['moments']} matter; best {best}: {rate(hard, best):.0%} vs {nh:.0%} there, {rate(easy, best):.0%} vs {ne:.0%} elsewhere; net {net:+.2%}")
        if j["moments"] >= 4 and net > 0 and rate(easy, best) >= ne - float(os.environ.get("COST", "0.02")) and rate(hard, best) > nh:
            a, w, j1, j2, h = best.split()
            rule = dt.replace(f'detect=true,name="{nm}"', f'move={{a={a},w={w},j1={j1},j2={j2},h={h}}},name="{TAG}{nm}"')
            cands.append((f"{TAG}{nm}", rule)); log(f"  -> candidate {TAG}{nm}: {rule}")
    if not cands:
        say("Overnight: no situation rule passed its trials"); log("no candidates"); return
    base = current_setups()
    tally = collections.defaultdict(lambda: [0, 0])
    keep = [c for c in cands]
    for k, first in enumerate((FIRST + 100000, FIRST + 200000)):
        say(f"Overnight: fresh check {k + 1} of {len(keep)} new rules from ground deaths")
        sets = ["--set", "setups={" + ",".join(([base] if base else []) + [r for _, r in keep]) + "}"]
        batch(f"{TAG}c{k}0", first, f"5-1 fresh reference (check {k + 1} of overnight rules)")
        batch(f"{TAG}c{k}1", first, f"5-1 check {k + 1}: overnight rules from ground deaths", sets)
        log(sh(f"python3 tools/compare.py {TAG}c{k}0 {TAG}c{k}1 | grep -E '^{TAG}|saved' | cut -c1-170"))
        rep = sh(f"python3 tools/rule_report.py {TAG}c{k}0 {TAG}c{k}1 0 | grep remembers"); log(rep)
        now = {}
        for m in re.finditer(r"remembers (\S+): .*?saved (\d+), lost (\d+)", rep):
            now[m.group(1)] = (int(m.group(2)), int(m.group(3)))
        keep = [(n, r) for n, r in keep if now.get(n, (0, 0))[0] > now.get(n, (0, 0))[1]]
        for n, _ in keep: tally[n][0] += now[n][0]; tally[n][1] += now[n][1]
        if not keep: break
    if not keep:
        say("Overnight: no new rule held up on fresh games"); log("none kept"); return
    p = f"{H}/lua/params.lua"; s = open(p).read(); old = s
    a = '{5,209,221,needs={{0,12,28,"e"}},move={a=1,w=16,j1=2,j2=nil,h=1},name="r7"}},'
    if a not in s:
        log("couldn't find the end of levels[5].setups; rules not added: " + "; ".join(r for _, r in keep)); return
    add = "".join(f"\n                -- overnight {TAG} (ground from {SRC}): two fresh checks where it acted {tally[n][0]} saved / {tally[n][1]} lost\n                {r}," for n, r in keep)
    s = s.replace(a, a[:-2] + "," + add.rstrip(",") + "},", 1)
    open(p, "w").write(s)
    if subprocess.run(["luac", "-p", p]).returncode != 0:
        open(p, "w").write(old); log("params.lua didn't parse; put back")
    else:
        log("adopted: " + ", ".join(f"{n} ({tally[n][0]} / {tally[n][1]})" for n, _ in keep))
        say(f"Overnight: {len(keep)} new rule(s) from ground deaths now on for 5-1")


if __name__ == "__main__":
    main()
