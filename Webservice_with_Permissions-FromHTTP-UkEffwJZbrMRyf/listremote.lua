
local Template=[[
<p>Click to download from this list of available Iguana versions for download.</p>
<table>
]]

function ListRemote(R,A)
   local Url = 'http://dl.interfaceware.com/iguana/linux/'
   local R = net.http.get{url=Url, live=true}
   local H = Template
   
   for K in R:rxmatch('href="(6[^/]*)/"') do
      trace(K)
      K = K:gsub("%_", ".")
      H = H .."<tr><td><a href='fetch?version="..K.."'>"..K.."</a></td></tr>\n"
   end
   H = H.."</table>"
    
   net.http.respond{body=H}
end