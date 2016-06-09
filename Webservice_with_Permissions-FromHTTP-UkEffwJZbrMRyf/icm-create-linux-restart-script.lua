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

killall iguana_service
sleep 2

# http://stackoverflow.com/questions/23104782/start-process-from-bash-without-inheriting-file-descriptors
#http://stackoverflow.com/questions/2208505/start-without-inheritance-of-parents-file-descriptors
SELF=$BASHPID
FDS=$(find /proc/$SELF/fd -type l -printf '%f\n')

# The following will even try to close the fd for the find sub
# shell although it is already closed. (0: stdin, 1: stdout, 2:
# stderr, 3: find)
for n in $FDS ; do
  if ((n > 2)) ; then
    eval "exec $n>&-"
  fi
done

sleep 2

#RUN_COMMAND#

pgrep -o -x iguana_service

exit 999
]=]

function restart.createScript(Version)
   local Dir = icm_utils.applicationVersion(Version)
   local RootDir = icm_utils.root()
   local Content = reStartScript
   Content = Content:gsub("#ROOT#", icm_utils.root())
   local Command = "cd "..Dir.." && ./iguana_service"
   trace(Command)
   Content = Content:gsub("#RUN_COMMAND#", Command)
   trace(Content)
   if not iguana.isTest() then
      local F = io.open(RootDir.."iguana_restart.bash", "w")
      F:write(Content)
      F:close()
      os.fs.chmod(RootDir.."iguana_restart.bash", 700)
   end
end

return restart