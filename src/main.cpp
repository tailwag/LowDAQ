#include <Arduino.h>
#include <lua_bridge.h>


void setup() {
    Serial.begin(115200);
    while(!Serial) {}
    delay(500);

    if (!initLua("/main.lua")) {
        Serial.println("Failed to initialize Lua!");
        while(true);
    }

    Serial.println("System ready!");

}

void loop() {
    luaLoop();  // call Lua's main loop
    delay(1);
}