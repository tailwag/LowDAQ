local RVC_hrcOutput = function(ecu, out, max, mode)
    hrcReset(0x7EA, 7)
    hrcSetValue(ecu,   0, 8, "unsigned") -- ECUreqDC  value, raw
    hrcSetValue(ecu,   8, 8, "unsigned") -- ECUreqVlt value, scale = 0.05, offset = 11
    hrcSetValue(out,  16, 8, "unsigned") -- RVCoutDC  value, raw
    hrcSetValue(out,  24, 8, "unsigned") -- RVCoutVlt value, scale = 0.05, offset = 11
    hrcSetValue(max,  32, 8, "unsigned") -- RVCmaxDC  value, raw
    hrcSetValue(max,  40, 8, "unsigned") -- RVCmaxVlt value, scale = 0.05, offset = 11
    hrcSetValue(mode, 48, 2, "unsigned") -- RVCmode   value, 1 = targetVolt, 2 = capVolt, 3 = targetSOC
    hrcSend()
end

local updateRvcJob = function(job)
    local jobId

    -- determine if rvc job already exists
    for i, v in ipairs(jobs) do
        if v.rvcMode then
            jobId = i
            break
        end
    end

    -- if rvc job exsits update it, if not, create it
    if jobId then
        jobs[jobId] = job
    else
        table.insert(jobs, job)
    end

    return nil, 0
end

rvcTargetVolt = function(val)
    if not val or val < 11.5 or val > 15.5 then
        return "value must be between 11.5 and 15.5", 1
    end

    -- calculate pwm for requested voltage
    local dutyCycle = val * 20 - 220

    -- this function is what gets called periodically by the jobs table
    local rvcFunc = function()
        if ModuleIsLoaded("hrc") then
            -- duty cycle output from the ECU 
            local ecuRequestDC = math.floor(pwmInGetDuty(1) + 0.5)

            RVC_hrcOutput(ecuRequestDC, dutyCycle, dutyCycle, 1)
        end

        pwmOutSet(1, 128, dutyCycle)
    end

    local job = {run=rvcFunc, period=100, description="auto added by rvc", enabled=1, lastSent=0, rvcMode="targetVolt", rvcSP=dutyCycle}

    return updateRvcJob(job)
end

rvcCapVolt = function(val)
    if not val or val < 11.5 or val > 15.5 then
        return "value must be between 11.5 and 15.5", 1
    end

    -- maxDutyCycle is the capped voltage converted to rvc dc %
    local maxDutyCycle = val * 20 - 220
    local dutyCycle

    -- this function is what gets called periodically by the jobs table
    local rvcFunc = function()
        -- duty cycle output from the ECU 
        local ecuRequestDC = math.floor(pwmInGetDuty(1) + 0.5)

        -- set lower then upper limits
        dutyCycle = ecuRequestDC >= 10 and ecuRequestDC or 10
        dutyCycle = dutyCycle < maxDutyCycle and dutyCycle or maxDutyCycle

        -- human readable can module
        if ModuleIsLoaded("hrc") then
            RVC_hrcOutput(ecuRequestDC, dutyCycle, maxDutyCycle, 2)
        end

        pwmOutSet(1, 128, dutyCycle)
    end

    local job = {run=rvcFunc, period=100, description="auto added by rvc", enabled=1, lastSent=0, rvcMode="capVolt", rvcSP=maxDutyCycle}

    return updateRvcJob(job)
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

commands.rvcGetMode         = {
    helpCategory            = "RVC Commands",
    helpDescription         = "return the current set RVC mode",
}
commands.rvcGetMode.run     = rvcGetMode

commands.rvcGetSetpoint     = {
    helpCategory            = "RVC Commands",
    helpDescription         = "return the current RVC setpoint",
}
commands.rvcGetSetpoint.run = rvcGetSetpoint

commands.rvcDisable         = {
    helpCategory            = "RVC Commands",
    helpDescription         = "disable the RVC output",
}
commands.rvcDisable.run     = rvcDisable

commands.rvcTargetVolt      = {
    helpCategory            = "RVC Commands",
    helpArguments           = {"value"},
    helpDescription         = "sets the rvc output to [value]",
}
commands.rvcTargetVolt.run  = rvcTargetVolt

commands.rvcCapVolt         = {
    helpCategory            = "RVC Commands",
    helpArguments           = {"value"},
    helpDescription         = "use the ECU's RVC value up to [value]",
}
commands.rvcCapVolt.run     = rvcCapVolt

commands.rvcTargetSOC       = {
    helpCategory            = "RVC Commands",
    helpArguments           = {"value"},
    helpDescription         = "attempt to modulate RVC to target an SOC value",
}
commands.rvcTargetSOC.run   = rvcTargetSOC

table.insert(LoadedModules, "rvc")
