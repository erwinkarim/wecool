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


  Paloma.callbacks['photos']['new'] = function(params){
    // Do something here.
    var fileUploadErrors = {
    maxFileSize: 'File is too big',
    minFileSize: 'File is too small',
    acceptFileTypes: 'Filetype not allowed',
    maxNumberOfFiles: 'Max number of files exceeded',
    uploadedBytes: 'Uploaded bytes exceed file size',
    emptyResult: 'Empty file upload result'
    };

    $(function () {
 
      // Initialize the jQuery File Upload widget:
      $('#fileupload').fileupload({
        dropZone: $('#dropzone'),
        drop: function(e, data){
          $.each(data.files, function(index, file){
            console.log('Dropped file: ' + file.name);
            var reader = new FileReader();
            reader.onload = function(){
              var hash = SparkMD5.hashBinary(reader.result);
              var results = $.ajax( 
                { url:params['get_dups_path'], dataType:'json', 
                  data:{ md5:hash } 
                }
                  
              ).done( function( data, textStatus, jqXHR) {
                if( data.length != 0){
                  console.log('dups detected');
                  // label it as dups or else leave it alone
                }
              });
            };
            reader.readAsBinaryString(file);
          });
        }
      });

      //clear uploaded files
      $('.clear').click( function() {
        $('.files').find('input:checkbox:checked').each( function() {
          $(this).closest('tr').detach();
        });
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
  }; // Paloma.callbacks['photos']['new'] = function(params){
})();
