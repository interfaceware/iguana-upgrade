-- Iguana Configuration Management Utility - currently only supports Linux
-- It's meant to make it easy to upgrade or roll back an Iguana instance to an earlier version

-- Only a user with admin privillege can access use this utility.

local display = require 'displayinstallstatus'
require 'activate'
require 'fetch'
require 'delete'

local basicauth = require 'web.basicauth'
local user = require 'iguana.user'
local actionTable = require 'iguana.action'

-- We set up the map of web requests to actions using the actionTable object.

function SetupActions()
   -- First we create it
   local Dispatcher = actionTable.create()
   -- Define the actions for Administrators
   -- Priority 1 means Administrator actions override actions defined for
   -- other groups that a user might belong to.
   local AdminActions = Dispatcher:actions{group='Administrators', priority=1}
   -- We just assign URL request paths to functions
   AdminActions[""] = display.status
   AdminActions["fetch"] = Fetch
   AdminActions["delete"] = Delete
   AdminActions["activate"] = Activate
   -- Define user actions
   -- Priority 2 means these actions will not be invoked if a user also belongs
   -- to a group with lower priority permissions.
   local UserActions = Dispatcher:actions{group='User', priority=2}
   UserActions[""] = UserStatus
   -- Notice that both the Administrator and User permissions define the
   -- default "" path.  This allows us to alter behavior of what administrators
   -- see vs. normal Users.
   -- You can add additional actions tables for different user groups.
   return Dispatcher
end
   
function main(Data)
   -- Setting up the dispatcher - we could do this outside of main if we wanted
   -- to be more efficient and only call the code once when the channel starts up.
   local Dispatcher = SetupActions()
   -- Parse the HTTP request
   local R = net.http.parseRequest{data=Data}
   
   -- Check for authentication against the users defined in Iguana.     
   if not basicauth.isAuthorized(R) then
      -- We display this in the prompt to the user (somewhat browser dependent)
      basicauth.requireAuthorization("Please enter your Iguana username and password.")
      iguana.logInfo("Failed authentication.")
      return
   end
   -- Extract the user name and password
   local Auth = basicauth.getCredentials(R)
   trace(Auth.username)
   
   -- Find an action based on the user name and request 
   local Action = Dispatcher:dispatch{path=R.location,  user=Auth.username}
   if (Action) then
      -- we will catch exceptions here
      if (iguana.isTest()) then
         Action(R, Auth)
      else
         local Success, ErrorMessage = pcall(Action, R,Auth)
         if not Success then
            -- TODO - pretty error formatting.
            net.http.respond{body=ErrorMessage, code=500}
         end
      end
   else
      net.http.respond{body="Request refused.", code=401}
   end
end

function UserStatus(R, A)
   net.http.respond{body="You need to be administrator to use this utility."} 
end


