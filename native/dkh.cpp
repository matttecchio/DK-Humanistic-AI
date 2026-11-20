// dkh: runs this project's MAME Lua scripts (agent.lua, mkstart.lua, ...) on the dkx emulator instead of MAME.
// It offers the small part of MAME's Lua API those scripts use, with MAME's frame-hook semantics as dkxtool.cpp has them:
//   - the frame_done callback runs at vblank_begin, before the input ports are latched for the frame;
//   - a load or save asked for in the callback happens after the current timeslice;
//   - input port values aren't part of a state, so what's held before a load carries into the loaded machine.
// Usage: dkh SCRIPT.lua   (ROMs from $DKX_ROMS, save states as $DKH_STATES/NAME.sta in dkx's own format)
#include "dk.h"
#include <string>
#include <cstdlib>
#include <cstring>
#include <fcntl.h>
#include <unistd.h>
#include <zlib.h>
extern "C" {
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
}

static lua_State *L;
void plan_register(lua_State *L);   // plan.cpp
void rivsim_register(lua_State *L);   // rivsim.cpp
static int hook_ref = LUA_NOREF;
static u8 cur_in0 = 0, cur_in2 = 0;
static int pend = 0; static std::string pend_file;      // 1 = load, 2 = save
static bool quit = false, failed = false;
static std::string states;

static const u32 MAGIC = 0x32584b44;  // same file format as dkxtool.cpp
static u8 packbuf[sizeof(Machine) + 1024];
static bool save_state(const std::string &path) {
	static Machine img; img = M;
	img.z80.icountptr = img.dma.icountptr = img.snd.icountptr = nullptr; img.snd.m_regptr = nullptr;
	uLongf plen = sizeof(packbuf) - 12;
	if (compress2(packbuf + 12, &plen, (const Bytef *)&img, sizeof(img), 1) != Z_OK) return false;
	u32 hdr[3] = { MAGIC, u32(sizeof(Machine)), u32(plen) }; memcpy(packbuf, hdr, 12);
	std::string tmp = path + ".tmp";
	int fd = open(tmp.c_str(), O_WRONLY | O_CREAT | O_TRUNC, 0644);
	if (fd < 0) return false;
	bool ok = write(fd, packbuf, 12 + plen) == ssize_t(12 + plen);
	close(fd);
	return ok && rename(tmp.c_str(), path.c_str()) == 0;
}
// States are kept in memory once read: a game start is a copy, not a file read.
#include <map>
static std::map<std::string, Machine *> cache;
static bool load_state(const std::string &path) {
	auto it = cache.find(path);
	if (it == cache.end()) {
		int fd = open(path.c_str(), O_RDONLY);
		if (fd < 0) return false;
		ssize_t n = read(fd, packbuf, sizeof(packbuf)); close(fd);
		u32 hdr[3]; if (n < 12) return false; memcpy(hdr, packbuf, 12);
		if (hdr[0] != MAGIC || hdr[1] != sizeof(Machine) || ssize_t(12 + hdr[2]) != n) return false;
		Machine *m = new Machine; uLongf rlen = sizeof(Machine);
		if (uncompress((Bytef *)m, &rlen, packbuf + 12, hdr[2]) != Z_OK || rlen != sizeof(Machine)) { delete m; return false; }
		it = cache.emplace(path, m).first;
	}
	memcpy(&M, it->second, sizeof(M)); dk_fixup();
	M.in0 = cur_in0; M.in2 = cur_in2;
	return true;
}

