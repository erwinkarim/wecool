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
  var _l = _L['personas'];


  Paloma.callbacks['personas']['get_picture'] = function(params){
    // Do something here.
    $(document).ready(function(){

      //allow box to be droppable
      $('#drop-target').droppable({
        accept:'img',
        drop: function(even, ui){
          setNewProfilePic(ui.draggable);
        }
      });    

      //handle items being dropped
      function setNewProfilePic($item){
        $('#drop-target').empty();
        $.ajax({
          url: '/photos/' + params['persona'] + '/get_single/' + $item.attr('id').split('_')[1],
          data: { size:'medium' }, 
          dataType: 'script'
        }).always( function (data){
          $('#drop-target').append(data.responseText);
          $('#selected_photo_path').val( $('#drop-target img').attr('src') );
          //add corp function to picture
          $( function(){
            $('.get_single_photo').Jcrop({
              aspectRatio:1, minSize:[75,75],
              allowSelect:false,
              onChange:updateCoor, setSelect:[0,0,75,75]
            });
          });
        });
      }

      function updateCoor(c){
        $('#x_coor').val(c.x);
        $('#y_coor').val(c.y);
        $('#h_coor').val(c.h);
        $('#w_coor').val(c.w);
      }

    });
  }; // Paloma.callbacks['personas']['get_picture'] = function(params){
})();
