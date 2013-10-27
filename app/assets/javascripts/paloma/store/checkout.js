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
				console.log('updating total amount');

				//update total amount etc. 
				var handle = $(this).closest('tr');
				handle.find('.total_price').text(
					handle.find('.unit_price').text() * handle.find('.quantity').text()
				);

				//update grand total amount
				var total_sum = 0;
				$('.cart-item').each( function(){
					total_sum += $(this).find('.unit_price').text() * $(this).find('.quantity').text();
				});
				$('.checkout-amount').text(total_sum);
			});
		}); // $(document).ready( function(){
  }; // Paloma.callbacks['store']['checkout'] = function(params){
})();
