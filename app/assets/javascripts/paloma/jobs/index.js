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
            (data[i].url==null) ? 
              $('<td/>', { text:data[i].type })
            :
              $('<td/>').append(
                $('<a/>', { text:data[i].type, href:data[i].url })
              )
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
              $('#loading-jobs').hide('slow');
              $('#zero-jobs-display').show();
            } else {
              $('#jobs-table').show();
              $('#loading-jobs').hide();
              console.log(data);
              
              populate_table(data);
            }
          }
        }
      );

      $('#refresh-jobs-list').bind('click', function(){
        $('#refresh-jobs-list').addClass('fa-spin');
        $.ajax( window.location.pathname + '/100/get_more', 
          {
            dataType:'json',
            success: function(data, textStatus, jqXHR){
              //clear the table and repopulate the data
              if(data.length==0){
                $('#jobs-table').hide();
                $('#zero-jobs-display').show();
              } else {
                $('#jobs-table').find('tbody').empty();
                populate_table(data);
              }
              $('#refresh-jobs-list').removeClass('fa-spin');
            }
          }
        );
      });
    });
  }; // Paloma.callbacks['jobs']['index'] = function(params){
})();
