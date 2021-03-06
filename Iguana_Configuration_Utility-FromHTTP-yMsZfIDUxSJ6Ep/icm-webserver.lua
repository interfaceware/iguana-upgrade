-- **********************************************************************
--
--   Iguana Configuration Management Utility:
--   ---------------------------------------- 
--
--   icm-webserver.lua
--
--   description:
--      - iguana web server handler
--
--   author:
--     iNTERFACEWARE Inc.
--
-- **********************************************************************

if not web then web = {} end

web.webserver = {}

-- This is a tiny back end Lua framework we use to serve the function of dispatching JSON
-- web server requests and static files like Javascript/CSS/HTML etc. This page in our wiki
-- gives a good overview of how it works.
-- http://help.interfaceware.com/kb/the-anatomy-of-an-iguana-app/2

require 'web.file'

local basicauth = require 'web.basicauth'

local webMT = {__index=web.webserver}

local function CheckVersion()
   local V = iguana.version()
   local D = V.major * 10000 + V.minor * 100 + V.build
   trace(D)
   if D < 50605 then
      iguana.stopOnError(true);
      error('Sorry this script requires Iguana 6.0 or greater.');
   end
end

local function CalcBaseUrl()
   CheckVersion()
   local Config = iguana.channelConfig{guid=iguana.channelGuid()}
   Config = xml.parse{data=Config}
   BaseUrl = '/'..tostring(Config.channel.from_http.mapper_url_path)
   if BaseUrl:sub(#BaseUrl) ~= '/' then
      iguana.stopOnError(true)
      error('Please reconfigure the channel to have the base URL path '..BaseUrl..'/');
   end
   return BaseUrl
end

local function MakeJsonTree(FT, Seen)
   if not Seen then 
      Seen = {} 
      Seen._G = true
      if (not loaded) then loaded = {} end
      Seen.loaded = true
   end
   local Out = {}
   trace(Seen)
   for K,V in pairs(FT) do
      trace(K)
      if (not Seen[V]) then
         if (type(V) == 'table') then
            if(not Seen[K]) then 
               trace(K)
               trace (Seen)
               Seen[V] = true
               Out[K] = MakeJsonTree(V, Seen)
            end
         else 
            Out[K] = 1
         end
      end
   end
   return Out
end

local function Filter(Table)
   local T = Table
   for K,V in pairs(T) do
      trace(K)
      if type(V) == "table" then
         Filter(V)
      elseif (not help.get(K)) then
         V = nil
      end
   end
   help.get(package.loaders[1])
   return T
end

function web.webserver.create(T)
   iguana.stopOnError(false) 
   T.baseUrl = CalcBaseUrl()
   T.baseUrlSize = #T.baseUrl +1
   if T.default == nil then
      error('Need default argument.', 2)
   end
   if T.methods then
      T.methodSummary = json.serialize{alphasort=true,data=Filter(MakeJsonTree(T.methods))}
   end
   setmetatable(T, webMT)  
   return T
end

local function ServeError(ErrMessage, Code, Stack, Data)
   local Body = {error = ErrMessage}
   if Stack then 
      Body.stack = Stack
   end
   if Data then 
      Body.data = Data 
   end
   net.http.respond{code = Code, body = json.serialize{data = Body}, entity_type = 'text/json'}
   -- Only log internal errors
   if Code > 499 then
      local ErrId = queue.push{data = Data}
      iguana.logError(Stack .. '\n' .. Data, ErrId)
   end
end

local function DoJsonAction(Self, R)   
   local Action = R.location:sub(Self.baseUrlSize)
   local Func = Self.actions[Action]
   trace(Func)
   if (Func) then
      local Result = Func(R, Self)
      if Result.error then 
         ServeError(Result.error, Result.code)
         return false
      end
      Result = json.serialize{data=Result}
      net.http.respond{body=Result, entity_type='text/json'}   
      return true
   end
   return false
end

local ContentTypeMap = {
   ['.js']  = 'application/x-javascript',
   ['.css'] = 'text/css',
   ['.gif'] = 'image/gif',
   ['.png'] = 'image/png',
   ['.html'] = 'text/html'
}

local function FindEntity(Location) 
   local Ext = Location:match('.*(%.%a+)$')
   local Entity = ContentTypeMap[Ext]
   return Entity or 'text/plain'
end

local function LoadIguanaFile(FileName) 
	local RootDir = iguana.appDir() .. 'web_docs/'
   local Path = os.fs.abspath(RootDir..FileName)
   if (Path:sub(1, #RootDir) ~=RootDir) then
      -- we have an above root attack
      return
   end
      if (os.fs.stat(Path)) then
      return os.fs.readFile(Path)
   end
end

local function LoadMilestonedFile(FileName) 
   -- TODO This could be simplified if Iguana 6 iguana.project.files() gave
   -- the local directory 
   local Guid = iguana.project.guid()
   local FilePath = iguana.workingDir()..'run/'..Guid..'/'..Guid..'/'..FileName
   if (os.fs.stat(FilePath)) then
      return os.fs.readFile(FilePath)
   end
   FileName = iguana.project.files()["other/"..FileName]
   trace(FileName)
   if FileName then
      return os.fs.readFile(FileName);
   end
end

local function LoadSandboxFile(FileName, User)
   local Guid = iguana.project.guid()
   local RootDir = iguana.workingDir()..'edit/'..User..'/'..Guid..'/'
   local Path = os.fs.abspath(RootDir..FileName)
   if (Path:sub(1, #RootDir) ~=RootDir) then
      -- we have an above root attack
      return 
   end
   if (os.fs.access(Path)) then
      -- it was a local dependency.
      return os.fs.readFile(Path)
   end
   -- Check for other dependency
   RootDir = iguana.workingDir()..'edit/'..User..'/other/'
   trace(RootDir)
   local Path = os.fs.abspath(RootDir..FileName)
   if (os.fs.access(Path)) then
      return os.fs.readFile(Path)
   end
end

local function ServeFile(Self, R)
   local FileName = R.location:sub(Self.baseUrlSize)
   if #FileName == 0 then 
      FileName = Self.default 
   end
   
   local Content
   if Self.test then 
      Content = LoadSandboxFile(FileName, Self.test)
   else
      Content = LoadMilestonedFile(FileName)
   end
   if not Content then 
      Content = LoadIguanaFile(FileName)
   end
   local Entity = FindEntity(FileName)
   trace(Content)
   if (Content) then
      net.http.respond{body=Content, entity_type=Entity}
      return true
   end
   return false
end

local function FindHelp(Method, Path, Root)
   local Address = Path:split('/')  
   local Result = {}
   for i =1, #Address do
      Method = Method[Address[i]]
   end
   if (not Method) then
      error("Function does not exist in database");
   end
   trace(Method)
   local Files = iguana.project.files()
   local Help = help.get(Method)
   trace('other/help/'..Root..'/'..Path..'.json')
   if (not Help) then
      for K,V in pairs(Files) do
         if (K == 'other/help/'..Root..'/'..Path..'.json') then
            Help = json.parse{data=os.fs.readFile(V)}
         end
      end
   end
   if (not Help) then
      return {["Title"] = Path:gsub("/", "%.")}
   else 
      return Help
   end
end

local function HelpAction(Self, R)
   local Action = R.location:sub(Self.baseUrlSize)
   if (Action == 'helpsummary') then

      local Body = Self.methodSummary
      net.http.respond{body=Body, entity_type='text/json'} 
      return true
   end
  
   if (Action == 'helpdata') then
      local Help = FindHelp(Self.methods, R.params.call, Self.root)
      net.http.respond{body=json.serialize{data = Help}, entity_type='text/json'}   
      return true
   end
   return false
end

local function ServeRequest(Self, P)
   local R = net.http.parseRequest{data=P.data}
   
   if Self.auth and not basicauth.isAuthorized(R) then
      basicauth.requireAuthorization()
      return
   end
   
   if DoJsonAction(Self, R) then return 'Served Json' end
   if ServeFile(Self, R) then return 'Served file' end
   if HelpAction(Self, R) then return 'Help action' end
   net.http.respond{code=400,body='Bad request'}   
   return 'Bad request'
end

-- Find the method for the action.
function web.webserver.serveRequest(Self, P)
   if iguana.isTest() then
      ServeRequest(Self, P)
   else
      -- When running, push full stack error out to browser.
      -- In the case of an internal error, log it.
      local Stack = nil
      local Success, ErrMsg = pcall(ServeRequest, Self, P)
      if (not Success) then
         local ErrObj = {error=ErrMsg}
         --net.http.respond{body=json.serialize{data=ErrObj},
         net.http.respond{body=ErrMsg, 
                          entity_type='text/json',
                          code=500}
      end
   end
end