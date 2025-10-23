pfList = function()
    local outputArray = {}

    local n = 1
    for i, f in ipairs(frames) do 
        local line = string.format("%d. 0x%X - %dms - ", i, f.id, f.period)
        for j = 1, f.dlc do 
            line = line .. string.format("%02X ", f.data[j]) 
        end
        table.insert(outputArray, line)
    end

    return table.concat(outputArray), 0
end

pfToggle = function(id, state)
    for _, f in ipairs(frames) do 
        if f.id == id then 
            f.enabled = state
            return nil, 0
        end 
    end

    return "Frame 0x" .. string.format("%X", id) .. " not found", 1
end

pfByteSet = function(id, index, value)
    if value > 255 or value < 0 then 
        return "Value must be between 0-255", 1
    end
    
    for _, f in ipairs(frames) do 
        if f.id == id then
            if index > f.dlc then
                return "Frame is only ".. f.dlc .. " bytes long.", 1
            end

            f.data[index] = value
            return nil, 0
        end
    end

    return "Frame 0x" .. string.format("%X", id) .. " not found!", 1
end

pfDlcSet = function(id, value) 
    if value > 8 or value < 0 then 
        return "Value must be between 0-8", 1
    end

    for _, f in ipairs(frames) do 
        if f.id == id then 
            f.dlc = value
            return nil, 0
        end 
    end

    return "Frame 0x" .. string.format("%X", id) .. " not found!", 1
end

pfTimeSet = function(id, value)
    if value > 100000 or value < 0 then 
        return "Value must be between 0-100000", 1
    end

    for _, f in ipairs(frames) do 
        if f.id == id then 
            f.period = value
            return nil, 0
        end
    end
    
    return "Frame 0x" .. string.format("%X", id) .. " not found!", 1
end

commands.pfList = {
    helpCategory    = "Periodic CAN Frame Commands",
    helpArguments   = {""},
    helpDescription = "returns list of all periodic frames",
        
    run = function() end
} 
commands.pfList.run        = pfList


commands.pfToggle = {
    helpCategory    = "Periodic CAN Frame Commands",
    helpArguments   = {"id", "[0,1]"},
    helpDescription = "toggles a periodic frame on or off",

    run = function() end
}
commands.pfToggle.run      = pfToggle


commands.pfByteSet = {
    helpCategory    = "Periodic CAN Frame Commands",
    helpArguments   = {"id", "index", "value"},
    helpDescription = "update the value of one byte",

    run = function() end
}
commands.pfByteSet.run     = pfByteSet


commands.pfDlcSet = {
    helpCategory    = "Periodic CAN Frame Commands", 
    helpArguments   = {"id", "value"}, 
    helpDescription = "update the length of a periodic frame", 

    run = function() end
}
commands.pfDlcSet.run      = pfDlcSet
    

commands.pfTimeSet = { 
    helpCategory    = "Periodic CAN Frame Commands",
    helpArguments   = {"id", "ms"},
    helpDescription = "adjust the period of a frame",

    run = function() end
}
commands.pfTimeSet.run     = pfTimeSet