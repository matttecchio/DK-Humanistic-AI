#!/usr/bin/env python3
"""Read-only website for watching the games. It can only start the watch game; it can't change anything."""
import glob, json, os, re, signal, struct, subprocess, sys, threading, time, zlib
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse

H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, f"{H}/tools")
import stats

LIVE = f"{H}/runs/.live"
W, H_ = 256, 224
PORT = int(os.environ.get("PORT", 8765))
IDLE_STOP = 60  # seconds with nobody watching before the watch game stops
BASE_ID = 1_000_000

lock = threading.Lock()
proc = None
current = {"kind": None}
last_view = 0.0


def start_game(kind, replay=None):
    """Starts the game being watched at normal speed, replacing any previous one."""
    global proc, current
    with lock:
        stop_game_locked()
        os.makedirs(LIVE, exist_ok=True)
        env = dict(os.environ, DKH=H, LIVE=LIVE)
        if kind == "live":
            env.update(MODE="live", START_ID=str(BASE_ID + int(time.time()) % 100000))
        else:
            path = f"{LIVE}/replay.txt"
            with open(path, "w") as f:
                f.write(f"{replay['id']}\n{replay['start']}\n{replay['inp']}\n")
            env.update(MODE="replay", REPLAY=path, START_PREFIX=replay.get("prefix", "s"))
        proc = subprocess.Popen([f"{H}/tools/mame.sh", "-numprocessors", "1", "-samplerate", "1000", "-state_directory", f"{H}/starts",
                                 "-autoboot_script", f"{H}/lua/agent.lua"], env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        current = {"kind": kind, "id": replay["id"] if replay else None}


def stop_game_locked():
    global proc
    if proc and proc.poll() is None:
        proc.terminate()
        try:
            proc.wait(3)
        except subprocess.TimeoutExpired:
            proc.kill()
    proc = None


def watchdog():
    global current
    while True:
        time.sleep(5)
        if proc and time.time() - last_view > IDLE_STOP:
            with lock:
                stop_game_locked()
                current = {"kind": None}


def png_chunk(t, d):
    return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d))


def frame_png():
    """The machine's screen is sideways and BGRA: turn it upright into a PNG."""
    try:
        raw = open(f"{LIVE}/frame.raw", "rb").read()
    except OSError:
        return None
    if len(raw) != W * H_ * 4:
        return None
    rows = []
    for x in range(W - 1, -1, -1):
        row = bytearray(H_ * 3)
        col = x * 4
        row[0::3] = raw[col + 2::W * 4]
        row[1::3] = raw[col + 1::W * 4]
        row[2::3] = raw[col::W * 4]
        rows.append(b"\0" + bytes(row))
    return (b"\x89PNG\r\n\x1a\n" + png_chunk(b"IHDR", struct.pack(">IIBBBBB", H_, W, 8, 2, 0, 0, 0)) +
            png_chunk(b"IDAT", zlib.compress(b"".join(rows), 1)) + png_chunk(b"IEND", b""))


done = {}


def batches():
    out = []
    root = stats.RUNS
    for name in os.listdir(root):
        p = f"{root}/{name}/meta.json"
        if name.startswith(".") or not os.path.exists(p):
            continue
        m = json.load(open(p))
        # a finished batch never changes, so only read it once
        if "finished" in m and name in done:
            s = done[name]
        else:
            s = stats.summary(stats.load(name))
            if "finished" in m:
                done[name] = s
        out.append({**m, **s})
    out.sort(key=lambda b: -b.get("started", 0))
    return out


NAME_OK = re.compile(r"^[\w.-]+$")


class Handler(BaseHTTPRequestHandler):
    def log_message(self, *a):
        pass

    def send(self, body, ctype="application/json", code=200):
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        global last_view
        u = urlparse(self.path)
        q = parse_qs(u.query)
        if u.path == "/":
            return self.send(open(f"{H}/web/index.html", "rb").read(), "text/html; charset=utf-8")
        if u.path == "/api/version":
            return self.send(json.dumps(os.path.getmtime(f"{H}/web/index.html")).encode())
        if u.path == "/detail":
            return self.send(open(f"{H}/web/detail.html", "rb").read(), "text/html; charset=utf-8")
        if u.path == "/frame.png":
            last_view = time.time()
            png = frame_png()
            return self.send(png, "image/png") if png else self.send(b"", "text/plain", 503)
        if u.path == "/bg.png":
            return self.send(open(f"{H}/web/bg.png", "rb").read(), "image/png")
        if u.path == "/api/status":
            try:
                return self.send(open(f"{stats.RUNS}/status.json", "rb").read())
            except OSError:
                return self.send(b"[]")
        if u.path == "/api/totals":
            return self.send(json.dumps(stats.totals()).encode())
        if u.path == "/api/grid":
            out = []
            now = time.time()
            for p in sorted(glob.glob(f"{stats.grid_dir()}/*.json")):
                try:
                    if now - os.path.getmtime(p) < 4:
                        out.append(json.load(open(p)))
                except (OSError, ValueError):
                    pass            # the worker just replaced it
            return self.send(json.dumps(out).encode())
        if u.path == "/api/stop":
            with lock:
                stop_game_locked()
                current.clear()
                current["kind"] = None
            return self.send(b'{"ok":true}')
        if u.path == "/api/state":
            try:
                state = json.load(open(f"{LIVE}/state.json"))
            except (OSError, ValueError):
                state = {}
            state["watching"] = current.get("kind")
            state["running"] = bool(proc and proc.poll() is None)
            return self.send(json.dumps(state).encode())
        if u.path == "/api/batches":
            return self.send(json.dumps(batches()).encode())
        if u.path == "/api/games":
            name = q.get("batch", [""])[0]
            if not NAME_OK.match(name) or not os.path.isdir(f"{stats.RUNS}/{name}"):
                return self.send(b"[]", code=404)
            return self.send(json.dumps(stats.load(name)).encode())
        if u.path == "/api/watch":
            last_view = time.time()
            name, gid = q.get("batch", [""])[0], q.get("id", [""])[0]
            if name == "" and gid == "":
                start_game("live")
                return self.send(b'{"ok":true}')
            if not NAME_OK.match(name) or not gid.isdigit():
                return self.send(b'{"ok":false}', code=400)
            for g in stats.load(name, inputs=True):
                if g["id"] == int(gid):
                    level = json.load(open(f"{stats.RUNS}/{name}/meta.json")).get("level", 1)
                    g["prefix"] = "s" if level == 1 else f"l{level}_"
                    start_game("replay", g)
                    return self.send(b'{"ok":true}')
            return self.send(b'{"ok":false}', code=404)
        self.send(b"not found", "text/plain", 404)


def main():
    signal.signal(signal.SIGTERM, lambda *a: (stop_game_locked(), os._exit(0)))
    threading.Thread(target=watchdog, daemon=True).start()
    print(f"http://0.0.0.0:{PORT}/", flush=True)
    ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()


if __name__ == "__main__":
    main()
