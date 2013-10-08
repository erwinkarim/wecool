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
        }
      }).bind( 'fileuploadadded', function (e,data) {
        $.each(data.files, function(index, file){
          var reader = new FileReader();
          reader.onload = function(){
            var hash = SparkMD5.hashBinary(reader.result);
            var results = $.ajax( 
              { url:params['get_dups_path'], dataType:'json', 
                data:{ md5:hash } 
              }
            ).done( function( data, textStatus, jqXHR) {
              if( data.length != 0){
                console.log('dups detected of file ' + file.name );

                //add the duplicate photos to the #duplisting
                $('#duplisting').append( 
                  $('<img/>', { src:data[0].avatar.thumb100.url, 
                    class:'img-polaroid pull-left', style:'margin:2px' }) 
                );

                //add download anyway button at individual level
                $('[data-name="' + file.name + '"]').toggleClass('warning');
                $('[data-name="' + file.name + '"]').toggleClass('duplicate');
                
                $('[data-name="' + file.name + '"]').find('.progress').after(
                  $('<div/>', { class:'duplicate-text', text:'Duplicate!'  } )
                );
                $('[data-name="' + file.name + '"]').find('.progress').hide()

                $('[data-name="' + file.name + '"]').find('.start').after(
                  $('<td/>', { class:'duplicate-button', colspan:2 } ).append(
                    $('<button/>', { type:'button', text:'Upload Anyway', class:'btn btn-warning'}
                    ).click( function(){
                      parentHandle = $(this).parent().parent();
                      parentHandle.find('.progress').show();
                      parentHandle.find('.start').show();
                      //this can cause the cancel button not to work so hide it for now
                      parentHandle.find('.cancel').show();
                      parentHandle.find('.duplicate-button').hide();
                      parentHandle.find('.duplicate-text').hide();
                      parentHandle.toggleClass('warning');
                      parentHandle.removeClass('duplicate');
                      parentHandle.addClass('template-upload');
                    })
                  )
                );
                $('[data-name="' + file.name + '"]').find('.start').hide();
                $('[data-name="' + file.name + '"]').find('.cancel').hide();

                //disable uploading dups: 
                $('[data-name="' + file.name + '"]').removeClass('template-upload');
              }
            });
          };
          reader.readAsBinaryString(file);
          //reader.readAsDataURL(file);
        });
      });

      //clear uploaded files
      $('.clear').click( function() {
        $('.files').find('input:checkbox:checked').each( function() {
          $(this).closest('tr').detach();
        });
      });

      //duplicate listing buttons
      $('#duplicate-discard-all').click( function(){
        $('.duplicate').remove();
      });

      $('#duplicate-upload-all-anyway').click( function(){
        $('.duplicate').each( function( index,value ){
          $(value).find('.duplicate-button').find('button').click();
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

			//dup zone accordion characteristics
			$('#dupzone_collapse').on('hide', function(){
				$('#dupzone-chevron').toggleClass('icon-chevron-down');
				$('#dupzone-chevron').toggleClass('icon-chevron-right');
			}).on('show', function(){
				$('#dupzone-chevron').toggleClass('icon-chevron-down');
				$('#dupzone-chevron').toggleClass('icon-chevron-right');
			});

      $(document).bind('drop dragover', function (e) {
        e.preventDefault();
      });
    });
  }; // Paloma.callbacks['photos']['new'] = function(params){
})();
