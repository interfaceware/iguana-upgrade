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

local WebServer = web.webserver.create{
   default = 'www/index.html',
    --test = 'admin',
      auth = true,
   actions = { 
                ["icm-api"] = api
             }
}

function main(Data)
  WebServer:serveRequest{data=Data}            
end



