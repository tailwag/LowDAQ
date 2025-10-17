frames = {
    {id=0x7FF, dlc=8, period=1000, data={0,64,128,255,96,1,2,4}, enabled=true, lastSent=0}
}
local repeatChar = function(c, n)
    line = ""
    
    for i = 1, n do 
        line = line .. c 
    end

    return line
end

local inTable = function(t, v) 
    for _, i in ipairs(t) do 
        if i == v then 
            return true
        end
    end

    return false
end

local padRight = function(strIn, width)
    local padding = ""

    local spcLen = width - #strIn

    for i = 1, spcLen do 
        padding = padding .. " "
    end

    return strIn .. padding
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
                helpTable[k] = {}
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

                table.insert(helpTable[tabCat], {column1, column2})
            end
            
            -- determine longest width of columns 1
            local col1max = 0
            local col2max = 0
            for cat, cmds in pairs(helpTable) do 
                for _, cols in ipairs(cmds) do
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

            for category, commands in pairs(helpTable) do 
                -- command category
                local cat = "=="
                cat = cat .. repeatChar(" ", categoryMargin)
                cat = cat .. padRight(category, maxWidth - categoryMargin)
                cat = cat .. "=="
                print(cat)

                for _, cmdArr in ipairs(commands) do 
                    -- command with args and description
                    local cmd = "=="
                    cmd = cmd .. repeatChar(" ", helpMargin)
                    cmd = cmd .. padRight(cmdArr[1], col1max)
                    cmd = cmd .. padRight(cmdArr[2], col2max)
                    cmd = cmd .. repeatChar(" ", helpMargin)
                    cmd = cmd .. "=="
                    print(cmd)
                end

                -- blank line in between categories
                print("==" .. repeatChar(" ", maxWidth) .. "==")

            end

            -- bottom border
            print(repeatChar("=", maxWidth + 4))
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
    }
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

function parseCommand(str)
    local name, args = string.match(str, "(%w+)%((.*)%)")
    if not name or name == "" then
        invalidCommand()
        printPrompt()
        return
    end

    local argList = {}
    for num in string.gmatch(args, "[^,]+") do
        table.insert(argList, tonumber(num))
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
    -- could add Lua serial command parsing here
end