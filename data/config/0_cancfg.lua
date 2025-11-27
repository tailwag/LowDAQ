----------------------------------------------------------------
---  1:1 map of C++ enums in FDCANDefines.h                  ---
---  DON'T CHANGE THESE                                      ---
----------------------------------------------------------------
local mode = {
    normal = 0,
    restricted = 1,
    monitoring = 2,
    internal_loopback = 3,
    external_loopback = 4,
}

local format = {
    classic = 0,
    fd_no_brs = 256,
    fd_brs = 768,
}
---------------------------------------------------------------
---  END ENUM VALUES                                        ---
---------------------------------------------------------------

---------------------------------------------------------------
---  Config values. Change these to modify CAN peripheral.  ---
---------------------------------------------------------------
local config_nominalBitrate     = 500000  -- bps
local config_dataBitrate        = 2000000 -- bps
local config_nominalSamplePoint = 80      -- %
local config_dataSamplePoint    = 80      -- %
local config_peripheralMode     = mode.normal
local config_frameFormat        = format.fd_brs
---------------------------------------------------------------
---                   END CONFIG VALUES                     ---
---------------------------------------------------------------


local canConfig = function()
    C_startCanPeripheral(config_nominalBitrate, config_dataBitrate,
                         config_nominalSamplePoint, config_dataSamplePoint,
                         config_peripheralMode, config_frameFormat)
end

table.insert(G_startup, canConfig)

