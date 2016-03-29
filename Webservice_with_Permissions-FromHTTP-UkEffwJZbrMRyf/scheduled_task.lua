local dir = require 'dir'
local XmlTemplate=[[
<?xml version="1.0" encoding="UTF-8"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>2016-03-28T10:51:09.0000000</Date>
    <Author>#USER#</Author>
    <Description>Change Iguana service</Description>
  </RegistrationInfo>
  <Triggers>
    <TimeTrigger>
      <StartBoundary>2016-03-28T10:51:09</StartBoundary>
      <Enabled>true</Enabled>
    </TimeTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>#USER#</UserId>
      <LogonType>Password</LogonType>
      <RunLevel>LeastPrivilege</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>false</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>P3D</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>"C:\Program Files\iNTERFACEWARE\Manager\Iguana\6_0_1\changeversion.bat"</Command>
      <WorkingDirectory>C:\Program Files\iNTERFACEWARE\Manager\Iguana\6_0_1\</WorkingDirectory>
    </Exec>
  </Actions>
</Task>
]]

local function RunCommand(Command)
   local P = io.popen(Command, "r")
   local C = P:read("*a")
   P:close()
   return C
end

local function MakeScheduledTask(Version, Username, Password)
   local Config = xml.parse{data=XmlTemplate}
   local AppDir = dir.applicationVersion(Version):gsub("/", "\\")
   Config.Task.Actions.Exec.Command[1] = '"'..AppDir..'changeversion.bat"'
   Config.Task.Actions.Exec.WorkingDirectory[1] = AppDir
   Config.Task.Principals.Principal.UserId[1] = Username
   Config.Task.RegistrationInfo.Author[1] = Username
   
   -- We schedule the restart in a few seconds
   local TimeStamp = os.ts.date('%Y-%m-%dT%H:%M:%S', os.ts.time() + 2)  
   Config.Task.RegistrationInfo.Date[1]= TimeStamp..".0000000"
   Config.Task.Triggers.TimeTrigger.StartBoundary[1] = TimeStamp
   trace(Config)
   local Flatwire = Config:S():gsub("&quot;", '"')
   trace(Flatwire)
   local F = io.open(AppDir..'change_task.xml', "w")
   F:write(Flatwire)
   F:close()
   local Drive = AppDir:sub(1,2)
   local Command = Drive.." && cd "..AppDir..' && schtasks /create /tn iguana_change /XML change_task.xml'
     ..' /RU "'..Username..'" /RP "'..Password..'" /F 2>&1'
   trace(Command)
   if not iguana.isTest() then
      return RunCommand(Command)
   else
      return "Not running change version in editor"
   end
end

return MakeScheduledTask