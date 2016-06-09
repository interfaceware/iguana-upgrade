local display = {}

require 'net.http.cache'
require 'html_templates'
require 'iguana.info'
require 'expiry'

local html_templates = require('html_templates')
-- This displays the main screen of the configuration management utility.

local dir = require 'dir'

local PlatformInfo = iguana.info()

local ErrorMessage=[[
<h3>Sorry, your OS is not supported with this utility.</h3>
<p>
Only Windows and Linux are supported unless you'd like to be brave and port it. 
<p>
The OS X DMG installer with Iguana 6 is really good though in terms of making
it easy to upgrade so unlikely to be worth the effort - just use the standard OS X DMG installer
from our website.
</p>
]]

local NoInternetlMessage=[[
<h3>An external internet connection is required for this utility.</h3>
<p>
please ensure internet access and and try again...
</p>
]]

local NoCurlMessage=[[
<h3>the system utility "Curl" is required (installed and in the path) for this utility.</h3>
<p>
please install Curl and and try again...
</p>
]]

local IndividualTrialMessage=[[
<h3>It appears your Iguana instance is running on a trial license</h3>
<ul>
  <li>Please contact your account representative, or contact: <a href="mailto:support@interfaceware.com">support@interfaceware.com</a></li>
</ul>
]]

local ExpiryMessage=[[
<h3>Sorry, this utility is not available to you at the moment:</h3>
<p>
Your maintenance plan has expired.
</p>
<ul>
  <li>Please contact your account representative, or contact: <a href="mailto:support@interfaceware.com">support@interfaceware.com</a></li>
  <li><a href="getmilspassword?version=6.0.4">Update</a> your registration details</li>
</ul>
]]

local NotActivated=[[
<h3>Sorry, this utility is not available to you at the moment:</h3>
<p>
Your Iguana instance needs to be registered in the iNTERFACEWARE Members Account.
</p>
<ul>
  <li>Register your Iguana instance at <a href="http://my.interfaceware.com" target="_blank">my.interfaceware.com</a></li>
</ul>
<p>
Please contact your account representative if you require further assistance.
</p>
]]


function display.status(R, A)
   local Url
   if iguana.webInfo().https_channel_server.use_https == true then   
      Url = "https://" ..R.headers.Host .. "/"
   else 
      Url = "http://" ..R.headers.Host .. "/"
   end
   Url = Url
   local X = xml.parse{data=iguana.channelConfig{guid=iguana.channelGuid()}}
   Url = Url..X.channel.from_http.mapper_url_path
   trace(Url)
   net.http.respond{body="See status", code=301,  headers={Location=Url}}
end

function display.main(R, A)

   -- check for valid platform...
   if (not ((PlatformInfo.os == 'windows' and PlatformInfo.cpu == '64bit') or
            (PlatformInfo.os == 'windows' and PlatformInfo.cpu == '32bit') or
            (PlatformInfo.os == 'linux' and PlatformInfo.cpu == '64bit') or
            (PlatformInfo.os == 'linux' and PlatformInfo.cpu == '32bit'))) then
      net.http.respond{body=html_templates.Header .. ErrorMessage .. html_templates.Footer(R)}
      return
   end
      
   -- check for internet access...
   local Success, ErrorMessage = pcall(net.http.get, {url="http://dl.interfaceware.com", cache_time=0, live=true})
   if not Success then
      net.http.respond{body=html_templates.Header.. NoInternetlMessage..html_templates.Footer(R)}
      return
   end
   
   -- check for curl
   if(PlatformInfo.os ~= 'windows') then
      local curlPresent = io.popen("curl --version")
      curlPresent:flush()
      local curlStatus = curlPresent:read()      
      curlPresent:close()      
      if not curlStatus:find("curl") then
         net.http.respond{body=html_templates.Header..NoCurlMessage..":"..curlStatus..html_templates.Footer(R)}
         return
      end
   end
        
   -- check for trial Iguana ID / license...
   if CheckIndividual(iguana.id()) == true then
      net.http.respond{body=html_templates.Header..IndividualTrialMessage..html_templates.Footer(R)}
      return
   end
   
   -- check for company Iguana ID with expired maintenance...  test with IguanaID=N7HVNMDTBMUW976T
   local MaintenanceCurrent, Expiry, MaintenanceExpiry = CheckExpiry(iguana.id())
   trace(MaintenanceExpiry)
   
   if(MaintenanceExpiry == '') then
      net.http.respond{body=html_templates.Header..NotActivated..html_templates.Footer(R)}
      return      
   end
   
   if CheckExpiry(iguana.id()) ~= true then
      net.http.respond{body=html_tempaltes.Header..ExpiryMessage..html_templates.Footer(R)}
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
      for K,V in os.fs.glob(dir.releases()..'*') do
         K = K:sub(#dir.releases()+1):gsub("%_", ".")
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
   
   local B = "<table>"
   B = B.. "<tr><th>Version</th><th>Current</th><th>Downloaded</th><th>Remove</th><th>Activate</th><th>License Expiry</th><th>Maintenance Expiry</th></tr>"
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
         --B = B.."<a href='fetch?version="..Version.."'>No</a>"
         B = B.."<div id='loading-"..Version.."'><a href='#' onClick='fetch(\""..Version.."\")'>No</a></div>"
      end
      B = B .. "</td><td>"
      if E.downloaded and not E.current then
         B = B.."<a href='delete?version="..Version.."'>Delete?</a>"
      end
      B = B .. "</td><td>"
      if not E.current and E.downloaded then
         if dir.isWindows() then
            B = B.."<a href='getadminpassword?version="..dir.versionString(Version).."'>Activate?</a>"
         else   
            B = B.."<a href='activate?version="..dir.versionString(Version).."'>Activate?</a>"
         end
      end
      B = B .. "</td><td>"
      if E.current then      
          B = B..Expiry
      end
      B = B .. "</td><td>"
      if E.current then      
         B = B..MaintenanceExpiry .. " (<a href='getmilspassword?version="..Version.."''>Update</a>)"
      end
       B = B..'</td></tr>\n'
   end
   B = B..'</table>\n'

   local body = html_templates.mustache_main_template
   body = body:gsub("##DYNAMIC_PAGE_CONTENT##", B)   
   net.http.respond{body=body}   
end

return display
