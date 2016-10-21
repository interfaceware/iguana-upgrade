-- source: 
--    https://github.com/Mashape/lua-multipart

--local stringy = require "stringy"

function string:split2(delimiter)
  local result = { }
  local from  = 1
  local delim_from, delim_to = string.find( self, delimiter, from  )
  while delim_from do
    table.insert( result, string.sub( self, from , delim_from-1 ) )
    from  = delim_to + 1
    delim_from, delim_to = string.find( self, delimiter, from  )
  end
  table.insert( result, string.sub( self, from  ) )
  return result
end

local MultipartData = {}
MultipartData.__index = MultipartData

setmetatable(MultipartData, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

local function is_header(value)
   if string.match(value, "(C%S+):%s*(%S+)") and string.match(value, "^w+") then
      return true
   else
      return nil
   end
end


local function fastDecode(body, boundary)
   
   local s = body:find("\r\n\r\n", 0, plain)+4   
   local e = body:find("--"..boundary, string.len("--"..boundary), plain)-3   
   local payload = body:sub(s, e)
   
   return payload
   
end

local function decode(body, boundary)
   
   local result = {
      data = {},
      indexes = {}
   }

   local part_headers = {}
   local part_index = 1
   local part_name, part_value   

   chunks = string.split2(body, "\r\n")

   for element, line in pairs(chunks) do
      if line:find("--"..boundary, 0, true) then
         if part_name ~= nil then
            if part_value ~= nil then
               part_value = part_value:sub(0, (string.len(part_value)-1))
            end  
            result.data[part_index] = {
               name = part_name,
               headers = part_headers,
               value = part_value
            }
            result.indexes[part_name] = part_index
            -- Reset fields for the next part
            part_headers = {}
            part_value = nil
            part_name = nil
            part_index = part_index + 1
         end
      --elseif (string.lower(line):find("content-disposition", 0, true)) or 
      --   (string.lower(line):find("content-type", 0, true)) then
      elseif (string.lower(line):sub(0, 20) == "content-disposition:") or 
         (string.lower(line):sub(0,13) == "content-type:") then
         trace("found header!")
         local parts = string.split(line, ";")
         for _,v in ipairs(parts) do
            if not is_header(v) then -- If it's not content disposition part
               local current_parts = string.split(string.trimLWS(v), "=")
               if string.lower(table.remove(current_parts, 1)) == "name" then
                  local current_value = string.trimWS(table.remove(current_parts, 1))
                  part_name = string.sub(current_value, 2, string.len(current_value) - 1)
               end
            end
         end
         table.insert(part_headers, line)
      else
         if is_header(line) then
            table.insert(part_headers, line)
         --elseif string.len(line) > 0 then
         elseif line ~= nil then
            if(part_value == nil) then
               part_value = line .. "\r\n"
            else
               part_value = part_value .. line .. "\r\n"
            end
         end
      end    
   end
   return result
end

function MultipartData.new(data, content_type)
  local instance = {}
  setmetatable(instance, MultipartData)
  if content_type then
    instance._boundary = string.match(content_type, ";%s+boundary=(%S+)")
  end
  instance._data = decode(data or "", instance._boundary)
  fastDecode(data or "", instance._boundary) 
  return instance
end

function MultipartData:get(name)
  return self._data.data[self._data.indexes[name]]
end

function MultipartData:getXXX(data)
  trace(aaa.body)
   return fastDecode(yyy, boundary)
end


function MultipartData:tostring()
  return encode(self._data, self._boundary)
end

return MultipartData