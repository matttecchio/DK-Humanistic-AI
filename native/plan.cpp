// The planner's plan check (policy.lua try_plan_now), compiled. Same logic line for line and the same double
// arithmetic in the same order, so every result is bit-identical to the Lua version (built with -ffp-contract=off).
// policy.lua uses it only when running under dkh, and only for the settings this file covers; otherwise the Lua runs.
#include <vector>
#include <unordered_map>
#include <cmath>
extern "C" {
#include "lua.h"
#include "lauxlib.h"
}

static const double WALK = 0.67, JUMP_X = 0.5;
static const int LAND_STALL = 8, PLAN_STEPS = 80;
static int JUMP_LEN = 0; static double ARC[128];

struct Lvl { double a, s; long dir; bool ok; };
static Lvl LV[8]; static std::vector<long> DR[8];
struct Haz { double x, y; int m; double mval; bool w; int ray; long k = -1; long br = -1; double lad = -1; };   // lad: the ladder a "might" path takes   // m: 0 = not a "might", 1 = true, 2 = commit at mval; k: which barrel, br: which of its paths
struct Ray { double prob, commit; long stamp; };
static std::vector<Haz> hz[PLAN_STEPS + 1];
static std::vector<Ray> rays;
struct Fire { double x, y, vx; };
static std::vector<Fire> fires;
static double mx0, my0, target; static long floor_, dirn, ham, age;
static bool along_fix, land_stall2, ham_avoid, odds_risk, above_ok, slope_jump;
static double ham_avoid_x = 40;   // ham_avoid: no plan for him goes this far left on the 5th girder (the top hammer)
static double ray_clear, see_lag, land_wait, ray_discount, respond, need_clear, fire_horizon, fire_spread, fire_x, fire_y;
static long gen = 0;
static bool follow_check = false; static long follow_steps = 30;
static bool risk_odds = false;   // risk_odds (2026-11-14, the ROM's ladder rule 0x2186 at difficulty 5): the chance a "might" barrel takes its ladder
static bool contingent = false; static long contingent_lvl = 0, contingent_lag = 0;   // contingent: a "might" barrel is only a risk if, once he'd see it commit, he couldn't get away from it
static bool wild_aim = false;
static long dbg_act = 99, dbg_w1 = -1, dbg_j1 = 99;   // dbgnative {act, w1, j1}: say what the check finds for that plan
static bool wild_stick = false, wall_jump = false, wild_rom = false, wall_right = false;
static double right_stand = 224;
static std::vector<double> rom_us = {0.0, 0.5, 0.99};   // wild_rom: the speeds each bounce is checked at (wild_rom_us)
static bool has_ham2 = false; static double ham2_lo = 0, ham2_hi = 0;
// ham_plan (2026-11-14, from the ROM): holding the hammer, the plan check knows the swing and the smash. 0x6394 counts up each frame
// (not during a smash's pause); bit 3 set = hammer down, 16 px in front at his height, box +-5 x +-6; clear = up, over his head 16 px
// up, box +-6 x +-3. Barrels' boxes are +-2. Each frame the game checks Mario's own box first (a barrel touching it kills him),
// then the hammer's: the first barrel overlapping it is smashed and everything stops ~73 frames, so in the plan's time it's only gone.
static bool ham_on = false; static long ham_cnt = 0, ham_left = 0; static long ham_face0 = 1;
// ham_grab: the top hammer is there to take; a straight jump from x in [grab_lo, grab_hi] takes it at the jump's peak (19 frames in,
// measured), he lands as from any straight jump, holding it up over his head, and 4 frames after landing it starts to swing (counter 1)
static bool grab_on = false; static double grab_lo = 31, grab_hi = 40;

static double mario_y(long floor, double x) {
	if (floor == 1) return 243.4 - 0.038 * x;
	else if (floor == 2) return 198.8 + 0.0607 * x;
	else if (floor == 3) return 181.2 - 0.0611 * x;
	else if (floor == 4) return 132.7 + 0.0615 * x;
	else if (floor == 5) return 115.3 - 0.0616 * x;
	else return 68.7 + 0.05 * x;
}
static double along(double x, long d, double t) {
	bool heading = d != 0 && d == dirn;
	if (heading && along_fix) d = target > x ? 1 : -1;
	double nx = x + double(d) * WALK * t;
	if (heading && ((d > 0 && nx > target) || (d < 0 && nx < target))) nx = target;
	return nx;
}
static double num(lua_State *L, int t, const char *k) { lua_getfield(L, t, k); double v = lua_tonumber(L, -1); lua_pop(L, 1); return v; }
static bool truthy(lua_State *L, int t, const char *k) { lua_getfield(L, t, k); bool v = lua_toboolean(L, -1); lua_pop(L, 1); return v; }

