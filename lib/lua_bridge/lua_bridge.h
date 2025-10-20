#ifndef LUA_BRIDGE
#define LUA_BRIDGE
#endif

#include <c_functions.h>
#include "lua.hpp"

extern lua_State* L;

bool loadLuaScript(const char* path);
bool initLua(const char* scriptPath);
void luaLoop();