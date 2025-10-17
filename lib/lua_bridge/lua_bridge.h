#ifndef LUA_BRIDGE
#define LUA_BRIDGE
#endif

bool initLua(const char* scriptPath);
void luaLoop();