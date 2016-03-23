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

return cron