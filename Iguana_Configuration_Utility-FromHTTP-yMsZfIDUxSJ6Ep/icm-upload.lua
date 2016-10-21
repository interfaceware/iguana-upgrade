-- **********************************************************************
--
--   Iguana Configuration Management Utility:
--   ---------------------------------------- 
--
--   icm-upload.lua
--
--   description:
--      - faciliate manual upload of Iguana... (in case behind firewall, etc.)
--
--   author:
--     Scott C. Ripley
--
-- **********************************************************************

local icm_utils = require 'icm-utils'
local hdf = require 'icm-create-iguana-hdf-file'

local function processWindowsIguanaBinary(payload, iguanaVersion, iguanaFilename)

   local Version = icm_utils.versionString(iguanaVersion)
   
   icm_utils.create(icm_utils.application())
   icm_utils.create(icm_utils.releases())
   icm_utils.create(icm_utils.applicationVersion(Version))   
   
   Dir = icm_utils.applicationVersion(iguanaVersion)
   T = filter.zip.inflate(payload)
   icm_utils.UnpackDir(T['iNTERFACEWARE-Iguana'], Dir)
   hdf.create(iguanaVersion)
   hdf.changeVerson(iguanaVersion)
   
end

local function processLinuxIguanaBinary(payload, iguanaVersion, iguanaFilename)

   local Version = icm_utils.versionString(iguanaVersion)
   
   icm_utils.create(icm_utils.application())
   icm_utils.create(icm_utils.releases())
   icm_utils.create(icm_utils.applicationVersion(Version))      
   
   -- save uploaded binary...
   local F = io.open(icm_utils.releases() .. iguanaFilename, "wb")
   F:write(payload)
   F:close()                

   -- check uploaded binary...
   local result = os.executeAndCapture("tar -ztvf '".. icm_utils.releases() .. iguanaFilename .. "' 2>&1")
   local s, e = string.find(result, "Error")
   if s ~= nil and s ~= '' then
      os.remove(icm_utils.releases() .. iguanaFilename)
      error(result)
   end

   -- extract uploaded binary...
   local Command = "tar -zxf '" .. icm_utils.releases() .. iguanaFilename .. "' --strip-components=1 -C " .. icm_utils.applicationVersion(Version)
   os.execute(Command) 
   os.remove(icm_utils.releases() .. iguanaFilename)
   hdf.create(iguanaVersion)
   hdf.changeVerson(iguanaVersion)            
   
end



