#ifndef LUA_BRIDGE
#define LUA_BRIDGE
#endif

#include <c_functions.h>
#include "lua.hpp"

#ifdef ARDUINO_NUCLEO_F401RE
  #define CAN0_CS 10 
  #define SD_CS 9
  #define ADS1_ID 0x48
#endif

#ifdef ARDUINO_NUCLEO_G474RE
  #define CAN0_CS 10 
  #define SD_CS 9
  #define ADS1_ID 0x48
#endif

#ifdef ARDUINO_NUCLEO_H753ZI
  #define CAN0_CS 10 
  #define SD_CS 9
  #define ADS1_ID 0x48
#endif

#ifdef L432KC_BOARD
  #define CAN0_CS 2
  #define CAN1_CS 3
  #define CAN2_CS A3
  #define CAN3_CS A4
  #define SD_CS 6
  #define ADS1_ID 0x48
  #define ADS2_ID 0x49
#endif



extern lua_State* L;

void _log(String msg); 

bool loadLuaScript(const char* path);
bool initLua(const char* scriptPath);
void luaLoop();
