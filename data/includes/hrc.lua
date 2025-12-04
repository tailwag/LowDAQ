if not Global then
    Global = {}
end

if not Global.CanConfig then
    Global.CanConfig = {}
end

if not Global.CanConfig.mode then
    Global.CanConfig.mode = {
        normal = 0,
        restricted = 1,
        monitoring = 2,
        internal_loopback = 3,
        external_loopback = 4,
    }
end

if not Global.CanConfig.format then
    Global.CanConfig.format = {
        classic = 0,
        fd_no_brs = 256,
        fd_brs = 768,
    }
end

HRCFrameLength = 0
local dlcBytes = {1, 2, 3, 4, 5, 6, 7, 8, 12, 16, 20, 24, 32, 48, 64}

local typeMap = {
    unsigned = 1,
    signed = 2,
    float = 4,
}

local orderMap = {
    intel = 0,
    motorola = 1,
}

-- human readable can library
hrcReset = function(id, dlc, format)
    if not id or id < 0 or id > 0x7FF or id ~= math.floor(id) then
        return "id must be integer between 0x000 and 0x7FF", 1
    end

    if not dlc or dlc < 0 or dlc > 15 or dlc ~= math.floor(dlc) then
        return "dlc must be integer between 0 and 15"
    end

    format = format and format or "fd_brs"

    local formEnumVal = -1
    for k, v in pairs(Global.CanConfig.format) do
        if format == k then
            formEnumVal = v
            break
        end
    end

    if formEnumVal == -1 then
        return "invalid format specified, must be classic, fd_no_brs, or fd_brs", 1
    end

    HRCFrameLength = dlc == 0 and dlc or dlcBytes[dlc]

    C_hrcReset(id, dlc, formEnumVal)

    return nil, 0
end

hrcSetValue = function(value, startBit, length, type, order)
    if value and value == "help" then
        print("hrcSetValue command:")
        print("  value    - the value you'd like to set")
        print("  startBit - the absolute bit position of the signal")
        print("  length   - how many bits the signal spans")
        print("  type     - unsigned, signed, or float")
        print("  order    - (optional, defaults to intel) intel or motorola\n")

        return nil, 0
    end

    -- input verification for value 
    value = tonumber(value)

    if not value then return "must specify value to set", 1 end

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
    type = type:match("^%s*(.-)%s*$")
    if not type then return "must specify type", 1 end

    type = typeMap[type]
    if not type then return "type must be unsigned, signed, or float", 1 end

    -- avoid gsub if possible, while defaulting to intel
    if order then
        order = order:gmatch("^%s*(.-)%s*$")
    else
        order = "intel"
    end

    order = orderMap[order]

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
    helpArguments   = {"canId", "canDlc", "(format)"},
    helpDescription = "reset the human readable frame",
}
commands.hrcReset.run = hrcReset

commands.hrcSetValue = {
    helpCategory    = "Human Readable CAN Commands",
    helpArguments   = {"value", "startBit", "length", "type", "order"},
    helpDescription = "set a value, run hrcSetValue(help) for more info",
}
commands.hrcSetValue.run = hrcSetValue

commands.hrcSend = {
    helpCategory    = "Human Readable CAN Commands",
    helpDescription = "send the hr frame",
}
commands.hrcSend.run = hrcSend

table.insert(LoadedModules, "hrc")