// ---- the Lua side: manager.machine, its devices, ports and save states, and emu.register_frame_done
static int sp_read(lua_State *l) { lua_pushinteger(l, dk_rd(u16(luaL_checkinteger(l, 2)))); return 1; }
static int sp_write(lua_State *l) {
	long a = luaL_checkinteger(l, 2); int v = int(luaL_checkinteger(l, 3)) & 0xff;
	if (a < 0x6000 || a >= 0x6c00) return luaL_error(l, "dkh: write_u8 only covers work RAM, not %x", int(a));
	M.ram[a - 0x6000] = u8(v); return 0;
}
// A port field: upvalues are the port (0 = IN0, 2 = IN2) and the bit mask.
static int field_set(lua_State *l) {
	int port = int(lua_tointeger(l, lua_upvalueindex(1))); int mask = int(lua_tointeger(l, lua_upvalueindex(2)));
	bool on = luaL_checkinteger(l, 2) != 0;
	u8 &p = port == 0 ? cur_in0 : cur_in2;
	p = on ? u8(p | mask) : u8(p & ~mask);
	return 0;
}
static int mac_load(lua_State *l) { pend = 1; pend_file = states + "/" + luaL_checkstring(l, 2) + ".sta"; return 0; }
static int mac_save(lua_State *l) { pend = 2; pend_file = states + "/" + luaL_checkstring(l, 2) + ".sta"; return 0; }
static int mac_exit(lua_State *) { quit = true; return 0; }
// peek(n, in0) (2026-11-14, the all-knowing mode): after this frame, run a copy of the machine n frames ahead with port IN0 held at
// in0 (-1: as it is now), recording each frame the random number (0x6018), Mario (x, y) and the 10 barrels (on, x, y, byte 2,
// byte 7); then put the machine back exactly. peek_result() gives the record (53 numbers a frame) once it's ready, else nil.
#include <vector>
static int peek_req = 0, peek_in = -1; static std::vector<int> peek_out; static bool peek_ready = false;
static int mac_peek(lua_State *l) { peek_req = int(luaL_checkinteger(l, 2)); peek_in = int(luaL_optinteger(l, 3, -1)); peek_ready = false; return 0; }
static int mac_peek_result(lua_State *l) {
	if (!peek_ready) { lua_pushnil(l); return 1; }
	lua_createtable(l, int(peek_out.size()), 0);
	for (size_t i = 0; i < peek_out.size(); i++) { lua_pushinteger(l, peek_out[i]); lua_rawseti(l, -2, lua_Integer(i + 1)); }
	return 1;
}
static void peek_rec() {
	peek_out.push_back(dk_rd(0x6018)); peek_out.push_back(dk_rd(0x6203)); peek_out.push_back(dk_rd(0x6205));
	for (int k = 0; k < 10; k++) {
		u16 a = u16(0x6700 + 32 * k);
		peek_out.push_back(dk_rd(a) & 1); peek_out.push_back(dk_rd(u16(a + 3))); peek_out.push_back(dk_rd(u16(a + 5)));
		peek_out.push_back(dk_rd(u16(a + 2))); peek_out.push_back(dk_rd(u16(a + 7)));
	}
}
// peek_seqs({s1, s2, ...}) (the look-ahead mode): each s is a string of IN0 bytes, one a frame, s[1] the one set now. Each is
// played out on a copy of the machine; peek_seqs_result() gives for each {frames he stays alive (#s if he does), why it stopped:
// 0 still playing, 1 died, 2 board cleared, Mario's x, y at the end}
static std::vector<std::string> seq_req; static std::vector<int> seq_out; static bool seq_ready = false;
static const std::string *seq_cur = nullptr; static size_t seq_i = 0; static int seq_stop = 0, seq_alive = 0; static u8 seq_lives = 0;
static int mac_peek_seqs(lua_State *l) {
	seq_req.clear(); seq_ready = false;
	long n = long(luaL_len(l, 2));
	for (long i = 1; i <= n; i++) { lua_rawgeti(l, 2, i); size_t len; const char *c = lua_tolstring(l, -1, &len); seq_req.emplace_back(c, len); lua_pop(l, 1); }
	return 0;
}
static int mac_peek_seqs_result(lua_State *l) {
	if (!seq_ready) { lua_pushnil(l); return 1; }
	lua_createtable(l, int(seq_out.size() / 4), 0);
	for (size_t i = 0; i < seq_out.size() / 4; i++) {
		lua_createtable(l, 4, 0);
		for (int j = 0; j < 4; j++) { lua_pushinteger(l, seq_out[i * 4 + j]); lua_rawseti(l, -2, j + 1); }
		lua_rawseti(l, -2, lua_Integer(i + 1));
	}
	seq_ready = false;
	return 1;
}
static void seq_rec() {
	if (seq_stop) return;
	u8 mode = dk_rd(0x600A);
	if (mode == 0x16) { seq_stop = 2; return; }
	if (mode != 0x0C || dk_rd(0x6200) == 0 || dk_rd(0x639D) != 0 || dk_rd(0x6228) < seq_lives) { seq_stop = 1; return; }
	seq_alive++;
	seq_i++;
	u8 v = seq_i < seq_cur->size() ? u8((*seq_cur)[seq_i]) : 0;
	cur_in0 = v; M.in0 = v;   // what the player sets at this frame's hook, as in a real game
}
static void run_seqs() {
	static Machine bak; bak = M;
	void (*h)() = dk_frame_hook; dk_frame_hook = seq_rec;
	u8 keep0 = cur_in0;
	seq_out.clear();
	u8 lives = dk_rd(0x6228);
	for (const std::string &sq : seq_req) {
		seq_cur = &sq; seq_i = 0; seq_stop = 0; seq_alive = 0; seq_lives = lives;
		u8 v = sq.empty() ? 0 : u8(sq[0]); cur_in0 = v; M.in0 = v;
		u64 target = M.frame_number + sq.size();
		while (M.frame_number < target && !seq_stop) dk_timeslice();
		seq_out.push_back(seq_alive); seq_out.push_back(seq_stop); seq_out.push_back(dk_rd(0x6203)); seq_out.push_back(dk_rd(0x6205));
		memcpy(&M, &bak, sizeof(M)); dk_fixup();
	}
	cur_in0 = keep0; M.in0 = cur_in0; M.in2 = cur_in2;
	dk_frame_hook = h; seq_req.clear(); seq_ready = true;
}
// ---- SEARCH (Matt, 2026-11-14: the all-knowing mode). He always holds a plan that a copy of the game has played out and survived,
// up to SH frames ahead, as a chain of short moves (walk, stand, climb, a jump played out to its landing). Each frame, after the hook,
// the chain is grown from its end: a move that dies is replaced by the next one; when none from a point lives, the move before it is
// undone and its next alternative tried (never anything already pressed). Moves along his route come first. The game has no
// randomness of its own, so a press list that survived on the copy survives for real, exactly, as long as it's what's pressed.
struct Seg { Machine *end; std::vector<u8> press; int next_alt; };
static std::vector<Seg> plan; static bool search_on = false, search_hooked = false, plan_clears = false;
static int SH = 120, SBUDGET = 600; static long search_dead = 0, search_frames = 0, search_backs = 0;
static int root_alt = 0;
static double route_x[8] = {0};
static int route_v = 0;
static int route_in = -1;   // (rivets) the player's own press this frame, raw IN0 (-1: none): the search tries it first   // (rivets) which way he wants to climb at the route point: 1 up, -1 down, 0 either (barrels: up first)
static int stop_why = 0;   // in a move's run: 1 died, 2 cleared, 3 done
static u8 lives0 = 0;
static Machine *now_m = nullptr;
static Machine *snap() { Machine *m = new Machine; *m = M; return m; }
static void restore(const Machine *m) { memcpy(&M, m, sizeof(M)); dk_fixup(); }
static int floor_of(int y) { return y >= 220 ? 1 : y >= 190 ? 2 : y >= 155 ? 3 : y >= 120 ? 4 : y >= 101 ? 5 : 6; }
// a move: what to press each frame, decided as it runs. kind: 0 stand, 1 walk his way (stops at the ladder), 2 walk, 3 jump (dir),
// 6 up, 7 down, 8 nothing till he lands
static std::vector<u8> *mv_out; static int mv_kind, mv_n, mv_i, mv_dir, mv_phase;
static u8 raw_dir(int d) { return d > 0 ? 0x01 : d < 0 ? 0x02 : 0; }   // IN0: right 1, left 2
static void mv_rec() {
	if (stop_why) return;
	u8 mode = dk_rd(0x600A);
	if (mode == 0x16) { stop_why = 2; return; }
	if (mode != 0x0C || dk_rd(0x6200) == 0 || dk_rd(0x639D) != 0 || dk_rd(0x6228) < lives0) { stop_why = 1; return; }
	// (rivets: a fall into a pulled rivet's gap only kills on landing, after the search has looked: moving down while not on a ladder
	// and not jumping is a fall, and counts as death at once)
	{ static int prev_y = -1, prev_i = -1; int yy = dk_rd(0x6205);
	  if (dk_rd(0x6227) == 4 && mv_i > 0 && prev_i == mv_i - 1 && yy > prev_y + 1 && dk_rd(0x6215) == 0 && dk_rd(0x6216) == 0) { stop_why = 1; prev_i = -1; return; }
	  prev_y = yy; prev_i = mv_i; }
	u8 v = 0;
	int x = dk_rd(0x6203);
	switch (mv_kind) {
	case 1: { int lx = int(route_x[floor_of(dk_rd(0x6205))]); v = raw_dir(mv_dir); if (x == lx) { v = 0; mv_n = mv_i + 1; } break; }
	case 2: v = raw_dir(mv_dir); break;
	case 3:
		if (mv_i < 3) v = u8(0x10 | raw_dir(mv_dir));
		else if (mv_i > 6 && dk_rd(0x6216) == 0) { if (mv_phase++ >= 2) mv_n = mv_i + 1; }
		if (mv_i > 90) mv_n = mv_i + 1;
		break;
	case 6: v = 0x04; break;
	case 7: v = 0x08; break;
	case 8: if (dk_rd(0x6216) == 0) mv_n = mv_i + 1; break;
	case 9:   // his own press (rivets): held; a jump pressed 3 frames, then nothing till he lands
		if (route_in & 0x10) { if (mv_i < 3) v = u8(route_in); else if (mv_i > 6 && dk_rd(0x6216) == 0) mv_n = mv_i + 1; if (mv_i > 90) mv_n = mv_i + 1; }
		else v = u8(route_in);
		break;
	default: v = 0;
	}
	mv_out->push_back(v); mv_i++;
	cur_in0 = v; M.in0 = v;
	if (mv_i >= mv_n) stop_why = 3;   // done: the state at the end of this frame's slice is where the next move starts, as "now" is
}
// run a move from machine `from`: 0 he lives through it (M then holds the state after it), 1 died, 2 cleared
static int run_move(const Machine *from, int kind, int dir, int n, std::vector<u8> &out) {
	restore(from); out.clear();
	mv_out = &out; mv_kind = kind; mv_n = n; mv_i = 0; mv_dir = dir; mv_phase = 0; stop_why = 0;
	void (*h)() = dk_frame_hook; dk_frame_hook = mv_rec;
	u64 lim = M.frame_number + 110;
	while (!stop_why && M.frame_number < lim) { u64 f0 = M.frame_number; dk_timeslice(); search_frames += long(M.frame_number - f0); }
	dk_frame_hook = h;
	return stop_why == 3 ? 0 : (stop_why == 0 ? 1 : stop_why);
}
// the moves worth trying from a state, best first
static int moves_from(const Machine *m, int kinds[], int dirs[], int ns[]) {
	restore(m);
	int x = dk_rd(0x6203), y = dk_rd(0x6205), lad = dk_rd(0x6215), jmp = dk_rd(0x6216);
	int lx = int(route_x[floor_of(y)]); int d = lx > x ? 1 : lx < x ? -1 : 0;
	int k = 0;
	auto add = [&](int kd, int dr, int n) { kinds[k] = kd; dirs[k] = dr; ns[k] = n; k++; };
	if (jmp) { add(8, 0, 100); return k; }
	if (route_in >= 0) add(9, 0, (route_in & 0x10) ? 100 : 8);   // (rivets) his own press first
	if (lad) { if (route_v < 0) { add(7, 0, 8); add(0, 0, 8); add(6, 0, 8); } else { add(6, 0, 8); add(0, 0, 8); add(7, 0, 8); } return k; }
	// (down at the route point: rivets only)
	if (d == 0) { if (route_v < 0) { add(7, 0, 8); add(6, 0, 8); } else { add(6, 0, 8); if (dk_rd(0x6227) == 4) add(7, 0, 8); } add(0, 0, 6); add(3, 0, 100); add(2, 1, 8); add(2, -1, 8); add(3, 1, 100); add(3, -1, 100); add(0, 0, 20); return k; }
	add(1, d, 8); add(3, d, 100); add(0, 0, 6); add(3, 0, 100); add(2, -d, 8); add(3, -d, 100); add(0, 0, 20); add(2, -d, 20);
	return k;
}
static int planned() { int t = 0; for (const Seg &g : plan) t += int(g.press.size()); return t; }
static void pop_seg() { delete plan.back().end; plan.pop_back(); search_backs++; }
static void search_work() {
	u8 keep0 = cur_in0, keep2 = cur_in2;
	if (now_m) delete now_m;
	now_m = snap(); lives0 = dk_rd(0x6228);
	// moves done with: their end is now (exactly), and the next move's choices start fresh
	while (!plan.empty() && plan.front().press.empty()) { delete plan.front().end; plan.erase(plan.begin()); root_alt = 0; }
	long budget_end = search_frames + SBUDGET;
	static std::vector<u8> out;
	int kinds[16], dirs[16], ns[16];
	while (!plan_clears && planned() < SH && search_frames < budget_end) {
		const Machine *from = plan.empty() ? now_m : plan.back().end;
		int &alt = plan.empty() ? root_alt : plan.back().next_alt;
		int n = moves_from(from, kinds, dirs, ns);
		if (alt >= n) {
			if (plan.empty()) {   // nothing from here lives: he'll do his best unchecked
				search_dead++; root_alt = 0;
				if (getenv("SDBG")) { restore(now_m); fprintf(stderr, "DEAD f=%llu x=%d y=%d lad=%d jmp=%d\n", (unsigned long long)M.frame_number, dk_rd(0x6203), dk_rd(0x6205), dk_rd(0x6215), dk_rd(0x6216)); }
				break;
			}
			pop_seg(); continue;
		}
		int i = alt++;
		int r = run_move(from, kinds[i], dirs[i], ns[i], out);
		if (getenv("SDBG2")) fprintf(stderr, "  depth %zu move %d/%d -> %d (%zu frames, planned %d)\n", plan.size(), kinds[i], dirs[i], r, out.size(), planned());
		if (r == 1) continue;
		plan.push_back({snap(), out, 0});
		if (r == 2) plan_clears = true;
	}
	restore(now_m);
	cur_in0 = keep0; cur_in2 = keep2; M.in0 = cur_in0; M.in2 = cur_in2;
}
static int s_on(lua_State *l) {
	search_on = lua_toboolean(l, 2); SH = int(luaL_optinteger(l, 3, 120)); SBUDGET = int(luaL_optinteger(l, 4, 600));
	while (!plan.empty()) pop_seg(); root_alt = 0; plan_clears = false; search_backs = 0;
	return 0;
}
static int s_route(lua_State *l) { for (int f = 1; f <= 6; f++) { lua_rawgeti(l, 2, f); route_x[f] = lua_tonumber(l, -1); lua_pop(l, 1); } lua_rawgeti(l, 2, 7); route_v = lua_isnumber(l, -1) ? int(lua_tointeger(l, -1)) : 0; lua_pop(l, 1); lua_rawgeti(l, 2, 8); route_in = lua_isnumber(l, -1) ? int(lua_tointeger(l, -1)) : -1; lua_pop(l, 1); return 0; }
// the press for this frame from the checked plan (IN0 bits), or -1 if there's none
static int s_press(lua_State *l) {
	search_hooked = true;
	if (plan.empty() || plan.front().press.empty()) { lua_pushinteger(l, -1); return 1; }
	u8 v = plan.front().press.front(); plan.front().press.erase(plan.front().press.begin());
	lua_pushinteger(l, v); lua_pushinteger(l, planned()); return 2;
}
// ---- RSEARCH (2026-11-20, Matt: "try option 3", the all-knowing rivet player as a teacher): every few frames, every two-move
// sequence (stand, walk left / right, up, down, jump left / right / straight) is played on an exact copy of the game, then a short
// tail (stand, or the second move again) to check he doesn't die just after; each survivor is scored by progress: rivets pulled
// (a lot), else -(his route's cost to the next target), from the Lua function passed in; the first move of the best is returned
static long rs_frames = 0;
// (the first version ran the game inside Lua's frame callback and hung: like the barrel search, Lua now asks (mac:rsearch(fn)), the
// main loop searches between frames, and the answer is read on a later call: -2 while it's pending)
static int rs_ref = LUA_NOREF, rs_raw = -1, rs_jump = 0; static bool rs_req = false, rs_ready = false;
static lua_State *rs_L = nullptr;
static void rsearch_core() {
	lua_State *l = rs_L;
	int left0 = dk_rd(0x6290);
	u8 keep0 = cur_in0, keep2 = cur_in2;
	Machine *now = snap(); lives0 = dk_rd(0x6228);
	const int K[8] = {0, 2, 2, 6, 7, 3, 3, 3}, D[8] = {0, -1, 1, 0, 0, -1, 1, 0}, N[8] = {10, 12, 12, 12, 12, 100, 100, 100};
	static std::vector<u8> out;
	double best = -1e18; int bi = -1;
	long f0 = search_frames;
	auto score_here = [&](int cleared) -> double {
		if (cleared) return 1e9;
		int x = dk_rd(0x6203), y = dk_rd(0x6205), lad = dk_rd(0x6215), left = dk_rd(0x6290);
		lua_rawgeti(l, LUA_REGISTRYINDEX, rs_ref); lua_pushinteger(l, x); lua_pushinteger(l, y); lua_pushinteger(l, lad); lua_pushinteger(l, left);
		double v = -1e6;
		if (lua_pcall(l, 4, 1, 0) == 0) { v = lua_isnumber(l, -1) ? lua_tonumber(l, -1) : -1e6; }
		else if (getenv("RSDBG")) fprintf(stderr, "RS progress error: %s\n", lua_tostring(l, -1));
		lua_pop(l, 1);
		return v + 10000.0 * (left0 - left);
	};
	for (int a = 0; a < 8; a++) {
		int ra = run_move(now, K[a], D[a], N[a], out);
		if (ra == 1) continue;
		if (ra == 2) { if (1e9 > best) { best = 1e9; bi = a; } continue; }
		Machine *m1 = snap();
		for (int b = 0; b < 8; b++) {
			int rb = run_move(m1, K[b], D[b], N[b], out);
			if (rb == 1) continue;
			double sc;
			if (rb == 2) sc = 1e9;
			else {
				sc = score_here(0);
				Machine *m2 = snap();
				// the tail: he must be able to live 60 more frames (standing, or the same move again)
				// (60 frames: a fall into a gap only kills on landing, after the first 30)
				int t1 = run_move(m2, 0, 0, 60, out);
				int t2 = (t1 == 1) ? run_move(m2, K[b], D[b], b >= 5 ? 100 : 60, out) : 0;
				delete m2;
				if (t1 == 1 && t2 == 1) continue;
			}
			if (sc > best) { best = sc; bi = a; }
		}
		delete m1;
	}
	rs_frames += search_frames - f0;
	if (getenv("RSDBG")) fprintf(stderr, "RS x=%d y=%d best move %d score %.1f\n", dk_rd(0x6203), dk_rd(0x6205), bi, best);
	restore(now); delete now;
	cur_in0 = keep0; cur_in2 = keep2; M.in0 = cur_in0; M.in2 = cur_in2;
	if (bi < 0) { rs_raw = -1; rs_jump = 0; }
	else { rs_raw = K[bi] == 6 ? 0x04 : K[bi] == 7 ? 0x08 : K[bi] == 3 ? int(0x10 | raw_dir(D[bi])) : K[bi] == 2 ? raw_dir(D[bi]) : 0; rs_jump = K[bi] == 3 ? 1 : 0; }
	rs_ready = true;
}
static int rsearch(lua_State *l) {
	if (rs_ready) { rs_ready = false; lua_pushinteger(l, rs_raw); lua_pushinteger(l, rs_jump); return 2; }
	if (!rs_req) {
		luaL_checktype(l, 2, LUA_TFUNCTION);   // (called as mac:rsearch(fn): 1 is mac)
		if (rs_ref != LUA_NOREF) luaL_unref(l, LUA_REGISTRYINDEX, rs_ref);
		lua_pushvalue(l, 2); rs_ref = luaL_ref(l, LUA_REGISTRYINDEX); rs_L = l; rs_req = true;
	}
	lua_pushinteger(l, -2); lua_pushinteger(l, 0); return 2;
}
static int s_stats(lua_State *l) { lua_pushinteger(l, search_dead); lua_pushinteger(l, search_frames); lua_pushinteger(l, search_backs); return 3; }
static void run_peek() {
	static Machine bak; bak = M;
	void (*h)() = dk_frame_hook; dk_frame_hook = peek_rec;
	peek_out.clear();
	u8 in0 = peek_in >= 0 ? u8(peek_in) : cur_in0;
	M.in0 = in0;
	u8 keep0 = cur_in0; cur_in0 = in0;
	dk_run_frames(peek_req);
	cur_in0 = keep0;
	memcpy(&M, &bak, sizeof(M)); dk_fixup();
	M.in0 = cur_in0; M.in2 = cur_in2;
	dk_frame_hook = h; peek_req = 0; peek_ready = true;
}
static int reg_frame_done(lua_State *l) {
	luaL_checktype(l, 1, LUA_TFUNCTION); lua_pushvalue(l, 1); hook_ref = luaL_ref(l, LUA_REGISTRYINDEX); return 0;
}
static void add_field(const char *name, int port, int mask) {
	lua_newtable(L);
	lua_pushinteger(L, port); lua_pushinteger(L, mask); lua_pushcclosure(L, field_set, 2); lua_setfield(L, -2, "set_value");
	lua_setfield(L, -2, name);
}
static void build_api() {
	lua_newtable(L);                                   // emu
	lua_pushcfunction(L, reg_frame_done); lua_setfield(L, -2, "register_frame_done");
	lua_setglobal(L, "emu");
	lua_newtable(L);                                   // manager
	lua_newtable(L);                                   // machine
	lua_pushcfunction(L, mac_load); lua_setfield(L, -2, "load");
	lua_pushcfunction(L, mac_save); lua_setfield(L, -2, "save");
	lua_pushcfunction(L, mac_exit); lua_setfield(L, -2, "exit");
	lua_pushcfunction(L, mac_peek); lua_setfield(L, -2, "peek");
	lua_pushcfunction(L, mac_peek_result); lua_setfield(L, -2, "peek_result");
	lua_pushcfunction(L, mac_peek_seqs); lua_setfield(L, -2, "peek_seqs");
	lua_pushcfunction(L, s_on); lua_setfield(L, -2, "search_on");
	lua_pushcfunction(L, s_route); lua_setfield(L, -2, "search_route");
	lua_pushcfunction(L, s_press); lua_setfield(L, -2, "search_press");
	lua_pushcfunction(L, s_stats); lua_setfield(L, -2, "search_stats");
	lua_pushcfunction(L, rsearch); lua_setfield(L, -2, "rsearch");
	lua_pushcfunction(L, mac_peek_seqs_result); lua_setfield(L, -2, "peek_seqs_result");
	lua_newtable(L);                                   // devices
	lua_newtable(L);                                   // :maincpu
	lua_newtable(L);                                   // spaces
	lua_newtable(L);                                   // program
	lua_pushcfunction(L, sp_read); lua_setfield(L, -2, "readv_u8");
	lua_pushcfunction(L, sp_read); lua_setfield(L, -2, "read_u8");
	lua_pushcfunction(L, sp_write); lua_setfield(L, -2, "write_u8");
	lua_setfield(L, -2, "program");
	lua_setfield(L, -2, "spaces");
	lua_setfield(L, -2, ":maincpu");
	lua_setfield(L, -2, "devices");
	lua_newtable(L);                                   // ioport
	lua_newtable(L);                                   // ports
	lua_newtable(L); lua_newtable(L);                  // :IN0 and its fields. DK's IN0 has right at bit 0, left at bit 1.
	add_field("P1 Right", 0, 0x01); add_field("P1 Left", 0, 0x02); add_field("P1 Up", 0, 0x04); add_field("P1 Down", 0, 0x08); add_field("P1 Button 1", 0, 0x10);
	lua_setfield(L, -2, "fields"); lua_setfield(L, -2, ":IN0");
	lua_newtable(L); lua_newtable(L);                  // :IN2
	add_field("Coin 1", 2, 0x80); add_field("1 Player Start", 2, 0x04);
	lua_setfield(L, -2, "fields"); lua_setfield(L, -2, ":IN2");
	lua_setfield(L, -2, "ports");
	lua_setfield(L, -2, "ioport");
	lua_setfield(L, -2, "machine");
	lua_setglobal(L, "manager");
}

