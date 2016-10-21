-- **********************************************************************
--
--   Iguana Configuration Management Utility:
--   ---------------------------------------- 
--
--   icm-install-linux-cron.lua
--
--   description:
--      - This proveds JSON data for main screen of the Iguqana configuration 
--        management utility. (index.html)
-- 
--   author:
--     Eliot Muir / Scott Ripley
--
-- **********************************************************************
 
local display = {}

require 'net.http.cache'
require 'iguana.info'
require 'mils-license-utils'

local user = require 'iguana.user'
local basicauth = require 'web.basicauth'

local icm_utils = require 'icm-utils'

local ErrorMessage=[[
<h3>OS Not Supported</h3>
<p>
   This utility was requires either the Windows or Linux versions of Iguana.
</p>
<p>
   For OS X installations, please use the <a href="http://www.interfaceware.com/downloads.html">standard DMG installer</a> to manage your upgrades.
</p>
]]

local NoInternetMessage=[[
<h3>No Internet Connection Detected</h3>
<p>
   This utility requires external Internet connection in order to work
</p>
<p> 
   Please verify your connection and try again.
</p>
]]

local NoCurlMessage=[[
<h3>Unable To Find cURL</h3>
<p>
   This utility requires <a href="https://en.wikipedia.org/wiki/CURL">cURL</a> be installed and in the path.
</p>
<p>
   Please install cURL and try again.
</p>
]]

local IndividualTrialMessage=[[
<h3>Incompatible License Type</h3>
<p>
   This utility requires a non-trial licence in order to work.
</p>
<p>
  Please contact your account representative, or email <a href="mailto:support@interfaceware.com">support@interfaceware.com</a> for assistance.
</p>
]]

local ExpiryMessage=[[
<h3>Incompatible License Type</h3>
<p>
   This utility requires a valid maintenance plan in order to work.
</p>
<p>
   Please contact your account representative, or email <a href="mailto:support@interfaceware.com">support@interfaceware.com</a> for assistance.
</p>
]]

local NotActivated=[[
<h3>Incompatible License Type</h3>
<p>
   This utility requires a non-trial licence, associated with a company, in order to work.
</p>
<p>
  Please contact your account representative, or email <a href="mailto:support@interfaceware.com">support@interfaceware.com</a> for assistance.
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
   if (not ((icm_utils.isWindows() and icm_utils.is64Bit()) or
            (icm_utils.isWindows() and icm_utils.is32Bit()) or
            (icm_utils.isLinux() and icm_utils.is64Bit()) or
            (icm_utils.isLinux() and icm_utils.is32Bit()))) then
      t = { 
        ["status"]="error",
        ["windows"]="yes",
        ["dashboard_url"]= icm_utils.dashboardUrl(R),
        ["message"] = ErrorMessage   
      }
      return t           
      
   end
   
   -- check for curl
   if(not icm_utils.isWindows()) then
      local curlPresent = io.popen("curl --version")
      curlPresent:flush()
      local curlStatus = curlPresent:read()      
      curlPresent:close()      
      if not curlStatus:find("curl") then
         t = { 
           ["status"]="error",
           ["windows"]="yes",
           ["dashboard_url"]= icm_utils.dashboardUrl(R),
           ["message"] = NoCurlMessage
         }
         return t             
      end
   end
    
    -- check for running as service
   if(not icm_utils.isWindows()) then       
      local IguanaService = icm_utils.getIguanaService(iguana.appDir() .. "iguana_service.hdf")
      local IguanaServicePID = icm_utils.executeAndCapture("cat " .. iguana.appDir() .. "/"..IguanaService..".pid") 
      local IguanaServiceRunning = icm_utils.executeAndCapture("kill -0 " .. IguanaServicePID.." 2>&1")  
      if(not(IguanaServiceRunning=="")) then 
         t = { 
           ["status"]="error",
           ["dashboard_url"]= icm_utils.dashboardUrl(R),
           ["message"] = "Iguana must be running as a service..."
         }
         return t
      end
   end  
        
   -- check for trial Iguana ID / license...
   if CheckIndividual(iguana.id()) == true then
      t = { 
        ["status"]="error",
        ["windows"]="yes",
        ["dashboard_url"]= icm_utils.dashboardUrl(R),
        ["message"] = IndividualTrialMessage
      }
      return t          
   end
   
   -- check for company Iguana ID with expired maintenance...  test with IguanaID=N7HVNMDTBMUW976T
   local MaintenanceCurrent, Expiry, MaintenanceExpiry, SupportType = CheckExpiry(iguana.id())
   
   if SupportType == 'Suspended' or SupportType == 'Cancelled' or SupportType == 'None' then          
      t = { 
        ["status"]="error",
        ["windows"]="yes",
        ["dashboard_url"]= icm_utils.dashboardUrl(R),
        ["message"] = NotActivated
      }
      return t           
   end
   
   if CheckExpiry(iguana.id()) ~= true then
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
   
   if icm_utils.isWindows() then               
      t = { 
            ["status"]="ok",
            ["windows"]="yes",
            ["dashboard_url"]= icm_utils.dashboardUrl(R),
            ["versions"] = versions    
          }
   else 
      t = { 
            ["status"]="ok",
            ["dashboard_url"]= icm_utils.dashboardUrl(R),
            ["versions"] = versions
          }
   end

   -- check for internet access...
   local Success, ErrorMessage = pcall(net.http.get, {url="http://dl.interfaceware.com", cache_time=0, live=true})
   if  Success then
      t["internet"] ="yes";
   end
               
   return t
      
end
   
return display
