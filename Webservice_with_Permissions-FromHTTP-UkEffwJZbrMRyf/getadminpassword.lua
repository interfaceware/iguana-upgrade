require 'html_templates'

local Template=[[

<h2>Activate Iguana Version #VERSION#:</h2>
<h4>Windows Administrator Login</h4>
<p>
To activate Iguana version 6.0.1 it's necessary to enter the name and password of a user
with administrative privileges on the windows machine this Iguana instance is running on:
</p>
<form action="/update/activate" submit="activate">
<table>
<tbody>
<tr><th colspan="2">Windows Administrator</th></tr>
<tr><td>Username:</td><td><input name="username" type="text"></td></tr>
<tr><td>Password:</td><td><input name="password" type="password"></td></tr>
<tr><td colspan="2"><input value="Login" type="submit"></td></tr>
</tbody></table>
<input value="#VERSION#" name="version" type="hidden">
</form>

]]

function GetAdminPassword(R,A)
   local Version = R.params.version
   
   net.http.respond{body=html_templates.PageHeader(R)..Template:gsub("#VERSION#", Version)..html_templates.PageFooter}
end