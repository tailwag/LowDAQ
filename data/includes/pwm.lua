pwmList = function()
    local pwmListString = getPwmList()
    local listLoader, err = load(pwmListString)

    if not listLoader then 
        print("Error loading PWM list from C api: "..err)
        return 
    end

    local pwmList = listLoader()

    if pwmList then 
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

            print(table.concat(lineArr))
        end
    end
end

pwmSet = function(chan, freq, dc)
    local numPWMs = getNumPWMs()

    if chan < 1 or chan > numPWMs then 
        print("Channel must be between 1 and " .. tostring(numPWMs))
        return
    end

    if freq < 1 or freq > 40000 then 
        print("Frequency must be between 1 and 40000")
        return
    end

    if dc < 0 or dc > 100 then 
        print("Duty cycle must be between 0 and 100")
        return
    end
    
    setPwmFrequency(chan, freq)
    setPwmDutyCycle(chan, dc)
end

pwmToggle = function(chan, state)
    local numPWMs = getNumPWMs()

    if chan < 1 or chan > numPWMs then 
        print("Channel must be between 1 and " .. tostring(numPWMs))
        return
    end

    if state ~= 0 and state ~= 1 then 
        print("State must be 0 or 1")
        return 
    end

    setPwmState(chan, state)
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