// set_arc(ARC): the jump's height table, once
static int set_arc(lua_State *L) {
	JUMP_LEN = int(luaL_len(L, 1));
	for (int i = 1; i <= JUMP_LEN; i++) { lua_rawgeti(L, 1, i); ARC[i] = lua_tonumber(L, -1); lua_pop(L, 1); }
	return 0;
}
// set_hz(hz): the hazards near his height at each step, as policy.lua's fill_hz laid them out
static int set_hz(lua_State *L) {
	rays.clear();
	std::unordered_map<const void *, int> ray_ix;
	for (int s = 0; s <= PLAN_STEPS; s++) {
		hz[s].clear();
		lua_rawgeti(L, 1, s); int h = lua_gettop(L);
		long n = long(luaL_len(L, h));
		for (long i = 1; i <= n; i += 6) {
			Haz z;
			lua_rawgeti(L, h, i); z.x = lua_tonumber(L, -1); lua_pop(L, 1);
			lua_rawgeti(L, h, i + 1); z.y = lua_tonumber(L, -1); lua_pop(L, 1);
			lua_rawgeti(L, h, i + 2);
			if (lua_isboolean(L, -1)) z.m = lua_toboolean(L, -1) ? 1 : 0, z.mval = 0; else z.m = 2, z.mval = lua_tonumber(L, -1);
			lua_pop(L, 1);
			lua_rawgeti(L, h, i + 3); z.w = lua_toboolean(L, -1); lua_pop(L, 1);
			lua_rawgeti(L, h, i + 4);
			if (lua_istable(L, -1)) {
				const void *p = lua_topointer(L, -1);
				auto it = ray_ix.find(p);
				if (it == ray_ix.end()) {
					Ray r; r.prob = num(L, lua_gettop(L), "prob"); r.commit = num(L, lua_gettop(L), "commit"); r.stamp = 0;
					rays.push_back(r); it = ray_ix.emplace(p, int(rays.size()) - 1).first;
				}
				z.ray = it->second;
			} else z.ray = -1;
			lua_pop(L, 1);
			hz[s].push_back(z);
		}
		lua_pop(L, 1);
	}
	return 0;
}
// fill(paths, floor_y): policy.lua's fill_hz, building the hazards straight from the predicted paths
static int fill(lua_State *L) {
	rays.clear();
	for (int s = 0; s <= PLAN_STEPS; s++) hz[s].clear();
	double floor_y = lua_tonumber(L, 2);
	long np = long(luaL_len(L, 1));
	for (long p = 1; p <= np; p++) {
		lua_rawgeti(L, 1, p); int t = lua_gettop(L);
		if (truthy(L, t, "climb_only")) { lua_pop(L, 1); continue; }
		Haz z; z.m = 0; z.mval = 0;
		if (truthy(L, t, "maybe")) {
			lua_getfield(L, t, "commit");
			if (lua_isnil(L, -1) || (lua_isboolean(L, -1) && !lua_toboolean(L, -1))) z.m = 1;
			else if (lua_isboolean(L, -1)) z.m = 1;
			else { z.m = 2; z.mval = lua_tonumber(L, -1); }
			lua_pop(L, 1);
		}
		z.w = truthy(L, t, "wild");
		z.ray = -1;
		lua_getfield(L, t, "bk"); z.k = lua_isnumber(L, -1) ? long(lua_tointeger(L, -1)) : -1; lua_pop(L, 1); z.br = p;
		lua_getfield(L, t, "lad"); z.lad = lua_isnumber(L, -1) ? lua_tonumber(L, -1) : -1; lua_pop(L, 1);
		if (truthy(L, t, "ray")) { rays.push_back({num(L, t, "prob"), num(L, t, "commit"), 0}); z.ray = int(rays.size()) - 1; }
		for (int s = 0; s <= PLAN_STEPS; s++) {
			if (lua_rawgeti(L, t, s * 2 + 1) == LUA_TNIL) { lua_pop(L, 1); break; }
			double bx = lua_tonumber(L, -1); lua_pop(L, 1);
			lua_rawgeti(L, t, s * 2 + 2); double by = lua_tonumber(L, -1); lua_pop(L, 1);
			if (by > floor_y - 34 && by < floor_y + 16) { z.x = bx; z.y = by; hz[s].push_back(z); }
		}
		lua_pop(L, 1);
	}
	return 0;
}
// set_ctx(params, mx0, my0, floor, dirn, target, ham, age, fires): what stays the same for one decision
static int set_ctx(lua_State *L) {
	along_fix = truthy(L, 1, "along_fix"); land_stall2 = truthy(L, 1, "land_stall2"); ham_avoid = truthy(L, 1, "ham_avoid"); slope_jump = truthy(L, 1, "slope_jump");
	lua_getfield(L, 1, "ham_avoid_x"); ham_avoid_x = lua_isnumber(L, -1) ? lua_tonumber(L, -1) : 40; lua_pop(L, 1);
	odds_risk = truthy(L, 1, "odds_risk"); above_ok = truthy(L, 1, "above_ok");
	ray_clear = num(L, 1, "ray_clear"); see_lag = num(L, 1, "see_lag"); land_wait = num(L, 1, "land_wait"); ray_discount = num(L, 1, "ray_discount");
	respond = num(L, 1, "respond"); need_clear = num(L, 1, "need_clear"); fire_horizon = num(L, 1, "fire_horizon"); fire_spread = num(L, 1, "fire_spread");
	fire_x = num(L, 1, "fire_x"); fire_y = num(L, 1, "fire_y");
	wild_stick = truthy(L, 1, "wild_stick");
	wall_jump = truthy(L, 1, "wall_jump");
	follow_check = truthy(L, 1, "follow_check");
	dbg_act = 99;
	lua_getfield(L, 1, "dbgnative");
	if (lua_istable(L, -1)) { lua_rawgeti(L, -1, 1); dbg_act = long(lua_tointeger(L, -1)); lua_pop(L, 1); lua_rawgeti(L, -1, 2); dbg_w1 = long(lua_tointeger(L, -1)); lua_pop(L, 1); lua_rawgeti(L, -1, 3); dbg_j1 = lua_isnil(L, -1) ? 9 : long(lua_tointeger(L, -1)); lua_pop(L, 1); }
	lua_pop(L, 1);
	wild_aim = truthy(L, 1, "wild_aim");
	lua_getfield(L, 1, "follow_steps"); follow_steps = lua_isnil(L, -1) ? 30 : long(lua_tointeger(L, -1)); lua_pop(L, 1);
	contingent = truthy(L, 1, "contingent"); risk_odds = truthy(L, 1, "risk_odds");
	lua_getfield(L, 1, "contingent"); contingent_lvl = lua_isnumber(L, -1) ? long(lua_tointeger(L, -1)) : (contingent ? 1 : 0); lua_pop(L, 1);
	lua_getfield(L, 1, "contingent_lag"); contingent_lag = lua_isnumber(L, -1) ? long(lua_tointeger(L, -1)) : 0; lua_pop(L, 1);
	lua_getfield(L, 1, "wild_rom_us"); rom_us = {0.0, 0.5, 0.99};
	if (lua_istable(L, -1)) { rom_us.clear(); long n = long(luaL_len(L, -1)); for (long i = 1; i <= n; i++) { lua_rawgeti(L, -1, i); rom_us.push_back(lua_tonumber(L, -1)); lua_pop(L, 1); } }
	lua_pop(L, 1);
	lua_getfield(L, 1, "right_stand"); right_stand = lua_isnil(L, -1) ? 224 : lua_tonumber(L, -1); lua_pop(L, 1);
	lua_getfield(L, 1, "wall_right"); wall_right = false;
	if (lua_istable(L, -1)) { lua_rawgeti(L, -1, lua_tointeger(L, 4)); wall_right = lua_toboolean(L, -1); lua_pop(L, 1); }   // only on girders that reach the wall
	lua_pop(L, 1);
	wild_rom = truthy(L, 1, "wild_rom");
	lua_getfield(L, 1, "ham_avoid2"); has_ham2 = lua_istable(L, -1);
	if (has_ham2) { lua_rawgeti(L, -1, 1); ham2_lo = lua_tonumber(L, -1); lua_pop(L, 1); lua_rawgeti(L, -1, 2); ham2_hi = lua_tonumber(L, -1); lua_pop(L, 1); }
	lua_pop(L, 1);
	mx0 = lua_tonumber(L, 2); my0 = lua_tonumber(L, 3); floor_ = long(lua_tointeger(L, 4)); dirn = long(lua_tointeger(L, 5)); target = lua_tonumber(L, 6);
	ham = long(lua_tointeger(L, 7)); age = long(lua_tointeger(L, 8));
	fires.clear();
	long n = long(luaL_len(L, 9));
	for (long i = 1; i <= n; i++) {
		lua_rawgeti(L, 9, i); int t = lua_gettop(L);
		fires.push_back({num(L, t, "x"), num(L, t, "y"), num(L, t, "vx")});
		lua_pop(L, 1);
	}
	return 0;
}
// set_ham(counter, face, frames left) with the hammer held and ham_plan on; set_ham() off
static int set_ham(lua_State *L) {
	ham_on = !lua_isnoneornil(L, 1);
	if (ham_on) { ham_cnt = long(lua_tointeger(L, 1)); ham_face0 = long(lua_tointeger(L, 2)); ham_left = long(lua_tointeger(L, 3)); }
	return 0;
}
static int set_grab(lua_State *L) {
	grab_on = !lua_isnoneornil(L, 1);
	if (grab_on) { grab_lo = lua_tonumber(L, 1); grab_hi = lua_tonumber(L, 2); ham_face0 = long(lua_tointeger(L, 3)); }
	return 0;
}
// The hammer frame `fr` from now: -1 none, 0 up, 1 down. g_at: the plan's grab jump starts then (-1: no grab in this plan)
static int ham_phase(long fr, long g_at, long g_len) {
	if (ham_on) {
		if (fr >= ham_left) return -1;
		return (((ham_cnt + age + fr - 1) & 8) != 0) ? 1 : 0;   // the swing is set from the counter before it counts up that frame (checked: 716 / 716 frames)
	}
	if (g_at < 0 || fr < g_at + 19) return -1;
	long c = fr - (g_at + g_len + 4) + 1;
	if (c < 1) return 0;
	if (c > 512) return -1;
	return (((c - 1) & 8) != 0) ? 1 : 0;
}
// Is a barrel at (bx, by) inside the hammer's box (phase ph), with him at (mx, my) facing `face`?
static bool ham_hits(double bx, double by, double mx, double my, long face, int ph) {
	if (ph < 0) return false;
	bool down = ph == 1;
	double dx = bx - (down ? mx + 16.0 * double(face) : mx), dy = by - (down ? my : my - 16);
	if (dx < 0) dx = -dx;
	if (dy < 0) dy = -dy;
	return down ? (dx < 7 && dy + 1 < 8) : (dx < 8 && dy + 1 < 5);
}
// Wild barrels that head for Mario each time they land (wild_dynamic): moved in step with each plan.
struct Wild { double px, py, pv, fall, rest; long lvl; double spd; bool pend; double u; bool dead = false; };   // u: the random part of its speed after each bounce (wild_rom)
static std::vector<Wild> wilds; static double wild_floor_y = 0;
static const double WILD_GRAVITY = 0.0625; static const double WILD_REST = 6;
static double pre_v = 0; static bool has_pre = false;   // wild_pre: before the oil is lit, every landing sends it right at this speed
static int set_wild(lua_State *L) {
	wilds.clear(); wild_floor_y = lua_tonumber(L, 2);
	has_pre = !lua_isnoneornil(L, 3); pre_v = has_pre ? lua_tonumber(L, 3) : 0;
	long n = long(luaL_len(L, 1));
	for (long i = 1; i <= n; i++) {
		lua_rawgeti(L, 1, i); int t = lua_gettop(L); double v[8];
		for (int k = 0; k < 8; k++) { lua_rawgeti(L, t, k + 1); v[k] = lua_tonumber(L, -1); lua_pop(L, 1); }
		if (wild_rom) { for (double u : rom_us) wilds.push_back({v[0], v[1], v[2], v[3], v[4], long(v[5]), v[6], v[7] != 0, u}); }
		else wilds.push_back({v[0], v[1], v[2], v[3], v[4], long(v[5]), v[6], v[7] != 0, 0});
		lua_pop(L, 1);
	}
	return 0;
}
// One frame of a wild barrel. Each time it lands it goes the way Mario's stick is pressed (wild_stick), or, with the
// stick centred, towards him: measured on 3-1, pressing right sent it right in 1,766 of 1,886 landings.
static void wild_step(Wild &w, double mx, long press) {
	double toward = (wild_stick && press > 0) ? 1.0 : (mx >= w.px ? 1 : -1);   // only pressing right flings it (left presses: towards Mario, as measured)
	// wild_rom: as the game does it (0x2303): at each bounce, towards Mario's x, at 1 + u px a frame to the right or 1 - u to the left
	auto speed = [&](double dir) { return wild_rom ? (dir > 0 ? 1.0 + w.u : -(1.0 - w.u)) : dir * w.spd; };
	// wild_aim (difficulty 5, 0x231A): each bounce is aimed at Mario, at (his x - its x) * 4 / 256 px a frame
	if (has_pre) { if (w.pend) { w.pv = pre_v; w.pend = false; } }
	else if (wild_aim) { if (w.pend) { w.pv = (mx - w.px) / 64; w.pend = false; } }
	else if (w.pend) { w.pv = speed(toward); w.pend = false; }
	w.px = w.px + w.pv;
	if (w.rest > 0) { w.rest = w.rest - 1; if (w.rest == 0) w.fall = 0.5; }
	else {
		w.fall = w.fall + WILD_GRAVITY;
		w.py = w.py + w.fall;
		double land = (w.lvl > 0 && w.lvl <= 6 && LV[w.lvl].ok) ? LV[w.lvl].a + LV[w.lvl].s * w.px : 999;
		if (w.py >= land) { w.py = land; w.rest = WILD_REST; w.fall = 0; w.lvl = w.lvl - 1; w.pv = has_pre ? pre_v : wild_aim ? (mx - w.px) / 64 : speed((wild_stick && press > 0) ? 1.0 : (mx >= w.px ? 1 : -1)); }
	}
}
// Can he still get through from step s0, standing at x, by standing, walking a little, and/or one jump?
static bool follow_ok(long s0, double x, const std::vector<Wild> &ws0, double branch = -1) {
	if (s0 > PLAN_STEPS) return true;
	static const long walks[] = {0, -1, 1}; static const long waits[] = {0, 8, 16}; static const long jumps[] = {9, 0, -1, 1};   // 9 = no jump
	for (long d : walks) for (long cw : waits) for (long jd : jumps) {
		if (d == 0 && cw > 0 && jd == 9) continue;
		std::vector<Wild> ws = ws0;
		bool ok = true;
		double xw = x + double(d) * WALK * cw;
		for (long s = s0; s <= std::min(long(PLAN_STEPS), s0 + follow_steps) && ok; s++) {
			long t = (s - s0) * 2;
			double mx, my; long press = 0;
			if (t < cw) { mx = x + double(d) * WALK * t; my = mario_y(floor_, mx); press = d; }
			else if (jd == 9) { mx = xw; my = mario_y(floor_, mx); }
			else {
				long tj = t - cw;
				if (tj < JUMP_LEN) { mx = xw + double(jd) * JUMP_X * tj; my = mario_y(floor_, mx) + ARC[tj + 1]; press = jd; }
				else { mx = xw + double(jd) * JUMP_X * JUMP_LEN; my = mario_y(floor_, mx); }
			}
			if (mx < (wall_jump ? 22 : 30) || mx > 222) { ok = false; break; }
			for (const Haz &h : hz[s]) {
				// what's certain, and the branch asked about; with contingent >= 2 every "might" too (the way out must dodge all of them)
				if (h.ray >= 0 || (h.m && !(branch >= 0 && ((h.m == 2 && h.mval == branch) || contingent_lvl >= 2)))) continue;
				double dx = h.x - mx, dy = h.y - my;
				if (dx < 5 && dx > -5 && dy < 7 && dy > -7) { ok = false; break; }
			}
			if (!ok) break;
			for (Wild &w : ws) {
				if (w.py > wild_floor_y - 34 && w.py < wild_floor_y + 16) {
					double dx = w.px - mx, dy = w.py - my;
					if (dx < 5 && dx > -5 && dy < 7 && dy > -7) { ok = false; break; }
				}
				wild_step(w, mx, press); wild_step(w, mx, press);
			}
		}
		if (ok) return true;
	}
	return false;
}

