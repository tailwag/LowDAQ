rvcSetMode = function(mode, val) 
    if mode == "help" then
        local retString = "Use PWM input 1 and PWM output 1 to control RVC\n"
        retString = retString .. "Modes:\n"
        retString = retString .. "  targetVolt - set generator output to specific voltage\n"
        retString = retString .. "  targetSOC  - modulate generator output to target battery SOC\n"
        retString = retString .. "  capVolt    - use RVC signal from vehicle with a voltage cap\n"

        return retString, 0
    end

    if not val then
        return "Must supply a target value", 1
    end

    if mode == "targetSOC"  then
        if val < 10 or val > 100 then
            return "SOC must be between 10 and 100%", 1
        end

        return nil

    elseif mode == "targetVolt" then
        if val < 11.5 or val > 15.5 then
            return "Voltage must be between 11.5 and 15.5", 1
        end

        local dutyCycle = val * 20 - 220

        local rvcFunc = function()
            pwmOutSet(1, 128, dutyCycle)
        end

        local job = {run=rvcFunc, period=100, description="auto added by rvc", enabled=1, lastSent=0, sig="rvc"}

        local jobId

        for i, v in ipairs(jobs) do
            if v.sig and v.sig == "rvc" then
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

    elseif mode == "capVolt" then
        if val < 11.5 or val > 15.5 then
            return "Voltage must be between 11.5 and 15.5"
        end

        local maxDutyCycle = val * 20 - 220

        local rvcFunc = function()
            local ecuRequestDC = math.floor(pwmInGetDuty(1) + 0.5)

            local dutyCycle = ecuRequestDC >= 10 and ecuRequestDC or 10
            dutyCycle = dutyCycle < maxDutyCycle and dutyCycle or maxDutyCycle

            pwmOutSet(1, 128, dutyCycle)
        end

        local job = {run=rvcFunc, period=100, description="auto added by rvc", enabled=1, lastSent=0, sig="rvc"}

        local jobId

        for i, v in ipairs(jobs) do
            if v.sig and v.sig == "rvc" then
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

    return "Invalid mode specified", 1
end

commands.rvcSetMode = {
    helpCategory    = "RVC Commands",
    helpArguments   = {"[help|(mode)], value"},
    helpDescription = "change which mode the RVC module operates in",

    run = function() end
}
commands.rvcSetMode.run = rvcSetMode
