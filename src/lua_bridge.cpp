#include <Arduino.h>
#include <SPI.h>
#include <mcp2515.h>
#include <stpwm.h>
#include <lua_bridge.h>
#include <Adafruit_ADS1X15.h>

#define CAN_CS 10 
#define SD_CS 9
#define ADS1_ID 0x48

htPwm * pwm[NUM_PWM] = {
    new htPwm(PA8),
    new htPwm(PA0),
    new htPwm(PB7),
};



MCP2515 can0(CAN_CS);
Adafruit_ADS1115 adc0;

lua_State* L;

int lua_getNumPWMs(lua_State* L) {
    lua_pushinteger(L, NUM_PWM);

    return 1;
}

int lua_setPwmFrequency(lua_State* L) {
    int chan = luaL_checkinteger(L, 1);
    int freq = luaL_checkinteger(L, 2);
    
    pwm[chan-1]->setFrequency(freq);

    return 0;
}

int lua_setPwmDutyCycle(lua_State* L) {
    int chan = luaL_checkinteger(L, 1);
    int duty = luaL_checkinteger(L, 2);

    pwm[chan-1]->setDutyCycle(duty);

    return 0;
}

int lua_setPwmState(lua_State* L) {
    int chan = luaL_checkinteger(L, 1);
    int state = constrain(luaL_checkinteger(L, 2), 0, 1); 

    if (state)
        pwm[chan-1]->enable();
    else
        pwm[chan-1]->disable();

    return 0;
}

int lua_getPwmList(lua_State* L) {
    char * pwmStrings[NUM_PWM];
    uint8_t a = 0;

    String pushString = "return {";
    for (auto &p : pwm) {
        pushString += "{";
        pushString += String(p->getFrequency()) + ",";
        pushString += String(p->getDutyCycle()) + ",";
        pushString += String(p->getState())     + "},";

        ++a;
    }
    pushString += "}";

    uint8_t sLen = pushString.length() + 1;

    char pushArr[sLen];

    pushString.toCharArray(pushArr, sLen); 

    lua_pushstring(L, pushArr);

    return 1;
}

// load a lua module file and return it as a string
int lua_getFileContents(lua_State* L) {
    const char* filename = luaL_checkstring(L, 1);

    File dataFile = SD.open(filename, FILE_READ);
    String fileText = "";

    if (dataFile) {
        while(dataFile.available()) {
            fileText += (char)dataFile.read();
        }
        dataFile.close();
    }

    int strArrLength = fileText.length() + 1;
    char retStr[strArrLength];
    fileText.toCharArray(retStr, strArrLength);

    lua_pushstring(L, retStr);

    return 1;
}

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

// expose ADC read to LUA
int lua_adcReadDiff(lua_State* L) {
    int channel = luaL_checkinteger(L, 1);

    float multiplier = 0.1875F;
    int16_t result   = 0;

    if (channel == 1)
        result = adc0.readADC_Differential_0_1();
    else if (channel == 2)
        result = adc0.readADC_Differential_2_3();

    lua_pushnumber(L, (float)result * multiplier);

    return 1;    
}

int lua_floatToString(lua_State* L) {
    float floatIn = luaL_checknumber(L, 1); 
    char buf[16]; 

    snprintf(buf, sizeof(buf), "%.3f", floatIn);
    lua_pushstring(L, buf); 

    return 1;
}

// Expose Serial print to Lua
int luaPrintHandler(lua_State* L) {
    int n = lua_gettop(L);
    for (int i = 1; i <= n; i++) {
        if (lua_isinteger(L, i)) {
            Serial.print("int");
            Serial.print(lua_tointeger(L, i));
        }
        //else if (lua_isnumber(L, i)) {
        //    Serial.print((float)lua_tonumber(L, i), 2); // force single-precision, 2 decimal places
        //} 
        else {
            Serial.print(lua_tostring(L, i));
        }
        if (i < n) Serial.print("\t");
    }
    return 0;
}
int lua_print(lua_State* L) {
    int ret = luaPrintHandler(L); 

    Serial.println();
    
    return ret;
}

int lua_printf(lua_State* L) {
    int ret = luaPrintHandler(L); 

    return ret;
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
    lua_register(L, "adcReadDiff", lua_adcReadDiff);
    lua_register(L, "floatToString", lua_floatToString);
    lua_register(L, "getFileContents", lua_getFileContents);
    lua_register(L, "getNumPWMs", lua_getNumPWMs);
    lua_register(L, "setPwmFrequency", lua_setPwmFrequency);
    lua_register(L, "setPwmDutyCycle", lua_setPwmDutyCycle);
    lua_register(L, "setPwmState", lua_setPwmState);
    lua_register(L, "getPwmList", lua_getPwmList);
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
    if (can0.reset() != MCP2515::ERROR_OK) {
        Serial.println("Kernel: could not initialize CAN");
        return false;
    }

    can0.setBitrate(CAN_500KBPS, MCP_16MHZ);
    can0.setNormalMode();

    if (!SD.begin(SD_CS)) {
        Serial.println("Kernel: could not initialize SD card");
        return false;
    }

    if (!adc0.begin(ADS1_ID)) {
        Serial.println("Kernel: could not initialize ADS");
        return false;
    }

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