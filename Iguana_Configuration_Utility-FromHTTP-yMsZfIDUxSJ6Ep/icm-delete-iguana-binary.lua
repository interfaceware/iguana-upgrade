-- **********************************************************************
--
--   Iguana Configuration Management Utility:
--   ---------------------------------------- 
--
--   icm-delete-iguana-binary.lua
--
--   description:
--      - This routine deletes the application directory unpacked from 
--        the iguana distribution for a particular version
--      - It tries to be smart about not deleting the running instance!
--
--   author:
--     Eliot Muir
--
-- **********************************************************************

local icm_utils = require 'icm-utils'
local display = require 'icm-installation-status'

os.fs.deleteDir = require 'os.fs.deleteDir'

function icm_delete_iguana_binary(R, A)
   local Version = icm_utils.versionString(R.params.version)
   if icm_utils.currentVersion() == Version:gsub("%_", ".") then
      return display.status(R,A)   
   end
   
   local appDir = icm_utils.applicationVersion(Version)
   
   if not os.fs.stat(appDir) then
      return { ["status"]="ok" }
   end

   local success, T = pcall(os.fs.deleteDir, { dir = appDir })
   if success then
      t = { 
         ["status"]="ok" 
      }       
   else 
      t = { 
         ["status"]="error",
         ["dashboard_url"]= icm_utils.dashboardUrl(R),
         ["message"] = "error removing directory ("..appDir..") - " .. T
      }      
   end    
   return t
end
