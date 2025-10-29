-- run a base lua command
exec = function(script)
	-- grab lua string from console and load as a function
    local func = load(script)

	-- execute function
    if func then 
        func()
    end

	-- return no error
    return nil, 0
end


-- test floating point math
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
