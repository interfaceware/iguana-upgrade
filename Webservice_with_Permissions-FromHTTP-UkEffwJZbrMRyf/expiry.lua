
require 'net.http.cache'

local dir = require 'dir'

function CheckIndividual(Data)
   
   local D,C,H = net.http.get{url=global_config.mils_url..":2000/scr-api?method=checkMaintenance&IguanaID="..iguana.id(), cache_time=0, live=true}
   local json_response = json.parse(D)
   if json_response.status == "trial" then
      return true
   else
      return false
   end   
   
end

function CheckExpiry(Data)

   local D,C,H = net.http.get{url=global_config.mils_url..":2000/scr-api?method=checkMaintenance&IguanaID="..iguana.id(), cache_time=0, live=true}
   local json_response = json.parse(D)
   return json_response.MaintenanceCurrent, json_response.Expiry, json_response.MaintenanceExpiry

end

