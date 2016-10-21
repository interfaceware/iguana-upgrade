-- **********************************************************************
--
--   Iguana Configuration Management Utility:
--   ---------------------------------------- 
--
--   icm-install-linux-cron.lua
--
--   description:
--      - This routine alters the crontab for the user we are running 
--        Iguana to run the iguana_start.sh script each minute.
--        It get's invoked by the activate routine.
--
--   author:
--     Eliot Muir
--
-- **********************************************************************

local cron = {}
  
-- This routine alters the crontab for the user we are running Iguana to run the iguana_start.sh script each minute.
-- It get's invoked by the activate routine.

local icm_utils = require 'icm-utils'
local cron = require 'cron.edit'
 
function cron.install()
   local IguanaService = icm_utils.getIguanaService(iguana.appDir() .. "iguana_service.hdf")
   cron.update('*/1 * * * * '..icm_utils.root()..IguanaService..'_monitor.bash  # Start Iguana if not started') 
   cron.update('@reboot '..icm_utils.root()..IguanaService..'_restart.bash  # start iguana after reboot...')   
end

function cron.update(CronLine)
   local OldCron = cron.read()
   local Lines = OldCron:split("\n")
   for i=1,#Lines do
      if Lines[i] == CronLine then
         return "Crontab is already installed."
      end
   end
   Lines[#Lines] = CronLine .. "\n"
   local NewCron = table.concat(Lines, '\n')
   cron.write(NewCron)
   return "Installed Crontab"    
end

return cron