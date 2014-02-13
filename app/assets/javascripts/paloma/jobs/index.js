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
  var _l = _L['jobs'];


  Paloma.callbacks['jobs']['index'] = function(params){
    // Do something here.
    var populate_table = function(data){
      for(var i = 0; i<data.length; i++){
        $('#jobs-table').find('tbody').append(
          $('<tr/>').append(
            $('<td/>', { text:data[i].id })
          ).append(
            $('<td/>', { text:data[i].object_lnk })
          ).append(
            $('<td/>', { text:data[i].method_name })
          ).append(
            $('<td/>', { text:data[i].started })
          )
        );
      }
    };

    $(document).ready( function(){
      //start loading past jobs
      $.ajax( window.location.pathname + '/100/get_more', 
        {
          dataType:'json',
          success: function(data, textStatus, jqXHR){
            //check if got data or not
            if(data.length==0){
              console.log('no data');
            } else {
              $('#jobs-table').show();
              $('#loading-jobs').hide();
              console.log(data);
              
              populate_table(data);
            }
          }
        }
      );
    });
  }; // Paloma.callbacks['jobs']['index'] = function(params){
})();
