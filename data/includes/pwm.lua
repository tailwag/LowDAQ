pwmList = function()
    local test = getPwmList()

    print(test)
end

pwmSet = function(pin, freq, dc)

end

pwmToggle = function(pin, state)

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