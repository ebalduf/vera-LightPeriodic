vera-LightPeriodic
=======================

Turns on a light for a fixed amount of time within a period.

## Configuration

### Zones file

Copy `L_LightPeriodic_zones.sample.lua` to `L_LightPeriodic_zones.lua`.

Adjust the file as required for your network. The numeric keys within each zone
are the Device IDs that you want to control. Supported `types` are "dimmer" and
"switch". For dimmer add a `percentage` integer of between 1 and 100.

### Schedule file

Copy `L_LightPeriodic.sample.lua` to
`L_LightPeriodic_schedule.lua`.

Adjust the file as required for your network. Each `zone` must relate to a key
in your `L_LightPeriodic.json` file. Then period and length times. These times
must be in the following formats
* period - hours:minutes (hh:mm) format.
* length - minutes

Be sure that your length is less than the period, sorry you'll have to do some
math.

## Installation

Copy the following files to Vera using the Apps > Develop Apps > Luup files tool.

* D_LightPeriodic.xml
* I_LightPeriodic.xml
* L_LightPeriodic.lua
* L_LightPeriodic_zones.lua
* L_LightPeriodic_schedule.lua
* json.lua

Now manually create a new device with a `Upnp Device Filename` of
"D_LightPeriodic.xml".

To cancel the schedule, delete the device.

Enjoy!
