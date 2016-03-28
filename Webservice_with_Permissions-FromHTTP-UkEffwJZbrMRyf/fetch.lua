local dir = require 'dir'
local display = require 'displayinstallstatus'
local hdf = require 'createhdffile'

require 'net.http.getCached'

-- This routine will fetch a 64 bit linux tarball using Curl and uncompress and untar it on the fly
-- into an versioned application directory.  Once that is done it can then be used to restart Iguana
-- to run off this version.

local function DownloadPath(Version)
   local Path = 'http://dl.interfaceware.com/iguana/'
   if dir.isWindows() then
      Path = Path.."windows"
   else
      Path = Path.."linux"
   end
   Path = Path ..'/'..Version..'/iguana_'
   if dir.isWindows() then
      Path = Path..'noinstaller_'..Version.."_windows_x"
      if dir.is64Bit() then 
         Path = Path..'64.zip'
      else
         Path = Path..'86.zip'
      end
   else
      -- TODO only 64 bit linux supported.
      Path = Path..Version..'_linux_centos5_x64.tar.gz'
   end
   return Path  
end

local function DownloadAndUnpackTarball(Url, Version)
   -- I use curl to download the tar ball and expand it on the fly using a pipe.  
   local Command = "curl "..Url.." | tar -zx --strip-components=1 -C "..dir.applicationVersion(Version)
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
         --write file
         local F=io.open(Dir..'/'..K, "wb")
         F:write(T[K])
         F:close()
      end
   end
end

local function DownloadAndUnpackZip(Url, Version)
   local Dir = dir.applicationVersion(Version)
   local D = net.http.getCached{url=Url,timeout=400}
   if not iguana.isTest() then
      local T = filter.zip.inflate(D)
      UnpackDir(T['iNTERFACEWARE-Iguana'], Dir)
   end
end

function Fetch(R,A)
   local Version = dir.versionString(R.params.version)
   dir.create(dir.root())
   dir.create(dir.application())
   dir.create(dir.applicationVersion(Version))
   local Url = DownloadPath(Version)
   if dir.isWindows() then
      DownloadAndUnpackZip(Url, Version)
   else 
      DownloadAndUnpackTarball(Url, Version)   
   end
   hdf.create(Version)
   hdf.changeVerson(Version)
   -- Old skool HTTP refresh.
   display.status(R,A)
end



