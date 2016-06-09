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
      --error("Not allowed to delete current version")     
   end
   local AppDir = icm_utils.applicationVersion(Version)
   
   if not os.fs.stat(AppDir) then
      return display.status(R,A)
      --error("This version is not installed.")
   end
   os.fs.deleteDir{dir=AppDir}
   --display.status(R,A)
   return { ["status"]="ok" }
end
