#!/usr/bin/env python3
"""inp_check.py [DIR]: which players' .inp recordings replay correctly on our MAME 0.264 (Matt, 2026-11-10: use the top ~50
players' INPs to add to what he's learned; they come from different MAME versions, so test which ones work).
Each .inp in DIR (default ~/dkong-human/inps; zips are unpacked first) is played back at full speed with the TAS project's
passive logger (~/dkong-fullgame-tas/playlog.lua: a line per board start and per score change, changing nothing). A recording
in sync reaches the score its player claims (in the file name, e.g. "Player 1234500.inp", or ask Matt), so the result lists
each file's last score, how many boards it played and how far it got. Note: MAME opens a window (black on this Mac) while
it runs. Results in DIR/check.txt."""
import glob, os, re, subprocess, sys, zipfile

DIR = os.path.expanduser(sys.argv[1] if len(sys.argv) > 1 else "~/dkong-human/inps")
MAME = os.path.expanduser("~/mame-0264-lto/dkong")
LOG = os.path.expanduser("~/dkong-fullgame-tas/playlog.lua")

for z in glob.glob(f"{DIR}/*.zip"):
    with zipfile.ZipFile(z) as zf:
        for n in zf.namelist():
            if n.lower().endswith(".inp") and not os.path.exists(os.path.join(DIR, os.path.basename(n))):
                open(os.path.join(DIR, os.path.basename(n)), "wb").write(zf.read(n))
out = open(f"{DIR}/check.txt", "a")
for inp in sorted(glob.glob(f"{DIR}/*.inp")):
    name = os.path.basename(inp)
    claim = max((int(x) for x in re.findall(r"\d{5,7}", name)), default=None)
    try:
        logf = f"{DIR}/{name}.log"
        env = dict(os.environ, LOG=logf)
        extra = ["-seconds_to_run", os.environ["SECONDS"]] if os.environ.get("SECONDS") else []
        r = subprocess.run([MAME, "dkong", "-rompath", os.path.expanduser("~/.mame/roms"), "-input_directory", DIR, "-playback", name,
                            "-autoboot_script", LOG, "-nothrottle", "-exit_after_playback", "-video", "none", "-sound", "none", "-skip_gameinfo"] + extra,
                           capture_output=True, text=True, timeout=3 * 3600, env=env)
        err = r.stdout + r.stderr
    except subprocess.TimeoutExpired:
        err = "timed out"
    text = open(logf).read() if os.path.exists(logf) else ""
    scores = [int(x) for x in re.findall(r"^score (\d+)", text, re.M)]
    boards = len(re.findall(r"^start ", text, re.M))
    bad = not text
    last = scores[-1] if scores else 0
    ok = claim is not None and last == claim
    line = (f"{name}: last score {last:,}, {boards} board starts" + (f", claimed {claim:,}" if claim else "")
            + (" -> IN SYNC" if ok else " -> out of sync or unknown" if not bad else " -> MAME could not play it"))
    print(line, flush=True); print(line, file=out, flush=True)
    if bad:
        open(f"{DIR}/{name}.err", "w").write(err)
