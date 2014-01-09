(function(){
  // You access variables from before/around filters from _x object.
  // You can also share variables to after/around filters through _x object.
  var _x = Paloma.variableContainer;

  // We are using _L as an alias for the locals container.
  // Use either of the two to access locals from other scopes.
  //
  // Example:
  // _L.otherController.localVariable = 100;
  var _L = Paloma.locals;

  // Access locals for the current scope through the _l object.
  //
  // Example:
  // _l.localMethod(); 
  var _l = _L['photos'];


  Paloma.callbacks['photos']['new_direct'] = function(params){
    // Do something here.
    var fileUploadErrors = {
    maxFileSize: 'File is too big',
    minFileSize: 'File is too small',
    acceptFileTypes: 'Filetype not allowed',
    maxNumberOfFiles: 'Max number of files exceeded',
    uploadedBytes: 'Uploaded bytes exceed file size',
    emptyResult: 'Empty file upload result'
    };

    $(function() {
      $.widget('blueimp.fileupload', $.blueimp.fileupload, {
      });
      $('#fileupload').fileupload({
        dropZone: $('#dropzone'), 
        // VERY IMPORTANT.  you will get 405 Method Not Allowed if you don't add this.
        //forceIframeTransport: true,   
        //autoUpload: true,
        dataType:'xml',
        submit: function (event, data) {
          $.ajax({
            url: "/photos_direct",
            type: 'POST',
            dataType: 'json',
            data: {doc: {title: data.files[0].name}},
            async: false,
            success: function(retdata) {
              // after we created our document in rails, it is going to send back JSON of they key,
              // policy, and signature.  We will put these into our form before it gets submitted to amazon.
              //$('#file_upload').find('input[name=key]').val(retdata.key);
              $('#fileupload').find('input[name=key]').val(retdata.key);
              $('#fileupload').find('input[name=policy]').val(retdata.policy);
              $('#fileupload').find('input[name=signature]').val(retdata.signature);
            }
            
          });

          //data.submit();
        },
        send: function(e, data) {
        },
				success: function(e, data){
					console.log(data)
				},
        fail: function(e, data) {
          console.log('fail');
          console.log(data);
        }
				/*
        done: function (event, data) {
					$('.progress').fadeOut(300, function() {
						$('.bar').css('width', 0)
					});
        }
				*/
      });

      //drop zone
      $(document).bind('dragover', function (e) {
        var dropZone = $('#dropzone'),
            timeout = window.dropZoneTimeout;
        if (!timeout) {
            dropZone.addClass('in');
        } else {
            clearTimeout(timeout);
        }
        if (e.target === dropZone[0]) {
            dropZone.addClass('hover');
        } else {
            dropZone.removeClass('hover');
        }
        window.dropZoneTimeout = setTimeout(function () {
            window.dropZoneTimeout = null;
          dropZone.removeClass('in hover');
        }, 100);
      });

      $(document).bind('drop dragover', function (e) {
        e.preventDefault();
      });
    });
  }; // Paloma.callbacks['photos']['new_direct'] = function(params){
})();
