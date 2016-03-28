local display = {}

require 'iguana.info'

-- This displays the main screen of the configuration management utility.

local dir = require 'dir'

local Html=[[
<html>
<head>
<style>
body {
  font-family: Arial;
}
table {
    border-collapse: collapse;
}

table, th, td {
   border: 1px solid black;
   padding : 2px
}

tr.current{
   background-color : lightgreen;
} 

</style>
</head>
<body>
<h1>Iguana Configuration Management Utility.</h1>
<p>
This utility is intended to make it easy to upgrade and/or rollback an
Iguana instance to a newer or older version of Iguana.  Only supports
Iguana 6 on 64 bit Linux and Windows currently.  The Windows support is
fairly limited in that it's currently using a hard coded user ID "iNTERFACEWARE"
that has Admin privilleges to run a scheduled task to change the service to windows
and it requires that user to be logged in etc.  Error checking is limited.
</p>
<p>
This utility is in ALPHA.  Don't use in production system yet.
</p>
<table>
<tr><th>Version</th><th>Current</th><th>Downloaded</th><th>Remove</th><th>Activate</th></tr>
]]

local Footer=[[
</table>
<p>
Head back to the <a href="#DASHBOARD_URL">Iguana Dashboard</a>.
</p>
</body>
</html>

]]

local PlatformInfo = iguana.info()

local ErrorMessage=[[
<p>
Very sorry.  Only 64 bit Windows and Linux are supported with this utility unless you'd like to be brave and port it.  It's probably quite do-able
since the 32 bit versions of Iguana on Windows and Linux are similar to the 64 bit version.
</p>
<p>
The OS X DMG installer with Iguana 6 is really good though in terms of making
it easy to upgrade so unlikely to be worth the effort - just use the standard OS X DMG installer
from our website.
</p>
]]



function display.status(R, A)
   if PlatformInfo.os ~= 'windows' and PlatformInfo.os ~= 'linux' or PlatformInfo.cpu ~= '64bit' then
      net.http.respond{body=ErrorMessage}
      return
   end
         
   local Url
   if dir.isWindows() then
      -- TODO
      Url = 'http://dl.interfaceware.com/iguana/windows/'
   else   
      Url = 'http://dl.interfaceware.com/iguana/linux/'
   end
   local DownloadInfo = net.http.get{url=Url, live=true}
   local I =  {}
   
   for K in DownloadInfo:rxmatch('href="(6[^/]*)/"') do
      trace(K)
      K = K:gsub("%_", ".")
      if not I[K] then
         I[K] = {}
      end 
   end
   trace(I)
   -- The application dir may not have been created
   if os.fs.stat(dir.application()) then
      for K,V in os.fs.glob(dir.application()..'*') do
         K = K:sub(#dir.application()+1):gsub("%_", ".")
         if not I[K] then
            I[K] = {}
         end 
         I[K].downloaded = true     
      end
   end
   trace(I)
   local C = dir.currentVersion()
   if not I[C] then
      I[C] = {}
   end
   I[C].current = true
   
   local Keys = {}
   for K in pairs(I) do
      Keys[#Keys+1] = K
   end
   table.sort(Keys)
   trace(Keys)
   
   
   local B = Html
   for i=1, #Keys do
      local Version = Keys[i]
      local E = I[Version]
      if E.current then
         B = B .. '<tr class="current">'
      else
         B = B .. '<tr>' 
      end
      
      B = B ..'<td>'..Keys[i]..'</td><td>'
      if E.current then
         B = B.."Yes"
      else
	      B = B.."-"
      end
      B = B .. "</td><td>"
      if E.downloaded then 
         B = B.."Yes"
      else
         B = B.."<a href='fetch?version="..Version.."'>No</a>"
      end
      B = B .. "</td><td>"
      if E.downloaded and not E.current then
         B = B.."<a href='delete?version="..Version.."'>Delete?</a>"
      end
      B = B .. "</td><td>"
      if not E.current and E.downloaded then
         B = B.."<a href='activate?version="..Version.."'>Activate?</a>"
      end
      B = B..'</td></tr>\n'
   end
   B = B .. Footer:gsub("#DASHBOARD_URL", dir.dashboardUrl(R))
   
   net.http.respond{body=B}   
end

return display
