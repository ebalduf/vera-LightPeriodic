-- Filename: L_LightPeriodic.lua

--[[
  Parses the schedule and sets up timers
  ]]
function lpSetupPeriod(lul_device)

    local temperature_device, tstamp = luup.variable_get("urn:madskier-com:serviceId:LightPeriodic1", "TemperatureDeviceID", lul_device)
    if ( luup.is_ready(tonumber(temperature_device)) == false ) then
        -- the weather app is not ready yet, reschedule for 2 minutes
        luup.log("Weather not up yet ... Delay")
        luup.call_timer("lpSetupPeriod", 1, "2m", "", lul_device)
        return
    end

    local temp, tstamp = luup.variable_get("urn:upnp-org:serviceId:TemperatureSensor1", "CurrentTemperature", tonumber(temperature_device))
    luup.log("Current Temperature: "..temp)
    local threshold, tstamp = luup.variable_get("urn:madskier-com:serviceId:LightPeriodic1", "ThresholdTemperature", tonumber(lul_device))

    if tonumber(temp) < tonumber(threshold) then
        local enabled, tstamp = luup.variable_get("urn:madskier-com:serviceId:LightPeriodic1", "Enabled", lul_device)
        if (enabled == 1) then
            local target_device, tstamp = luup.variable_get("urn:madskier-com:serviceId:LightPeriodic1", "TargetDeviceNum", lul_device)
            local base_length, tstamp = luup.variable_get("urn:madskier-com:serviceId:LightPeriodic1", "BaseLength", lul_device)

            length = base_length + (threshold - temp)
            -- if enabled, lpTurnOn
            lpTurnOn(tonumber(target_device))
            -- schedule lpTurnOff
            luup.call_timer("lpTurnOff", 1, math.floor(length+0.5).."m", "", tonumber(target_device))
        end
    end
    -- reschedule lpSetupPeriod
    local period, tstamp = luup.variable_get("urn:madskier-com:serviceId:LightPeriodic1", "Period", lul_device)
    luup.call_timer("lpSetupPeriod", 1, period.."m", "", lul_device)
end

--[[
  Turn on a switch
  ]]
function lpTurnOn(deviceId)
    luup.log("lpTurnOn switch: "..deviceId, 50)
    lul_arguments = {}
    lul_arguments["newTargetValue"] = 1
    luup.call_action("urn:upnp-org:serviceId:SwitchPower1", "SetTarget", lul_arguments, tonumber(deviceId))
end

--[[
  Turn off a switch
  ]]
function lpTurnOff(deviceId)
    luup.log("lpTurnOff switch: "..deviceId, 50)
    lpGetZones()
    lul_arguments = {}
    lul_arguments["newTargetValue"] = 0
    luup.call_action("urn:upnp-org:serviceId:SwitchPower1", "SetTarget", lul_arguments, tonumber(deviceId))
end

local function isempty(s)
  return s == nil or s == ''
end

--[[
    Startup function.
    Receives a map or sets the default
]]
function lpStartup(lul_device)

    luup.log("LightPeriodic, Startup Routine Called.")
    luup.task("Running Lua Startup", 1, "LightPeriodic", -1)
    -- check that all our variables are at least present
    local enabled, tstamp = luup.variable_get("urn:madskier-com:serviceId:LightPeriodic1", "Enabled", lul_device)
    if isempty(enabled) then
        luup.variable_set("urn:madskier-com:serviceId:LightPeriodic1", "Enabled", 0, lul_device)
        enabled = 0
    end

    local period, tstamp = luup.variable_get("urn:madskier-com:serviceId:LightPeriodic1", "Period", lul_device)
    if isempty(period) then
        luup.variable_set("urn:madskier-com:serviceId:LightPeriodic1", "Period", 60, lul_device)
    end
    local baseLength, tstamp = luup.variable_get("urn:madskier-com:serviceId:LightPeriodic1", "BaseLength", lul_device)
    if isempty(baseLength) then
        luup.variable_set("urn:madskier-com:serviceId:LightPeriodic1", "BaseLength", 5, lul_device)
    end
    local tgtDevId, tstamp = luup.variable_get("urn:madskier-com:serviceId:LightPeriodic1", "TargetDeviceNum", lul_device)
    if isempty(tgtDevId) then
        luup.variable_set("urn:madskier-com:serviceId:LightPeriodic1", "TargetDeviceNum", 0, lul_device)
    end
    local thresholdTemp, tstamp = luup.variable_get("urn:madskier-com:serviceId:LightPeriodic1", "ThresholdTemperature", lul_device)
    if isempty(thresholdTemp) then
        luup.variable_set("urn:madskier-com:serviceId:LightPeriodic1", "ThresholdTemperature", 32, lul_device)
    end
    local tempDevId, tstamp = luup.variable_get("urn:madskier-com:serviceId:LightPeriodic1", "TemperatureDeviceID", lul_device)
    if isempty(tempDevId) then
        luup.variable_set("urn:madskier-com:serviceId:LightPeriodic1", "TemperatureDeviceID", 0, lul_device)
    end

    if( tonumber(enabled) == 1 ) then
        luup.log("LightPeriodic enabled! Starting up.",1)
        lpSetupPeriod(lul_device)
    end
end

function toggle_enabled(self, lul_device)
    luup.log("Toggle Enabled: ")
    local enabled, tstamp = luup.variable_get("urn:madskier-com:serviceId:LightPeriodic1", "Enabled", lul_device)
    if ( tonumber(enabled) == 1 ) then
        luup.variable_set("urn:madskier-com:serviceId:LightPeriodic1", "Enabled", 0, lul_device)
    else
        luup.variable_set("urn:madskier-com:serviceId:LightPeriodic1", "Enabled", 1, lul_device)
        lpSetupPeriod(lul_device)
    end
    return 4, 0
end
