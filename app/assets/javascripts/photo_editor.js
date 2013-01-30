//this is photo_editor.js
var brightnessValue = 0;
var contrastValue = 0;

function setNewColor(newValue){
    if (newValue > 255) newValue=255;
    if (newValue < 0) newValue=0; 
    return newValue;
}

function copyImageData( canvas, imageContext, sourceImageData){
  var imageData = imageContext.createImageData(canvas.width, canvas.height);
  for(var i=0; i < imageData.data.length; i++){
    imageData.data[i] = sourceImageData.data[i];
  }

  return imageData;
} 

function setBrightness ( brightnessDelta, sourceImageData){
  brightnessValue = brightnessValue + brightnessDelta;
  if (brightnessValue < -150) brightnessValue = 0;
  if (brightnessValue > 150) brightnessValue = 150;
  
  var imageData = sourceImageData.data 
  for(var i=0; i < imageData.length; i+=4){
    imageData[i] = setNewColor(imageData[i]+brightnessValue);
    imageData[i+1] = setNewColor(imageData[i+1]+brightnessValue);
    imageData[i+2] = setNewColor(imageData[i+2]+brightnessValue);
  }

  
  sourceImageData.data = imageData;
  return sourceImageData;
  
}

function setContrast ( contrastDelta, sourceImageData){
}

//ready for the buttons
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
    //copy image data  
    var imageData = copyImageData( canvas, ctx, origImageData);

    //update value    
    imageData = setBrightness ( -1, imageData);

    ctx.putImageData(imageData, 0,0);
  });

  $("#brightness-plus").click(function (event) {

    //copy image data  
    var imageData = copyImageData( canvas, ctx, origImageData);

    //update value    
    imageData = setBrightness ( +1, imageData);

    ctx.putImageData(imageData, 0,0);
  });

  $("#contrast-minus").click(function (event) {
    //calculate contrast factor
    if (contrastValue != -128) contrastValue -= 1;
    var contrastFactor = (259 * (contrastValue + 255))/(255 * (259 - contrastValue));

    //copy image data from original and update
    var imageData = copyImageData( canvas, ctx, origImageData);
  
    //update value
    for(var i=0; i < imageData.data.length; i+=4){
      for(var x=0; x<3; x++){
        var colorValue = imageData.data[i+x];
        imageData.data[i+x] = setNewColor(contrastFactor * (colorValue-128) + 128);
      }
    }

    ctx.putImageData(imageData, 0,0);
  });

  $("#contrast-plus").click(function (event) {
    //calculate contrast factor
    if (contrastValue != 128) contrastValue += 1;
    var contrastFactor = (259 * (contrastValue + 255))/(255 * (259 - contrastValue));

    //copy image data from original and update
    var imageData = copyImageData( canvas, ctx, origImageData);
  
    //update value
    for(var i=0; i < imageData.data.length; i+=4){
      for(var x=0; x<3; x++){
        var colorValue = imageData.data[i+x];
        imageData.data[i+x] = setNewColor(contrastFactor * (colorValue-128) + 128);
      }
    }

    ctx.putImageData(imageData, 0,0);
    
  });
});
