local dir = require 'dir'
local display = require 'displayinstallstatus'

-- This routine deletes the application directory unpacked from the iguana distribution for a particular version
-- It tries to be smart about not deleting the running instance!

function Delete(R, A)
   local Version = dir.versionString(R.params.version)
   if dir.currentVersion() == Version:gsub("%_", ".") then
      return DisplayInstallStatus(R,A)
      --error("Not allowed to delete current version")     
   end
   local AppDir = dir.applicationVersion(Version)
   
   if not os.fs.stat(AppDir) then
      return DisplayInstallStatus(R,A)
      --error("This version is not installed.")
   end
   local Command = "rm -rf "..AppDir
   trace(Command)
   if not iguana.isTest() then
      os.execute(Command)
   end
   
   display.status(R,A)
end
