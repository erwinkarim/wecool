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
  var _l = _L['store'];


  Paloma.callbacks['store']['checkout'] = function(params){
    // Do something here.
		$(document).ready( function(){
			$('.best_in_place').best_in_place();
			$('.best_in_place').bind('ajax:success', function(){
				//update total amount etc. 
				var handle = $(this).closest('tr');
				handle.find('.total_price').text(
					handle.find('.unit_price').text() * handle.find('.quantity').text()
				);

				//update grand total amount
			});
		}); // $(document).ready( function(){
  }; // Paloma.callbacks['store']['checkout'] = function(params){
})();
