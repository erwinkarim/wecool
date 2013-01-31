//this is photo_editor.js
var brightnessValue = 0;
var contrastValue = 0;

function setNewColor(newValue){
    newValue = Math.round(newValue);
    if (newValue > 255) newValue=255;
    if (newValue < 0) newValue=0; 
    return newValue;
}

function setBrightness(brightnessDelta){
  brightnessValue += brightnessDelta;
  if (brightnessValue < -150) brightnessValue = -150;
  if (brightnessValue > 150) brightnessValue = 150;

  //update brightness value label
  $("#brightness-value").text(brightnessValue);
}

//returns a ImageData object with adjusted brightness in relation to the sourceImageData object
function brightnessFilter ( sourceImageData){
  //build imageData
  var returnImageData = ctx.createImageData(canvas.width, canvas.height);
  var imageDataArray = returnImageData.data;
  for(var i=0; i < sourceImageData.data.length; i+=4){
    imageDataArray[i] = setNewColor(sourceImageData.data[i] + brightnessValue);
    imageDataArray[i+1] = setNewColor(sourceImageData.data[i+1] + brightnessValue);
    imageDataArray[i+2] = setNewColor(sourceImageData.data[i+2] + brightnessValue);
    imageDataArray[i+3] = sourceImageData.data[i+3];
  }

  returnImageData.data = imageDataArray;

  return returnImageData;
  
}

function setContrast ( contrastDelta ){
  contrastValue += contrastDelta;

  if (contrastValue < -128) contrastValue = -128;
  if (contrastValue > 128) contrastValue = 128;

  //update contrast value label
  $("#contrast-value").text(contrastValue);
}

//returns a contrastFilter with adjusted contrast value in relation to sourceImageData
function contrastFilter ( sourceImageData){
  //calculate contrast factor
  var contrastFactor = (259 * (contrastValue + 255))/(255 * (259 - contrastValue));

  //update pixel value
  for(var i=0; i< sourceImageData.data.length; i+=4){
    for(var x=0; x<3; x++){
      sourceImageData.data[i+x] = setNewColor(contrastFactor * ( sourceImageData.data[i+x] - 128) + 128); 
    }
  }

  return sourceImageData;
}
//redraw the canvas with adjusted value
function reDraw(sourceImageData){

  //get empty ImageData object
  //apply brightness filter first
  imageData = brightnessFilter(sourceImageData); 

  //apply contrast filter
  imageData = contrastFilter(imageData);

  //redraw the canvas
  ctx.putImageData(imageData, 0,0);

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
    setBrightness( -5 );
 
    reDraw(origImageData); 
  });

  $("#brightness-plus").click(function (event) {

    setBrightness( +5 );

    reDraw(origImageData); 
  });

  $("#contrast-minus").click(function (event) {
      setContrast(-4);
      reDraw(origImageData);
  });

  $("#contrast-plus").click(function (event) {
    setContrast(+4);
    reDraw(origImageData);
  });

  $("#reset-image").click(function (event) {
    setContrast(-contrastValue);
    setBrightness(-brightnessValue);
    ctx.putImageData(origImageData, 0,0);
  });
});
