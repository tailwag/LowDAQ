/*  ----------------------------------------------  *
 *  --  LowDAQ Release 0.1.1 - 2025-11-27       --  *
 *  --  Devin Shoemaker - devin@shoemaker.info  --  *
 *  --  github.com/tailwag/LowDAQ               --  *
 *  --  Lua Version 5.4.8                       --  *
 *  --  STM32DuinoCANFD version 0.1.0           --  *
 *  --  STM32DuinoPWM   version 0.1.0           --  *
 *  ----------------------------------------------  */
#include <Arduino.h>
#include <lua_bridge.h>


const char * includeDir = "/includes/";
const char *  configDir = "/config/";

void loadFiles(const char * dir) {
    FileList * dirFiles = ls(dir);

    if (dirFiles == nullptr) {
        _log("    [HALT] ERROR: Unable to access " + String(dir));
        while (true) { }
    }

    for (uint16_t i = 0; i < dirFiles->count; i++) {
        String filePath = String(dir) + String(dirFiles->names[i]);

        if (!loadLuaScript(filePath.c_str())) {
            _log("    [HALT] ERROR: Unable to load file: " + String(dir) + String(filePath));
            while(true) { }
        }
        else {
            _log("    " + filePath + ": ✓");
        }
    }
}

void setup() {
    Serial.begin(115200);
    while(!Serial) {}
    delay(1000);

    Serial.println();
    _log("Starting up ...");
    delay(200);

	// load main lua file. this defines the console behavior and 
	// the main structure of the available commands
    if (!initLua("/main.lua")) {
        _log("Failed to initialize Lua!");
        while(true);
    }

    // load include files
    _log("Loading include files: ");
    loadFiles(includeDir);

    // load config files
    _log("Loading config files: ");
    loadFiles(configDir);


    // run lua setup function
    luaStartup();
    

    Serial.println();
    Serial.println("***********************************************************");
    Serial.println("**           __              ____  _____ _____           **");
    Serial.println("**          |  |   ___ _ _ _|    \\|  _  |     |          **");
    Serial.println("**          |  |__| . | | | |  |  |     |  |  |          **");
    Serial.println("**          |_____|___|_____|____/|__|__|__  _|          **");
    Serial.println("**                                         |__|          **");
    Serial.println("**  Low level data acquisition and logic control system. **");
    Serial.println("**      Devin Shoemaker, 2025 - devin@shoemaker.info     **");
    Serial.println("***********************************************************");
    Serial.println();
    Serial.print("LowDAQ > ");
}

void loop() {
    luaLoop();  // call Lua's main loop
    delay(1);
}
