-- **********************************************************************
--
--   Iguana Configuration Management Utility:
--   ---------------------------------------- 
--
--   icm-create-linux-start-script.lua
--
--   description:
--      -  This start script is invoked by cron under Linux once a minute
--      -  It's a shell script which checks to see if Iguana is running and then starts
--         it if it is not.  Aren't shell scripts cryptic!
--
--   author:
--     Eliot Muir
--
-- **********************************************************************

local start = {}

local icm_utils = require 'icm-utils'

local StartScript=[=[
#!/bin/bash
# WARNING - this file was autogenerated by the Iguana Configuration Management Utility
# This should be in the crontab (i.e. crontab -e)
# */5 * * * * #ROOT#iguana_start.sh
PATH=$PATH:/sbin:/bin
pidof iguana > /dev/null
if [[ $? -ne 0 ]]; then
  #RUN_COMMAND#
fi
]=]

function start.createScript(Version)
   local Dir = icm_utils.applicationVersion(Version)
   local RootDir = icm_utils.root()
   local Content = StartScript
   Content = Content:gsub("#ROOT#", dir.root())
   local Command = "cd "..Dir.." && ./iguana_service"
   trace(Command)
   Content = Content:gsub("#RUN_COMMAND#", Command)
   trace(Content)
   if not iguana.isTest() then
      local F = io.open(RootDir.."iguana_start.sh", "w")
      F:write(Content)
      F:close()
      os.fs.chmod(RootDir.."iguana_start.sh", 700)
   end
end

return start