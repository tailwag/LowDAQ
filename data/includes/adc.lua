-- get a reading from a single ADC channel
adcRead = function(channel)
	-- ensure channel is not null, default to channel 0 
    channel = channel or 0

	-- confine the channels to what's available 
	-- need to change this later to be more dynamic
    if channel and channel >= 1 and channel <= 2 then
		-- get initial raw reading from the c api
        local reading = adcReadDiff(channel)

		-- get scaling, offset, and unit from lua channel table
        local scale  = adcChannels[channel][1]
        local offset = adcChannels[channel][2]
        local unit   = adcChannels[channel][3]

		-- format output
        reading = reading * scale + offset

		-- return no error
        return floatToString(reading), unit, 0
    end

	-- channel out of bounds
    return "channel can only be 1 or 2 right now", 1
end


-- list configuration of current ADC channels
adcList = function()
    print("#      Scale    Offset     Unit\n")

    for i, v in ipairs(adcChannels) do
		-- get and format each value
        printf(padRight(tostring(i)..".", 3))
        printf(padLeft(tostring(v[1]), 9))
        printf(padLeft(tostring(v[2]), 9))
        printf(padLeft(tostring(v[3]), 9))
        print()
    end

	-- collapse table into string and return no error
    return nil, 0
end


-- update channel information
adcSetChannel = function(channel, scale, offset, unit)
	-- ensure channel is a valid number
    channel = tonumber(channel)

	-- input checking, make sure channel is in bounds
    if not channel or channel < 1 or channel > #adcChannels then
        return "invalid channel specified", 1
    end

	-- ensure values are numbers
    scale  = tonumber(scale)
    offset = tonumber(offset)

	-- if scale or offset invalid return error
    if not scale or not offset then
        return "invalid scale or offset specified", 1
    end

	-- ensure unit is not null
    unit = tostring(unit) or ""

	-- update values and return no error
    adcChannels[channel] = {scale, offset, unit}
    return nil, 0
end


-------------------------------------------------------------------
--- add all definied commands to the command parser in main.lua ---
-------------------------------------------------------------------
commands.adcRead = {
    helpCategory    = "ADC Commands",
    helpArguments   = {"channel"},
    helpDescription = "get a voltage measurement from the ADC",
}
commands.adcRead.run       = adcRead

commands.adcList = {
    helpCategory    = "ADC Commands",
    helpDescription = "list the config of the available adc channels",
}
commands.adcList.run       = adcList

commands.adcSetChannel = {
    helpCategory    = "ADC Commands",
    helpArguments   = {"channel", "scale", "offset", "unit"},
    helpDescription = "set scaling and offset for a channel",
}
commands.adcSetChannel.run = adcSetChannel

table.insert(LoadedModules, "adc")
