# dkh: this project's Lua scripts on the dkx emulator. DKX is the dkx source folder; Lua is MAME 0.264's own copy (5.4.4), so the player runs on the same Lua as in MAME.
DKX ?= $(HOME)/dkx-build/DK-x86-AI/dkx
LUASRC ?= $(HOME)/mame-0264-lto/3rdparty/lua/src
CXX = clang++
CC = clang
CXXFLAGS = -std=c++17 -O3 -mcpu=native -ffp-contract=off -I$(DKX) -I$(LUASRC) -w
CFLAGS = -O2 -mcpu=native -ffp-contract=off -DLUA_USE_MACOSX -w
LUAOBJ = $(patsubst $(LUASRC)/%.c,build/lua/%.o,$(filter-out $(LUASRC)/lua.c $(LUASRC)/luac.c,$(wildcard $(LUASRC)/*.c)))
build/dkh: dkh.cpp plan.cpp rivsim.cpp $(LUAOBJ) $(wildcard $(DKX)/*.cpp $(DKX)/*.h)
	$(CXX) $(CXXFLAGS) -o $@ dkh.cpp plan.cpp rivsim.cpp $(DKX)/unity.cpp $(LUAOBJ) -lz
build/lua/%.o: $(LUASRC)/%.c
	@mkdir -p build/lua
	$(CC) $(CFLAGS) -c -o $@ $<
clean:
	rm -rf build
