jobAdd = function(job, period, description)
    local func = load(job)

    if not func then
        return "Error processing job function", 1
    end

    period = tonumber(period)

    if not period or period < 1 then
        return "invalid period, must be >= 1 (ms)", 1
    end

    table.insert(jobs, {run = func, period = period, description = description, enabled = 1, lastSent = 0})

    return nil, 0
end


jobList = function()
    local outputArray = {"#       Period    Description"}

    for i, v in ipairs(jobs) do
        local j_index  = padRight(tostring(i) .. ".", 5)
        local j_period      = v.period and tostring(v.period) or ""
        local j_description = v.description and tostring(v.description) or ""

        j_index       = padRight(j_index, 5)
        j_period      = padLeft(j_period, 9)

        table.insert(outputArray, "\n"..j_index..j_period.."    "..j_description)
    end

    return table.concat(outputArray), 0
end

jobToggle = function(index, state)

end

-------------------------------------------------------------------
--- add all definied commands to the command parser in main.lua ---
-------------------------------------------------------------------

commands.jobAdd.helpCategory       = "Job Scripting Commands"
commands.jobAdd.helpArguments      = {"function()", "period(ms)", "description"}
commands.jobAdd.helpDescription    = "schedule a job to occur peridically"
commands.jobAdd.run = jobAdd

commands.jobList.helpCategory      = "Job Scripting Commands"
commands.jobList.helpDescription   = "list current jobs"
commands.jobList.run = jobList

commands.jobToggle.helpCategory    = "Job Scripting Commands"
commands.jobToggle.helpArguments   = {"index", "[0|1]"}
commands.jobToggle.helpDescription = "toggle a job on or off"
commands.jobToggle.run = jobToggle
