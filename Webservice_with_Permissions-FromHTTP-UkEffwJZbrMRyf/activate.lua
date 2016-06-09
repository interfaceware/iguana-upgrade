local html_templates = require 'html_templates'

local start   = require 'create-linux-start-script'
local restart = require 'create-linux-restart-script'
local install = require 'install-linux-cron'
local display = require 'iguana-installation-status'

local MakeScheduledTask = require 'windows.scheduler'

local dir = require 'dir'

-- This call will:
-- 1) Recreate the start script so that it points to the Iguana version we are switching to
-- 2) Make sure the start script is registered with the cron for the user
-- 3) Kill Iguana
-- Hopefully after that the cron job which runs the start script will restart Iguana with the new version otherwise
-- you will need to login into the machine to fix it.

function api_activate(R,A)
   local Version = dir.versionString(R.params.version)
   if dir.currentVersion() == Version:gsub("%_", ".") then
      return display.status(R,A)
      --error("This is the current version!")     
   end
   local AppDir = dir.applicationVersion(Version)   
   --if not os.fs.stat(AppDir) then      
   --   return display.status(R,A)
   --   --error("This version is not installed.")
   --end
   -- We could do more checks for the validity of the install
   -- we are changing over to.
   local StatusMessage
   if dir.isWindows() then
      local Username = R.params.username
      local Password = R.get_params.password
      local Command = AppDir..'changeversion.bat'
      local Result = MakeScheduledTask{user=Username, password=Password, command=Command, working_dir=AppDir, delay=2, taskname="iguana_change"}          
      if Result:find("SUCCESS") then
         StatusMessage = [[
            <h2>Activate Iguana Version #DVERSION#:</h2>
            <h4>Windodws Administrator Login Successful</h4>         
            <p>This Iguana instance is being shutdown. In about a minute the new version should be started...</p>
            <div class="status">
            <pre>#OUTPUT#</pre>
            </div>
         ]]
         StatusMessage = StatusMessage:gsub("#OUTPUT#", Result)         
         StatusMessage = StatusMessage:gsub("#DVERSION#", R.params.dversion)  
         StatusMessage = StatusMessage:gsub("#VERSION#", R.params.version)         
      else
         StatusMessage = [[
            <h2>Activate Iguana Version #DVERSION#:</h2>
            <h4>Windows Administrator Login Un-Successful</h4>         
            <p>an error was encountered...  (please ensure you are using a valid Administrator username and password!)</p>
            <div class="status">
            <pre>#OUTPUT#</pre>
            </div>
            <p><a class="button" href="/update/www/activate-login.html?version=#VERSION#&action=activate-login">Try Again?</a></p>
         ]]
         StatusMessage = StatusMessage:gsub("#OUTPUT#", Result)
         StatusMessage = StatusMessage:gsub("#DVERSION#", R.params.dversion)  
         StatusMessage = StatusMessage:gsub("#VERSION#", R.params.version)         
      end
   else
      --start.createScript(Version)
      restart.createScript(Version)
      --install.cron()
   end

   
   if not dir.isWindows() and not iguana.isTest() then
      -- this does a graceful shut down / restart
      --local exit_status = os.execute ("(setsid "..dir.root().."/iguana_restart.bash <&- >&- 2>&- & disown)")      
      local pexit = io.popen("(setsid "..dir.root().."/iguana_restart.bash & disown)")
      pexit:flush()
      local exit_status = pexit:read()      
      pexit:close()
      
      if exit_status:find("started") then         
         StatusMessage = [[
            <h2>Activate Iguana Version #DVERSION#:</h2>
            <h4>attempting to re-start iguana...</h4>         
            <p>This Iguana instance is being shutdown. In about a minute the new version should be started...</p>
            <div class="status">
            <pre>SUCCESS: #EXIT_STATUS#</pre>
            </div>
         ]]
         StatusMessage = StatusMessage:gsub("#DVERSION#", R.params.dversion)  
         StatusMessage = StatusMessage:gsub("#VERSION#", R.params.version)      
         StatusMessage = StatusMessage:gsub("#EXIT_STATUS#", exit_status)  
      else
         StatusMessage = [[
            <h2>Activate Iguana Version #DVERSION#:</h2>
            <h4>attempting to re-start iguana...</h4>         
            <p>there was an issue encountered re-start this Iguana instance...</p>
               <div class="status">
               <pre>ERROR: #EXIT_STATUS#</pre>
              </div>
           <p><a class="button" href="/update/www/activate-login.html?version=#VERSION#&action=activate-login">Try Again?</a></p>
            ]]
         StatusMessage = StatusMessage:gsub("#DVERSION#", R.params.dversion)   
         StatusMessage = StatusMessage:gsub("#VERSION#", R.params.version)      
         StatusMessage = StatusMessage:gsub("#EXIT_STATUS#", exit_status)           
      end
   end   

   t = { 
         ["status"]="ok",
         ["dashboard_url"] = dir.dashboardUrl(R),
         ["message"] = StatusMessage,
         ["dversion"] = dir.versionDotString(Version),
         ["version"] = dir.versionString(Version)
   }
      
   return t
   
 end