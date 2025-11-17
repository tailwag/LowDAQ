pwmInList = function()
    local pwmListString = C_getPwmInList()
    local listLoader, err = load(pwmListString)

    if not listLoader then
        return "Error loading PWM input list from C api: "..err, 1
    end

    local pwmList = listLoader()

    if not pwmList then
        return "Error loading PWM list from C api.", 1
    end

    for i, v in ipairs(pwmList) do
        printf(padRight(tostring(i)..".", 5))
        printf(padRight(tostring(v[1]).."Hz", 9))
        printf(padRight(tostring(v[2]).."%", 6))
        print()
    end

    return nil, 0
end

pwmInGetFreq = function(chan)
    local numPWMs = C_getNumPWMIn()

    if chan < 1 or chan > numPWMs then
        return "Channel must be between 1 and " .. tostring(numPWMs), 1
    end

    return tonumber(C_getPwmInFrequency(chan)), 0
end

pwmInGetDuty = function(chan)
    local numPWMs = C_getNumPWMIn()

    if chan < 1 or chan > numPWMs then
        return "Channel must be between 1 and " .. tostring(numPWMs), 1
    end

    return tonumber(C_getPwmInDutyCycle(chan)), 0
end

-- list all current hardware PWMs
pwmOutList = function()
	-- pwm list is managed directly on the c side, since the pwm 
	-- function uses the ST HAL timers directly
	-- getPwmList() returns a lua function which creates an array
	-- containing an array of frequency, duty cycle, and on/off state
	-- return {
		-- {128,  50, 1},
		-- {1000, 40, 0},
	-- }

	-- get the return string from c, and initialize function to get data out
    local pwmListString = C_getPwmOutList()
    local listLoader, err = load(pwmListString)

	-- if loader is nil then return error
    if not listLoader then
        return "Error loading PWM list from C api: "..err, 1
    end

	-- calling this function initializes pwmList as an array
	-- containing the data we passed in from the c function
    local pwmList = listLoader()

	-- if the array is nil then return error
    if not pwmList then
        return "Error loading PWM list from C api.", 1
    end

    for i, v in ipairs(pwmList) do
        printf(padRight(tostring(i)..".", 5))
        printf(padRight(tostring(v[1]).."Hz", 9))
        printf(padRight(tostring(v[2]).."%", 6))
        printf(padRight(tostring(v[3]), 6))
        print()
    end

    return nil, 0
end


-- set the frequency and duty cycle of a pwm output
pwmOutSet = function(chan, freq, dc)
	-- get number of pwm outputs from c api
    local numPWMs = C_getNumPWMOut()

	-- input sanitization
    if chan < 1 or chan > numPWMs then
        return "Channel must be between 1 and " .. tostring(numPWMs), 1
    end

    if freq < 1 or freq > 40000 then
        return "Frequency must be between 1 and 40000", 1
    end

    if dc < 0 or dc > 100 then
        return "Duty cycle must be between 0 and 100", 1
    end

	-- bound c functions defined in lua_bridge.cpp
    C_setPwmOutFrequency(chan, freq)
    C_setPwmOutDutyCycle(chan, dc)

    return nil, 0
end


-- toggles a pwm on or off
pwmOutToggle = function(chan, state)
	-- get number of pwm outputs from c api
    local numPWMs = C_getNumPWMOut()

	-- input sanitization
    if chan < 1 or chan > numPWMs then
        return "Channel must be between 1 and " .. tostring(numPWMs), 1
    end

    if state ~= 0 and state ~= 1 then
        return "State must be 0 or 1", 1
    end

	-- bound c function from lua_bridge.cpp
    C_setPwmOutState(chan, state)

    return nil, 0
end

-------------------------------------------------------------------
--- add all definied commands to the command parser in main.lua ---
-------------------------------------------------------------------
commands.pwmInList    = {
    helpCategory      = "PWM Commands",
    helpDescription   = "show state of all pwm inputs",
}
commands.pwmInList.run = pwmInList

commands.pwmInGetFreq = {
    helpCategory      = "PWM Commands",
    helpDescription   = "measure frequency of pwm input",
    helpArguments     = {"pin"},
}
commands.pwmInGetFreq.run = pwmInGetFreq

commands.pwmInGetDuty = {
    helpCategory      = "PWM Commands",
    helpDescription   = "measure duty cycle of pwm input",
    helpArguments     = {"pin"},
}
commands.pwmInGetDuty.run = pwmInGetDuty

commands.pwmOutList   = {
    helpCategory      = "PWM Commands",
    helpDescription   = "show state of all pwm outputs",
}
commands.pwmOutList.run = pwmOutList

commands.pwmOutSet    = {
    helpCategory      = "PWM Commands",
    helpArguments     = {"pin", "frequency", "dutycycle"},
    helpDescription   = "sets up a pwm output, defaults to on",
}
commands.pwmOutSet.run = pwmOutSet

commands.pwmOutToggle = {
    helpCategory      = "PWM Commands",
    helpArguments     = {"pin", "[0|1]"},
    helpDescription   = "toggles a pwm output on or off",
}
commands.pwmOutToggle.run = pwmOutToggle

table.insert(LoadedModules, "pwm")
