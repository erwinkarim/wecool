
          //this is photo_editor.js
          $(document).ready( function(){
            //for the buttons

            $("#corp").click(function (event) {
              alert("corp clicked");
            });

            $("#rotateLeft").click(function (event) {
              ctx.translate(canvas.width/2, canvas.height/2);
              ctx.clearRect(canvas.width/-2, canvas.height/-2, canvas.width, canvas.height);
              ctx.rotate(90 * (Math.PI/180));
              ctx.drawImage(img,img.width/-2,img.height/-2);
              ctx.translate(canvas.width/-2, canvas.height/-2);
            });

            $("#rotateRight").click(function (event) {
              ctx.translate(canvas.width/2, canvas.height/2);
              ctx.clearRect(canvas.width/-2, canvas.height/-2, canvas.width, canvas.height);
              ctx.rotate(-90 * (Math.PI/180));
              ctx.drawImage(img,img.width/-2,img.height/-2);
              ctx.translate(canvas.width/-2, canvas.height/-2);
            });

            $("#brightness-minus").click(function (event) {
              //get image data  
              var imageData = ctx.getImageData(0,0,canvas.width, canvas.height);
              var data = imageData.data;

              brightnessValue -= 1;
              if(brightnessValue < 150) brightnessValue = 150;

              for(var i=0; i < data.length; i+=4){
                var red = data[i];
                var green = data[i+1];
                var blue = data[i+2];

                if (red != 0) data[i]-=1;
                if (green != 0) data[i+1]-=1;
                if (blue != 0) data[i+2]-=1;
              } 
              ctx.putImageData(imageData, 0,0);
              //ctx.drawImage(img,0,0);
            });

            $("#brightness-plus").click(function (event) {
              //get image data  
              var imageData = ctx.getImageData(0,0, canvas.width, canvas.height);
              var data = imageData.data;

              console.log(imageData);
              brightnessValue += 1;
              if(brightnessValue < 150) brightnessValue = 150;

              for(var i=0; i < data.length; i+=4){
                var red = data[i];
                var green = data[i+1];
                var blue = data[i+2];

                if (red != 255) data[i]+=1;
                if (green != 255) data[i+1]+=1;
                if (blue != 255) data[i+2]+=1;
              } 
              ctx.putImageData(imageData, 0,0);
            });

            $("#contrast-minus").click(function (event) {
              //calculate contrast factor
              if (contrastValue != 128) contrastValue -= 1;
              var contrastFactor = (259 * (contrastValue + 255))/(255 * (259 - contrastValue));

              var imageData = ctx.getImageData(0,0,canvas.width, canvas.height);
              var data = imageData.data;
              //update value
              for(var i=0; i < data.length; i+=4){
                for(var x=0; x<3; x++){
                  var colorValue = data[i+x];
                  var newColor = (contrastFactor * (colorValue-128) + 128);
                  if (newColor > 255) newColor = 255;
                  data[i+x]=newColor;
                }
              }
              ctx.putImageData(imageData, 0,0);
            });

            $("#contrast-plus").click(function (event) {
              //calculate contrast factor
              if (contrastValue != 128) contrastValue += 1;
              var contrastFactor = (259 * (contrastValue + 255))/(255 * (259 - contrastValue));

              var imageData = ctx.getImageData(0,0,canvas.width, canvas.height);
              var data = imageData.data;
              //update value
              for(var i=0; i < data.length; i+=4){
                for(var x=0; x<3; x++){
                  var colorValue = data[i+x];
                  var newColor = (contrastFactor * (colorValue-128) + 128);
                  if (newColor > 255) newColor = 255;
                  data[i+x]=newColor;
                }
              }
              ctx.putImageData(imageData, 0,0);
              
            });
          });
