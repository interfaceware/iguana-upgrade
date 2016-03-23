local dir = require 'dir'
local display = require 'displayinstallstatus'
local hdf = require 'createhdffile'

-- This routine will fetch a 64 bit linux tarball using Curl and uncompress and untar it on the fly
-- into an versioned application directory.  Once that is done it can then be used to restart Iguana
-- to run off this version.

function Fetch(R,A)
   local Version = dir.versionString(R.params.version)
   dir.create(dir.application())
   dir.create(dir.applicationVersion(Version))

   local Path = 'http://dl.interfaceware.com/iguana/linux/'..Version..'/iguana_'..Version..'_linux_centos5_x64.tar.gz'   
   trace(Path)
   -- I use curl to download the tar ball and expand it on the fly using a pipe.  
   local Command = "curl "..Path.." | tar -zx --strip-components=1 -C "..dir.applicationVersion(Version)
   trace(Command)
   if not iguana.isTest() then 
      os.execute(Command)
   end
   hdf.create(Version)
   -- Old skool HTTP refresh.
   display.status(R,A)
end



