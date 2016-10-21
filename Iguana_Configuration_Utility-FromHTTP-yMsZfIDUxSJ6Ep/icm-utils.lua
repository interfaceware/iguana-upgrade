-- **********************************************************************
--
--   Iguana Configuration Management Utility:
--   ---------------------------------------- 
--
--   icm-install-linux-cron.lua
--
--   description:
--      - Common  routines that say where things are located, OS type etc.
--        We should be running under the  home directory of the Iguana user
--        we are using in Linux.
-- 
--   author:
--     Eliot Muir
--
-- **********************************************************************

local utils = {}

function utils.executeAndCapture(cmd)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  return s
end

function utils.getPlatform()
   if os.getenv("programfiles") ~= nil then
      return "windows"       
   end      
   local platform = utils.executeAndCapture("uname -a 2>&1")      
   if(platform:upper()):match(".*LINUX.*") ~= nil then
      return "linux"
   elseif(platform:upper()):match(".*DARWIN.*") ~= nil then
      return "osx"      
   end
end

function utils.isWindows()
   return utils.getPlatform() == "windows"
end

function utils.isLinux()
   return utils.getPlatform() == "linux"
end

function utils.is64Bit()
   if utils.isWindows() then
      if os.getenv("ProgramW6432") ~= nil then
         return true
      else       
         return false
      end
   elseif utils.isLinux() then
      local platform = utils.executeAndCapture("uname -a 2>&1")
      if(platform:upper()):match(".*X86_64*") ~= nil then
         return true;
      else 
         return false
      end         
   end
end

function utils.is32Bit()
   return not utils.is64Bit()
end

function utils.isUbuntu()
   local platform = utils.executeAndCapture("uname -a 2>&1")
   if(platform:upper()):match(".*UBUNTU*") ~= nil then
      return true;
   else 
      return false
   end
 end

function utils.isCentos()
   local platform = utils.executeAndCapture("uname -a 2>&1")
   if(platform:upper()):match(".*CENTOS*") ~= nil then
      return true;
   else 
      return false
   end
 end

function utils.getProgramFilesDirectory()
   local programFilesDirectory = os.getenv('ProgramFiles')
   programFilesDirectory = programFilesDirectory:gsub("\\", "/")   
   return programFilesDirectory
end

function utils.root()
   if utils.isWindows() then
      return utils.getProgramFilesDirectory()..'/iNTERFACEWARE/'      
   else 
      return os.getenv('HOME')..'/'
   end
end

function utils.application()
   if utils.isWindows() then
      return utils.getProgramFilesDirectory()..'/iNTERFACEWARE/'..utils.getIguanaService()..'-6/'      
   else 
      return os.getenv('HOME')..'/'..utils.getIguanaService()..'-6/'
   end
end

function utils.releases()
   trace(ProgramFilesDirectory)
   if utils.isWindows() then
      return utils.getProgramFilesDirectory()..'/iNTERFACEWARE/'..utils.getIguanaService()..'-6/Releases/'      
   else 
      return os.getenv('HOME')..'/'..utils.getIguanaService()..'-6/Releases/'
   end
end

function utils.applicationVersion(Version)
   return utils.releases() .. Version..'/'
end

function utils.currentVersion()
   local T = iguana.version()
   return T.major .. "." .. T.minor.."."..T.build
end

function utils.versionString(Version)
   if not Version then
      error("Need version")
   end
   return Version:gsub("%.", "_")
end

function utils.versionDotString(Version)
   if not Version then
      error("Need version")
   end
   return Version:gsub("%_", ".")
end

function utils.create(Dir)
   local Stats = os.fs.stat(Dir)
   if Stats == nil then
      trace("Create tar ball dir")
      os.fs.mkdir(Dir, 700)
   end
   Stats = os.fs.stat(Dir)
   if not Stats.isdir then
      error(utils.. ' is not a directory')
   end
end

function utils.dashboardUrl(R)
   if iguana.webInfo().web_config.use_https == true then
      return "https://"..
      R.headers.Host:gsub(iguana.webInfo().https_channel_server.port, 
         iguana.webInfo().web_config.port)..'/'   
   else
      return "http://"..
      R.headers.Host:gsub(iguana.webInfo().https_channel_server.port, 
         iguana.webInfo().web_config.port)..'/'
   end
end

function utils.UnpackDir(T,Dir)
   if os.fs.stat(Dir) == nil then
      os.fs.mkdir(Dir)
   end
   for K in pairs(T) do
      trace(K)
      if type(T[K]) == 'table' then
         utils.UnpackDir(T[K], Dir..'/'..K)
      else
         local F=io.open(Dir..'/'..K, "wb")
         F:write(T[K])
         F:close()
      end
   end
end

function utils.readFile(filename)
    local f = io.open(filename, "r")
    local content = f:read("*all")
    f:close()
    return content
end

function utils.getIguanaService()
   local IguanaService = utils.readFile(iguana.appDir() .. "iguana_service.hdf")
   IguanaService = string.gsub(IguanaService, ".*service_name=([^\n]*).*", "%1")   
   return IguanaService
end

function utils.fileExists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end
   
return utils