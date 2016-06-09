local html_templates = require 'html_templates'

local Template=[[

<h2>Update Iguana License:</h2>
<h4>Please log in to your iNTERFACEWARE Members Account</h4>
<p>
To update your Iguana License it's necessary to enter the username and password for your 
"my.interfaceware.com" account.
</p>
<form action="/update/mils-license" submit="license">
<table>
<tbody>
<tr><th colspan="2">Members Account (my.interfaceware.com)</th></tr>
<tr><td>Username:</td><td><input name="username" type="text"></td></tr>
<tr><td>Password:</td><td><input name="password" type="password"></td></tr>
<tr><td colspan="2"><input value="Update License" type="submit"></td></tr>
</tbody></table>
<input value="#VERSION#" name="version" type="hidden">
</form>

]]

function GetMilsPassword(R,A)   
   local Version = R.params.version
   trace(html_templates.PageHeader(R))
   net.http.respond{body=html_templates.PageHeader(R)..Template:gsub("#VERSION#", Version)..html_templates.PageFooter}
end