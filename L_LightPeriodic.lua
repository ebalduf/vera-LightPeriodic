json = require('json')

package.path = '../?.lua;'..package.path

local lpZoneData
local lpSchedule

--[[
  Parses the schedule and sets up timers
  ]]
function lpSetupPeriod()

    lpGetSchedule()

    -- loop schedule
    for k,sched in pairs(lpSchedule) do

        -- turn on now.
        lpTurnOn(sched['zone'])
        luup.log("lpTurnOn "..sched['zone'].." at "..os.date("%Y-%m-%d %H:%M:%S",os.time()),50)

        -- set off timer
        luup.call_timer("lpTurnOff", 1, sched['length'].."m", "", sched['zone'])
        luup.log("lpTurnOff "..sched['zone'].." scheduled for "..sched['length'],50)

        -- find the next run time
        splitPeriod = lpSplit(sched['period'], "[:]+")
        periodMinutes = ( splitPeriod[1] * 60 ) + splitPeriod[2]

        -- stop back at next period
        luup.call_timer("lpSetupPeriod", 1, periodMinutes.."m", "", "")
        luup.log("lpNextRun "..sched['zone'].." scheduled for "..periodMinutes.."m",50)

    end

end

--[[
  Turn on a zone
  ]]
function lpTurnOn(zone)

    luup.log("lpTurnOn "..zone,50)

    lpZoneData = lpGetZones()

    for device,settings in pairs(lpZoneData[zone]) do

        luup.log("lpTurnOn device "..device,50)

        if settings["type"] == "dimmer" then
            lpSetDimmer( device,settings["percentage"] )
        else
            lpSetSwitch(device,1)
        end

    end
end

--[[
  Turn off a zone
  ]]
function lpTurnOff(zone)

    luup.log("lpTurnOff "..zone,50)

    lpGetZones()

    for device,settings in pairs(lpZoneData[zone]) do
        lpSetSwitch(device,0)
    end
end

function lpGetZones()
    lpZoneData = json.decode(lpMyZones)
    return lpZoneData
end

--[[
  String split function. From the Lua wiki
  ]]
function lpSplit(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
     table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

--[[
  Schedule Getter
  ]]
function lpGetSchedule()
    if(lpSchedule == nil) then
        lpSetSchedule(lpMySchedule)
    end

    return lpSchedule
end

function lpSetSchedule(data)

    lpSchedule = json.decode(data)
end


--[[
  Set a dimmer value
  ]]
function lpSetDimmer( deviceId,value )

    luup.log("lpSetDimmer about to start HandleActionRequest for "..deviceId.." to "..value,50)

    lul_arguments = {}
    lul_arguments["newLoadlevelTarget"] = tonumber(value)
    luup.call_action("urn:upnp-org:serviceId:Dimming1", "SetLoadLevelTarget", lul_arguments,tonumber(deviceId))


end

--[[
  Control a basic on/off switch
  ]]
function lpSetSwitch( deviceId,onoff )

    luup.log("lpSetSwitch "..deviceId.." to "..onoff,50)

    lul_arguments = {}
    lul_arguments["newTargetValue"] = tonumber(onoff)
    luup.call_action("urn:upnp-org:serviceId:SwitchPower1", "SetTarget", lul_arguments,tonumber(deviceId))
end

--[[
    Startup function.
    Receives a map or sets the default
]]
function lpStartup(lul_device)

    luup.task("Running Lua Startup", 1, "LightPeriodic", -1)

    luup.log("lpStartup",1)

    -- Set the schedule
    lpSetupPeriod()

end
