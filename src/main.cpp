#include <Arduino.h>
#include <lua_bridge.h>


const char includeDir[] = "/includes/";

void setup() {
    Serial.begin(115200);
    while(!Serial) {}
    delay(1000);

    Serial.println();
    Serial.println("Staring up ...");
    Serial.print("Initialize Lua ... ");
    delay(200);

    if (!initLua("/main.lua")) {
        Serial.println("Failed to initialize Lua!");
        while(true);
    }
    Serial.println("✓");
    
    Serial.println("Loading include files: ");

    FileList * includeFiles = ls(includeDir);

    for (uint16_t i = 0; i < includeFiles->count; i++) {
        String filePath = String(includeDir) + String(includeFiles->names[i]);

        if (!loadLuaScript(filePath.c_str())) {
            Serial.print("Error loading include file: ");
            Serial.println(filePath);
        }
        else {
            Serial.println("    " + filePath + ": ✓");
        }
    }

    Serial.println();
    Serial.println("***********************************************************");
    Serial.println("**           __              ____  _____ _____           **");
    Serial.println("**          |  |   ___ _ _ _|    \\|  _  |     |          **");
    Serial.println("**          |  |__| . | | | |  |  |     |  |  |          **");
    Serial.println("**          |_____|___|_____|____/|__|__|__  _|          **");
    Serial.println("**                                         |__|          **");
    Serial.println("**  Low level data scquisition and logic control system. **");
    Serial.println("**      Devin Shoemaker, 2025 - devin@shoemaker.info     **");
    Serial.println("***********************************************************");
    Serial.println();
    Serial.print("LowDAQ >");
}

void loop() {
    luaLoop();  // call Lua's main loop
    delay(1);
}