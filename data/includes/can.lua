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

local getFormEnumVal = function(format)
    format = format and format or "fd_brs"

    for k, v in pairs(Global.CanConfig.format) do
        if format == k then
            return v
        end
    end

    return -1
end

local getFormStringVal = function(format)
    for k, v in pairs(Global.CanConfig.format) do 
        if format == v then 
            return k
        end
    end

    return nil
end



-- list out existing periodic can frames
pfList = function()
	-- initialize an array to hold frames

	-- iterate over global frames array, this is what holds all periodic frame definitions
    for i, f in ipairs(frames) do
        local formStringVal = getFormStringVal(f.format)

		-- format line as "1. 0x7FF - 1000ms"
        printf(string.format("%d. 0x%X %s - %dms - ", i, f.id, formStringVal, f.period))

        --TODO: fewer bytes given than dlc causes crash due to nil being passed to format
		-- add each data byte to line in hex
        for j = 1, f.dlc do
            printf(string.format("%02X ", f.data[j]))
        end

		-- line should look like "1. 0x7FF - 1000ms - AA BB CC DD EE FF 00 11"
        print()
    end

	-- collapse array of strings into one string and return no error
    return nil, 0
end


-- toggle a periodic frame on or off
pfToggle = function(id, state)
	-- input sanitization
	if not state or state and (state ~= 0 and state ~= 1) then
		return "State must be either 1 or 0", 1
	end

	-- iterate over current frames until we find what we need
    for _, f in ipairs(frames) do
        if f.id == id then
			-- enable/disable and return no error
            f.enabled = state
            return nil, 0
        end
    end

    return "Frame 0x" .. string.format("%X", id) .. " not found", 1
end

pfAddFrame = function(id, dlc, format, period, ...)
    if not id or id < 0x000 or id > 0x7FF or math.floor(id) ~= id then
        return "id must be integer between 0x000 and 0x7FF", 1
    end

    if not dlc or dlc < 0 or dlc > 15 or math.floor(dlc) ~= dlc then
        return "dlc must be integer between 0 and 15", 1
    end

    local formEnumVal = getFormEnumVal(format)
    if formEnumVal == -1 then
        return "invalid format value, must be classic, fd_no_brs, or fd_brs", 1
    end

    if not period or period < 1 or period > 100000 or math.floor(period) ~= period then
        return "period must be integer between 1 and 100000", 1
    end

    local pf = { id = id, dlc = dlc, format = formEnumVal, period = period, data = table.pack(...), enabled = true, lastSent = 0 }

    for _, v in ipairs(pf.data) do
        v = v >   0 and v or   0
        v = v < 255 and v or 255
    end

    table.insert(frames, pf)

    return nil, 0
end

pfDelFrame = function(id)
    if not id or id < 0x000 or id > 0x7FF or math.floor(id) ~= id then
        return "id must be integer between 0x000 and 0x7FF", 1
    end

    for i, v in ipairs(frames) do
        if v.id == id then
            frames[i] = nil
            return nil, 0
        end
    end
    return "frame not found", 1
end


-- function for setting individual byte of data within a periodic can frame
pfByteSet = function(id, index, value)
	-- input sanitization
    if value > 255 or value < 0 then
        return "Value must be between 0-255", 1
    end

	-- iterate over current frames until we find what we need
    for _, f in ipairs(frames) do
        if f.id == id then
			-- ensure we're not setting a byte that doesn't exist
            if index > f.dlc then
                return "Frame is only ".. f.dlc .. " bytes long.", 1
            end

			-- set value and return no error
            f.data[index] = value
            return nil, 0
        end
    end

	-- no match for specified frame
    return "Frame 0x" .. string.format("%X", id) .. " not found!", 1
end


-- update the dlc (length) of an existing periodic can frame
pfDlcSet = function(id, value)
	-- input sanitization
    if value > 8 or value < 0 then
        return "Value must be between 0-8", 1
    end

	-- iterate over frames in list until we find what we need
    for _, f in ipairs(frames) do
        if f.id == id then
			-- set value and return no error
            f.dlc = value
            return nil, 0
        end
    end

	-- no match for specified frame
    return "Frame 0x" .. string.format("%X", id) .. " not found!", 1
end

pfTimeSet = function(id, value)
	-- input sanitization
    if value > 100000 or value < 0 then
        return "Value must be between 0-100000", 1
    end

	-- iterate over frames in list until we find what we need
    for _, f in ipairs(frames) do
        if f.id == id then
			-- set value and return no error
            f.period = value
            return nil, 0
        end
    end

	-- no match for specified frame
    return "Frame 0x" .. string.format("%X", id) .. " not found!", 1
end

ssSend = function(id, dlc, format, ...)
    if id > 0x7FF or id < 0x000 then
      return "ID must be between 0x000 and 0x7FF (11 bit)"
    end

    if dlc > 15 or dlc < 0 then
      return "DLC must be between 0 and 15"
    end

    local formEnumVal = getFormEnumVal(format)

    if formEnumVal == -1 then
        return "invalid format value, must be classic, fd_no_brs, or fd_brs", 1
    end

    sendCanFrame(id, dlc, formEnumVal, ...)

    return nil, 0
end

-------------------------------------------------------------------
--- add all definied commands to the command parser in main.lua ---
-------------------------------------------------------------------
commands.pfList = {
    helpCategory    = "Periodic CAN Frame Commands",
    helpArguments   = {""},
    helpDescription = "returns list of all periodic frames",
}
commands.pfList.run        = pfList

commands.pfToggle = {
    helpCategory    = "Periodic CAN Frame Commands",
    helpArguments   = {"id", "[0,1]"},
    helpDescription = "toggles a periodic frame on or off",
}
commands.pfToggle.run      = pfToggle

commands.pfAddFrame = {
    helpCategory    = "Periodic CAN Frame Commands",
    helpArguments   = {"id", "dlc", "period", "d1", "d2", "..."},
    helpDescription = "add a new periodic frame"
}
commands.pfAddFrame.run = pfAddFrame

commands.pfDelFrame = {
    helpCategory    = "Periodic CAN Frame Commands",
    helpArguments   = {"id"},
    helpDescription = "delete a period frame",
}
commands.pfDelFrame.run = pfDelFrame

commands.pfByteSet = {
    helpCategory    = "Periodic CAN Frame Commands",
    helpArguments   = {"id", "index", "value"},
    helpDescription = "update the value of one byte",
}
commands.pfByteSet.run     = pfByteSet

commands.pfDlcSet = {
    helpCategory    = "Periodic CAN Frame Commands",
    helpArguments   = {"id", "value"},
    helpDescription = "update the length of a periodic frame",
}
commands.pfDlcSet.run      = pfDlcSet

commands.pfTimeSet = {
    helpCategory    = "Periodic CAN Frame Commands",
    helpArguments   = {"id", "ms"},
    helpDescription = "adjust the period of a frame",
}
commands.pfTimeSet.run     = pfTimeSet

commands.ssSend = {
  helpCategory    = "Single Shot CAN Frame Commands", 
  helpArguments   = {"id", "dlc", "format", "data1", "data2", "..."},
  helpDescription = "send a can frame once",
}
commands.ssSend.run  = ssSend

table.insert(LoadedModules, "can")
