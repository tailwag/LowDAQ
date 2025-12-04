---------------------------------------------------------------
---  Config values. Change these to modify CAN peripheral.  ---
---------------------------------------------------------------
local config_nominalBitrate     = 500000  -- bps
local config_dataBitrate        = 2000000 -- bps
local config_nominalSamplePoint = 80      -- %
local config_dataSamplePoint    = 80      -- %

-- CanConfig table defined in can module. Either hrc.lua or can.lua
local config_peripheralMode     = Global.CanConfig.mode.external_loopback
local config_frameFormat        = Global.CanConfig.format.fd_brs
---------------------------------------------------------------
---                   END CONFIG VALUES                     ---
---------------------------------------------------------------


local canConfig = function()
    C_startCanPeripheral(config_nominalBitrate, config_dataBitrate,
                         config_nominalSamplePoint, config_dataSamplePoint,
                         config_peripheralMode, config_frameFormat)
end

table.insert(G_startup, canConfig)

