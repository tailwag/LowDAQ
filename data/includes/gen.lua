exec = function(script)
    local func = load(script)

    if func then 
        func()
    end

    return nil, 0
end

testFloats = function()
    local test

    print("Set `local test = 1.1` and print:")
    test = 1.1
    print(test)

    print("Set `local test = 1.1 * 2 and print:")
    test = 1.1 * 2
    print(test)

    print("Set `local test = 1.1 * 1.1 and print:")
    test = 1.1 * 1.1
    print(test)

    return nil, 0
end

commands.exec = {
    helpArguments    = {"code"},
    helpDescription  = "run lua code directly",

    run = function() end
}
commands.exec.run          = exec


commands.testFloats = {
    helpDescription = "print floating point number tests",

    run = function() end
}
commands.testFloats.run    = testFloats