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


  Paloma.callbacks['photos']['editor'] = function(params){
    // Do something here.
    //Canvas handle and other variables
    var canvas = document.getElementById('canvas');
    var ctx = canvas.getContext('2d');
    var origImageData, initData , imageDataDelta;
    var img;
    var jcrop_api, canvas_obj;

    //load init image
    theCanvas = {};

    //reset the canvas
    theCanvas.reset = function(){
      //redraw the original image and crop if required	
      canvas = document.getElementById('canvas');

      ctx = canvas.getContext('2d');
      ctx.clearRect(0,0, canvas.width, canvas.height);
      img = new Image();
      img.src = params['img_src']; 
        $('#canvas').css('width', img.width);
        $('#canvas').css('height', img.height);
        canvas.width = img.width;
        canvas.height = img.height;
      img.onload = function(){
        ctx.drawImage(img, 0,0);
      };
      canvas_obj = $('#canvas').first();
    };
    
    //first boot. load properly
    theCanvas.firstBoot = function(){
      img = new Image();
      img.src = params['img_src']; 
      canvas = document.getElementById('canvas');
      ctx = canvas.getContext('2d');
      img.onload = function(){
        ctx.drawImage(img, 0, 0);
        theCanvas.setInitData();
          $('#crop-cancel').attr('x', 0);
    $('#crop-cancel').attr('y', 0);
    $('#crop-cancel').attr('x2', img.width);
    $('#crop-cancel').attr('y2', img.height);
      }; 
    };

    //set the init data. usually called after the image has been loaded or cropped
    theCanvas.setInitData = function(){
      imageData = ctx.getImageData(0,0, canvas.width, canvas.height);
      initData = new Array(imageData.data)[0];
    };

    
    //enable or disable buttons in the main menu
    theCanvas.toggleMainMenu = function(){
      //toggle main menu functions (enable or disable them)
      $('.icon-sun').parent().toggleClass('disabled');
      $('.icon-adjust').parent().toggleClass('disabled');
      $('.icon-rotate-right').parent().toggleClass('disabled');
      $('.icon-rotate-left').parent().toggleClass('disabled');
      $('.icon-save').parent().toggleClass('disabled');

      //check if the crop-submenu is closed and the check box is checked, then uncheck it
      if ( !$('icon-crop').parent().parent().hasClass('active') && 
        $('#crop-submenu form input:checked').length != 0 ){
        //console.log('clicked');
        $('#crop-constraint-check').click();
      }
    };

    //if cancel or toggle is pressed, re-hide the submenu
    // and restore the picture and crop it if required
    // and applied the  
    function cancel_crop(){
      //need to reset when they cropped it
      $('#crop').parent().removeClass('active');
      $('#crop-submenu').css('display', 'none');  
      jcrop_api.destroy();
      canvas_obj.attr('style', '');
      $('#canvas-area').append(canvas_obj);

      //crop back the picture
    };

    //convey the x,y and x2,y2 coordinates to the crop-submenu for tracking
    function updateCoor(c){
      $('#crop-submenu').attr('x', c.x);
      $('#crop-submenu').attr('y', c.y);
      $('#crop-submenu').attr('x2', c.x2);
      $('#crop-submenu').attr('y2', c.y2);
    };

    //send the files to your machine
    $('#photo-download').click( function(){
      Canvas2Image.saveAsJPEG(canvas);
    });

    //toggle the crop button
    // if open, show the crop square
    // if close, cancel the crop process
    $('#crop').click( function(){
      $('#crop').parent().toggleClass('active');
      if ( $('#crop').parent().hasClass('active') ) {
        //capture original crop co-ordinates if it's not full screen
        if ( $('#crop-submenu').attr('x') != $('#crop-submenu').attr('x2') ) {
          $('#crop-cancel').attr('x', $('#crop-submenu').attr('x') );
          $('#crop-cancel').attr('y', $('#crop-submenu').attr('y') );
          $('#crop-cancel').attr('x2', $('#crop-submenu').attr('x2') );
          $('#crop-cancel').attr('y2', $('#crop-submenu').attr('y2') );
        };

        //reload from orignal image
        theCanvas.reset();

        //TODO: show img based on proper orientation and show the crop by orientation too.
        theCanvas.displayRotatedImage();

        //properly set the brightness and contrast
        theCanvas.setInitData();
        newData = Filters.filterImage( 
          Filters.brightnessAndContrast, document.getElementById('canvas'), 
          $('#brightness-slider').slider('option', 'value'), $('#contrast-slider').slider('option', 'value') 
        );
        ctx.putImageData(newData, 0,0);

        //display the submenu and the crop square
        $('#crop-submenu').css('display', 'block');  
        jcrop_api = $.Jcrop('#canvas', { minSize:[150,150], allowSelect:false, 
          setSelect:[
            $('#crop-submenu').attr('x'), $('#crop-submenu').attr('y'), 
            $('#crop-submenu').attr('x2'), $('#crop-submenu').attr('y2')
          ],
          onChange: updateCoor }
        );

        theCanvas.toggleMainMenu();
      
      } else {
        cancel_crop();
        theCanvas.crop( true );

        theCanvas.toggleMainMenu();
      }
    });

    //handle when aspect ratio is selected
    $('#crop-constraint-check').change( function(){
      if ( $('#crop-submenu form input:checked').length) {
        //set aspect ratio to the crop square
        ratio = $('#ratio_size').val().split('x');
        jcrop_api.setOptions({ aspectRatio: ratio[0] / ratio[1] });  
        $('#ratio_size').prop('disabled', false);
        $('#crop-orientation button').prop('disabled', false);
      } else {
        //unset aspect ratio to the crop square
        jcrop_api.setOptions({ aspectRatio: null });
        $('#ratio_size').prop('disabled', true);
        $('#crop-orientation button').prop('disabled', true);
      };
    });

    //handle when aspect ratio select is changed
    $('#ratio_size').change( function(){
      ratio = $('#ratio_size').val().split('x'); 
      jcrop_api.setOptions({ aspectRatio: ratio[0] / ratio[1] });
    });

    //handle when crop square orientation changed
    $('#crop-orientation button').click( function() {
      //flip each
      $('#ratio_size option').each( function(){
        ratio = $(this).val().split('x');
        $(this).val( ratio[1] + 'x' + ratio[0] );
        $(this).text( ratio[1] + 'x' + ratio[0] );
      });

      //reset the aspect ratio
      newRatio = $('#ratio_size option:selected').val().split('x'); 
      jcrop_api.setOptions({ aspectRatio: newRatio[0]/newRatio[1] });
    });

    theCanvas.crop = function( cancel ){
      //crop the picture out
      if ($('#crop-submenu').attr('x') != $('#crop-submenu').attr('x2') ){
        if (cancel) {

          //crop to original image or orignal crop if cancelled
          newHeight = parseInt($('#crop-cancel').attr('y2') - $('#crop-cancel').attr('y'));
          newWidth = parseInt($('#crop-cancel').attr('x2') - $('#crop-cancel').attr('x'));
          startX = $('#crop-cancel').attr('x');
          startY = $('#crop-cancel').attr('y');

          //reset crop position
          $('#crop-submenu').attr('x', $('#crop-cancel').attr('x') );
          $('#crop-submenu').attr('x2', $('#crop-cancel').attr('x2') );
          $('#crop-submenu').attr('y', $('#crop-cancel').attr('y') );
          $('#crop-submenu').attr('y2', $('#crop-cancel').attr('y2') );
        } else {
          newHeight = parseInt($('#crop-submenu').attr('y2') - $('#crop-submenu').attr('y'));
          newWidth = parseInt($('#crop-submenu').attr('x2') - $('#crop-submenu').attr('x'));
          startX = $('#crop-submenu').attr('x');
          startY = $('#crop-submenu').attr('y');
        };

        //console.log('newHeight =' + newHeight);


        $('#canvas').css('width', newWidth);
        $('#canvas').css('height', newHeight);
        canvas.height = newHeight;
        canvas.width = newWidth;
        ctx.clearRect(0,0, newWidth, newHeight);
     
        //rotate the image
        ctx.drawImage(img, 
          startX, startY,
          newWidth, newHeight, 
          0, 0, 
          newWidth, newHeight
        );

        //reset the initData to the cropped pic
        theCanvas.setInitData();
        newData = Filters.filterImage( 
          Filters.brightnessAndContrast, document.getElementById('canvas'), 
          $('#brightness-slider').slider('option', 'value'), $('#contrast-slider').slider('option', 'value') 
        );
        ctx.putImageData(newData, 0,0);
      }
    }

    /*
      display the image as rotate image
      assume that this function is called after theCanvas.reset()
    */ 
    theCanvas.displayRotatedImage = function(){ 
      if ($('#canvas').attr('rotation') == '90' || $('#canvas').attr('rotation') == '270') {
        newHeight = canvas.width;
        newWidth = canvas.height;
      } else {
        newHeight = canvas.height;
        newWidth = canvas.width;
      };  
      
      canvas.width = newWidth;
      $('#canvas').width(newWidth);
      canvas.height = newHeight;
      $('#canvas').height(newHeight);

      //rotate the canvas at center point
      ctx.clearRect(0,0, img.width, img.height);
      ctx.translate(newWidth/2, newHeight/2);
      ctx.rotate( (Math.PI/180) * parseInt( $('#canvas').attr('rotation') ) );
     
      //redraw the full image
      ctx.drawImage(img, -img.width/2, -img.height/2);

      //apply brightness/contrast settings
      /*
      theCanvas.setInitData();
      newData = Filters.filterImage( 
        Filters.brightnessAndContrast, document.getElementById('canvas'), 
        $('#brightness-slider').slider('option', 'value'), $('#contrast-slider').slider('option', 'value') 
      );
      ctx.putImageData(newData, 0,0);
      */

      //set the coordinate back to the top-left hand conner
      ctx.translate(-newWidth/2, -newHeight/2);
      //ctx.restore();
    };

    /*rotate the picture
      arguments:-
        direction   rotate the canvas in the direction. valid are 'left', 'right' and 'none'
                    'none' is use when to rotate the re-display the image in the rotated view 
    */
    theCanvas.rotate = function(direction){
      newData = new Array(initData.length);
      origXY = [
        parseInt($('#crop-submenu').attr('x')),
        parseInt($('#crop-submenu').attr('y')),
        parseInt($('#crop-submenu').attr('x2')),
        parseInt($('#crop-submenu').attr('y2')),
      ];	
      
      //add rotation data
      //switch the coordinate system appriopiately
      if(direction == 'left') {
        $('#canvas').attr('rotation', 
          $('#canvas').attr('rotation') == '0' ? '270' : $('#canvas').attr('rotation') - 90
        );
        newXy = [
          $('#crop-submenu').attr('y2'),
          $('#crop-submenu').attr('x'),
          $('#crop-submenu').attr('y'),
          $('#crop-submenu').attr('x2')
        ];
      } else if (direction == 'right') {
        $('#canvas').attr('rotation', $('#canvas').attr('rotation') == '360' ? '0' : parseInt($('#canvas').attr('rotation')) + 90);
        newXy = [
          $('#crop-submenu').attr('y'),
          $('#crop-submenu').attr('x2'),
          $('#crop-submenu').attr('y2'),
          $('#crop-submenu').attr('x')
        ];
      }

      //setup new dimension and resize the canvas
      //switch the canvas height if rotated 90 or 270 degrees
      newWidth = canvas.height;
      newHeight = canvas.width;

      canvas.width = newWidth;
      $('#canvas').width(newWidth);
      canvas.height = newHeight;
      $('#canvas').height(newHeight);

      //rotate the canvas at center point
      ctx.translate(newWidth/2, newHeight/2);
      ctx.rotate( (Math.PI/180) * parseInt( $('#canvas').attr('rotation') ) );

      //redraw the image based on crop settings
      imgWidth = origXY[0] == origXY[2] ? img.width : origXY[2] - origXY[0];
      imgHeight = origXY[1] == origXY[3] ? img.height : origXY[3] - origXY[1];
      ctx.drawImage(img, 
        origXY[0],origXY[1],
        imgWidth, imgHeight,
        -imgWidth/2, -imgHeight/2,
        imgWidth, imgHeight
      );

      // apply brightness/contrast modifiers
      theCanvas.setInitData();
      newData = Filters.filterImage( 
        Filters.brightnessAndContrast, document.getElementById('canvas'), 
        $('#brightness-slider').slider('option', 'value'), $('#contrast-slider').slider('option', 'value') 
      );
      ctx.putImageData(newData, 0,0);

      //restore the coordinate system for next use
      ctx.restore;
    
      //setup new coordinates for the crop square
      $('#crop-submenu').attr('x', newXy[0]);
      $('#crop-submenu').attr('y', newXy[1]);
      $('#crop-submenu').attr('x2', newXy[2]);
      $('#crop-submenu').attr('y2', newXy[3]);

      return newData;
    }
    
    //done cropping
    $('#crop-done').click( function(){
      //remove the jcrop api
      cancel_crop();
      theCanvas.crop();
      theCanvas.toggleMainMenu();
    });

    //cancel cropping
    $('#crop-cancel').click( function(){
      cancel_crop();
      theCanvas.crop(true );
      theCanvas.toggleMainMenu();
    });

    //setup for rotate
    $('#rotate-left').click( function(){
      theCanvas.rotate('left');
    });

    $('#rotate-right').click( function(){
      theCanvas.rotate('right');
    });

    //setup the sliders for brightness and contrast
    $('.slider').slider({ value:0, min:-128, max:128 });
    $('#brightness-slider').on('slide', function(event, ui){
      $('#brightness-value').val(ui.value);
      newData = Filters.filterImage( 
        Filters.brightnessAndContrast, document.getElementById('canvas'), 
        ui.value, $('#contrast-slider').slider('option', 'value') 
      );
      ctx.putImageData(newData, 0,0);
    } );

    $('#contrast-slider').on('slide', function(event, ui){
      $('#contrast-value').val(ui.value);
      newData = Filters.filterImage( 
        Filters.brightnessAndContrast, document.getElementById('canvas'), 
        $('#brightness-slider').slider('option', 'value'), ui.value
      );
      ctx.putImageData(newData, 0,0);
    } );

    // see http://www.html5rocks.com/en/tutorials/canvas/imagefilters/
    Filters = {};

    Filters.getPixels = function(){
      //return c.getContext('2d').getImageData(0,0, c.width, c.height);
      origImageData = ctx.getImageData(0,0, canvas.width, canvas.height);
      for( i=0; i<initData.length; i++){
        origImageData.data[i] = initData[i];
      }
      return origImageData;
    };

    Filters.filterImage = function(filter, var_args){
      var args = [Filters.getPixels()];
      for (var i=2; i < arguments.length; i++){
        args.push(arguments[i]);
      }
    
      return filter.apply(null, args);
    };

    //brightness and contrast filters
    Filters.brightnessAndContrast = function(pixels, brightnessAdjustment, contrastAdjustment){
      //console.log('brightness: ' + brightnessAdjustment + ' contrast: ' + contrastAdjustment);
      var d = pixels.data;
      var contrastFactor = contrastAdjustment == 0 ? 1 : (259 * (contrastAdjustment + 255))/(255 * (259 - contrastAdjustment));
      for (var i =0; i < d.length; i+=4){
        d[i] = (contrastFactor * ( d[i] - 128 ) + 128) + brightnessAdjustment;
        d[i+1] = (contrastFactor * ( d[i+1] - 128 ) + 128) + brightnessAdjustment;
        d[i+2] = (contrastFactor * ( d[i+2] - 128 ) + 128) + brightnessAdjustment;
      }
      return pixels;
    }

    $(document).ready( function(){
      //setup the canvas
      theCanvas.firstBoot();
    });
  }; // Paloma.callbacks['photos']['editor'] = function(params){
})();
