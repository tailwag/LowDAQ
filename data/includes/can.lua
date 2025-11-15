-- list out existing periodic can frames
pfList = function()
	-- initialize an array to hold frames
    local outputArray = {}

	-- iterate over global frames array, this is what holds all periodic frame definitions
    for i, f in ipairs(frames) do
		-- format line as "1. 0x7FF - 1000ms"
        local line = string.format("%d. 0x%X - %dms - ", i, f.id, f.period)

		-- add each data byte to line in hex
        for j = 1, f.dlc do
            line = line .. string.format("%02X ", f.data[j])
        end

		-- line should look like "1. 0x7FF - 1000ms - AA BB CC DD EE FF 00 11"
        table.insert(outputArray, line)
    end

	-- collapse array of strings into one string and return no error
    return table.concat(outputArray), 0
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

ssSend = function(id, dlc, ...)
  if id > 0x7FF or id < 0x000 then
    return "ID must be between 0x000 and 0x7FF (11 bit)"
  end

  if dlc > 15 or dlc < 0 then
    return "DLC must be between 0 and 15"
  end

  sendCanFrame(id, dlc, ...)

  return nil
end

-------------------------------------------------------------------
--- add all definied commands to the command parser in main.lua ---
-------------------------------------------------------------------
commands.pfList.helpCategory       = "Periodic CAN Frame Commands"
commands.pfList.helpDescription    = "returns list of all periodic frames"
commands.pfList.run = pfList

commands.pfToggle.helpCategory     = "Periodic CAN Frame Commands"
commands.pfToggle.helpArguments    = {"id", "[0,1]"}
commands.pfToggle.helpDescription  = "toggles a periodic frame on or off"
commands.pfToggle.run = pfToggle

commands.pfByteSet.helpCategory    = "Periodic CAN Frame Commands"
commands.pfByteSet.helpArguments   = {"id", "index", "value"}
commands.pfByteSet.helpDescription = "update the value of one byte"
commands.pfByteSet.run = pfByteSet

commands.pfDlcSet.helpCategory     = "Periodic CAN Frame Commands"
commands.pfDlcSet.helpArguments    = {"id", "value"}
commands.pfDlcSet.helpDescription  = "update the length of a periodic frame"
commands.pfDlcSet.run = pfDlcSet

commands.pfTimeSet.helpCategory    = "Periodic CAN Frame Commands"
commands.pfTimeSet.helpArguments   = {"id", "ms"}
commands.pfTimeSet.helpDescription = "adjust the period of a frame"
commands.pfTimeSet.run = pfTimeSet

commands.ssSend.helpCategory       = "Single Shot CAN Frame Commands"
commands.ssSend.helpArguments      = {"id", "dlc", "data1", "data2", "..."}
commands.ssSend.helpDescription    = "send a can frame once"
commands.ssSend.run  = ssSend
