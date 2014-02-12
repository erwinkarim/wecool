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
    $(document).ready( function(){
      //start loading past jobs
      //
      var populate_jobs_table = function(data){
        if(data.length > 0){
          //remove spinner
          $('#loading-jobs').hide('slow');
          //load data into the table
          $('#jobs-table').show('slow');
          $.each( data, function(index,value){
            console.log(data[index].handler);
          });
        } else {
          // show no pending jobs
        }
      };

      $.ajax(
        window.location + '/100/get_more', {
          dataType: 'script'
        }
      );
    });
  }; // Paloma.callbacks['jobs']['index'] = function(params){
})();
