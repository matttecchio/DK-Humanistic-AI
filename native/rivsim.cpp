// rivsim.cpp: imagined futures for the rivet board (2026-11-15, Matt: "you may do all of those"; the fireball behaviour model).
// Fireballs are moved by the odds measured in his own games (runs/fx01_fire, 400 games, every 4 frames):
//   along a girder: keep going, turn ~12% per 8 frames (calibrated: 3.7% measured on open girder alone was overconfident), turn back at a girder's end or a pulled rivet's gap (they can't cross)
//   a ladder going up from where it is: taken on 16% of visits, whatever Mario does
//   a ladder going down: taken on 22% of visits only with Mario below it, never otherwise
//   speeds (px/frame): typical, pauses included: right 0.48, left 0.40, down a ladder 0.53, up a ladder 0.20
// Calibrated against the logs: predicted vs real share of a fireball reaching a spot within 90 frames, error 0.0052 per case.
// Nothing here knows the game's random numbers: the futures are what a player who knows how fireballs behave would imagine.
// dkh_native.rivsim(fires, gone, course, opts) -> share of futures where a fireball touches him, mean frame of the first touch
//   fires: {{x, y, vx, vy}, ...}   gone: bitmask of pulled rivets (2L=1, 2R=2, 3L=4, 3R=8, 4L=16, 4R=32, 5L=64, 5R=128)
//   course: {t, x, y, t, x, y, ...} where he'll be (every few frames; after the last point he stays there)
//   opts: {n = futures, T = frames, seed, rx = touch distance x, ry = touch distance y}
extern "C" {
#include "lua.h"
#include "lauxlib.h"
}
#include <cmath>
#include <cstdint>
#include <vector>