static void hook() {
	if (hook_ref != LUA_NOREF && !quit) {
		lua_rawgeti(L, LUA_REGISTRYINDEX, hook_ref);
		if (lua_pcall(L, 0, 0, 0) != LUA_OK) { fprintf(stderr, "dkh: %s\n", lua_tostring(L, -1)); lua_pop(L, 1); quit = failed = true; }
	}
	M.in0 = cur_in0; M.in2 = cur_in2;   // the ports latch after the hook, as in MAME
}

int main(int argc, char **argv) {
	if (argc < 2) { fprintf(stderr, "usage: dkh SCRIPT.lua\n"); return 1; }
	const char *roms = getenv("DKX_ROMS"); const char *st = getenv("DKH_STATES");
	if (!roms || !st) { fprintf(stderr, "dkh: set DKX_ROMS and DKH_STATES\n"); return 1; }
	states = st;
	if (!dk_load_roms(roms)) return 1;
	L = luaL_newstate(); luaL_openlibs(L); build_api(); if (!getenv("DKH_LUA_ONLY")) { plan_register(L); rivsim_register(L); }
	if (luaL_dofile(L, argv[1]) != LUA_OK) { fprintf(stderr, "dkh: %s\n", lua_tostring(L, -1)); return 1; }
	dk_frame_hook = hook; dk_power_on();
	while (!quit) {
		dk_timeslice();
		if (peek_req > 0) run_peek();
		if (!seq_req.empty()) run_seqs();
		if (search_on && search_hooked && !pend) { search_hooked = false; search_work(); }
		if (rs_req && !pend) { rs_req = false; rsearch_core(); }
		if (pend == 1) { rs_req = false; rs_ready = false; }   // (a new game: no search answer carried over)
		if (pend == 1) { while (!plan.empty()) pop_seg(); root_alt = 0; plan_clears = false; search_hooked = false; }   // a new game: nothing planned
		if (pend) {
			int p = pend; pend = 0;
			if (p == 2) { if (!save_state(pend_file)) fprintf(stderr, "dkh: cannot save %s\n", pend_file.c_str()); }
			else if (!load_state(pend_file)) { fprintf(stderr, "dkh: cannot load %s\n", pend_file.c_str()); return 1; }
		}
	}
	return failed ? 1 : 0;
}
