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

local install = {}

-- This routine alters the crontab for the user we are running Iguana to run the iguana_start.sh script each minute.
-- It get's invoked by the activate routine.

local icm_utils = require 'icm-utils'
local cron = require 'cron.edit'

local CronLine =  '*/1 * * * * '..icm_utils.root()..'iguana_start.sh  # Start Iguana if not started'

function install.cron()
   local OldCron = cron.read()
   local Lines = OldCron:split("\n")
   for i=1,#Lines do
      if Lines[i] == CronLine then
         return "Crontab is already installed."
      end
      if Lines[i]:find("iguana_start.sh") then
         Lines[i] = ''
      end
   end
   trace(Lines)
   Lines[#Lines+1] = CronLine
   local NewCron = table.concat(Lines, '\n')
   NewCron = NewCron:gsub("\n\n", "").."\n"
   trace(NewCron)
   cron.write(NewCron)
   return "Installed Crontab"
end

return install