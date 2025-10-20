----------------------------------------------------------------------------
------- main.lua - all logic and baseline functions (non user called) ------
-------            should reside here. user functions in func.lua     ------
----------------------------------------------------------------------------

-- periodic can frames
frames = {
    {id=0x7FF, dlc=8, period=1000, data={0,64,128,255,96,1,2,4}, enabled=true, lastSent=0}
}

-- periodic jobs (cron)
jobs = {}

-- adc channel scale, offset, and unit
adcChannels = {
    {1,0,"mV"},
    {1,0,"mV"},
}

-- check if value is in table
inTable = function(t, v) 
    for _, i in ipairs(t) do 
        if i == v then 
            return true
        end
    end

    return false
end

-- return a string of n number of c characters
repeatChar = function(c, n)
    local chArray = {} 

    for i = 1, n do 
        table.insert(chArray, c)
    end

    return table.concat(chArray)
end

-- pad a string with spaces
padRight = function(strIn, width)
    local spcLen = width - #strIn

    return strIn .. repeatChar(" ", spcLen)
end
padLeft = function(strIn, width)
    local spcLen = width - #strIn

    return repeatChar(" ", spcLen) .. strIn
end

-- user facing commands 
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

    -- run function definitions pulled in from func.lua


    -- TODO trigger commands?
    -- like if I push a button that puts a hardware pin high or low then do some action
    -- trigCreate(ioGetPin(2) == 1, ioSetPin(1))
    -- maybe create a lua array for every io pin
    -- use interupts on the c++ side to push values to lua?
    -- I'd like to do a trigger so you can trigger on changed state 
}

---------------------------------------------------------
------ pull in function definitions from func.lua -------
---------------------------------------------------------
-- local functionImportString = getFileContents("func.lua")
-- print("Loading Functions...")
-- local reqFunc = load(functionImportString)
-- if reqFunc then reqFunc() end
-- reqFunc = nil
-- functionImportString = nil
-- 
-- local commandsImportString = getFileContents("cmds.lua")
-- print("Loading Commands...")
-- local reqCmds = load(commandsImportString)
-- if reqCmds then reqCmds() end
-- reqCmds = nil 
-- commandsImportString = nil
-- 
-- collectgarbage()
---------------------------------------------------------
------------ end function load --------------------------
---------------------------------------------------------

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
