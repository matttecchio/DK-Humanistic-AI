#!/usr/bin/env python3
"""inp_rivets.py TRACE: an expert's rivet boards from tools/inp_trace.lua (BOARD=4): per board, the order and time (s) each rivet
comes out (from the rivet count 0x6290 dropping, and where Mario is), when each hammer is taken (0x6681 / 0x6691), and whether
the board was cleared or a life was lost (the next start's lives). (Matt, 2026-11-15: add barra's rivets to the learnings.)"""
import sys, collections
RIV = {(200, 0): "2L", (200, 1): "2R", (160, 0): "3L", (160, 1): "3R", (120, 0): "4L", (120, 1): "4R", (80, 0): "5L", (80, 1): "5R"}
boards, cur, last_lives = [], None, None
for l in open(sys.argv[1]):
    if l.startswith("start "):
        p = l.split(); lives = int(p[6])
        if cur is not None and cur.get("lives") is not None and lives < cur["lives"] and cur["end"] is None: cur["end"] = "died"
        if cur is not None and not cur.get("next_lives"): cur["next_lives"] = lives
        continue
    if l.startswith("board "):
        p = l.split(); cur = {"id": int(p[1]), "level": int(p[3]), "f0": int(p[7]), "ev": [], "end": None, "rl": 8, "h0": 0, "h1": 0}; boards.append(cur); continue
    if l.startswith("end "):
        continue
    if cur is None or "|" not in l: continue
    parts = l.rstrip("\n").split("|"); h = parts[0].split()
    f, x, y = int(h[1]), int(h[2]), int(h[3])
    t = (f - cur["f0"]) / 60
    for q in parts[1:]:
        if q.startswith("H "): _, on, held = q.split(); held = int(held)
        if q.startswith("R "):
            _, rl, ton, theld = q.split(); rl, theld = int(rl), int(theld)
            if rl < cur["rl"]:
                gird = min((200, 160, 120, 80), key=lambda g: abs(g - y)); side = 0 if x < 128 else 1
                cur["ev"].append((round(t, 1), RIV[(gird, side)])); cur["rl"] = rl
            if theld and not cur["h1"]: cur["h1"] = 1; cur["ev"].append((round(t, 1), "top hammer"))
    if held and not cur["h0"] and x < 128: cur["h0"] = 1; cur["ev"].append((round(t, 1), "bottom hammer"))
for b in boards:
    end = "cleared" if b["rl"] == 0 else "life lost"
    print(f'{b["id"]:3d} L{b["level"]:02d} {end:9s} ' + " ".join(f"{k}@{t}" for t, k in b["ev"]))
