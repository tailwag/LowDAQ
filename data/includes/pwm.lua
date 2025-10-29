-- list all current hardware PWMs
pwmList = function()
	-- pwm list is managed directly on the c side, since the pwm 
	-- function uses the ST HAL timers directly
	-- getPwmList() returns a lua function which creates an array
	-- containing an array of frequency, duty cycle, and on/off state
	-- return {
		-- {128,  50, 1},
		-- {1000, 40, 0},
	-- }
	
	-- get the return string from c, and initialize function to get data out
    local pwmListString = getPwmList()
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

    local outputArray = {}

    for i, v in ipairs(pwmList) do
        local pin  = i
        local freq = v[1]
        local duty = v[2]
        local en   = v[3]

        lineArr = {}
        table.insert(lineArr, padRight(tostring(pin)..".", 5))
        table.insert(lineArr, padRight(tostring(freq).."Hz", 9))
        table.insert(lineArr, padRight(tostring(duty).."%", 6))
        table.insert(lineArr, padRight(tostring(en), 6))

        table.insert(outputArray, table.concat(lineArr).."\n")
    end

    return table.concat(outputArray), 0
end


-- set the frequency and duty cycle of a pwm output
pwmSet = function(chan, freq, dc)
	-- get number of pwm outputs from c api
    local numPWMs = getNumPWMs()

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
    setPwmFrequency(chan, freq)
    setPwmDutyCycle(chan, dc)

    return nil, 0
end


-- toggles a pwm on or off
pwmToggle = function(chan, state)
	-- get number of pwm outputs from c api
    local numPWMs = getNumPWMs()

	-- input sanitization
    if chan < 1 or chan > numPWMs then 
        return "Channel must be between 1 and " .. tostring(numPWMs), 1
    end

    if state ~= 0 and state ~= 1 then 
        return "State must be 0 or 1", 1
    end

	-- bound c function from lua_bridge.cpp
    setPwmState(chan, state)

    return nil, 0
end

-------------------------------------------------------------------
--- add all definied commands to the command parser in main.lua ---
-------------------------------------------------------------------

commands.pwmList = {
    helpCategory    = "PWM Commands",
    helpDescription = "show state of all pwm outputs",

    run = function() end
}
commands.pwmList.run       = pwmList


commands.pwmSet = {
    helpCategory    = "PWM Commands", 
    helpArguments   = {"pin", "frequency", "dutycycle"},
    helpDescription = "sets up a pwm output, defaults to on",

    run = function() end
}
commands.pwmSet.run        = pwmSet


commands.pwmToggle = {
    helpCategory    = "PWM Commands",
    helpArguments   = {"pin", "[0|1]"},
    helpDescription = "toggles a pwm output on or off",

    run = function() end
}
commands.pwmToggle.run     = pwmToggle
