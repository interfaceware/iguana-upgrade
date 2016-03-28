local dir = {}

-- Common  routines that say where things are located, OS type etc.  We should be running under the
-- home directory of the Iguana user we are using in Linux.

function dir.isWindows()
   if os.getenv('SYSTEMROOT') and os.getenv('SYSTEMROOT'):find('Windows') then
      return true
   end
   return false
end

function dir.is64Bit()
   if dir.isWindows() then
      if os.getenv('PROCESSOR_ARCHITECTURE') and 
         os.getenv('PROCESSOR_ARCHITECTURE'):find('64') then
         return true
      else 
         -- could be wrong!
         return false
      end
   else
      -- TODO for now assume all linux is 64 bit
      return true
   end
end

function dir.root()
   if dir.isWindows() then
      return os.getenv('ProgramFiles')..'/iNTERFACEWARE/Manager/'
   end
   return os.getenv('HOME')..'/'
end

function dir.application()
   return dir.root()..'Iguana/'
end

function dir.applicationVersion(Version)
   return dir.application() .. Version..'/'
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
   return "http://"..
       R.headers.Host:gsub(iguana.webInfo().https_channel_server.port, 
         iguana.webInfo().web_config.port)..'/'
end

return dir
