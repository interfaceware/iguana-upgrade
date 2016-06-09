local icm_utils = require 'icm-utils'

-- We need to over-write the iguana_service.hdf file
-- This file is loaded by iguana_service program which uses it to know how to 
-- invoke the core iguana executable as a daemon or service.
-- The key change we have to have is to put in the iguana.workingDir() rather
-- than defaulting to the same working directory as the iguana application files
-- are in.

local hdf = {}

local HdfScript=[[
application{
   service_kill_timeout = 500000
   service_display_name=iNTERFACEWARE Iguana
   service_name=Iguana
   service_description=Integration Engine
   command_line=iguana --working_dir "#WORKING_DIR"
   command_line_unix=./iguana --working_dir #WORKING_DIR
   path_registry_entry_win32 = SYSTEM\CurrentControlSet\Control\Session Manager\Environment
}
]]

function hdf.create(Version)
   local C = HdfScript:gsub("#WORKING_DIR", iguana.workingDir())
   trace(C)
   local HdfFileName = icm_utils.applicationVersion(Version)..'iguana_service.hdf'
   trace(HdfFileName)
   if not iguana.isTest() then
      local F=io.open(HdfFileName, "w")
      F:write(C)
      F:close()
   end
end

local ChangeVersion=[[
net stop iguana
iguana_service --install
net start iguana
]]

function hdf.changeVerson(Version)
   local FileName = icm_utils.applicationVersion(Version)..'changeversion.bat'
   trace(FileName)
   if not iguana.isTest() then
      local F=io.open(FileName, "w")
      F:write(ChangeVersion)
      F:close()
   end
end

return hdf
