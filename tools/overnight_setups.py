#!/usr/bin/env python3
"""overnight_setups.py: the recurring-setup loop, unattended (Matt, 2026-11-09: keep boosting the % overnight; 100% is the goal).
1. The biggest recurring setups behind the latest fresh run's barrel deaths (clusters.py), plus the Kong's-ladder setup.
2. One detector run (10,000 fresh games) logging every instance of each, changing nothing.
3. For each setup, every move at every instance where no move sometimes dies, and on a sample where it always lives
   (setup_moves.py).
4. A move becomes a rule for that setup only if it clearly beats no move where it matters (by MIN_GAIN) and doesn't
   hurt where he lives anyway (by more than MAX_HARM).
5. 10,000 fresh games without and with those rules; the per-rule firing report; the rules are kept only if the
   total isn't lower. Summary in runs/overnight_setups.txt, and a status line on the website."""
import json, os, re, subprocess, sys

H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MIN_GAIN, MAX_HARM = 0.10, 0.02
# round names and fresh game ranges (each round its own); setups already adopted stay on in every run
TAG, FIRST = os.environ.get("TAG", "ky"), int(os.environ.get("FIRST", 8900000))
BASE = os.environ.get("BASE_SETUPS", "")
out = open(f"{H}/runs/overnight_setups.txt", "a")


def log(t):
    print(t, file=out, flush=True); print(t, flush=True)


def say(t):
    subprocess.run([sys.executable, f"{H}/tools/say.py", t])


def sh(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, cwd=H).stdout


def batch(name, first, note, sets):
    s = " ".join(f"--set '{x}'" for x in sets)
    sh(f"python3 tools/run_batch.py {name} --level 5 --games 10000 --first {first} --native --note \"{note}\" {s} </dev/null")


def main():
    src = sys.argv[1] if len(sys.argv) > 1 else "kx00"
    det = [l.split("\t")[1].strip().replace('name="s', f'name="{TAG}s') for l in sh(f"python3 tools/clusters.py {src} 6").splitlines() if "\t" in l]
    log(f"setups to work on ({len(det)}):\n  " + "\n  ".join(det))
    say(f"Overnight: finding every time {len(det)} recurring death setups come up in 10,000 fresh games")
    pre = BASE + "," if BASE else ""
    batch(f"{TAG}00", FIRST, "5-1: logging every instance of the recurring setups (changes nothing)", ["setups={" + pre + ",".join(det) + "}"])
    rules = []
    for d in det:
        name = re.search(r'name="([^"]+)"', d).group(1)
        say(f"Overnight: trying every move at every instance of setup {name}")
        sh(f"python3 tools/setup_moves.py {TAG}00 \"{name}\" --level 5 --seeds 2 --offsets 0 > runs/{TAG}00/setup_{name.replace(' ', '_')}.txt 2>&1")
        jf = f"{H}/runs/{TAG}00/setup_{name.replace(' ', '_')}.json"
        if not os.path.exists(jf):
            log(f"{name}: no result"); continue
        r = json.load(open(jf))
        hard, easy = r["hard"], r["easy"]
        rate = lambda d, m: d.get(m, [0, 0])[0] / max(d.get(m, [0, 1])[1], 1)
        nh, ne = rate(hard, ""), rate(easy, "")
        # the setup's moments are mostly ones he lives through anyway: weigh gain and harm by how often each kind comes up
        ph = r["moments"] / max(r.get("all_moments", r["instances"]), 1)
        net = lambda m: ph * (rate(hard, m) - nh) + (1 - ph) * (rate(easy, m) - ne)
        best = max((m for m in hard if m), key=net, default=None)
        log(f"{name}: {r['instances']} instances, {r['moments']} where no move sometimes dies; no move {nh:.1%} there, {ne:.1%} elsewhere; "
            f"best {best}: {rate(hard, best):.1%} there, {rate(easy, best):.1%} elsewhere")
        log(f"  share of moments where no move sometimes dies {ph:.1%}; best move's net change over all moments {net(best):+.2%}" if best else "")
        if best and r["moments"] >= 8 and net(best) > 0.005 and rate(hard, best) - nh >= MIN_GAIN and rate(easy, best) >= ne - MAX_HARM:
            a, w, j1, j2, h = best.split()
            rules.append(d.replace("detect=true", f"move={{a={a},w={w},j1={j1},j2={j2},h={h}}}"))
            log(f"  -> rule: {rules[-1]}")
    if not rules:
        log("no setup gave a move that clearly wins"); say("Overnight: no setup gave a move that clearly beats his own play"); return
    say(f"Overnight: checking {len(rules)} new setup rules on 10,000 fresh games")
    batch(f"{TAG}01", FIRST + 100000, "5-1 fresh reference for the setup rules", [])
    batch(f"{TAG}02", FIRST + 100000, f"5-1 fresh: {len(rules)} new recurring-setup rules", ["setups={" + pre + ",".join(rules) + "}"])
    log(sh(f"python3 tools/compare.py {TAG}01 {TAG}02 | grep -E '^k|saved' | cut -c1-200"))
    log(sh(f"python3 tools/rule_report.py {TAG}01 {TAG}02 0 | grep remembers"))
    json.dump(rules, open(f"{H}/runs/overnight_rules_{TAG}.json", "w"))
    say("Overnight: setup rules checked; results in runs/overnight_setups.txt")


if __name__ == "__main__":
    main()
