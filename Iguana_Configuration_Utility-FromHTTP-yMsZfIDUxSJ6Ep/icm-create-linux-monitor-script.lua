-- **********************************************************************
--
--   Iguana Configuration Management Utility:
--   ---------------------------------------- 
--
--   icm-create-linux-monitor-script.lua
--
--   description:
--     - checks for running iguana & iguana_service / attempts restart if not running...
--
--   author:
--     Scott C. Ripley
--
-- **********************************************************************

local monitor = {}

-- This start script is invoked by cron under Linux once a minute
-- It's a shell script which checks to see if Iguana is running and then starts
-- it if it is not.  Aren't shell scripts cryptic!

local icm_utils = require 'icm-utils'

local monitorScript=[=[
#!/bin/bash

PATH=$PATH:/sbin:/bin

IGUANA_SERVICE_PID=#IGUANA_SERVICE_PID#
IGUANA_SERVICE_RUNNING=`kill -0 "$IGUANA_SERVICE_PID" 2>&1`
if [ ! -z "$IGUANA_SERVICE_RUNNING" ] ;  then
   sleep 5;
   IGUANA_SERVICE_RUNNING=`kill -0 "$IGUANA_SERVICE_PID" 2>&1`
   if [ ! -z "$IGUANA_SERVICE_RUNNING" ] ;  then
      #RUN_COMMAND#
   fi
fi

sleep 2

exit 999
]=]

function monitor.createScript(Version)
   local IguanaService = icm_utils.getIguanaService(iguana.appDir() .. "iguana_service.hdf")
   local Dir = icm_utils.applicationVersion(Version)
   local RootDir = icm_utils.root()
   local Content = monitorScript
   local Command = "cd "..RootDir.." && ./"..IguanaService.."_restart.bash"
   local IguanaServicePID = icm_utils.executeAndCapture("cat " .. iguana.appDir() .. "/"..IguanaService..".pid")  
   Content = Content:gsub("#IGUANA_SERVICE_PID#", IguanaServicePID)
   Content = Content:gsub("#RUN_COMMAND#", Command)
   if not iguana.isTest() then      
      local F = io.open(RootDir..IguanaService.."_monitor.bash", "w")
      F:write(Content)
      F:close()
      os.fs.chmod(RootDir..IguanaService.."_monitor.bash", 700)
   end
end

return monitor