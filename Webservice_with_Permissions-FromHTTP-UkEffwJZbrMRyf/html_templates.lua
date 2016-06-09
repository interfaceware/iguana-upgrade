local html_templates = {}

local dir = require 'dir'

function html_templates.PageHeader(R)

local PageHeader = [[
<html>
<head>
<style>
body {
   display: table;
   height: 100%;
   width: 100%;
   background: rgba(0, 0, 0, 0) linear-gradient(135deg, #4caf50 35%, #8bc34a 100%) repeat scroll 0 0;
   font-family: "Open Sans",sans-serif;
   color: #414042;
}
   
div.container {
   display: table-cell;
   vertical-align: middle;
}
   
div.contents {
   margin-left: auto;
   margin-right: auto;
   width: 800px;
   background: #FFFFFF;
   border-radius: 4px;
   box-shadow: 0 1px 2px rgba(0, 0, 0, 0.5);
   padding: 40px;
   height: 400px;
   text-align: center;
}

div.dashboard {
   float: right;
}

h2 {
   font-weight: 300;
   color: #357D57;
   margin: 0px 0px 10px 0px;
   padding-bottom: 10px;
   border-bottom: 1px solid #98C21F;
}
   
p {
   margin: 15px 0px 20px 0px;
   line-height: 1.5em;
   }

table {
   width: 500;
   margin-left:auto; 
   margin-right:auto;
   /*margin: 20px 0px;*/
   border: 1px solid #EEEEEE;
}
   
th {
   background: #cfd8dc none repeat scroll 0 0;
   color: #455a64;
   font-size: 12px;
   font-weight: 400;
   letter-spacing: 0.08em;
   padding: 12px 5px;
   text-align: center;
   text-transform: uppercase;
}

tr:nth-child(even) {background: #fefefe}
tr:nth-child(odd) {background: #f5f5f5}

td {
   font-size: 14px;
   padding: 7px 10px;
   text-align: center;
}
   
input[type=text], input[type=password] {
   font-size: 14px;
   line-height: 20px;
   border-radius: 3px;
   border: 1px solid #DDDDDD;
   padding: 5px 10px;
}

input[type=submit] {
    font-size: 14px;
    line-height: 20px;
    background-color: #82bf56;
    border-left: medium none;
    border-right: medium none;
    border-top: medium none;
    border-bottom: 2px solid #669644;
    text-shadow: 0 -1px #669644;
    border-radius: 3px;
    color: #ffffff;
    cursor: pointer;
    font-family: "Open Sans",sans-serif;
    padding: 5px 20px;
    text-decoration: none;
    white-space: nowrap;
}

p.footer {
   border-top: 1px solid #EEEEEE;
   font-size: smaller;
   padding: 25px 0px 0px 0px;
   margin-bottom: 0px;
   margin-top: 30px;
   font-weight: 600;
   color: #808285;
}

div.status {
   box-shadow: inset 0px 1px 2px 0px rgba(0,0,0,0.5);
   background: #f5f5f5;
   border-radius: 3px;
   padding: 10px 20px;
   overflow: auto;
}

a.button {
    font-size: 14px;
    line-height: 20px;
    background-color: #82bf56;
    border-left: medium none;
    border-right: medium none;
    border-top: medium none;
    border-bottom: 2px solid #669644;
    text-shadow: 0 -1px #669644;
    border-radius: 3px;
    color: #ffffff;
    cursor: pointer;
    font-family: "Open Sans",sans-serif;
    padding: 5px 20px;
    text-decoration: none;
    white-space: nowrap;
}

</style>
<link href='https://fonts.googleapis.com/css?family=Open+Sans:400,300,600,700' rel='stylesheet' type='text/css'>
</head>
<body>

<div class="container">
<div class="contents">
<div class="dashboard">
<a href="#DASHBOARD_URL#" class="button">Go to Dashboard</a>
</div> 

]]
   
   PageHeader = PageHeader:gsub("#DASHBOARD_URL#", dir.dashboardUrl(R))
   
   return PageHeader;

end

html_templates.PageFooter = [[
</div><!-- End .container -->
</div>

</body>
</html>
]]
   
html_templates.Header=[[
<html>
<head>
<style>
body {
   display: table;
   height: 100%;
   width: 100%;
   background: rgba(0, 0, 0, 0) linear-gradient(135deg, #4caf50 35%, #8bc34a 100%) repeat scroll 0 0;
   font-family: "Open Sans",sans-serif;
   color: #414042;
}
   
a {
   color: #006DB6;
}
   
div.container {
   display: table-cell;
   vertical-align: middle;
}
   
div.contents {
   margin-left: auto;
   margin-right: auto;
   width: 70%;
   background: #FFFFFF;
   border-radius: 4px;
   box-shadow: 0 1px 2px rgba(0, 0, 0, 0.5);
   padding: 40px;
}
   
div.dashboard {
   float: right;
}

h1 {
   font-weight: 300;
   color: #357D57;
   margin: 0px 0px 10px 0px;
   padding-bottom: 20px;
   border-bottom: 1px solid #98C21F;
}
   
p {
   margin: 15px 0px 20px 0px;
   line-height: 1.5em;
   }

table {
   width: 100%;
   margin: 20px 0px;
   border: 1px solid #EEEEEE;
}
   
th {
   background: #cfd8dc none repeat scroll 0 0;
   color: #455a64;
   font-size: 12px;
   font-weight: 400;
   letter-spacing: 0.08em;
   padding: 12px 5px;
   text-align: center;
   text-transform: uppercase;
}

tr:nth-child(even) {background: #fefefe}
tr:nth-child(odd) {background: #f5f5f5}

td {
   font-size: 14px;
   padding: 7px 10px;
   text-align: center;
}

tr.current{
   background-color : #dcedc8;
} 

a.button {
    font-size: 14px;
    line-height: 20px;
    background-color: #82bf56;
    border-left: medium none;
    border-right: medium none;
    border-top: medium none;
    border-bottom: 2px solid #669644;
    text-shadow: 0 -1px #669644;
    border-radius: 3px;
    color: #ffffff;
    cursor: pointer;
    font-family: "Open Sans",sans-serif;
    padding: 5px 20px;
    text-decoration: none;
    white-space: nowrap;
}

p.footer {
   border-top: 1px solid #EEEEEE;
   font-size: smaller;
   padding: 25px 0px 0px 0px;
   margin-bottom: 0px;
   margin-top: 30px;
   font-weight: 600;
   color: #808285;
}
} 

</style>
<link href='https://fonts.googleapis.com/css?family=Open+Sans:400,300,600,700' rel='stylesheet' type='text/css'>
<script src="http://ajax.aspnetcdn.com/ajax/jQuery/jquery-1.12.2.min.js"></script>
</head>

<body>

<div class="container">
<div class="contents">
<div class="dashboard">
<a href="#DASHBOARD_URL#" class="button">Go to Dashboard</a>
</div> 
   
<h1>Iguana Configuration Management Utility</h1>
]]

function html_templates.Footer(R)

   Footer=[[            </table>
                     </div>
                  </div>
               </body>
            </html>

]]

      Footer = Footer:gsub("#DASHBOARD_URL#", dir.dashboardUrl(R))
   
   return Footer;

end


html_templates.mustache_main_template = [[

<html>
   <head>
      <title></title>
      <style id="styles"></style>
      <script src="http://devops.ifware/~sripley/mustache/js/mustache.js"></script>
      <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.2/jquery.min.js"></script>
      <script type="text/javascript" language="javascript" src="https://cdn.datatables.net/1.10.11/js/jquery.dataTables.min.js"></script>
      <link href='https://fonts.googleapis.com/css?family=Open+Sans:400,300,600,700' rel='stylesheet' type='text/css'>

      <script language="javascript">

         $(document).ready(function() {

            // dynamically load CSS... (demo / not necessarily good idea...)
            $("#styles").load("http://devops.ifware/~sripley/mustache/templates/style.mustache");

            // load page body via Mustache template...
            updatePage()

         });

         function updatePage() {
            // reference:
            //   - http://boilingplastic.com/using-mustache-templates-for-javascript-practical-examples/
            //   - http://jonnyreeves.co.uk/2012/using-external-templates-with-mustachejs-and-jquery/
            //$.get('http://devops.ifware/~sripley/mustache/templates/main.mustache', function(body_template) {          
               $.getJSON('/update/api', function(body_data) {      
                  //var body = $(body_template).filter('#body_template').html();
                  var body = $('#body_template').html();
                  var body_html = Mustache.to_html(body, body_data);
                  //console.log(body)
                  $('#body_section').html(body_html);
               });
            //});

         }

         function fetch(version) {
            document.getElementById("loading-"+version).innerHTML = "<img src=\"http://static.interfaceware.com/devops/spinner.gif\"/>";
            $.ajax({
               type: 'GET',
               url: '/update/fetch-iguana-binary?version='+version,
               error: function() {
                  updatePage();
               },
               success: function(data) {
                  updatePage();
               }
            });
         }

         function removing(version) {
            document.getElementById("removing-"+version).innerHTML = "<img src=\"http://static.interfaceware.com/devops/spinner.gif\"/>";
            $.ajax({
               type: 'GET',
               url: '/update/delete-iguana-binary?version='+version,
               error: function() {
                  updatePage();
               },
               success: function(data) {
                  updatePage();
               }
            });
         }

      </script>

   </head>

   <body>

      <!-- placeholder to by replaced by populated template -->
      <div id="body_section" class="container"></div>


      <!-- ********************
            mustache templates
           ******************** -->

      <script id="body_template" type="text/template">
         <div class="container">
            <div class="contents">
               <div class="dashboard">
               <a href="{{dashboard_url}}" class="button">Go to Dashboard</a>
               </div> 
               <h1>Iguana Configuration Management Utility</h1>
               <p>
                  This utility is intended to make it easy to upgrade and/or rollback an
                  Iguana instance to a newer or older version of Iguana.  It only supports
                  Iguana 6 on Linux and Windows currently.  Error checking is limited so be careful!
               </p>
               <p>
                  This utility is in ALPHA.  Don't use in production system unless you really know what you are doing.
               </p>
               <table id="main-table">
                  <tr><th>Version</th><th>Current</th><th>Downloaded</th><th>Remove</th><th>Activate</th><th>License Expiry</th><th>Maintenance Expiry</th></tr>
                  {{#versions}}
                  {{#current}}<tr class="current">{{/current}}
                  {{^current}}<tr>{{/current}} 
                     <td>{{version}}</td>
                     {{#current}}    <td>Yes</td> {{/current}}
                     {{^current}}    <td>-</td> {{/current}} 
                     {{#downloaded}} <td>Yes</td> {{/downloaded}}
                     {{^downloaded}} <td><div id="loading-{{dir_version}}"><a href='#' onClick='fetch("{{dir_version}}")'>No</a></div></td> {{/downloaded}} 
                     {{#remove}}     <td><div id="removing-{{dir_version}}"><a href='#' onClick='removing("{{dir_version}}")'>Remove?</a></div></td> {{/remove}}
                     {{^remove}}     <td>-</td> {{/remove}} 
                     {{#activate}}   
                        {{#windows}} <td><a href='/update/activate-login?version={{dir_version}}'>Activate?</a></td>{{/windows}} 
                        {{^windows}} <td><a href='/update/activate?version={{dir_version}}'>Activate?</a></td>{{/windows}} 
                     {{/activate}}
                     {{^activate}}   <td>-</td> {{/activate}} 
                     {{#license_expiry}}   <td>{{license_expiry}}</td> {{/license_expiry}} 
                     {{^license_expiry}}   <td>-</td> {{/license_expiry}} 
                     {{#maintenance_expiry}}   <td>{{maintenance_expiry}} (<a href="/update/mils-login?version={{dir_version}}">Update?</a>)</td> {{/maintenance_expiry}} 
                     {{^maintenance_expiry}}   <td>-</td> {{/maintenance_expiry}}                      
                  </tr>
                  {{/versions}}
               </table>
            </div>
         </div>
      </script>

   </body>

</html>

]]
   
   

return html_templates