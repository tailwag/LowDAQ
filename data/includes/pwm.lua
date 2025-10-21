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
    setPwmFrequency(chan, freq)
    setPwmDutyCycle(chan, dc)
end

pwmToggle = function(chan, state)
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