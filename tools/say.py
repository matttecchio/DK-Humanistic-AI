#!/usr/bin/env python3
"""Posts a line to the "What's happening" panel on the website: say.py "Testing a new idea" """
import json, os, sys, time
H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
path = f"{H}/runs/status.json"
try:
    log = json.load(open(path))
except (OSError, ValueError):
    log = []
log.append({"t": time.time(), "text": " ".join(sys.argv[1:])})
tmp = path + ".tmp"
json.dump(log[-6:], open(tmp, "w"))
os.replace(tmp, path)
