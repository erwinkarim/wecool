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


  Paloma.callbacks['photos']['transform_exp'] = function(params){
    // Do something here.
		$(document).ready( function(){
			var img_handle = $('#img-handle');

			$('#rotate-left').click( function(){
				console.log('rotate left clicked');
				img_handle.css('transform', 'rotate(90deg)');
			});

			$('#rotate-right').click( function(){
				console.log('rotate right clicked');
				img_handle.css('transform', 'rotate(270deg)');
			});
		}); // $(document).ready( function(){
  }; // Paloma.callbacks['photos']['transform_exp'] = function(params){
})();
