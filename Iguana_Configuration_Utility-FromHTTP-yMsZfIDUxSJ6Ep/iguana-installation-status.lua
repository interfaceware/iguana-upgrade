local display = {}

require 'net.http.cache'
require 'iguana.info'
require 'mils-utils'

local user = require 'iguana.user'
local basicauth = require 'web.basicauth'

-- This displays the main screen of the configuration management utility.

local icm_utils = require 'icm-utils'

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

local NoInternetMessage=[[
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

function display.api_status(R,A)
   
   -- check for admin user
   local Auth = basicauth.getCredentials(R)
   local userInfo = user.open()
   if not userInfo:userInGroup{user=Auth.username, group='Administrators'} then      
      t = { 
        ["status"]="error",
        ["windows"]="yes",
        ["dashboard_url"]= icm_utils.dashboardUrl(R),
        ["message"] = "You need to be an Iguana administrator to use this utility."  
      }
      return t           
   end

   -- check for valid platform...
   if (not ((PlatformInfo.os == 'windows' and PlatformInfo.cpu == '64bit') or
            (PlatformInfo.os == 'windows' and PlatformInfo.cpu == '32bit') or
            (PlatformInfo.os == 'linux' and PlatformInfo.cpu == '64bit') or
            (PlatformInfo.os == 'linux' and PlatformInfo.cpu == '32bit'))) then
      --net.http.respond{body=html_templates.Header .. ErrorMessage .. html_templates.Footer(R)}
      --return
      t = { 
        ["status"]="error",
        ["windows"]="yes",
        ["dashboard_url"]= icm_utils.dashboardUrl(R),
        ["message"] = ErrorMessage   
      }
      return t           
      
   end
      
   -- check for internet access...
   local Success, ErrorMessage = pcall(net.http.get, {url="http://dl.interfaceware.com", cache_time=0, live=true})
   if not Success then
      --net.http.respond{body=html_templates.Header.. NoInternetMessage..html_templates.Footer(R)}
      --return
      t = { 
        ["status"]="error",
        ["windows"]="yes",
        ["dashboard_url"]= icm_utils.dashboardUrl(R),
        ["message"] = NoInternetMessage
      }
      return t                       
   end
   
   -- check for curl
   if(PlatformInfo.os ~= 'windows') then
      local curlPresent = io.popen("curl --version")
      curlPresent:flush()
      local curlStatus = curlPresent:read()      
      curlPresent:close()      
      if not curlStatus:find("curl") then
         --net.http.respond{body=html_templates.Header..NoCurlMessage..":"..curlStatus..html_templates.Footer(R)}
         --return
         t = { 
           ["status"]="error",
           ["windows"]="yes",
           ["dashboard_url"]= icm_utils.dashboardUrl(R),
           ["message"] = NoInternetMessage
         }
         return t             
      end
   end
        
   -- check for trial Iguana ID / license...
   if CheckIndividual(iguana.id()) == true then
      --net.http.respond{body=html_templates.Header..IndividualTrialMessage..html_templates.Footer(R)}
      --return
      t = { 
        ["status"]="error",
        ["windows"]="yes",
        ["dashboard_url"]= icm_utils.dashboardUrl(R),
        ["message"] = IndividualTrialMessage
      }
      return t          
   end
   
   -- check for company Iguana ID with expired maintenance...  test with IguanaID=N7HVNMDTBMUW976T
   local MaintenanceCurrent, Expiry, MaintenanceExpiry = CheckExpiry(iguana.id())
   trace(MaintenanceExpiry)
   
   if(MaintenanceExpiry == '') then
      --net.http.respond{body=html_templates.Header..NotActivated..html_templates.Footer(R)}
      --return      
      t = { 
        ["status"]="error",
        ["windows"]="yes",
        ["dashboard_url"]= icm_utils.dashboardUrl(R),
        ["message"] = NotActivated
      }
      return t           
   end
   
   if CheckExpiry(iguana.id()) ~= true then
      --net.http.respond{body=html_templates.Header..ExpiryMessage..html_templates.Footer(R)}
      --return
      t = { 
        ["status"]="error",
        ["windows"]="yes",
        ["dashboard_url"]= icm_utils.dashboardUrl(R),
        ["message"] = ExpiryMessage
      }
      return t  
   end

   -- check for company Iguana ID with expired maintenance...  test with IguanaID=N7HVNMDTBMUW976T
   local MaintenanceCurrent, Expiry, MaintenanceExpiry = CheckExpiry(iguana.id())  
               
   local Url
   if icm_utils.isWindows() then
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
   if os.fs.stat(icm_utils.application()) then
      for K,V in os.fs.glob(icm_utils.releases()..'*') do
         K = K:sub(#icm_utils.releases()+1):gsub("%_", ".")
         if not I[K] then
            I[K] = {}
         end 
         I[K].downloaded = true     
      end
   end
   trace(I)
   local C = icm_utils.currentVersion()
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
   
   j = "{}"
   versions = {}
   for i=1, #Keys do  
      local Version = Keys[i]
      local E = I[Version]
      version={}
      version["version"] = Version
      version["dir_version"] = icm_utils.versionString(Version)
      if E.current then
         version["current"] = "yes"
         version["license_expiry"] = Expiry
         version["maintenance_expiry"] = MaintenanceExpiry
      end
      if E.downloaded then
         version["downloaded"] = "yes"
      end
      if E.downloaded and not E.current then
         version["remove"] = "remove?"
         version["activate"] = "activate?"
      end
      versions[i] = version
   end
      
   t = { 
         ["status"]="ok",
         ["windows"]="yes",
         ["dashboard_url"]= icm_utils.dashboardUrl(R),
         ["versions"] = versions     
       }
            
   return t
      
end
   
return display
