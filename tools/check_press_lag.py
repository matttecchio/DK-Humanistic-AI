#!/usr/bin/env python3
"""check_press_lag.py: second fresh checks of press_lag = 1 on 4-1 and 2-1 (2026-11-12; first checks 4-1 94.74 -> 95.39,
402 / 340; 2-1 97.62 -> 98.62, 232 / 132). Adopted per level if it wins again (higher, more saved than lost). Log in
runs/check_press_lag.txt."""
import os, re, subprocess, sys

H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
out = open(f"{H}/runs/check_press_lag.txt", "a")


def log(t):
    print(t, file=out, flush=True); print(t, flush=True)


def sh(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, cwd=H).stdout


def batch(name, level, first, note, sets=()):
    subprocess.run([sys.executable, "tools/run_batch.py", name, "--level", str(level), "--games", "10000", "--first", str(first),
                    "--native", "--note", note, *sets], cwd=H, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL)


def adopt(level):
    p = f"{H}/lua/params.lua"; s = open(p).read(); old = s
    key = f"    [{level}] = {{"
    i = s.index(key); j = s.index("\n", i)          # levels 1-4 are one line each
    line = s[i:j]
    if "press_lag = " in line:
        line = re.sub(r"press_lag = \d+", "press_lag = 1", line, count=1)
    else:
        line = line.replace(key, key + "press_lag = 1, ", 1)
    s = s[:i] + line + s[j:]
    open(p, "w").write(s)
    if subprocess.run(["luac", "-p", p]).returncode != 0:
        open(p, "w").write(old); log(f"  level {level}: params.lua didn't parse, put back")
    else:
        log(f"  adopted press_lag = 1 on level {level}")


for level, first in ((4, 11650000), (2, 11750000)):
    batch(f"pk{level}0", level, first, f"{level}-1 fresh reference (second check of the 1-frame jump allowance)")
    batch(f"pk{level}1", level, first, f"{level}-1 second check: the planner allows 1 frame for a jump press to take effect", ["--set", "press_lag=1"])
    t = sh(f"python3 tools/compare.py pk{level}0 pk{level}1")
    pct = {m.group(1): float(m.group(2)) for m in re.finditer(r"^(\S+) 10000 ([\d.]+)%", t, re.M)}
    m = re.search(r"(\d+) saved (\d+) lost", t); sv, lo = (int(m.group(1)), int(m.group(2))) if m else (0, 0)
    b, n = pct.get(f"pk{level}0"), pct.get(f"pk{level}1")
    log(f"{level}-1 second check: {b}% -> {n}%, saved {sv} lost {lo}")
    if b is not None and n is not None and n > b and sv > lo:
        adopt(level)
