local config_capVolt = 14.2

if ModuleIsLoaded("pwm") and ModuleIsLoaded("hrc") and ModuleIsLoaded("rvc") then
    local rvcConfig = function()
        _log("    == RVC: Cap volt to " .. tostring(config_capVolt) .. " ==")
        rvcCapVolt(config_capVolt)
    end

    table.insert(G_startup, rvcConfig)
end
