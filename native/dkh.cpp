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
	L = luaL_newstate(); luaL_openlibs(L); build_api(); if (!getenv("DKH_LUA_ONLY")) plan_register(L);
	if (luaL_dofile(L, argv[1]) != LUA_OK) { fprintf(stderr, "dkh: %s\n", lua_tostring(L, -1)); return 1; }
	dk_frame_hook = hook; dk_power_on();
	while (!quit) {
		dk_timeslice();
		if (pend) {
			int p = pend; pend = 0;
			if (p == 2) { if (!save_state(pend_file)) fprintf(stderr, "dkh: cannot save %s\n", pend_file.c_str()); }
			else if (!load_state(pend_file)) { fprintf(stderr, "dkh: cannot load %s\n", pend_file.c_str()); return 1; }
		}
	}
	return failed ? 1 : 0;
}
