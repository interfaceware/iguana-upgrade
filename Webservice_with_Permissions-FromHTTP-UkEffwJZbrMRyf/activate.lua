local start   = require 'createstartscript'
local install = require 'installcron'
local display = require 'displayinstallstatus'

local dir = require 'dir'

-- This call will:
-- 1) Recreate the start script so that it points to the Iguana version we are switching to
-- 2) Make sure the start script is registered with the cron for the user
-- 3) Kill Iguana
-- Hopefully after that the cron job which runs the start script will restart Iguana with the new version otherwise
-- you will need to login into the machine to fix it.

local RebootScreen=[[
<p>
This Iguana is being shutdown.  In about a minute the new version should be started. 
</p>
<p>
Go to <a href='#URL'>#URL</a>
</p>
]]

function Activate(R,A)
   local Version = dir.versionString(R.params.version)
   if dir.currentVersion() == Version:gsub("%_", ".") then
      return display.status(R,A)
      --error("This is the current version!")     
   end
   local AppDir = dir.applicationVersion(Version)
   
   if not os.fs.stat(AppDir) then
      return DisplayInstallStatus(R,A)
      --error("This version is not installed.")
   end
   -- We could do more checks for the validity of the install
   -- we are changing over to.
   start.createScript(Version)
   install.cron()
   net.http.respond{body=RebootScreen:gsub("#URL", dir.dashboardUrl(R))}
   
   if not iguana.isTest() then
      -- this does a graceful shut down.  The cron job should restart Iguana
      os.execute("killall iguana_service")
   end   
end
