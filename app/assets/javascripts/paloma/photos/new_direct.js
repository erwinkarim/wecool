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
        imageOrientation:true,
        previewMaxWidth:300,
        previewMaxHeight:300,
        // VERY IMPORTANT.  you will get 405 Method Not Allowed if you don't add this.
        //forceIframeTransport: true,   
        //autoUpload: true,
        dataType:'xml'
      }).bind('fileuploadsubmit', function (event, data) {
          $.ajax({
            url: "/photos/" + params['persona_id'] + "/gen_s3_data" ,
            type: 'GET',
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

          //drop data that is should not be send
          $('#fileupload').find('input[name=description]').attr('disabled', 'disabled');
          $('#fileupload').find('input[name=newMediasetTitle]').attr('disabled', 'disabled');
          $('#fileupload').find('textarea[name=newMediasetDescription]').attr('disabled', 'disabled');
          $('#fileupload').find('input:checked').each( function(){ 
            $(this).attr('disabled', 'disabled');
          });

      }).bind('fileuploaddone', function(e, data){
        //console.log( data.result);
				//console.log( data.textStatus);
				//console.log( data.jqXHR);
        $('#fileupload').find('input[name=description]').removeAttr('disabled');
        $('#fileupload').find('input[name=newMediasetTitle]').removeAttr('disabled');
        $('#fileupload').find('textarea[name=newMediasetDescription]').removeAttr('disabled');
        $('#fileupload').find('input:checked').each( function(){ 
          $(this).removeAttr('disabled');
        });
        var mediasets = $('#fileupload').find('input:checked').each( function(){
          return $(this).val();
        });

        //generate the photo from s3 path
				var mediaset_selected = $('#fileupload').find('input[name="mediaset[]"]:checked').map( function() {
					return $(this).val();
				});
        var file_handler = data.files[0].name;
        var isVisible = $('#fileupload').find('[data-name="' + file_handler + '"]').find(
          '[name="visible[]"]:checked').length > 0 ? false : true;
        postData = { 
          responseText:data.jqXHR.responseText, 
          description:$('#description').val(), 
					mediasets:$.makeArray(mediaset_selected),
          visible:isVisible 
        };
				
        $.ajax( '/photos/' + params['persona_id'] + '/gen_from_s3', {
          type: 'POST',
          dataType: 'json',
          data: postData
        }).done( function (data){
          //find the current upload template and fade it out
          $('.files').find('[data-name="' + file_handler + '"]').fadeOut();
        });
      }).bind( 'fileuploadfail', function(e, data) {
          //console.log('fail');
          //console.log(data);
      }).bind( 'fileuploadadded', function( e, data) { // $('#fileupload').fileupload({
        //toggle picture visibility after the upload template has been rendered
        $('#file-listing').find(("[data-name='" + data.files[0].name + "']"  ) ).find('.visible_button').bind(
          'click', function(){
            var visible_checkbox = $(this).parent().find('.visible');
            visible_checkbox.attr('checked', !visible_checkbox.attr('checked')); 
            if(  visible_checkbox.attr('checked') != null ) {
              $(this).html( '<i class="icon-eye-close"></i> Private');
            } else {
              $(this).html( '<i class="icon-eye-open"></i> Public');
            };
          }
        )//bind
			}).bind( 'fileuploadadded', function(e,data) {
        //detect dupes when file uploaded
        $.each(data.files, function(index, file){
          var reader = new FileReader();
          reader.onload = function(){
            var hash = SparkMD5.hashBinary(reader.result);

						//label file w/ md5
						$('[data-name="' + file.name + '"]').attr('data-md5', hash);
						//file is also already in queue
						if ( $('[data-md5="' + hash + '"]').length > 1){
							$('[data-md5="' + hash + '"]:last').fadeOut(400, function(){ $(this).remove() } );
							return;
							//$('[data-md5="' + hash + '"]').remove();
						}

            var results = $.ajax( 
              { url:params['get_dups_path'], dataType:'json', 
                data:{ md5:hash } 
              }
            ).done( function( data, textStatus, jqXHR) {
              if( data.length != 0){
                //file is already in server

                //display the dupzone and duplicate photos
                $('#dupzone').fadeIn();
                $('#duplisting').append( 
                  $('<img/>', { src:data[0].avatar.square100.url, 
                    class:'img-polaroid pull-left', style:'margin:2px', 'data-md5':hash }) 
                );

                //add download anyway button at individual level
                $('[data-name="' + file.name + '"]').addClass('warning');
                $('[data-name="' + file.name + '"]').addClass('duplicate');
                
                $('[data-name="' + file.name + '"]').find('.progress').after(
                  $('<div/>', { class:'duplicate-text', text:'Duplicate!'  } )
                );
                $('[data-name="' + file.name + '"]').find('.progress').hide()

								//add upload anyway button
                $('[data-name="' + file.name + '"]').find('.start').after(
                  $('<td/>', { class:'duplicate-button' } ).append(
                    $('<button/>', { type:'button', class:'btn btn-danger'}
                    ).html('<i class="icon-upload"></i> Upload Anyway').click( function(){
                      parentHandle = $(this).parent().parent();
                      parentHandle.find('.progress').show();
                      parentHandle.find('.start').show();
                      //this can cause the cancel button not to work so hide it for now
                      parentHandle.find('.cancel').show();
                      parentHandle.find('.visibility').show();
                      parentHandle.find('.duplicate-button').hide();
                      parentHandle.find('.duplicate-text').hide();
                      parentHandle.find('.duplicate-cancel').hide();
                      parentHandle.toggleClass('warning');
                      parentHandle.removeClass('duplicate');
                      parentHandle.addClass('template-upload');
                      $('#duplisting').find('[data-md5="' + parentHandle.attr('data-md5') +'"]').slideUp(
                        400, function(){
                          $(this).remove();
                          if( $('#duplisting').find('img').length == 0) {
                            $('#dupzone').slideUp();
                          }
                      });
                    })
                  )
                ); // $('[data-name="' + file.name + '"]').find('.start').after(
	
								//add cancel dups button
                $('[data-name="' + file.name + '"]').find('.cancel').after(
                  $('<td/>', { class:'duplicate-cancel' } ).append(
                    $('<button/>', { type:'button', class:'btn btn-warning'}
                    ).html('<i class="icon-ban-circle"></i> Cancel').click(function(){
                      //cancel individual uploads
                      parentHandle = $(this).parent().parent();
                      parentHandle.slideUp(500);
                      $('#duplisting').find('[data-md5="' + parentHandle.attr('data-md5') +'"]').slideUp(
                        400, function(){
                          $(this).remove();
                          if( $('#duplisting').find('img').length == 0) {
                            $('#dupzone').slideUp();
                          }
                        });
                    })
                  )
                );

                $('[data-name="' + file.name + '"]').find('.start').hide();
                $('[data-name="' + file.name + '"]').find('.cancel').hide();
                $('[data-name="' + file.name + '"]').find('.visibility').hide();
  

                //disable dups from being upload
                $('[data-name="' + file.name + '"]').removeClass('template-upload');
              } //if(data.length != 0)
            }); //).done( function( data, textStatus, jqXHR) {
          }; // reader.onload = function(){

          reader.readAsBinaryString(file);
          //reader.readAsDataURL(file);
        }); // $.each(data.files, function(index, file){
      }); // }).bind('filuploadadded', function(e,data) { ;

      //duplicate listing buttons
      //discard every duplicate
      $('#duplicate-discard-all').click( function(){
        $('#dupzone').slideUp(400, function() {
          $('.duplicate').remove();
          $('#duplisting').find('img').remove();
        });
      });

      //upload anyway every listed duplicates
      $('#duplicate-upload-all-anyway').click( function(){
        $('#dupzone').slideUp( 400, function(){
          $('#duplisting').find('img').remove();
        });
        $('.duplicate').each( function( index,value ){
          $(value).find('.duplicate-button').find('button').click();
        });
        $('.duplicate').remove();
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
