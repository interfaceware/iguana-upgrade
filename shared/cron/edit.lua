local cron = {}

-- This module allows one to programmatically read a cron tab and (gulp!) write to it.
-- Be cautious with writing to crontabs :-)

-- This code has only been tested under Linux

function cron.read()
   local P = io.popen("crontab -l")
   local C = P:read("*a")
   P:close()
   return C  
end

function cron.write(NewContent)
   if not iguana.isTest() then
      -- Write to standard output.
      local P = io.popen("crontab -", "w")
      P:write(NewContent)
      P:close()
   end   
end


local CronReadHelp=[[{
   "Returns": [{"Desc": "Returns contents of the current user crontab in string."}],
   "Title": "cron.read()",
   "Parameters": [],
   "ParameterTable": false,
   "Usage": "local Contents = cron.read()",
   "Examples": ["
local Contents = cron.read();
-- Change contents
cron.write(Contents);
"
   ],
   "Desc": "This function load the contents of the crontab file for the Iguana current user.  It only works under operating systems like linux which support cron."
}]]

help.set{input_function=cron.read, help_data=json.parse{data=CronReadHelp}}

return cron