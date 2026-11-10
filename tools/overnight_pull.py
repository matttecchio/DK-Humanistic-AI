#!/usr/bin/env python3
"""overnight_pull.py (2026-11-10 night; Matt: if there's nothing else to do, see whether the day's learnings raise the earlier
barrel boards, or solve more scenarios). 1. Waits for the second 5-1 check of pulling barrels down (lp10 / lp12); adopts
steer_pull = 8 + pull_moving on level 5 if it wins again (+0.1 points and more saved than lost). 2. The same pull on 4-1, 3-1,
2-1 (fresh reference and pull run, 10,000 games each); adopted per level on the same bar. 1-1: tested and reported only (no
regressions without Matt). 3. Traces the remaining 5-1 barrel deaths and reruns the expert comparison on them.
Everything goes to runs/overnight_pull.txt and the website's status line."""
import json, os, re, subprocess, sys, time

H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
out = open(f"{H}/runs/overnight_pull.txt", "a")
PULL = ["--set", "steer_pull=8", "--set", "pull_moving=true"]


def log(t):
    print(t, file=out, flush=True); print(t, flush=True)


def say(t):
    subprocess.run([sys.executable, f"{H}/tools/say.py", t])


def sh(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, cwd=H).stdout


def batch(name, level, first, note, sets=()):
    subprocess.run([sys.executable, "tools/run_batch.py", name, "--level", str(level), "--games", "10000", "--first", str(first),
                    "--native", "--note", note, *sets], cwd=H, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL)


def result(base, new):
    t = sh(f"python3 tools/compare.py {base} {new}")
    pct = {m.group(1): float(m.group(2)) for m in re.finditer(r"^(\S+) 10000 ([\d.]+)%", t, re.M)}
    m = re.search(r"(\d+) saved (\d+) lost", t)
    return pct.get(base), pct.get(new), (int(m.group(1)), int(m.group(2))) if m else (0, 0), t


def adopt(level):
    p = f"{H}/lua/params.lua"; s = open(p).read()
    key = f"    [{level}] = {{"
    if key not in s:
        log(f"  could not find levels[{level}] in params.lua"); return
    old = s
    i = s.index(key); j = s.find("\n    [", i + len(key)); j = len(s) if j < 0 else j
    block = s[i:j]
    if "steer_pull = " in block:       # the level's own value would win over a second one, so replace it
        block = re.sub(r"steer_pull = [\d.]+", "steer_pull = 8, pull_moving = true", block, count=1)
    else:
        block = block.replace(key, key + "steer_pull = 8, pull_moving = true, ", 1)
    s = s[:i] + block + s[j:]
    open(p, "w").write(s)
    if subprocess.run(["luac", "-p", p]).returncode != 0:
        log("  params.lua no longer parses: put back"); open(p, "w").write(old)
    else:
        log(f"  adopted on level {level}")


def wins(b, n, sl):
    return b is not None and n is not None and n - b >= 0.1 and sl[0] > sl[1]


def main():
    while not os.path.exists(f"{H}/runs/lp12") or sum(1 for p in os.listdir(f"{H}/runs/lp12") if p.startswith("games_")) == 0 or \
            int(sh("cat runs/lp12/games_*.jsonl | wc -l").strip() or 0) < 10000:
        time.sleep(60)
    time.sleep(60)
    b, n, sl, t = result("lp10", "lp12")
    log(f"5-1 second check of pulling: {b}% -> {n}%, saved {sl[0]} lost {sl[1]}")
    if wins(b, n, sl):
        adopt(5); say(f"Pulling barrels down like the experts: 5-1 {b}% to {n}% on a second check, now on")
    else:
        say(f"Pulling barrels down: second 5-1 check {b}% to {n}%, not adopted")
    for level, first in ((4, 10200000), (3, 10300000), (2, 10400000), (1, 10500000)):
        say(f"Overnight: does pulling barrels down like the experts help level {level}-1 too? (10,000 fresh games each way)")
        batch(f"pl{level}0", level, first, f"{level}-1 fresh reference for pulling barrels down")
        batch(f"pl{level}1", level, first, f"{level}-1: pulls barrels down a downstream ladder from 8 frames ahead, while walking too", PULL)
        b, n, sl, t = result(f"pl{level}0", f"pl{level}1")
        log(f"{level}-1: {b}% -> {n}%, saved {sl[0]} lost {sl[1]}")
        if level == 1:
            log("  1-1: reported only (no regressions without Matt)")
        elif wins(b, n, sl):
            adopt(level)
    # what's left on 5-1: trace the deaths of a fresh run with today's settings and compare them with the experts again
    say("Overnight: tracing the 5-1 barrel deaths that are left and comparing them with the experts again")
    batch("pz00", 5, 10600000, "5-1 fresh, today's settings: the deaths that are left")
    ids = sh("""python3 -c "
import json,glob
gs=[json.loads(l) for p in glob.glob('runs/pz00/games_*.jsonl') for l in open(p)]
print(','.join(str(g['id']) for g in gs if g['outcome']=='died' and 'barrel' in g['cause']))" """).strip()
    sh(f"python3 tools/autopsy.py pz00 --ids {ids}")
    sh("python3 tools/expert_match.py pz00 --trials 6 > runs/pz00/expert_match.txt 2>&1")
    log(sh("tail -1 runs/pz00/expert_match.txt"))
    log(sh("python3 tools/compare.py pz00 | head -1 | cut -c1-160"))
    say("Overnight work done: results in runs/overnight_pull.txt")


if __name__ == "__main__":
    main()
