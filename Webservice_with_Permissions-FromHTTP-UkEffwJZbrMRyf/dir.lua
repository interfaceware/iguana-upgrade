local dir = {}

-- Common directory routines that say where things are located.  We should be running under the
-- home directory of the Iguana user we are using.

local RootDir = os.getenv('HOME')..'/'

function dir.root()
   return RootDir
end

function dir.application()
   return RootDir..'iguana_app/'
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