namespace {
const int FY[6] = {0, 240, 200, 160, 120, 80};
const int ENDL[6] = {0, 19, 27, 28, 43, 51}, ENDR[6] = {0, 234, 229, 221, 213, 205};
const int LADS[5][5] = {{0}, {24, 120, 224, -1}, {32, 88, 160, 216, -1}, {40, 120, 208, -1}, {48, 80, 168, 200, -1}};   // up from girder 1-4
const int RIVX[2] = {72, 176};   // rivet columns (x .. x+7), girders 2-5

struct Rng { uint64_t s; double u() { s ^= s << 13; s ^= s >> 7; s ^= s << 17; return (s >> 11) * (1.0 / 9007199254740992.0); } };

struct Fb { double x, y; int g; int mode; int dir; double frozen = 0; };   // frozen: still until that frame (riv_freeze)   // mode 0 girder (g), 1 up a ladder, -1 down a ladder

int girder_at(double y) { for (int g = 1; g <= 5; g++) if (std::fabs(y - FY[g]) <= 3) return g; return 0; }

bool gap(int gone, int g, int side) { return g >= 2 && (gone >> ((g - 2) * 2 + side) & 1); }

int rivsim(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE); int gone = (int)luaL_checkinteger(L, 2); luaL_checktype(L, 3, LUA_TTABLE); luaL_checktype(L, 4, LUA_TTABLE);
	auto num = [&](int idx, const char *k, double d) { lua_getfield(L, idx, k); double v = lua_isnumber(L, -1) ? lua_tonumber(L, -1) : d; lua_pop(L, 1); return v; };
	int N = (int)num(4, "n", 32), T = (int)num(4, "T", 90); double rx = num(4, "rx", 8), ry = num(4, "ry", 9);
	// speeds: by default the calibrated averages; the caller passes the current difficulty's (Matt: they speed up through the board)
	double VR = num(4, "vr", 0.48), VL = num(4, "vL", 0.40), VU = num(4, "vu", 0.20), VD = num(4, "vd", 0.53);
	VL = num(4, "vl", VL);
	// (Matt: "go ahead") the next spawn: due spawn_t frames from now (negative: none); a new fireball appears at the end of one
	// of girders 1-4 (measured: always a girder end), on the side opposite where he is then
	double SPT = num(4, "spawn_t", -1);
	// (Matt: "It's like he has a better awareness of the fireballs and is able to manipulate them better") measured: a fireball
	// turning on a girder turns towards Mario's side 66% of the time with him on its girder, 74% with him below, 52% above: so
	// with him level or below, heading away it turns more often (hi), heading towards him less (lo), per 8 frames
	double TURN = num(4, "turn", 0.12);   // turn chance per 8 frames (calibrated 0.12; tunable for the tests)
	int BIAS = (int)num(4, "bias", 0);
	double BHB = num(4, "bias_hi_below", 0.18), BLB = num(4, "bias_lo_below", 0.065), BHL = num(4, "bias_hi_level", 0.16), BLL = num(4, "bias_lo_level", 0.08);
	const int SPX[2][5] = {{0, 16, 24, 32, 40}, {0, 232, 224, 216, 208}};
	Rng rng{(uint64_t)num(4, "seed", 12345) * 2654435761ull + 1};
	std::vector<Fb> f0;
	int nf = (int)lua_rawlen(L, 1);
	for (int i = 1; i <= nf; i++) {
		lua_rawgeti(L, 1, i);
		lua_rawgeti(L, -1, 1); double x = lua_tonumber(L, -1); lua_pop(L, 1);
		lua_rawgeti(L, -1, 2); double y = lua_tonumber(L, -1); lua_pop(L, 1);
		lua_rawgeti(L, -1, 3); double vx = lua_tonumber(L, -1); lua_pop(L, 1);
		lua_rawgeti(L, -1, 4); double vy = lua_tonumber(L, -1); lua_pop(L, 1);
		lua_rawgeti(L, -1, 5); double fz = lua_isnumber(L, -1) ? lua_tonumber(L, -1) : 0; lua_pop(L, 1);
		lua_pop(L, 1);
		Fb b{x, y, girder_at(y), 0, vx > 0.05 ? 1 : (vx < -0.05 ? -1 : 0)};
		b.frozen = fz;
		if (!b.g) b.mode = vy < 0 ? 1 : -1;
		f0.push_back(b);
	}
	std::vector<double> ct, cx, cy;
	int nc = (int)lua_rawlen(L, 3);
	for (int i = 1; i + 2 <= nc; i += 3) {
		lua_rawgeti(L, 3, i); ct.push_back(lua_tonumber(L, -1)); lua_pop(L, 1);
		lua_rawgeti(L, 3, i + 1); cx.push_back(lua_tonumber(L, -1)); lua_pop(L, 1);
		lua_rawgeti(L, 3, i + 2); cy.push_back(lua_tonumber(L, -1)); lua_pop(L, 1);
	}
	if (ct.empty()) { lua_pushnumber(L, 0); lua_pushnumber(L, 0); return 2; }
	const double dt = 2;
	int hits = 0; double tsum = 0;
	for (int k = 0; k < N; k++) {
		std::vector<Fb> fb = f0;
		for (auto &b : fb) if (b.mode == 0 && b.dir == 0) b.dir = rng.u() < 0.5 ? -1 : 1;
		size_t ci = 0; bool hit = false; bool spawned = SPT < 0;
		for (double t = 0; t <= T && !hit; t += dt) {
			while (ci + 1 < ct.size() && ct[ci + 1] <= t) ci++;
			double mx = cx[ci], my = cy[ci];
			if (!spawned && t >= SPT) {
				spawned = true;
				int side = mx < 128 ? 1 : 0, g = 1 + (int)(rng.u() * 4);
				fb.push_back(Fb{(double)SPX[side][g], (double)FY[g], g, 0, side ? -1 : 1});
			}
			for (auto &b : fb) {
				if (b.frozen > t) { if (std::fabs(b.x - mx) < rx && std::fabs(b.y - my) < ry) { hit = true; hits++; tsum += t; break; } continue; }
				if (b.mode == 0) {
					double sp = b.dir > 0 ? VR : VL;
					double nx = b.x + b.dir * sp * dt;
					double tr = TURN;
					if (BIAS) {
						bool lev = std::fabs(my - b.y) <= 4, below = my > b.y + 4;
						if (lev || below) { bool toward = (mx - b.x) * b.dir > 0; tr = toward ? (below ? BLB : BLL) : (below ? BHB : BHL); }
					}
					if (rng.u() < 1 - std::pow(1 - tr, dt / 8)) b.dir = -b.dir, nx = b.x + b.dir * sp * dt;
					// ends and gaps: turn back
					if (nx < ENDL[b.g] || nx > ENDR[b.g]) { b.dir = -b.dir; nx = b.x; }
					for (int s = 0; s < 2 && b.g >= 2; s++) if (gap(gone, b.g, s)) {
						double lo = RIVX[s] - 1, hi = RIVX[s] + 8;
						if ((b.x <= lo && nx > lo) || (b.x >= hi && nx < hi)) { b.dir = -b.dir; nx = b.x; }
					}
					// passing a ladder's middle: up (16%), or down (22%, only with Mario below)
					bool moved = false;
					for (int j = 0; b.g <= 4 && LADS[b.g][j] >= 0 && j < 5 && !moved; j++) {
						double c = LADS[b.g][j] + 4;
						if ((b.x - c) * (nx - c) <= 0 && nx != b.x && rng.u() < 0.16) { b.x = c; b.mode = 1; moved = true; }
					}
					for (int j = 0; b.g >= 2 && LADS[b.g - 1][j] >= 0 && j < 5 && !moved; j++) {
						double c = LADS[b.g - 1][j] + 4;
						if ((b.x - c) * (nx - c) <= 0 && nx != b.x && my > b.y + 4 && rng.u() < 0.22) { b.x = c; b.mode = -1; moved = true; }
					}
					if (!moved) b.x = nx;
				} else {
					b.y += (b.mode > 0 ? -VU : VD) * dt;
					for (int g = 1; g <= 5; g++) if ((b.mode > 0 && b.y <= FY[g] && b.y > FY[g] - 3) || (b.mode < 0 && b.y >= FY[g] && b.y < FY[g] + 3)) {
						b.y = FY[g]; b.g = g; b.mode = 0; b.dir = rng.u() < 0.5 ? -1 : 1; break;
					}
				}
				if (std::fabs(b.x - mx) < rx && std::fabs(b.y - my) < ry) { hit = true; hits++; tsum += t; break; }
			}
		}
	}
	lua_pushnumber(L, (double)hits / N);
	lua_pushnumber(L, hits ? tsum / hits : 0);
	return 2;
}
}

void rivsim_register(lua_State *L) {
	lua_getglobal(L, "dkh_native");
	if (lua_istable(L, -1)) { lua_pushcfunction(L, rivsim); lua_setfield(L, -2, "rivsim"); }
	lua_pop(L, 1);
}
