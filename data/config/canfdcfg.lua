----------------------------------------------------------------
---  1:1 map of FDCAN_Bitrate enum in FDCANDefines.h         ---
---  DON'T CHANGE THESE                                      ---
----------------------------------------------------------------
local bitRate = {
    br_31k   = 0,  br_33k   = 1,  br_40k   = 2,  br_50k   = 3,  br_62k   = 4,  br_80k   = 5,
    br_83k   = 6,  br_100k  = 7,  br_125k  = 8,  br_160k  = 9,  br_200k  = 10, br_250k  = 11,
    br_400k  = 12, br_500k  = 13, br_800k  = 14, br_1000k = 15, br_1250k = 16, br_1600k = 17,
    br_2000k = 18, br_2500k = 19, br_4000k = 20, br_5000k = 21, br_6000k = 22, br_8000k = 23,
}

local mode = {
    normal = 0,
    restricted = 1,
    monitoring = 2,
    internal_loopback = 3,
    external_loopback = 4,
}

local format = {
    classic = 0,
    fd_no_brs = 1,
    fd_brs = 2,
}
---------------------------------------------------------------
---  END ENUM VALUES                                        ---
---------------------------------------------------------------

---------------------------------------------------------------
---  Config values. Change these to modify CAN peripheral.  ---
---------------------------------------------------------------
local config_nominalBitrate = bitRate.br_500k
local config_dataBitrate    = bitRate.br_2000k
local config_peripheralMode = mode.normal
local config_frameFormat    = format.fd_brs
---------------------------------------------------------------
---                   END CONFIG VALUES                     ---
---------------------------------------------------------------


local canConfig = function()
    C_startCanPeripheral(config_nominalBitrate, config_dataBitrate, config_peripheralMode, config_frameFormat)
end

table.insert(G_startup, canConfig)

