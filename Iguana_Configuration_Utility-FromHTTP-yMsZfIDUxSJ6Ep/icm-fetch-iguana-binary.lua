-- **********************************************************************
--
--   Iguana Configuration Management Utility:
--   ---------------------------------------- 
--
--   icm-fetch-iguana-binary.lua
--
--   description:
--      - This routine will fetch a 64 bit linux tarball using Curl 
--        and uncompress and untar it on the fly into an versioned 
--        application directory.   Once that is done it can then be 
--        used to restart Iguana to run off this version.
--
--   author:
--     Eliot Muir
--
-- **********************************************************************

local icm_utils = require 'icm-utils'
local display = require 'icm-installation-status'
local hdf = require 'icm-create-iguana-hdf-file'

require 'net.http.getCached'

local function DownloadPath(Version)
   local Path = 'http://dl.interfaceware.com/iguana/'
   if icm_utils.isWindows() then
      Path = Path.."windows"
   else
      Path = Path.."linux"
   end
   Path = Path ..'/'..Version..'/iguana_'
   if icm_utils.isWindows() then
      Path = Path..'noinstaller_'..Version.."_windows_x"
      if icm_utils.is64Bit() then 
         Path = Path..'64.zip'
      else
         Path = Path..'86.zip'
      end
   else
      if  icm_utils.isUbuntu() then
         Path = Path..Version..'_linux_ubuntu1204_x'
      else 
         Path = Path..Version..'_linux_centos5_x'
      end
      
      if icm_utils.is64Bit() then 
         Path = Path..'64.tar.gz'
      else
         Path = Path..'86.tar.gz'
      end
   end
   return Path  
end

local function DownloadTarball(Url, Version)
   local filename = Url:match("([^/]+)$")
   local Command = "curl -o '" .. icm_utils.releases() .. filename .. "' " .. Url
   trace(Command)
   if not iguana.isTest() then 
      os.execute(Command)
   end
end

function os.executeAndCapture(cmd)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  return s
end

local function VerifyTarball(Url, Version)
   local filename = Url:match("([^/]+)$")
   local Command = "tar -ztvf ".. icm_utils.releases() .. filename
   trace(Command)
   if not iguana.isTest() then 
      local result = os.executeAndCapture("tar -ztvf '".. icm_utils.releases() .. filename .. "' 2>&1")
      local s, e = string.find(result, "Error")
      if s ~= nil and s ~= '' then
         os.fs.deleteDir{dir=icm_utils.applicationVersion(Version)}
         error("problem with downloaded Iguana binary...")
      end
      trace(result)
   end
end

local function UnpackTarball(Url, Version)
   local filename = Url:match("([^/]+)$")
   local Command = "tar -zxf '" .. icm_utils.releases() .. filename .. "' --strip-components=1 -C " .. icm_utils.applicationVersion(Version)
   trace(Command)
   if not iguana.isTest() then 
      os.execute(Command)
      os.remove(icm_utils.releases() .. filename)
   end
end

local function DownloadAndUnpackTarball(Url, Version)
   local Command = "curl "..Url.." | tar -zx --strip-components=1 -C "..icm_utils.applicationVersion(Version)
   trace(Command)
   if not iguana.isTest() then 
      os.execute(Command)
   end
end

local function UnpackDir(T,Dir)
   if os.fs.stat(Dir) == nil then
      os.fs.mkdir(Dir)
   end
   for K in pairs(T) do
      trace(K)
      if type(T[K]) == 'table' then
         UnpackDir(T[K], Dir..'/'..K)
      else
         local F=io.open(Dir..'/'..K, "wb")
         F:write(T[K])
         F:close()
      end
   end
end

local function DownloadZip(Url, Version)
   local Dir = icm_utils.releases()
   local D = net.http.getCached{url=Url,timeout=400}
   local filename = Url:match( "([^/]+)$" )
   local F=io.open(Dir.."/"..filename, "wb")
   F:write(D)
   F:close()   
end

local function UnpackZip(Url, Version)
   local Dir = icm_utils.releases()
   local filename = Url:match( "([^/]+)$" )
   local F = io.open(Dir.."/"..filename, "rb")
   local D = F:read("*all")
   F:close()
   if not iguana.isTest() then
      local T = filter.zip.inflate(D)
      UnpackDir(T['iNTERFACEWARE-Iguana'], icm_utils.applicationVersion(Version))
   end
end

local function processWindowsIguanaBinary(Url, Version)
   local Dir = icm_utils.applicationVersion(Version)
   local D = net.http.getCached{url=Url,timeout=400}
   if not iguana.isTest() then
      T = filter.zip.inflate(D)
      UnpackDir(T['iNTERFACEWARE-Iguana'], Dir)
   end  
end

local function processLinuxIguanaBinary(Url, Version)
   DownloadTarball(Url, Version)
   VerifyTarball(Url, Version)
   UnpackTarball(Url, Version)
end

function icm_fetch_iguana_binary(R,A)
   t={}
   if not iguana.isTest() then
      local Version = icm_utils.versionString(R.params.version)
      icm_utils.create(icm_utils.root())
      icm_utils.create(icm_utils.application())
      icm_utils.create(icm_utils.releases())
      icm_utils.create(icm_utils.applicationVersion(Version))
      local Url = DownloadPath(Version)
      if icm_utils.isWindows() then
         local success, T = pcall(processWindowsIguanaBinary, Url, Version)
         if success then
            hdf.create(Version)
            hdf.changeVerson(Version)
            t = { 
               ["status"]="ok" 
            }       
         else 
            local appDir = icm_utils.applicationVersion(Version);
            os.fs.deleteDir{dir=appDir}
            t = { 
              ["status"] = "error",
              ["windows"] = "yes",
              ["dashboard_url"] = icm_utils.dashboardUrl(R),
              ["message"] = "error handling Iguana Windows Distribution binary - " .. T
            }   
         end
      else 
         local success, T = pcall(processLinuxIguanaBinary, Url, Version)
         if success then
            hdf.create(Version)
            hdf.changeVerson(Version)
            t = { 
               ["status"]="ok" 
            }       
         else 
            local appDir = icm_utils.applicationVersion(Version);
            os.fs.deleteDir{dir=appDir}
            t = { 
              ["status"]="error",
              ["dashboard_url"]= icm_utils.dashboardUrl(R),
              ["message"] = "error handling Iguana Linux Distribution binary - " .. T
            }      
         end      
      end
   end
  return t
end
