local Html=[[
Welcome to the Iguana upgrade administation screen.
<p>
<a href="listlocal">List Locally Installed Versions</a>
<p>
<a href="listremote">List Published Versions</a>
<p>
]]


function AdminStatus(R, A)
   net.http.respond{body=Html}   
end