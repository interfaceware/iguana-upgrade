
local XmlTemplate=[[
<?xml version="1.0" encoding="UTF-8"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>#TIMESTAMP#</Date>
    <Author>#USER#</Author>
    <Description>Change Iguana service</Description>
  </RegistrationInfo>
  <Triggers>
    <TimeTrigger>
      <StartBoundary>#TIMESTAMP#</StartBoundary>
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
      <Command>"#COMMAND#"</Command>
      <WorkingDirectory>#WORKING_DIR#</WorkingDirectory>
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

local function MakeScheduledTask(T)
   local WorkingDir = T.working_dir:gsub("/", "\\")
   local Command    = T.command   :gsub("/", "\\")
   local TimeDelay  = T.delay
   local TaskName   = T.taskname
   local Username   = T.user
   local Password   = T.password
   
   local Config = xml.parse{data=XmlTemplate}
   
   Config.Task.Actions.Exec.Command[1] = '"'..Command..'"'
   Config.Task.Actions.Exec.WorkingDirectory[1] = WorkingDir
   Config.Task.Principals.Principal.UserId[1] = Username
   Config.Task.RegistrationInfo.Author[1] = Username
   
   -- We schedule the restart after the time delay
   local TimeStamp = os.ts.date('%Y-%m-%dT%H:%M:%S', os.ts.time() + TimeDelay)  
   Config.Task.RegistrationInfo.Date[1]= TimeStamp..".0000000"
   Config.Task.Triggers.TimeTrigger.StartBoundary[1] = TimeStamp
   trace(Config)
   local Flatwire = Config:S():gsub("&quot;", '"')
   trace(Flatwire)
   local TempName = os.tmpname()
   local F = io.open(TempName, "w")
   F:write(Flatwire)
   F:close()
   local Command = "schtasks /create /tn "..TaskName.." /XML "..TempName
     ..' /RU "'..Username..'" /RP "'..Password..'" /F 2>&1'
   trace(Command)
   local Result
   if not iguana.isTest() then
      Result = RunCommand(Command)
   else
      Result = "Not running change version in editor"
   end
   os.remove(TempName)
   return Result
end

return MakeScheduledTask