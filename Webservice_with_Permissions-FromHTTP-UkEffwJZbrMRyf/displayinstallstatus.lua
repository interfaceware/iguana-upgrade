local display = {}

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
Iguana instance to a newer or older version of Iguana.  Only Iguana 6 on
64 bit Linux is supported as of now.
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

function display.status(R, A)
   local Url = 'http://dl.interfaceware.com/iguana/linux/'
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
   for K,V in os.fs.glob(dir.application()..'*') do
      K = K:sub(#dir.application()+1):gsub("%_", ".")
      if not I[K] then
         I[K] = {}
      end 
      I[K].downloaded = true     
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
