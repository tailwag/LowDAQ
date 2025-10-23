pwmList = function()
    local pwmListString = getPwmList()
    local listLoader, err = load(pwmListString)

    if not listLoader then 
        return "Error loading PWM list from C api: "..err, 1
    end

    local pwmList = listLoader()

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

pwmSet = function(chan, freq, dc)
    local numPWMs = getNumPWMs()

    if chan < 1 or chan > numPWMs then 
        return "Channel must be between 1 and " .. tostring(numPWMs), 1
    end

    if freq < 1 or freq > 40000 then 
        return "Frequency must be between 1 and 40000", 1
    end

    if dc < 0 or dc > 100 then 
        return "Duty cycle must be between 0 and 100", 1
    end
    
    setPwmFrequency(chan, freq)
    setPwmDutyCycle(chan, dc)

    return nil, 0
end

pwmToggle = function(chan, state)
    local numPWMs = getNumPWMs()

    if chan < 1 or chan > numPWMs then 
        return "Channel must be between 1 and " .. tostring(numPWMs), 1
    end

    if state ~= 0 and state ~= 1 then 
        return "State must be 0 or 1", 1
    end

    setPwmState(chan, state)

    return nil, 0
end

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