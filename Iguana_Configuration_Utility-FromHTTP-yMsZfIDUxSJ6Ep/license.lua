
local html_templates = require 'html_templates'
require 'net.http.cache' 

require 'expiry'
local dir = require 'dir'


function License(R,A)

   local Response
   local Output 

   local mils_user = R.params.username
   local mils_password = R.get_params.password  
   local mils_method = ""
   local mils_product = "Iguana"
   local mils_token = ""
   local mils_activationID = ""
   local mils_license_code
   local mils_version = dir.versionString(R.params.version)
   trace(mils_version)
   -- establish session / obtains mils token
   mils_method = "session.login"
   
   local StatusMessage
   
   local D,C,H = net.http.get{url=global_config.mils_url.."/api?method="..mils_method.."&username="..mils_user.."&password="..mils_password, cache_time=60, live=true}
   local json_response = json.parse(D)
   if json_response.status == "ok" then 
      mils_token = json_response.data.Token   
      -- fetch activations / look for iguana.id()
      mils_method = "license.listActivations"
      D,C,H = net.http.get{url=global_config.mils_url.."/api?method="..mils_method.."&token="..mils_token.."&product="..mils_product, cache_time=60, live=true}
      local json_response = json.parse(D)
      local i = 1
      while i <= #json_response.data do
         if json_response.data[i].instance_id == iguana.id() then
            mils_activationID = json_response.data[i].activation_id
            break
         end
         i=i+1
      end
   
      if(mils_activationID ~= '') then
         -- update maintenance expiry
         mils_method = "license.updateMaintenance"
         D,C,H = net.http.get{url=global_config.mils_url.."/api?method="..mils_method.."&token="..mils_token.."&product="..mils_product.."&activationID="..mils_activationID, cache_time=60, live=true}
         local json_response = json.parse(D)
         trace(json_response.data.code)    
         mils_license_code = json_response.data.code
         
         local lf = io.open(iguana.workingDir().."IguanaLicense", "w")
      	lf:write(mils_license_code)
         io.close(lf)
         
         if dir.isWindows() then
            StatusMessage = [[
               <h2>Update Iguana License:</h2>
               <h4>Please log in to your iNTERFACEWARE Members Account</h4>         
               <div class="status">
               <pre>SUCCESS: your Iguana license has been updated!</pre>
               </div>
               <p><a class="button" href="/update/www/restart_login.html?version=#VERSION#">Restart Iguana!</a></p>
            ]] 
          else
            StatusMessage = [[
               <h2>Update Iguana License:</h2>
               <h4>Please log in to your iNTERFACEWARE Members Account</h4>         
               <div class="status">
               <pre>SUCCESS: your Iguana license has been updated!</pre>
               </div>
               <p><a class="button" href="/update/www/restart_login.html?version=#VERSION#">Restart Iguana!</a></p>
            ]]                  
          end
         StatusMessage = StatusMessage:gsub("#VERSION#", mils_version) 
         trace(StatusMessage)
      else 
         StatusMessage = [[
            <h2>Update Iguana License:</h2>
            <h4>Please log in to your iNTERFACEWARE Members Account</h4>         
            <div class="status">
            <pre>ERROR: your Iguana ID: #IGUANA_ID#" was not found.... (please try again or contract: support@interfaceware.com)</pre>
            </div>
            <p><a class="button" href="/update/www/mils_login.html?version=#VERSION#">Try Again?</a></p>
         ]]   
         StatusMessage = StatusMessage:gsub("#IGUANA_ID#", iguana.id())      
         StatusMessage = StatusMessage:gsub("#VERSION#", mils_version) 
         
         status = "the Iguana ID: " .. iguana.id() .. "was not found / contact support@interfaceware.com!"
      end
   else 
         StatusMessage = [[
            <h2>Update Iguana License:</h2>
            <h4>Please log in to your iNTERFACEWARE Members Account</h4>         
            <div class="status">
            <pre>ERROR: invalid username/password...</pre>
            </div>
            <p><a class="button" href="/update/www/mils_login.html?version=#VERSION#">Try Again?</a></p>
         ]]   
         StatusMessage = StatusMessage:gsub("#VERSION#", mils_version)          
   end
   
   local Body = html_templates.PageHeader(R) .. StatusMessage .. html_templates.PageFooter
   net.http.respond{body=Body}
   
end