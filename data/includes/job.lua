jobAdd = function(job, period, description)
    local func = load(job)

    if not func then
        return "Error processing job function", 1
    end

    period = tonumber(period)

    if not period or period < 1 then
        return "invalid period, must be >= 1 (ms)", 1
    end

    table.insert(jobs, {run = func, period = period, description = description, enabled = true, lastSent = 0})

    return nil, 0
end

jobDel = function(job)
    job = tonumber(job)

    if not job or job < 0 or job > #jobs then
        return "invalid index", 1
    end

    jobs[job] = nil

    return nil, 0
end

jobList = function()
    print("#       Period    Description")

    for i, v in ipairs(jobs) do
        printf(padRight(tostring(i) .. ".", 5))
        printf(padLeft(v.period and tostring(v.period) or "", 9))
        printf("    ")
        printf(v.description and tostring(v.description) or "")

        print()
    end

    return nil, 0
end

jobToggle = function(index, state)
    for i, v in ipairs(jobs) do
        if i == index then
            v.enabled = state == 1 and true or false
        end
    end
end

-------------------------------------------------------------------
--- add all definied commands to the command parser in main.lua ---
-------------------------------------------------------------------
commands.jobAdd = {
    helpCategory    = "Job Scripting Commands",
    helpArguments   = {"function()", "period(ms)", "description"},
    helpDescription = "schedule a job to occur peridically",
}
commands.jobAdd.run = jobAdd

commands.jobDel = {
    helpCategory    = "Job Scripting Commands",
    helpArguments   = {"index"}, 
    helpDescription = "remove a periodic job",
}
commands.jobDel.run = jobDel

commands.jobList = {
    helpCategory    = "Job Scripting Commands",
    helpDescription = "list current jobs",
}
commands.jobList.run       = jobList

commands.jobToggle = {
    helpCategory    = "Job Scripting Commands",
    helpArguments   = {"index", "[0|1]"},
    helpDescription = "toggle a job on or off",
}
commands.jobToggle.run     = jobToggle

table.insert(LoadedModules, "job")
