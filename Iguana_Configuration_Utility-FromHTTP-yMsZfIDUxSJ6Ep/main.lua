-- **********************************************************************
--
--   Iguana Configuration Management Utility:
--   ---------------------------------------- 
--
--   main.lua
--
--   description:
--      - a utility to allow easy upgrade/rollback of iguana instances.
--      - only supports Linux and Windows
--      - only with Iguana 6.0 onwards
--      - a user with admin privileges (Iguana and OS) is required
--        to use this application.
--   See http://help.interfaceware.com/v6/iguana-configuration-utility
--
--   authors:
--      Eliot Muir and Scott Ripley
--
-- **********************************************************************

global_config = require 'icm-config'

require 'icm-api'

require 'icm-webserver'
require 'icm-upload'

local icm_utils = require 'icm-utils'
local installMonitorScript = require 'icm-create-linux-monitor-script'
local installRestartScript = require 'icm-create-linux-restart-script'
local installCronScript = require 'icm-install-linux-cron'

function init()
   if icm_utils.isLinux() then
      local Version = icm_utils.versionString(icm_utils.currentVersion())
      installMonitorScript.createScript(Version)
      installRestartScript.createScript(Version)
      installCronScript.install()
   end      
end   

local init =  init()   

local WebServer = web.webserver.create{
   default = 'www/index.html',
   --test = 'admin',
   auth = true,
   actions = { 
                ["icm-api"] = api,
                ["icm-upload"] = upload
             }
}

function main(Data)
   iguana.stopOnError(false)
   WebServer:serveRequest{data=Data}            

end