// try(act, w1, j1, w2, j2, stay, last, usual, steps) -> as try_plan_now
static int try_plan(lua_State *L) {
	long act = long(lua_tointeger(L, 1)); double w1 = lua_tonumber(L, 2);
	bool has_j1 = !lua_isnil(L, 3); long j1 = has_j1 ? long(lua_tointeger(L, 3)) : 0;
	double w2 = lua_isnil(L, 4) ? 0 : lua_tonumber(L, 4);
	bool has_j2 = !lua_isnil(L, 5); long j2 = has_j2 ? long(lua_tointeger(L, 5)) : 0;
	bool stay = lua_toboolean(L, 6);
	double usual = lua_tonumber(L, 8); long steps = long(lua_tointeger(L, 9));
	bool juke = lua_toboolean(L, 10);
	// step (2026-11-14, the oracle review): press act only for the first `step` frames, then stand until w1 (step, pause, jump)
	double step = lua_isnumber(L, 11) ? lua_tonumber(L, 11) : 1e9;
	if (step > w1) step = 1e9;
	double jdx = 0;   // how far juke taps have moved him
	double xw = along(mx0, act, std::fmin(w1, step));
	auto wall = [](double x) { return (wall_jump && x < 22) ? 44 - x : ((wall_jump && wall_right && x > 233) ? 466 - x : x); };
	// slope_jump (measured 2026-11-11, Matt: landing on an incline takes a little longer): a jump lasts a frame longer for each
	// pixel lower he lands (downhill), a frame shorter landing higher
	auto jlen = [&](double x0, double x1) -> long {
		if (!slope_jump) return JUMP_LEN;
		long e = lround(mario_y(floor_, x1) - mario_y(floor_, x0));
		return JUMP_LEN + std::max(-1L, std::min(3L, e));
	};
	double xl = has_j1 ? wall(xw + double(j1) * JUMP_X * JUMP_LEN) : xw;
	const long JL1 = has_j1 ? jlen(xw, xl) : JUMP_LEN;
	if (has_j1 && JL1 != JUMP_LEN) xl = wall(xw + double(j1) * JUMP_X * JL1);
	double xs2 = 0, xl2 = xl; long JL2 = JUMP_LEN;
	if (has_j2) {
		xs2 = along(xl, dirn, land_stall2 ? std::fmax(0.0, w2 - LAND_STALL) : w2); xl2 = wall(xs2 + double(j2) * JUMP_X * JUMP_LEN);
		JL2 = jlen(xs2, xl2); if (JL2 != JUMP_LEN) xl2 = wall(xs2 + double(j2) * JUMP_X * JL2);
	}
	double best_c = 99; bool touched = false; bool risk = false; double mx = mx0, my = my0;
	bool dbg = act == dbg_act && long(w1) == dbg_w1 && (has_j1 ? j1 : 9) == dbg_j1 && !has_j2;
	double chance = 0;
	gen++;
	std::vector<Wild> ws = wilds;
	static double plan_x[PLAN_STEPS + 2]; static bool plan_air[PLAN_STEPS + 2];
	static long press_at[PLAN_STEPS + 2]; double risk_p = 0;   // risk_odds: the stick at each step, and the likeliest "might" that can't be dodged
	struct Gone { long k, br; }; std::vector<Gone> gone;   // ham_plan: barrels (or one path of one) smashed earlier in this plan
	auto smashed = [&](const Haz &h) { if (h.k < 0) return false; for (const Gone &g : gone) if (g.k == h.k && (g.br < 0 || g.br == h.br)) return true; return false; };
	long face = ham_face0; double px = mx0;
	// the game checks for the hammer once a jump, at its 19th frame: a straight first jump over it takes it (modelled); any other jump
	// that would be over it then is one we haven't measured, so it isn't planned
	auto over = [&](double x) { return x >= grab_lo && x <= grab_hi; };
	const bool grab = grab_on && !ham_on && has_j1 && j1 == 0 && !has_j2 && over(xw);   // this plan takes the top hammer
	if (grab_on && !ham_on && has_j1 && !grab) {
		bool bad = over(wall(xw + double(j1) * JUMP_X * 19)) || (has_j2 && over(wall(xs2 + double(j2) * JUMP_X * 19)));
		if (bad) { lua_pushnil(L); lua_pushinteger(L, long(w1)); lua_pushboolean(L, false); lua_pushnumber(L, xw); return 4; }
	}
	const long g_at = grab ? long(w1) : -1;
	const bool hammer = ham_on || grab;
	std::vector<char> fgone(fires.size(), 0);   // ham_plan: fireballs smashed earlier in this plan (Matt: the hammer smashes them too)
	for (long s = 0; s <= steps; s++) {
		long t = s * 2;
		if (t < w1) { mx = along(mx0, act, std::fmin(double(t), step)); my = mario_y(floor_, mx); }
		else if (!has_j1) { mx = stay ? xw : along(xw, dirn, t - w1); my = mario_y(floor_, mx); }   // stay (ham_plan): step, then stand
		else {
			double tj = t - w1;
			if (tj < JL1) { mx = wall(xw + double(j1) * JUMP_X * tj); my = mario_y(floor_, mx) + ARC[long(tj) + 1]; }
			else {
				double tw = tj - JL1;
				if (has_j2 && tw >= w2) {
					double tk = tw - w2;
					if (tk < JL2) { mx = wall(xs2 + double(j2) * JUMP_X * tk); my = mario_y(floor_, mx) + ARC[long(tk) + 1]; }
					else { mx = stay ? xl2 : along(xl2, dirn, std::fmax(0.0, tk - JL2 - LAND_STALL)); my = mario_y(floor_, mx); }
				} else { mx = (stay || has_j2) ? xl : along(xl, dirn, std::fmax(0.0, tw - LAND_STALL)); my = mario_y(floor_, mx); }
			}
		}
		bool ham2 = has_ham2 && floor_ == 2 && ham == 0 && has_j1 && t >= w1 && t - w1 < JL1 && mx >= ham2_lo && mx <= ham2_hi;
		if (jdx != 0) { my = my + mario_y(floor_, mx + jdx) - mario_y(floor_, mx); mx = mx + jdx; }
		bool airborne = has_j1 && ((t >= w1 && t - w1 < JL1) || (has_j2 && t - w1 - JL1 >= w2 && t - w1 - JL1 - w2 < JL2));
		plan_x[s] = mx; plan_air[s] = airborne;
		double right_end = (wall_jump && wall_right) ? (airborne ? 234 : right_stand) : 222;   // in the air up to the wall; standing, on the girder
		if (dbg && (mx < (wall_jump ? 22 : 30) || mx > right_end)) printf("    t=%ld off the girder at %.1f\n", t, mx);
		if (mx < (wall_jump ? 22 : 30) || mx > right_end || (ham_avoid && floor_ == 5 && mx < ham_avoid_x && mx0 >= ham_avoid_x && ham == 0) || ham2) {
			lua_pushnil(L); lua_pushinteger(L, t); lua_pushboolean(L, risk); lua_pushnumber(L, mx); return 4;
		}
		if (hammer) { if (mx > px + 0.01) face = 1; else if (mx < px - 0.01) face = -1; px = mx; }
		for (const Haz &h : hz[s]) {
			if (t > usual && !h.w) continue;
			if (hammer && smashed(h)) continue;
			double dx = h.x - mx, dy = h.y - my;
			if (dx < 0) dx = -dx;
			if (dy < 0) dy = -dy;
			double cl = dx - 5;
			if (dy - 7 > cl) cl = dy - 7;
			if (h.ray >= 0) {
				Ray &r = rays[h.ray];
				if (cl <= ray_clear && r.stamp != gen) {
					r.stamp = gen;
					double free = r.commit + see_lag;
					if (has_j1 && free >= w1 && free < w1 + JL1 + land_wait) free = w1 + JL1 + land_wait;
					chance = chance + r.prob * (t - free >= respond ? ray_discount : 1);
				}
			} else if (h.m) {
				if (cl < need_clear) {
					if (h.m == 1 || !odds_risk) risk = true;
					else if (t >= h.mval) {
						double free = h.mval + see_lag;
						if (has_j1 && free >= w1) {
							double a1 = w1 + JL1 + land_wait;
							if (free < a1) free = a1;
							if (has_j2) {
								double a2 = a1 - land_wait + w2;
								if (free >= a2 && free < a2 + JL2 + land_wait) free = a2 + JL2 + land_wait;
							}
						}
						if (t - free < respond) {
							// contingent (Matt, 2026-11-13: plan like a person who'll react when he sees which way it goes): from where this
							// plan has him when he'd see it commit, is there a way out of that branch (stand, step, or a jump)?
							long sf = std::max(0L, std::min(long(free + contingent_lag + 1) / 2, s));   // contingent_lag: frames of extra reaction
							if (contingent && !plan_air[sf] && follow_ok(sf, plan_x[sf], std::vector<Wild>(), h.mval)) {}
							else {
								risk = true;
								if (risk_odds) {
									// when it decides (commit, mval frames on): down 3 in 4 if his stick points at the ladder or he's at its x, else 3 in 16
									long sc = std::max(0L, std::min(long(h.mval) / 2, s));
									double lx = h.lad, px = plan_x[sc];
									bool toward = lx < 0 || std::fabs(px - lx) < 1 || (press_at[sc] > 0 && lx > px) || (press_at[sc] < 0 && lx < px);
									double p = toward ? 0.75 : 0.1875;
									if (p > risk_p) risk_p = p;
								}
							}
						}
					}
				}
			} else {
				if (dbg && cl < 3) printf("    t=%ld mario(%.1f,%.1f) barrel(%.1f,%.1f) cl=%.1f\n", t, mx, my, h.x, h.y, cl);
				if (cl <= 0) { lua_pushnil(L); lua_pushinteger(L, t); lua_pushboolean(L, risk); lua_pushnumber(L, mx); return 4; }
				bool roof = above_ok && !h.w && h.y < my && cl == dy - 7;
				if (!roof && cl < best_c) { best_c = cl; touched = true; }
			}
		}
		if (hammer) {
			// he's still alive this step: the first barrel inside the hammer's box is smashed (the game's order: Mario first, then the hammer)
			bool hit = false;
			for (long fr = t; fr <= t + 1 && !hit; fr++) {
				for (const Haz &h : hz[s]) {
					if (h.ray >= 0 || h.k < 0 || smashed(h)) continue;
					if (ham_hits(h.x, h.y, mx, my, face, ham_phase(fr, g_at, JL1))) { gone.push_back({h.k, h.m ? h.br : -1}); hit = true; break; }
				}
				if (!hit) for (Wild &w : ws) if (!w.dead && ham_hits(w.px, w.py, mx, my, face, ham_phase(fr, g_at, JL1))) { w.dead = true; hit = true; break; }
			}
		}
		// which way this plan has the stick pressed at this moment
		long press;
		if (t < w1) press = t < step ? act : 0;
		else if (!has_j1) press = (stay || mx == target) ? 0 : dirn;
		else {
			double tj = t - w1;
			if (tj < JL1) press = j1;
			else if (has_j2 && tj - JL1 >= w2 && tj - JL1 - w2 < JL2) press = j2;
			else press = (stay || (has_j2 && tj - JL1 < w2)) ? 0 : ((mx == target) ? 0 : dirn);
		}
		press_at[s] = press;
		// a juke: while standing, tap right if a wild barrel lands during these two frames
		if (juke && t < w1 && act == 0) {
			bool lands = false;
			for (const Wild &w : ws) { Wild c = w; long l0 = c.lvl; wild_step(c, mx, 1); wild_step(c, mx, 1); if (c.lvl != l0) lands = true; }
			if (lands) { press = 1; jdx = jdx + 2 * WALK; }
		}
		for (Wild &w : ws) {
			if (!w.dead && w.py > wild_floor_y - 34 && w.py < wild_floor_y + 16) {
				double dx = w.px - mx, dy = w.py - my;
				if (dx < 0) dx = -dx;
				if (dy < 0) dy = -dy;
				double cl = dx - 5;
				if (dy - 7 > cl) cl = dy - 7;
				if (dbg && cl < 3) printf("    t=%ld mario(%.1f,%.1f) wild(%.1f,%.1f) cl=%.1f\n", t, mx, my, w.px, w.py, cl);
				if (cl <= 0) { lua_pushnil(L); lua_pushinteger(L, t); lua_pushboolean(L, risk); lua_pushnumber(L, mx); return 4; }
				if (cl < best_c) { best_c = cl; touched = true; }
			}
			wild_step(w, mx, press); wild_step(w, mx, press);
		}
		if (t <= fire_horizon && t <= usual) {
			double sp = fire_spread * t;
			for (size_t fi = 0; fi < fires.size(); fi++) {
				const Fire &fb = fires[fi];
				if (fgone[fi]) continue;
				// with the hammer: smashed if its predicted spot is in the hammer's box (barrel-sized, so it doesn't count on near misses)
				if (hammer && (ham_hits(fb.x + fb.vx * double(age + t), fb.y, mx, my, face, ham_phase(t, g_at, JL1)) || ham_hits(fb.x + fb.vx * double(age + t), fb.y, mx, my, face, ham_phase(t + 1, g_at, JL1)))) { fgone[fi] = 1; continue; }
				double dx = fb.x + fb.vx * double(age + t) - mx, dy = fb.y - my;
				if (dx < 0) dx = -dx;
				if (dy < 0) dy = -dy;
				double cl = dx - fire_x - sp;
				if (dy - fire_y - sp > cl) cl = dy - fire_y - sp;
				if (cl <= 0) { lua_pushnil(L); lua_pushinteger(L, t); lua_pushboolean(L, risk); lua_pushnumber(L, mx); return 4; }
				if (cl < best_c) { best_c = cl; touched = true; }
			}
		}
	}
	if (touched) lua_pushnumber(L, best_c); else lua_pushinteger(L, 99);
	lua_pushvalue(L, 7); lua_pushboolean(L, risk); lua_pushnumber(L, mx); lua_pushnumber(L, chance);
	// follow_check: from where this plan leaves him, is there still some simple safe move? (a player thinks one step on)
	if (follow_check) lua_pushboolean(L, follow_ok(steps + 1, mx, ws)); else lua_pushnil(L);
	lua_pushnumber(L, risk_p);   // (risk_odds)
	return 7;
}

