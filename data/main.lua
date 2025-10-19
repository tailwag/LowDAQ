frames = {
    {id=0x7FF, dlc=8, period=1000, data={0,64,128,255,96,1,2,4}, enabled=true, lastSent=0}
}
jobs = {}
adcChannels = {
    {1,0,"mV"},
    {1,0,"mV"},
}
local inTable = function(t, v) 
    for _, i in ipairs(t) do 
        if i == v then 
            return true
        end
    end

    return false
end

local repeatChar = function(c, n)
    local chArray = {} 

    for i = 1, n do 
        table.insert(chArray, c)
    end

    return table.concat(chArray)
end

local padRight = function(strIn, width)
    local spcLen = width - #strIn

    return strIn .. repeatChar(" ", spcLen)
end

local padLeft = function(strIn, width)
    local spcLen = width - #strIn

    return repeatChar(" ", spcLen) .. strIn
end

commands = {
    -------------------------------------------------------------
    --- you shouldn't have to mess with this 
    --- the help command contains all the logic for 
    --- generating the help menu within itself
    --- just set helpCategory, helpArguments, and helpDescription
    --- for each other command you add
    -------------------------------------------------------------
    help = {
        helpDescription = "display this menu",

        run = function() 
            -- name displayed in title bar of help menu
            local menuTitle = " Low Level DAQ System "

            -- number of spaces between border and category text
            local categoryMargin = 1

            -- number of spaces between border and command text
            local helpMargin = 4

            -- alphabetize command names
            local commandNames = {}

            for k in pairs(commands) do 
                table.insert(commandNames, k)
            end

            table.sort(commandNames)

            -- retrieve and alphabetize category names
            local categories = {}

            for k, v in pairs(commands) do 
                if v.helpCategory and not inTable(categories, v.helpCategory) then -- new category
                    table.insert(categories, v.helpCategory)
                end
            end

            table.sort(categories)
            
            -- insert general commands at top
            table.insert(categories, 1, "General Commands")
            
            -- build output help array
            local helpTable = {}

            for _, k in ipairs(categories) do 
                table.insert(helpTable, {k, {}})
            end

            -- add commands 
            for _, k in ipairs(commandNames) do 
                -- get index for helpTable, if nil then use general
                local tabCat = commands[k].helpCategory or "General Commands"
                
                -- create example argument string
                local argString = ""
                if commands[k].helpArguments then 
                    argString = table.concat(commands[k].helpArguments, ", ")
                end

                -- generate each "column" of the help line for calculating line padding
                local column1 = k .. "(" .. argString .. ")"
                local column2 = " - " .. commands[k].helpDescription

                for _, v in ipairs(helpTable) do 
                    if v[1] == tabCat then
                        table.insert(v[2], {column1, column2})
                    end
                    --TODO: break?
                end
            end
            
            -- determine longest width of columns 1
            local col1max = 0
            local col2max = 0
            for _, v in pairs(helpTable) do 
                for _, cols in ipairs(v[2]) do
                     col1max = #cols[1] > col1max and #cols[1] or col1max
                     col2max = #cols[2] > col2max and #cols[2] or col2max
                end
            end

            -- calculate max width of a whole line (both columns)
            local maxWidth = col1max + col2max + 2 * helpMargin

            -- if width id odd add an extra = 
            if maxWidth % 2 == 1 then 
                maxWidth = maxWidth + 1
                col2max = col2max + 1
            end

            -- figure out how many = we need on either side of the title
            local titlePad = math.floor((maxWidth - #menuTitle) / 2) + 2
            local borderBar = repeatChar("=", titlePad)

            local titleLine = borderBar .. menuTitle .. borderBar

            -- finally print the output
            print(titleLine)

            for _, v in ipairs(helpTable) do 
                local l_category = v[1]
                local l_commands = v[2]

                -- command category
                printf("==")
                printf(repeatChar(" ", categoryMargin))
                printf(padRight(l_category, maxWidth - categoryMargin))
                print ("==")
                collectgarbage()

                for _, cmdArr in ipairs(l_commands) do 
                    -- command with args and description
                    printf("==")
                    printf(repeatChar(" ", helpMargin))
                    printf(padRight(cmdArr[1], col1max))
                    printf(padRight(cmdArr[2], col2max))
                    printf(repeatChar(" ", helpMargin))
                    print ("==")
                    collectgarbage()
                end

                -- blank line in between categories
                print("==" .. repeatChar(" ", maxWidth) .. "==")
                collectgarbage()
            end

            -- bottom border
            print(repeatChar("=", maxWidth + 4))

            -- avoid memory fragmentation
            collectgarbage()
        end
    },
    --------------------------------------------------------------
    ----- end help command 
    --------------------------------------------------------------


    pfList = {
        helpCategory    = "Periodic CAN Frame Commands",
        helpArguments   = {""},
        helpDescription = "returns list of all periodic frames",
        
        run = function()
            local n = 1
            for i, f in ipairs(frames) do 
                local line = string.format("%d. 0x%X - %dms - ", i, f.id, f.period)
                for j = 1, f.dlc do 
                    line = line .. string.format("%02X ", f.data[j]) 
                end
                print(line)
            end
        end
    }, 

    pfToggle = {
        helpCategory    = "Periodic CAN Frame Commands",
        helpArguments   = {"id", "[0,1]"},
        helpDescription = "toggles a periodic frame on or off",

        run = function(id, state)
            for _, f in ipairs(frames) do 
                if f.id == id then 
                    f.enabled = state
                end 
            end
        end
    }, 

    pfByteSet = {
        helpCategory    = "Periodic CAN Frame Commands",
        helpArguments   = {"id", "index", "value"},
        helpDescription = "update the value of one byte",

        run = function(id, index, value)
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
    },

    pfDlcSet = {
        helpCategory    = "Periodic CAN Frame Commands", 
        helpArguments   = {"id", "value"}, 
        helpDescription = "update the length of a periodic frame", 

        run = function(id, value) 
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
    }, 
    
    pfTimeSet = { 
        helpCategory    = "Periodic CAN Frame Commands",
        helpArguments   = {"id", "ms"},
        helpDescription = "adjust the period of a frame",

        run = function(id, value)
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
    }, 

    pwmList = {
        helpCategory    = "PWM Commands",
        helpDescription = "show state of all pwm outputs",

        run = function()

        end          
    },

    pwmSet = {
        helpCategory    = "PWM Commands", 
        helpArguments   = {"pin", "frequency", "dutycycle"},
        helpDescription = "sets up a pwm output, defaults to on",

        run = function(pin, freq, dutycycle) 

        end
    },

    pwmToggle = {
        helpCategory    = "PWM Commands",
        helpArguments   = {"pin", "[0|1]"},
        helpDescription = "toggles a pwm output on or off",

        run = function(pin, state)
        
        end
    },

    adcRead = {
        helpCategory    = "ADC Commands",
        helpArguments   = {"channel"},
        helpDescription = "get a voltage measurement from the ADC",

        run = function(channel)
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
    },

    adcList = {
        helpCategory    = "ADC Commands",
        helpDescription = "list the configuration of the available adc channels",

        run = function()
            print("#      Scale    Offset     Unit")

            for i, v in ipairs(adcChannels) do
                col1 = padRight(tostring(i)..".", 3)
                col2 = padLeft(tostring(v[1]), 9)
                col3 = padLeft(tostring(v[2]), 9)
                col4 = padLeft(tostring(v[3]), 9)
                
                print(col1..col2..col3..col4)
            end
        end
    },

    adcSetChannel = {
        helpCategory    = "ADC Commands", 
        helpArguments   = {"channel", "scale", "offset", "unit"},
        helpDescription = "set scaling and offset for a channel",

        run = function(channel, scale, offset, unit)
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
    },

    jobAdd = {
        helpCategory    = "Job Scripting Commands",
        helpArguments   = {"function()", "period(ms)", "description"},
        helpDescription = "schedule a job to occur peridically",

        run = function(job, period, description)
            local func = load(job)

            if not func then 
                print("error processing job function")
                return
            end

            period = tonumber(period)

            if not period or period < 1 then 
                print("invalid period, must be > 1 (ms)")
                return 
            end

            table.insert(jobs, {run = func, period = period, description = description, enabled = 1, lastSent = 0})
            return
        end
    },

    jobList = {
        helpCategory    = "Job Scripting Commands",
        helpDescription = "list current jobs",

        run = function()

        end
    }, 

    jobToggle = {
        helpCategory    = "Job Scripting Commands", 
        helpArguments   = {"index", "[0|1]"},
        helpDescription = "toggle a job on or off", 

        run = function(index, state)

        end
    },

    exec = {
        helpArguments    = {"code"},
        helpDescription  = "run lua code directly",

        run = function(script)
            local func = load(script)

            if func then 
                func()
            end
        end
    },

    testFloats = {
        helpDescription = "print floating point number tests",

        run = function()
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
        end
    }

    -- TODO trigger commands?
    -- like if I push a button that puts a hardware pin high or low then do some action
    -- trigCreate(ioGetPin(2) == 1, ioSetPin(1))
    -- maybe create a lua array for every io pin
    -- use interupts on the c++ side to push values to lua?
    -- I'd like to do a trigger so you can trigger on changed state 
}

function sendPeriodicFrames()
    local t = millis()
    for _, f in ipairs(frames) do
        if f.enabled and t >= f.lastSent + f.period then
            sendCanFrame(f.id, f.dlc, table.unpack(f.data))
            f.lastSent = t
        end
    end
end

function runPeriodicJobs()
    local t = millis()
    for _, j in ipairs(jobs) do
        if j.enabled and t >= j.lastSent + j.period then
            j.run()
            j.lastSent = t
        end
    end
end

-- ===== Serial command parser =====
prompt = "LowDAQ > "

function printPrompt()
    printf(prompt)
end

function invalidCommand()
    print("Invalid Command. Run help() for list of commands.")
end

inputBuffer = ""

function processSerial()
    local c = serialRead()
    while c ~= -1 do
        local ch = string.char(c)
        if ch == '\n' and inputBuffer then -- newline
            print()
            parseCommand(inputBuffer)
            inputBuffer = ""
        else
            inputBuffer = inputBuffer .. ch
            printf(ch)
        end
        c = serialRead()
    end
end

-- function parseCommand(str)
--     local name, args = string.match(str, "(%w+)%((.*)%)")
--     if not name or name == "" then
--         invalidCommand()
--         printPrompt()
--         return
--     end
-- 
--     local argList = {}
--     for arg in string.gmatch(args, "[^,]+") do
--         table.insert(argList, tonumber(arg) or arg)
--     end
-- 
--     for n, c in pairs(commands) do 
--         if n == name then 
--             c.run(table.unpack(argList))
--             printPrompt()
--             return
--         end
--     end
-- 
--     invalidCommand()
--     printPrompt()
-- end

-- Robust Lua command parser for nested parentheses and quotes
function parseCommand(str)
    local name, args = str:match("^(%w+)%((.*)%)")
    if not name then
        invalidCommand()
        printPrompt()
        return
    end

    local argList = {}
    local current = ""
    local inString = false
    local escape = false
    local depth = 0

    for i = 1, #args do
        local c = args:sub(i, i)

        if inString then
            if escape then
                current = current .. c
                escape = false
            elseif c == "\\" then
                current = current .. c
                escape = true
            elseif c == '"' then
                current = current .. c
                inString = false
            else
                current = current .. c
            end
        else
            if c == '"' then
                current = current .. c
                inString = true
            elseif c == "(" then
                current = current .. c
                depth = depth + 1
            elseif c == ")" then
                if depth > 0 then
                    current = current .. c
                    depth = depth - 1
                end
            elseif c == "," and depth == 0 then
                local v = tonumber(current) or current
                table.insert(argList, v)
                current = ""
            else
                current = current .. c
            end
        end
    end

    if current ~= "" then
        table.insert(argList, tonumber(current) or current)
    end

    for n, c in pairs(commands) do
        if n == name then
            c.run(table.unpack(argList))
            printPrompt()
            return
        end
    end

    invalidCommand()
    printPrompt()
end

function loop()
    sendPeriodicFrames()
    runPeriodicJobs()
    -- could add Lua serial command parsing here
end