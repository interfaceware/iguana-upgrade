require 'icm-delete-iguana-binary'
require 'icm-fetch-iguana-binary'
require 'icm-iguana-restart'
require 'iguana.info'
require 'mils-license'
require 'mils-license-utils'
require 'net.http.cache'

local display = require 'icm-installation-status'
local icm_utils = require 'icm-utils'

function Api(R,A)   

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
      return api_License(R,A)      
   elseif R.params.action == "restart-login" then   
      t = { 
            ["dashboard_url"]= icm_utils.dashboardUrl(R),
            ["dversion"] = icm_utils.versionDotString(Version),
            ["version"] = icm_utils.versionString(Version)
         }      
      return t  
   elseif R.params.action == "icm-iguana-restart" then         
      return Restart(R,A)      
   elseif R.params.action == "fetch-iguana-binary" then 
      Fetch(R,A)      
   elseif R.params.action == "delete-iguana-binary" then 
      Delete(R, A)
   end

end