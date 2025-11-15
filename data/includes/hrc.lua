HRCFrameLength = 0
local dlcBytes = {1, 2, 3, 4, 5, 6, 7, 8, 12, 16, 20, 24, 32, 48, 64}

-- human readable can library
hrcReset = function(id, dlc)
    if not id or id < 0 or id > 0x7FF or id ~= math.floor(id) then
        return "id must be integer between 0x000 and 0x7FF", 1
    end

    if not dlc or dlc < 0 or dlc > 15 or dlc ~= math.floor(dlc) then
        return "dlc must be integer between 0 and 15"
    end

    HRCFrameLength = dlc == 0 and dlc or dlcBytes[dlc]

    C_hrcReset(id, dlc)

    return nil, 0
end

hrcSetValue = function(value, startBit, length, type, order)
    if value and value == "help" then
        local retVal = "hrcSetValue command:\n"
        retVal = retVal .. "  startBit - the absolute bit position of the signal\n"
        retVal = retVal .. "  length   - how many bits the signal spans\n"
        retVal = retVal .. "  type     - unsigned, signed, or float\n"
        retVal = retVal .. "  order    - (optional, defaults to intel) intel or motorola\n\n"

        return retVal, 0
    end

    -- input verification for value 
    value = value and tonumber(value) or nil

    if not value then
        return "must specify value to set", 1
    end

    -- input verification for startBit
    startBit = startBit and tonumber(startBit) or nil
    local maxBit = HRCFrameLength * 8

    if not startBit or startBit < 0 or startBit > maxBit or startBit ~= math.floor(startBit) then
        return "startBit must be integer between 0 and " .. tostring(maxBit), 1
    end

    -- input verification for length
    length = length and tonumber(length) or nil

    if not length or length < 1 or length > 32 or length ~= math.floor(length) then
        return "length must be integer between 1 and 32", 1
    end

    -- type: 1 = unsigned, 2 = signed, 4 = float
    type = type:gsub(" ", "")
    if not type or (type and type ~= "unsigned" and type ~= "signed" and type ~= "float") then
        return "type must be unsigned, signed, or float"
    end

    type = type == "unsigned" and 1 or type
    type = type == "signed"   and 2 or type
    type = type == "float"    and 4 or type

    -- order: 1 = intel, 2 = motorola
    order = order and order or "intel"
    order = order:gsub(" ", "")

    if order ~= "intel" and order ~= "motorola" then
        return "invalid argument, order must be intel or motorola", 1
    end

    order = order == "intel"    and 0 or order
    order = order == "motorola" and 1 or order

    -- call C api
    C_hrcSetValue(value, startBit, length, type, order)

    return nil, 0
end

hrcSend = function()
    C_hrcSend()

    return nil, 0
end

commands.hrcReset = {
    helpCategory    = "Human Readable CAN Commands",
    helpArguments   = {"canId", "canDlc"},
    helpDescription = "clear the human readable frame",
}
commands.hrcReset.run = hrcReset

commands.hrcSetValue = {
    helpCategory    = "Human Readable CAN Commands",
    helpArguments   = {"startBit", "length", "type", "order"},
    helpDescription = "set a value, run hrcSetValue(help) for more info",
}
commands.hrcSetValue.run = hrcSetValue

commands.hrcSend = {
    helpCategory    = "Human Readable CAN Commands",
    helpDescription = "send the hr frame",
}
commands.hrcSend.run = hrcSend

table.insert(LoadedModules, "hrc")
