         function updatePage() {
            // reference:
            //   - http://boilingplastic.com/using-mustache-templates-for-javascript-practical-examples/
            //   - http://jonnyreeves.co.uk/2012/using-external-templates-with-mustachejs-and-jquery/
            $.ajax({
               type: 'GET',
               url: '/update/icm-api?action=icm-installation-status',
               error: function (request, status, error) {
                  handleAjaxError(request, status, error);
               },
               success: function(body_data) {
                  if(body_data.status == "ok") {
                     addQueryParamsForMustache(document.location.search, body_data);
                     var body = $('#main').html();
                     var body_html = Mustache.to_html(body, body_data);
                     $('#outer').html(body_html);
                  } else {
                     var error = $('#error').html();
                     var error_html = Mustache.to_html(error, body_data);
                     $('#outer').replaceWith(error_html);                  
                  }
               }
            });            
         }

         function fetch(version) {
            document.getElementById("loading-"+version).innerHTML = "<img src=\"http://static.interfaceware.com/devops/spinner.gif\"/>";
            $.ajax({
               type: 'GET',
               url: '/update/icm-api?action=icm-fetch-iguana-binary&version='+version,
               error: function (request, status, error) {
                  handleAjaxError(request, status, error);
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
               url: '/update/icm-api?action=icm-delete-iguana-binary&version='+version,
               error: function() {
                  handleAjaxError(request, status, error);
               },
               success: function(data) {
                  updatePage();
               }
            });
         }          
         
         function milsLogin(version) {            
            $.ajax({
               type: 'GET',
               url: '/update/icm-api?action=mils-login&version='+version,
               error: function() {
                  handleAjaxError(request, status, error);
               },
               success: function(data) {
                  var body = $('#mils_login').html();
                  var body_html = Mustache.to_html(body, data);
                  $('#outer').replaceWith(body_html);                  
               }
            });                       
         }
         
         function restartLogin(version) {            
            $.ajax({
               type: 'GET',
               url: '/update/icm-api?action=restart-login&version='+version,
               error: function() {
                  handleAjaxError(request, status, error);
               },
               success: function(data) {
                  var body = $('#restart_login').html();
                  var body_html = Mustache.to_html(body, data);
                  $('#outer').replaceWith(body_html);                  
               }
            });                       
         }

         function updateMilsLicense() {
            var d = getFormData('#mils_form');
            $.ajax({
               type: 'GET',
               url: "/update/icm-api",
               data: d,
               error: function() {
                  handleAjaxError(request, status, error);
               },
               success: function(data) {
                  var body = $('#result').html();
                  var body_html = Mustache.to_html(body, data);
                  $('#outer').replaceWith(body_html);                  
               }
            });                       
         }  
         
         // http://stackoverflow.com/questions/2276463/how-can-i-get-form-data-with-javascript-jquery
         function getFormData(dom_query){
            var out = {};
            var s_data = $(dom_query).serializeArray();
            for(var i = 0; i<s_data.length; i++){
              var record = s_data[i];
              out[record.name] = record.value;
            }
            return out;
         }

         
         function activateLinuxLicense(version) {
            document.getElementById("activating-"+version).innerHTML = "<img src=\"http://static.interfaceware.com/devops/spinner.gif\"/>";
            $.ajax({
               type: 'GET',
               url: '/update/icm-api?action=icm-iguana-restart&version='+version,
               error: function() {
                  handleAjaxError(request, status, error);
               },
               success: function(data) {
                  var body = $('#result').html();
                  var body_html = Mustache.to_html(body, data);
                  $('#outer').replaceWith(body_html);                  
               }
            });                       
         }
         
         function activateWindowsLicense(version) {
            var d = getFormData('#restart_form');
            if(d.action == null) {
              d["action"]="icm-iguana-restart";
            }
            if(d.version == null) {
              d["version"]=version;
            }            
            document.getElementById("activating-"+version).innerHTML = "<img src=\"http://static.interfaceware.com/devops/spinner.gif\"/>";
            $.ajax({
               type: 'GET',
               url: '/update/icm-api',
               data: d,
               error: function() {
                  handleAjaxError(request, status, error);
               },
               success: function(data) {
                  var body = $('#result').html();
                  var body_html = Mustache.to_html(body, data);
                  $('#outer').replaceWith(body_html);                  
               }
            });                       
         }      

         function handleAjaxError(request, status, error) {
            var error_data = { message : request.statusText + ": " + request.responseText + " (" + status + ")" };
            var error = $('#error').html();
            var error_html = Mustache.to_html(error, error_data);
            $('#outer').replaceWith(error_html);            
         }