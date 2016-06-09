-- **********************************************************************
--
--   Iguana Configuration Management Utility:
--   ---------------------------------------- 
--
--   icm-iguana-restart.lua
--
--   description:
--      - This call will:
--        1) Recreate the start script so that it points to the Iguana 
--           version we are switching to
--        2) Make sure the start script is registered with the cron for the user
--        3) Kill Iguana
--        Hopefully after that the cron job which runs the start script will 
--        restart Iguana with the new version otherwise you will need to login 
--        into the machine to fix it.
--
--   author:
--     Eliot Muir
--
-- **********************************************************************

local start   = require 'icm-create-linux-start-script'
local restart = require 'icm-create-linux-restart-script'
local install = require 'icm-install-linux-cron'
local display = require 'icm-installation-status'

local MakeScheduledTask = require 'windows.scheduler'

local icm_utils = require 'icm-utils'

function icm_iguana_restart(R,A)

   local Version = icm_utils.versionString(R.params.version)
   local DotVersion = icm_utils.versionDotString(R.params.version)
   local AppDir = icm_utils.applicationVersion(Version)   
   
   --if not os.fs.stat(AppDir) then      
   --   return display.status(R,A)
   --   --error("This version is not installed.")
   --end
   -- We could do more checks for the validity of the install
   -- we are changing over to.
   local StatusMessage
   if icm_utils.isWindows() then
      local Username = R.params.username
      local Password = R.get_params.password
      local Command = AppDir..'changeversion.bat'
      local Result = MakeScheduledTask{user=Username, password=Password, command=Command, working_dir=AppDir, delay=2, taskname="iguana_change"}          
      if Result:find("SUCCESS") then
         StatusMessage = [[            
            <h2>Activate Iguana Version #DVERSION#:</h2>
            <h4>Windows Administrator Login Successful</h4>         
            <p>This Iguana instance is being shutdown and the new version will be started shortly.</p>
            <h3>Redirecting to the Iguana Dashboard in: <span id="count"></span> seconds...</h3>
            <div class="status">
            <pre>#OUTPUT#</pre>
            </div>
            <script language="javascript">
            redirect(15, "#DASHBOARD#")
            </script>
         ]]
         dashboard_url = icm_utils.dashboardUrl(R)
         StatusMessage = StatusMessage:gsub("#DASHBOARD#", dashboard_url)    
         StatusMessage = StatusMessage:gsub("#OUTPUT#", Result)         
         StatusMessage = StatusMessage:gsub("#DVERSION#", DotVersion)           
      else
         StatusMessage = [[
            <h2>Activate Iguana Version #DVERSION#:</h2>
            <h4>Windows Administrator Login Un-Successful</h4>         
            <p>We encountered an error. Please ensure you are using a valid Administrator username and password.</p>
            <div class="status">
            <pre>#OUTPUT#</pre>
            </div>
            <p><a href="#" class="button" onClick="restartLogin('#VERSION#')">Try Again?</a><div id="activating-#VERSION#"></div></p>
         ]]
         StatusMessage = StatusMessage:gsub("#OUTPUT#", Result)
         StatusMessage = StatusMessage:gsub("#DVERSION#", DotVersion)  
         StatusMessage = StatusMessage:gsub("#VERSION#", Version)         
      end
   else
      --start.createScript(Version)
      restart.createScript(Version)
      --install.cron()
   end

   
   if not icm_utils.isWindows() and not iguana.isTest() then
      -- this does a graceful shut down / restart
      --local exit_status = os.execute ("(setsid "..icm_utils.root().."/iguana_restart.bash <&- >&- 2>&- & disown)")      
      local pexit = io.popen("(setsid "..icm_utils.root().."/iguana_restart.bash & disown)")
      pexit:flush()
      local exit_status = pexit:read()      
      pexit:close()
      
      if exit_status:find("started") then         
         StatusMessage = [[
            <h2>Activate Iguana Version #DVERSION#:</h2>
            <h4>Attempting to Restart Iguana</h4>         
            <p>This Iguana instance is being shutdown and the new version will be started shortly.</p>
            <h3>Redirecting to the Iguana Dashboard in: <span id="count"></span> seconds...</h3>
            <div class="status">
            <pre>#EXIT_STATUS#</pre>
            </div>
            <script language="javascript">
            redirect(15, "#DASHBOARD#")
            </script>
         ]]
         dashboard_url = icm_utils.dashboardUrl(R)
         StatusMessage = StatusMessage:gsub("#DASHBOARD#", dashboard_url)           
         StatusMessage = StatusMessage:gsub("#DVERSION#", DotVersion)  
         StatusMessage = StatusMessage:gsub("#VERSION#", Version)      
         StatusMessage = StatusMessage:gsub("#EXIT_STATUS#", exit_status)  
      else
         StatusMessage = [[
            <h2>Activate Iguana Version #DVERSION#:</h2>
            <h4>Attempting to Restart Iguana</h4>         
            <p>We encountered an error when attempting to restart this Iguana instance:</p>
               <div class="status">
               <pre>ERROR: #EXIT_STATUS#</pre>
              </div>
           <p><a class="button" href="/update/www/result.html?action=icm-iguana-restart&version=#VERSION#">Try Again?</a><div id="activating-#VERSION#"></div></p>
            ]]
         StatusMessage = StatusMessage:gsub("#DVERSION#", DotVersion)   
         StatusMessage = StatusMessage:gsub("#VERSION#", Version)      
         StatusMessage = StatusMessage:gsub("#EXIT_STATUS#", exit_status)           
      end
   end   

   t = { 
         ["status"]="ok",
         ["dashboard_url"] = icm_utils.dashboardUrl(R),
         ["message"] = StatusMessage,
         ["dversion"] = icm_utils.versionDotString(Version),
         ["version"] = icm_utils.versionString(Version)
   }
      
   return t
   
 end