adcRead = function(channel)
    channel = channel or 0

    local reading

    if channel and channel >= 1 and channel <= 2 then 
        reading = adcReadDiff(channel)

        local scale  = adcChannels[channel][1]
        local offset = adcChannels[channel][2]
        local unit   = adcChannels[channel][3]

        reading = reading * scale + offset

        print(floatToString(reading) .. unit)
        return
    end

    print("channel can only be 1 or 2 right now")
    return
end

adcList = function()
    print("#      Scale    Offset     Unit")

    for i, v in ipairs(adcChannels) do
        col1 = padRight(tostring(i)..".", 3)
        col2 = padLeft(tostring(v[1]), 9)
        col3 = padLeft(tostring(v[2]), 9)
        col4 = padLeft(tostring(v[3]), 9)
        
        print(col1..col2..col3..col4)
    end
end

adcSetChannel = function(channel, scale, offset, unit)
    channel = tonumber(channel)

    if not channel or channel < 1 or channel > #adcChannels then 
        print("invalid channel specified")
        return 
    end 

    scale  = tonumber(scale)
    offset = tonumber(offset)

    if not scale or not offset then 
        print("invalid scale or offset specified")
        return 
    end

    unit = tostring(unit) or ""

    adcChannels[channel] = {scale, offset, unit}
    return             
end

commands.adcRead = {
    helpCategory    = "ADC Commands",
    helpArguments   = {"channel"},
    helpDescription = "get a voltage measurement from the ADC",

    run = function() end 
}
commands.adcRead.run       = adcRead


commands.adcList = {
    helpCategory    = "ADC Commands",
    helpDescription = "list the configuration of the available adc channels",

    run = function() end
}
commands.adcList.run       = adcList


commands.adcSetChannel = {
    helpCategory    = "ADC Commands", 
    helpArguments   = {"channel", "scale", "offset", "unit"},
    helpDescription = "set scaling and offset for a channel",

    run = function() end
}
commands.adcSetChannel.run = adcSetChannel