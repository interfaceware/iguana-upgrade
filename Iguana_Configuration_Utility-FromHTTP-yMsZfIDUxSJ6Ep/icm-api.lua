-- **********************************************************************
--
--   Iguana Configuration Management Utility:
--   ---------------------------------------- 
--
--   icm-api.lua
--
--   description:
--     - handle ajax requests / JSON respones
--
--   author:
--     Scott C. Ripley
--
-- **********************************************************************


require 'iguana.info'

require 'icm-delete-iguana-binary'
require 'icm-fetch-iguana-binary'
require 'icm-iguana-restart'

require 'mils-license'
require 'mils-license-utils'

require 'net.http.cache'

local display = require 'icm-installation-status'
local icm_utils = require 'icm-utils'

function api(R,A)   

   local Version = R.params.version
   
   if R.params.action == "icm-installation-status" then      
      return display.api_status(R,A)    
   elseif R.params.action == "activate-login" then      
      t = { 
            ["dashboard_url"]= icm_utils.dashboardUrl(R),
            ["dversion"] = icm_utils.versionDotString(Version),
            ["version"] = icm_utils.versionString(Version)
         }      
      return t      
   elseif R.params.action == "mils-login" then   
      t = { 
            ["dashboard_url"]= icm_utils.dashboardUrl(R),
            ["dversion"] = icm_utils.versionDotString(Version),
            ["version"] = icm_utils.versionString(Version)
         }      
      return t
   elseif R.params.action == "mils-license" then   
      return mils_license(R,A)      
   elseif R.params.action == "restart-login" then   
      t = { 
            ["dashboard_url"]= icm_utils.dashboardUrl(R),
            ["dversion"] = icm_utils.versionDotString(Version),
            ["version"] = icm_utils.versionString(Version)
         }      
      return t  
   elseif R.params.action == "icm-iguana-restart" then         
      return icm_iguana_restart(R,A)      
   elseif R.params.action == "icm-fetch-iguana-binary" then 
      return icm_fetch_iguana_binary(R,A)      
   elseif R.params.action == "icm-delete-iguana-binary" then 
      return icm_delete_iguana_binary(R, A)
   end

end