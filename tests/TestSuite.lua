require('luaunit')

package.path = '../?.lua;'..package.path
require('luup');
require('L_LightPeriodic')

dofile("../L_LightPeriodic_zones.lua")
dofile("../L_LightPeriodic_schedule.lua")

TestCode = {} --class

    function TestCode:testStuff()
    end

    function TestCode:testMakeTime1()

        -- case #1 normal
        startTime = os.time({year=os.date('%Y'),month=os.date('%m'),day=os.date('%d'),hour=8, min=1, sec=2})
        endTime = os.time({year=os.date('%Y'),month=os.date('%m'),day=os.date('%d'),hour=9, min=45, sec=46})
        stamp = lrMakeTime('08:01:02','09:45:46')
        assertGreaterThan(stamp,startTime)
        assertLessThan(stamp,endTime)
    end

    function TestCode:testMakeTime2()
        -- case #2 sunrise
        startTime = os.time({year=os.date('%Y'),month=os.date('%m'),day=os.date('%d'),hour=8, min=1, sec=2})
        endTime = os.time({year=os.date('%Y'),month=os.date('%m'),day=os.date('%d'),hour=9, min=45, sec=46})
        stamp = lrMakeTime('sunrise','09:45:46')
        assertGreaterThan(stamp,startTime)
        assertLessThan(stamp,endTime)
    end

    function TestCode:testMakeTime3()
        -- case #3 sunset
        startTime = os.time({year=os.date('%Y'),month=os.date('%m'),day=os.date('%d'),hour=8, min=1, sec=2})
        endTime = os.time({year=os.date('%Y'),month=os.date('%m'),day=os.date('%d'),hour=19, min=45, sec=46})
        stamp = lrMakeTime('08:01:02','sunset')
        assertGreaterThan(stamp,startTime)
        assertLessThan(stamp,endTime)
    end

    function TestCode:testMakeTime4()
        -- case #4 minus delta time
        startTime = os.time({year=os.date('%Y'),month=os.date('%m'),day=os.date('%d'),hour=19, min=15, sec=46})
        endTime = os.time({year=os.date('%Y'),month=os.date('%m'),day=os.date('%d'),hour=19, min=45, sec=46})
        stamp = lrMakeTime('-30','sunset')
        assertGreaterThan(stamp,startTime)
        assertLessThan(stamp,endTime)
    end

    function TestCode:testMakeTime5()
        -- case #5 plus delta time
        startTime = os.time({year=os.date('%Y'),month=os.date('%m'),day=os.date('%d'),hour=8, min=1, sec=2})
        endTime = os.time({year=os.date('%Y'),month=os.date('%m'),day=os.date('%d'),hour=8, min=36, sec=2})
        stamp = lrMakeTime('sunrise','+35')
        assertGreaterThan(stamp,startTime)
        assertLessThan(stamp,endTime)
    end

    function TestCode:testMakeTime6()
        -- case #6 wrong plus delta time
        startTime = os.time({year=os.date('%Y'),month=os.date('%m'),day=os.date('%d'),hour=19, min=15, sec=46})
        endTime = os.time({year=os.date('%Y'),month=os.date('%m'),day=os.date('%d'),hour=19, min=45, sec=46})
        stamp = lrMakeTime('+30','sunset')
        assertGreaterThan(stamp,startTime)
        assertLessThan(stamp,endTime)
    end

    function TestCode:testMakeTime7()
        -- case #7 wrong negative delta time
        startTime = os.time({year=os.date('%Y'),month=os.date('%m'),day=os.date('%d'),hour=8, min=1, sec=2})
        endTime = os.time({year=os.date('%Y'),month=os.date('%m'),day=os.date('%d'),hour=8, min=36, sec=2})
        stamp = lrMakeTime('sunrise','-35')
        assertGreaterThan(stamp,startTime)
        assertLessThan(stamp,endTime)
    end

    function TestCode:testTurnOn()

        lrTurnOn("lounge")

        assertEquals(luup.variable_get("urn:upnp-org:serviceId:Dimming1","newLoadlevelTarget",5),50);
        assertEquals(luup.variable_get("urn:upnp-org:serviceId:SwitchPower1","newTargetValue",6),1);
    end

    function TestCode:testTurnOff()

        lrTurnOn("porch")
        assertEquals(luup.variable_get("urn:upnp-org:serviceId:SwitchPower1","newTargetValue",10),1);

        lrTurnOff("porch")
        assertEquals(luup.variable_get("urn:upnp-org:serviceId:SwitchPower1","newTargetValue",10),0);

    end

    function TestCode:testLoadZones()
        zones = lrGetZones()
        assertEquals(type(zones),'table');
        assertEquals(type(zones["lounge"]),'table');
        assertEquals(type(zones["lounge"]["5"]),'table');
        assertEquals(zones["lounge"]["5"]["type"],'dimmer');
        assertEquals(zones["lounge"]["5"]["percentage"],50);
        assertEquals(type(zones["lounge"]["6"]),'table');
        assertEquals(zones["lounge"]["6"]["type"],'switch');
        assertEquals(type(zones["porch"]),'table');
    end

-- class TestCode

LuaUnit:run()
