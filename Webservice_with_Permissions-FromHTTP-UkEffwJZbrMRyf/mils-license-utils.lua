-- **********************************************************************
--
--   Iguana Configuration Management Utility:
--   ---------------------------------------- 
--
--   mils-license-utils.lua
--
--   description:
--      - utilize MILS web service(s) to fetch license information based
--        on instance IguanaID
--
--   author:
--     Scott C. Ripley
--
-- **********************************************************************

require 'net.http.cache'

function CheckIndividual(Data)
   local D,C,H = net.http.get{url=global_config.mils_url.."/icm-api?method=checkMaintenance&IguanaID="..iguana.id(), cache_time=0, live=true}
   local json_response = json.parse(D)
   if json_response.status == "trial" then
      return true
   else
      return false
   end   
end

function CheckExpiry(Data)
   local D,C,H = net.http.get{url=global_config.mils_url.."/icm-api?method=checkMaintenance&IguanaID="..iguana.id(), cache_time=0, live=true}
   local json_response = json.parse(D)
   return json_response.MaintenanceCurrent, json_response.Expiry, json_response.MaintenanceExpiry, json_response.SupportType
end