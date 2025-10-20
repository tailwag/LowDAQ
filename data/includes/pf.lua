pfList = function()
    local n = 1
    for i, f in ipairs(frames) do 
        local line = string.format("%d. 0x%X - %dms - ", i, f.id, f.period)
        for j = 1, f.dlc do 
            line = line .. string.format("%02X ", f.data[j]) 
        end
        print(line)
    end
end

pfToggle = function(id, state)
    for _, f in ipairs(frames) do 
        if f.id == id then 
            f.enabled = state
        end 
    end
end

pfByteSet = function(id, index, value)
    if value > 255 or value < 0 then 
        print("Value must be between 0-255")
        return 
    end
    
    for _, f in ipairs(frames) do 
        if f.id == id then
            if index > f.dlc then
                print("Frame is only ".. f.dlc .. " bytes long.")
                return
            end

            f.data[index] = value
            return 
        end
    end
    print("Frame 0x" .. string.format("%X", id) .. " not found!")
end

pfDlcSet = function(id, value) 
    if value > 8 or value < 0 then 
        print("Value must be between 0-8")
        return
    end

    for _, f in ipairs(frames) do 
        if f.id == id then 
            f.dlc = value
            return 
        end 
    end
    print("Frame 0x" .. string.format("%X", id) .. " not found!")
end

pfTimeSet = function(id, value)
    if value > 100000 or value < 0 then 
        print("Value must be between 0-100000")
        return 
    end

    for _, f in ipairs(frames) do 
        if f.id == id then 
            f.period = value
            return
        end
    end
    print("Frame 0x" .. string.format("%X", id) .. " not found!")
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