function upload(R,A)  

   local T = nil
   
   local boundary = string.match(R.headers["Content-Type"], ";%s+boundary=(%S+)")
   local s = R.body:find("\r\n\r\n", 0, plain)+4   
   local e = R.body:find("--"..boundary, string.len("--"..boundary), plain)-3   
   local payload = R.body:sub(s, e)
   
   local headers = string.lower(R.body:sub(0,s-1))
   
   local iguanaVersion
   if icm_utils.isWindows() then
      iguanaVersion = headers:match("content%-disposition: form%-data; name=\"filename\"; filename=\"iguana_noinstaller_([%w_]+)_windows_x%d%d.zip\"")
   elseif icm_utils.isLinux() then
      if headers:find("ubuntu") ~= nil then
         if headers:find("ubuntu") > 0 then
            iguanaVersion = headers:match("content%-disposition: form%-data; name=\"filename\"; filename=\"iguana_([%w_]+)_linux_ubuntu1204_x%d%d.tar.gz\"")
         end
      elseif headers:find("centos") ~= nil then
         if headers:find("centos") > 0 then
            iguanaVersion = headers:match("content%-disposition: form%-data; name=\"filename\"; filename=\"iguana_([%w_]+)_linux_centos5_x%d%d.tar.gz\"")
         end
      end      
   end
   
   local iguanaFilename = headers:match("content%-disposition: form%-data; name=\"filename\"; filename=\"([%w_.]+)\"")  
      
   if(iguanaFilename == nil) then
      t = { 
         ["status"]="error",
         ["message"] = "please select a valid Iguana binary distribution..."
      }             
      return t  
   elseif icm_utils.isWindows() and icm_utils.is64Bit() and not iguanaFilename:match("^iguana_noinstaller_6_[0-9]+_[0-9]+_windows_x64.zip") then
      t = { 
         ["status"]="error",
         ["message"] = "please select a valid Iguana binary distribution... (i.e. iguana_noinstaller_6_%5B0-9%5D%2B_%5B0-9%5D%2B_windows_x64.zip)"
      } 
      return t
   elseif icm_utils.isWindows() and icm_utils.is32Bit() and not iguanaFilename:match("^iguana_noinstaller_6_[0-9]+_[0-9]+_windows_x86.zip") then
      t = { 
         ["status"]="error",
         ["message"] = "please select a valid Iguana binary distribution... (i.e. iguana_noinstaller_6_%5B0-9%5D%2B_%5B0-9%5D%2B_windows_x86.zip)"
      } 
      return t      
   elseif icm_utils.isLinux() and icm_utils.is64Bit() and icm_utils.isCentos() and not iguanaFilename:match("^iguana_6_[0-9]+_[0-9]+_linux_centos5_x64.tar.gz") then
       t = { 
         ["status"]="error",
         ["message"] = "please select a valid Iguana binary distribution... (i.e. iguana_6_%5B0-9%5D%2B_%5B0-9%5D%2B_linux_centos5_x64.tar.gz)"
            
      }    
      return t
   elseif icm_utils.isLinux() and icm_utils.is32Bit() and icm_utils.isCentos() and not iguanaFilename:match("^iguana_6_[0-9]+_[0-9]+_linux_centos5_x86.tar.gz") then
       t = { 
         ["status"]="error",
         ["message"] = "please select a valid Iguana binary distribution... (i.e. iguana_6_%5B0-9%5D%2B_%5B0-9%5D%2B_linux_centos5_x86.tar.gz)"
            
      }    
      return t            
   elseif icm_utils.isLinux() and icm_utils.is64Bit() and icm_utils.isUbuntu() and not iguanaFilename:match("^iguana_6_[0-9]+_[0-9]+_linux_ubuntu1204_x64.tar.gz") then
       t = { 
         ["status"]="error",
         ["message"] = "please select a valid Iguana binary distribution... (i.e. iguana_6_%5B0-9%5D%2B_%5B0-9%5D%2B_linux_ubuntu1204_x64.tar.gz)"
            
      }    
      return t      
   elseif icm_utils.isLinux() and icm_utils.is32Bit() and icm_utils.isUbuntu() and not iguanaFilename:match("^iguana_6_[0-9]+_[0-9]+_linux_ubuntu1204_x86.tar.gz") then
       t = { 
         ["status"]="error",
         ["message"] = "please select a valid Iguana binary distribution... (i.e. iguana_6_%5B0-9%5D%2B_%5B0-9%5D%2B_linux_ubuntu1204_x86.tar.gz)"
            
      }    
      return t                        
   elseif iguanaVersion == icm_utils.versionString(icm_utils.currentVersion()) then
      t = { 
         ["status"] = "error",
         ["message"] = "please select an Iguana binary distribution that is different from the one currently running..."
      }
      return t
   end
          
   if icm_utils.isWindows() then
      t = { ["status"]="success" }  
      if not iguana.isTest() then        
         local Success, M = pcall(processWindowsIguanaBinary, payload, iguanaVersion, iguanaFilename)
         if not Success then
            local Version = icm_utils.versionString(iguanaVersion)             
            local appDir = icm_utils.applicationVersion(Version);
            os.fs.deleteDir{dir=appDir}    
            t = { ["status"] = "error", 
                  ["message"] = "error handling Iguana Windows Distribution binary - " .. M
               }
         end
      end      
   elseif icm_utils.isLinux() then
      t = { ["status"]="success" }  
      if not iguana.isTest() then        
         local Success, M = pcall(processLinuxIguanaBinary, payload, iguanaVersion, iguanaFilename)       
         if not Success then
            local Version = icm_utils.versionString(iguanaVersion)             
            local appDir = icm_utils.applicationVersion(Version);
            os.fs.deleteDir{dir=appDir}    
            t = { ["status"] = "error", 
                  ["message"] = "error handling Iguana Linux Distribution binary - " .. M
               }
         end
      end
   end
   
   return t;
   
end
