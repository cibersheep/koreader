local BasePowerD = require("device/generic/powerd")
local NickelConf = require("device/kobo/nickel_conf")

local KoboPowerD = BasePowerD:new{
    fl_min = 0, fl_max = 100,
    flIntensity = 20,
    restore_settings = true,
    fl = nil,

    batt_capacity_file = "/sys/devices/platform/pmic_battery.1/power_supply/mc13892_bat/capacity",
    is_charging_file = "/sys/devices/platform/pmic_battery.1/power_supply/mc13892_bat/status",
    battCapacity = nil,
    is_charging = nil,
}

function KoboPowerD:init()
    if self.device.hasFrontlight() then
        local kobolight = require("ffi/kobolight")
        local ok, light = pcall(kobolight.open)
        if ok then self.fl = light end
    end
end

function KoboPowerD:toggleFrontlight()
    if self.fl ~= nil then
        self.fl:toggle()
    end
end

function KoboPowerD:setIntensityHW()
    if self.fl ~= nil then
        self.fl:setBrightness(self.flIntensity)
        if KOBO_SYNC_BRIGHTNESS_WITH_NICKEL then
            NickelConf.frontLightLevel.set(self.flIntensity)
        end
    end
end

function KoboPowerD:getCapacityHW()
    self.battCapacity = self:read_int_file(self.batt_capacity_file)
    return self.battCapacity
end

function KoboPowerD:isChargingHW()
    self.is_charging = self:read_str_file(self.is_charging_file) == "Charging\n"
    return self.is_charging
end

return KoboPowerD
