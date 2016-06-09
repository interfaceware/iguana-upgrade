local dir = {}

require 'iguana.info'

local Info = iguana.info()

-- Common  routines that say where things are located, OS type etc.  We should be running under the
-- home directory of the Iguana user we are using in Linux.

function dir.isWindows()
   return Info.os == "windows"
end

function dir.isLinux()
   return Info.os == "linux"
end

function dir.is64Bit()
   return Info.cpu == '64bit'
end

function dir.is32Bit()
   return Info.cpu == '32bit'
end

function dir.root()
   if dir.isWindows() then
      return os.getenv('ProgramFiles')..'/iNTERFACEWARE/'      
   else 
      return os.getenv('HOME')..'/'
   end
end

function dir.application()
   if dir.isWindows() then
      return os.getenv('ProgramFiles')..'/iNTERFACEWARE/Iguana-6/'      
   else 
      return os.getenv('HOME')..'/Iguana-6/'
   end
end

function dir.releases()
   if dir.isWindows() then
      return os.getenv('ProgramFiles')..'/iNTERFACEWARE/Iguana-6/Releases/'      
   else 
      return os.getenv('HOME')..'/Iguana-6/Releases/'
   end
end

function dir.applicationVersion(Version)
   return dir.releases() .. Version..'/'
end

function dir.currentVersion()
   local T = iguana.version()
   return T.major .. "." .. T.minor.."."..T.build
end

function dir.versionString(Version)
   if not Version then
      error("Need version")
   end
   return Version:gsub("%.", "_")
end

function dir.versionDotString(Version)
   if not Version then
      error("Need version")
   end
   return Version:gsub("%_", ".")
end

function dir.create(Dir)
   local Stats = os.fs.stat(Dir)
   if Stats == nil then
      trace("Create tar ball dir")
      os.fs.mkdir(Dir, 700)
   end
   Stats = os.fs.stat(Dir)
   if not Stats.isdir then
      error(Dir.. ' is not a directory')
   end
end

function dir.dashboardUrl(R)
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

return dir