// ---- barrel_paths' roll(): a barrel rolling along the girders from (x, y) at step t on level lvl, with every ladder it
// might take as another path. Same steps and arithmetic as policy.lua's roll.
#include <deque>

static long NSTEP = 0; static double drop_rate = 0.95; static bool arc_snap = false, arc_timed = false;
static const double ROLL = 1.0; static const long STEP = 2, LEFT_END = 27, RIGHT_END = 227, END_FRAMES = 24, END_OUT = 9;
struct CPath { std::vector<double> v; long commit, lad; };
static std::deque<CPath> alts; static long nout, mfloor;
static void roll_c(double x, double y, long t, long lvl, std::vector<double> &into) {
	if (lvl < 1 || lvl > 6 || !LV[lvl].ok) return;
	Lvl L = LV[lvl];
	std::vector<long> *drops = (lvl >= 1 && lvl <= 6 && !DR[lvl].empty()) ? &DR[lvl] : nullptr;
	while (t <= NSTEP) {
		into.push_back(x); into.push_back(L.a + L.s * x);
		double nx = x + double(L.dir) * ROLL * STEP;
		if (drops && nout < 4 && lvl > mfloor) {
			for (long d : *drops) {
				if ((x <= d && nx > d) || (x >= d && nx < d)) {
					alts.push_back({into, t * STEP, d}); CPath &alt = alts.back(); nout++;
					double ax = double(d), ay = L.a + L.s * double(d); long at = t + 1;
					if (lvl - 1 >= 1 && LV[lvl - 1].ok) {
						Lvl nl = LV[lvl - 1];
						double land = nl.a + nl.s * double(d);
						while (at <= NSTEP && ay < land) { ay = ay + drop_rate * STEP; alt.v.push_back(ax); alt.v.push_back(ay); at = at + 1; }
						if (at <= NSTEP) roll_c(ax, ay, at, lvl - 1, alt.v);
					}
				}
			}
		}
		x = nx; t = t + 1;
		if ((L.dir > 0 && x >= RIGHT_END) || (L.dir < 0 && x <= LEFT_END)) {
			if (lvl - 1 < 1 || !LV[lvl - 1].ok) return;
			Lvl nl = LV[lvl - 1];
			long side = L.dir; double xe = x, ye = L.a + L.s * x;
			double tt = 0;
			if (arc_snap) { xe = side > 0 ? 228 : 26; ye = L.a + L.s * xe; tt = std::fmax(0.0, (x - xe) * double(side) / ROLL); }
			while (t <= NSTEP && tt < END_FRAMES) {
				into.push_back(xe + double(side * END_OUT) * tt / double(END_FRAMES));
				into.push_back(ye + tt * tt / 30);
				tt = tt + STEP; t = t + 1;
			}
			x = xe + double(side * END_OUT);
			if (arc_snap) {
				double past = tt - END_FRAMES - 2;
				if (past > 0) x = x - double(side) * ROLL * past;
			} else if (arc_timed && t <= NSTEP) {
				into.push_back(x); into.push_back(ye + double(END_FRAMES * END_FRAMES) / 30); t = t + 1;
			}
			lvl = lvl - 1; L = nl; drops = !DR[lvl].empty() ? &DR[lvl] : nullptr;
		}
	}
}
// set_world(LEVEL, DROPS, NSTEP, params): the girders and ladders, once
static int set_world(lua_State *L) {
	for (int l = 1; l <= 6; l++) {
		LV[l].ok = false; DR[l].clear();
		if (lua_rawgeti(L, 1, l) == LUA_TTABLE) { LV[l] = {num(L, -1, "a"), num(L, -1, "s"), long(num(L, -1, "dir")), true}; }
		lua_pop(L, 1);
		if (lua_rawgeti(L, 2, l) == LUA_TTABLE) {
			long n = long(luaL_len(L, -1));
			for (long i = 1; i <= n; i++) { lua_rawgeti(L, -1, i); DR[l].push_back(long(lua_tointeger(L, -1))); lua_pop(L, 1); }
		}
		lua_pop(L, 1);
	}
	NSTEP = long(lua_tointeger(L, 3));
	lua_getfield(L, 4, "drop_rate"); drop_rate = lua_isnil(L, -1) ? 0.95 : lua_tonumber(L, -1); lua_pop(L, 1);
	arc_snap = truthy(L, 4, "arc_snap"); arc_timed = truthy(L, 4, "arc_timed");
	return 0;
}
// roll(x, y, t, lvl, into, out, mario_floor): as policy.lua's roll, writing into `into` and adding ladder paths to `out`
static int roll(lua_State *L) {
	double x = lua_tonumber(L, 1), y = lua_tonumber(L, 2); long t = long(lua_tointeger(L, 3)), lvl = long(lua_tointeger(L, 4));
	mfloor = long(lua_tointeger(L, 7));
	long n0 = long(luaL_len(L, 5));
	std::vector<double> into; into.reserve(n0 + 2 * NSTEP + 8);
	for (long i = 1; i <= n0; i++) { lua_rawgeti(L, 5, i); into.push_back(lua_tonumber(L, -1)); lua_pop(L, 1); }
	long out0 = long(luaL_len(L, 6)); nout = out0; alts.clear();
	roll_c(x, y, t, lvl, into);
	for (size_t i = n0; i < into.size(); i++) { lua_pushnumber(L, into[i]); lua_rawseti(L, 5, lua_Integer(i + 1)); }
	long k = out0;
	for (CPath &a : alts) {
		lua_createtable(L, int(a.v.size()), 3);
		for (size_t i = 0; i < a.v.size(); i++) { lua_pushnumber(L, a.v[i]); lua_rawseti(L, -2, lua_Integer(i + 1)); }
		lua_pushboolean(L, 1); lua_setfield(L, -2, "maybe");
		lua_pushinteger(L, a.commit); lua_setfield(L, -2, "commit");
		lua_pushinteger(L, a.lad); lua_setfield(L, -2, "lad");
		lua_rawseti(L, 6, ++k);
	}
	return 0;
}
// juke_now(n): would a wild barrel land within n frames, with the stick pressed right?
static int juke_now(lua_State *L) {
	long n = long(luaL_optinteger(L, 1, 3));
	for (const Wild &w : wilds) { Wild c = w; long l0 = c.lvl; for (long i = 0; i < n; i++) wild_step(c, mx0, 1); if (c.lvl != l0) { lua_pushboolean(L, 1); return 1; } }
	lua_pushboolean(L, 0); return 1;
}
void plan_register(lua_State *L) {
	lua_newtable(L);
	lua_pushcfunction(L, set_arc); lua_setfield(L, -2, "set_arc");
	lua_pushcfunction(L, set_hz); lua_setfield(L, -2, "set_hz");
	lua_pushcfunction(L, fill); lua_setfield(L, -2, "fill");
	lua_pushcfunction(L, set_world); lua_setfield(L, -2, "set_world");
	lua_pushcfunction(L, roll); lua_setfield(L, -2, "roll");
	lua_pushcfunction(L, set_wild); lua_setfield(L, -2, "set_wild");
	lua_pushcfunction(L, juke_now); lua_setfield(L, -2, "juke_now");
	lua_pushcfunction(L, set_ctx); lua_setfield(L, -2, "set_ctx");
	lua_pushcfunction(L, set_ham); lua_setfield(L, -2, "set_ham");
	lua_pushcfunction(L, set_grab); lua_setfield(L, -2, "set_grab");
	lua_pushcfunction(L, try_plan); lua_setfield(L, -2, "try");
	lua_setglobal(L, "dkh_native");
}
