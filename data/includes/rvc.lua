rvcTargetVolt = function(val)
    if not val or val < 11.5 or val > 15.5 then
        return "value must be between 11.5 and 15.5", 1
    end

    local dutyCycle = val * 20 - 220

    local rvcFunc = function()
        pwmOutSet(1, 128, dutyCycle)
    end

    local job = {run=rvcFunc, period=100, description="auto added by rvc", enabled=1, lastSent=0, rvcMode="targetVolt", rvcSP=dutyCycle}

    local jobId

    for i, v in ipairs(jobs) do
        if v.rvcMode then
            jobId = i
            break
        end
    end

    if jobId then
        jobs[jobId] = job
    else
        table.insert(jobs, job)
    end

    return nil, 0
end

rvcCapVolt = function(val)
    if not val or val < 11.5 or val > 15.5 then
        return "value must be between 11.5 and 15.5", 1
    end

    local maxDutyCycle = val * 20 - 220
    local dutyCycle
    local rvcFunc = function()
        local ecuRequestDC = math.floor(pwmInGetDuty(1) + 0.5)

        dutyCycle = ecuRequestDC >= 10 and ecuRequestDC or 10
        dutyCycle = dutyCycle < maxDutyCycle and dutyCycle or maxDutyCycle

        pwmOutSet(1, 128, dutyCycle)
    end

    local job = {run=rvcFunc, period=100, description="auto added by rvc", enabled=1, lastSent=0, rvcMode="capVolt", rvcSP=dutyCycle}

    local jobId

    for i, v in ipairs(jobs) do
        if v.rvcMode then
            jobId = i
            break
        end
    end

    if jobId then
        jobs[jobId] = job
    else
        table.insert(jobs, job)
    end

    return nil, 0
end

rvcTargetSOC = function(val)
    return "not implemented yet", 1
end

rvcGetMode = function()
    for _, v in ipairs(jobs) do
        if v.rvcMode then
            return v.rvcMode, 0
        end
    end
    return "RVC output not enabled", 1
end

rvcGetSetpoint = function()
    for _, v in ipairs(jobs) do
        if v.rvcSP then
            return v.rvcSP, 0
        end
    end
    return "RVC output not enabled", 1
end


rvcDisable = function()
    for i, v in ipairs(jobs) do
        if v.rvcMode then
            pwmOutSet(1, 128, 0)
            jobs[i] = nil
            return nil, 0
        end
    end
    return "RVC output not enabled", 1
end

commands.rvcGetMode.helpCategory        = "RVC Commands"
commands.rvcGetMode.helpDescription     = "return the current set RVC mode"
commands.rvcGetMode.run = rvcGetMode

commands.rvcGetSetpoint.helpCategory    = "RVC Commands"
commands.rvcGetSetpoint.helpDescription = "return the current RVC setpoint"
commands.rvcGetSetpoint.run = rvcGetSetpoint

commands.rvcDisable.helpCategory        = "RVC Commands"
commands.rvcDisable.helpDescription     = "disable the RVC output"
commands.rvcDisable.run = rvcDisable

commands.rvcTargetVolt.helpCategory     = "RVC Commands"
commands.rvcTargetVolt.helpArguments    = {"value"}
commands.rvcTargetVolt.helpDescription  = "sets the rvc output to [value]"
commands.rvcTargetVolt.run = rvcTargetVolt

commands.rvcCapVolt.helpCategory        = "RVC Commands"
commands.rvcCapVolt.helpArguments       = {"value"}
commands.rvcCapVolt.helpDescription     = "use the ECU's RVC value up to [value]"
commands.rvcCapVolt.run = rvcCapVolt

commands.rvcTargetSOC.helpCategory      = "RVC Commands"
commands.rvcTargetSOC.helpArguments     = {"value"}
commands.rvcTargetSOC.helpDescription   = "attempt to modulate RVC to target an SOC value"
commands.rvcTargetSOC.run = rvcTargetSOC
