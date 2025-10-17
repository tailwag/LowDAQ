#include <Arduino.h>
#include <SPI.h>
#include <SD.h>
#include <mcp2515.h>
#include "lua.hpp"
#include <lua_bridge.h>

#define CAN_CS 10 
#define SD_CS 9

MCP2515 can0(CAN_CS);
lua_State* L;

// Expose millis() to lua
int lua_millis(lua_State* L) {
    lua_pushinteger(L, millis());
    return 1;
}

// Expose CAN frame send to LUA
int lua_sendCanFrame(lua_State* L) {
    int id  = luaL_checkinteger(L, 1);
    int dlc = luaL_checkinteger(L, 2);

    uint8_t data[8] = {0};
    for (int i = 0; i < dlc; i++) 
        data[i] = luaL_checkinteger(L, 3 + i); 

    can_frame frame;

    frame.can_id = id;
    frame.can_dlc = dlc;

    memcpy(frame.data, data, dlc);

    can0.sendMessage(&frame);
    return 0;
}

// Expose Serial print to Lua
int lua_print(lua_State* L) {
    int n = lua_gettop(L);
    for (int i = 1; i <= n; i++) {
        if (lua_isstring(L, i)) Serial.print(lua_tostring(L, i));
        else Serial.print(luaL_tolstring(L, i, NULL));
        if (i != n) Serial.print("\t");
    }
    Serial.println();
    return 0;
}

// Expose Serial print to Lua
int lua_printf(lua_State* L) {
    int n = lua_gettop(L);
    for (int i = 1; i <= n; i++) {
        if (lua_isstring(L, i)) Serial.print(lua_tostring(L, i));
        else Serial.print(luaL_tolstring(L, i, NULL));
        if (i != n) Serial.print("\t");
    }
    return 0;
}

// Expose Serial reading to lua
int lua_serialRead(lua_State* L) {
    if (Serial.available() > 0)
        lua_pushinteger(L, Serial.read());
    else 
        lua_pushinteger(L, -1);
    
    return 1;
}

// Register functions
void registerLuaFunctions(lua_State* L) {
    lua_register(L, "millis", lua_millis);
    lua_register(L, "sendCanFrame", lua_sendCanFrame);
    lua_register(L, "print", lua_print);
    lua_register(L, "printf", lua_printf);
    lua_register(L, "serialRead", lua_serialRead);
}

bool loadLuaScript(const char* path) {
    File file = SD.open(path);
    if (!file) {
        Serial.println("Failed to open Lua script on SD!");
        return false;
    }

    // Read entire file into memory
    size_t size = file.size();
    char* buffer = new char[size + 1];
    file.readBytes(buffer, size);
    buffer[size] = '\0';
    file.close();

    // Execute Lua script
    if (luaL_dostring(L, buffer) != LUA_OK) {
        Serial.print("Lua error: ");
        Serial.println(lua_tostring(L, -1));
        lua_pop(L, 1);
        delete[] buffer;
        return false;
    }

    delete[] buffer;
    return true;
}

// ---- Public API ----
bool initLua(const char* scriptPath) {
    if (can0.reset() != MCP2515::ERROR_OK) return false;
    can0.setBitrate(CAN_500KBPS, MCP_16MHZ);
    can0.setNormalMode();

    if (!SD.begin(SD_CS)) return false;

    L = luaL_newstate();
    luaL_openlibs(L);
    registerLuaFunctions(L);

    return loadLuaScript(scriptPath);
}

void luaLoop() {
    lua_getglobal(L, "loop");
    if (lua_pcall(L, 0, 0, 0) != LUA_OK) {
        Serial.print("Lua loop error: ");
        Serial.println(lua_tostring(L, -1));
        lua_pop(L, 1);
    }

    // call Lua serial command parser
    lua_getglobal(L, "processSerial");
    if (lua_pcall(L, 0, 0, 0) != LUA_OK) {
        Serial.print("Lua serial error: ");
        Serial.println(lua_tostring(L, -1));
        lua_pop(L, 1);
    }
}