local Template=[[
<html>
<head>
</head>
<body>
<p>
To activate Iguana version #VERSION# it's necessary to enter the name and password of a user
with administrative privileges on the windows machine this Iguana instance is running on.
</p>
<p>
Please do so:
</p>
<form submit="activate" action="activate">
<table>
<tr><td>Username:</td><td><input type="text" name="username"></td></tr>
<tr><td>Password:</td><td><input type="password" name="password"></td></tr>
<tr><td></td><td><input type="submit"></td></tr>
</table>
<input type="hidden" name="version" value="#VERSION#">
</form>
</body>
</html>
]]

function GetAdminPassword(R,A)
   local Version = R.params.version
   
   net.http.respond{body=Template:gsub("#VERSION#", Version)}
end