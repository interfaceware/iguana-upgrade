-- **********************************************************************
--
--   Iguana Configuration Management Utility:
--   ---------------------------------------- 
--
--   icm-create-linux-restart-script.lua
--
--   description:
--     - launch process that survives iguana shutdown / re-start iguana
--
--   author:
--     Scott C. Ripley
--
-- **********************************************************************

local restart = {}

-- This start script is invoked by cron under Linux once a minute
-- It's a shell script which checks to see if Iguana is running and then starts
-- it if it is not.  Aren't shell scripts cryptic!

local icm_utils = require 'icm-utils'

local reStartScript=[=[
#!/bin/bash

PATH=$PATH:/sbin:/bin

kill -9 #IGUANA_SERVICE_PID#
sleep 2

SELF=$BASHPID
FDS=$(find /proc/$SELF/fd -type l -printf '%f\n')
for n in $FDS ; do
  if ((n > 2)) ; then
    eval "exec $n>&-"
  fi
done

sleep 2

#RUN_COMMAND#

]=]

function restart.createScript(Version)
   local IguanaService = icm_utils.getIguanaService(iguana.appDir() .. "iguana_service.hdf")
   local Dir = icm_utils.applicationVersion(Version)
   local RootDir = icm_utils.root()
   local Content = reStartScript
   Content = Content:gsub("#ROOT#", icm_utils.root())
   local Command = "cd "..Dir.." && ./iguana_service"
   local IguanaPID = icm_utils.executeAndCapture("cat " .. iguana.appDir() .. "/"..IguanaService..".pid")  
   Content = Content:gsub("#IGUANA_SERVICE_PID#", IguanaPID)
   Content = Content:gsub("#RUN_COMMAND#", Command)
   if not iguana.isTest() then
      local IguanaService = icm_utils.getIguanaService(iguana.appDir() .. "iguana_service.hdf")
      local F = io.open(RootDir..IguanaService.."_restart.bash", "w")
      F:write(Content)
      F:close()
      os.fs.chmod(RootDir..IguanaService.."_restart.bash", 700)
   end
end

return restart