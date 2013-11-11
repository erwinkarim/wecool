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


  Paloma.callbacks['personas']['show'] = function(params){
    // Do something here.
		var get_activity = function() { 
			$.ajax(
				'/personas/' + params['screen_name'] + '/activities',
				{
					data: { begin_date:$('#recent-activity-body').attr('last') },
					dataType:'script',
					error: function(xhr, status, error) {
						console.log(status + ":" + error );
					}
				}
			);
		};

		$(document).ready( function(){

      //init load		
			get_activity();

			//when click get more activities
			$('#get-more-activities').click(function(e){
				e.preventDefault();

        $('#recent-activity-body').append(
          $.parseHTML('<tr id="loading-activities"><td><i class="icon-spinner icon-4x icon-spin"></i></td></tr>')
        );
				get_activity();
			});
    });
  }; // Paloma.callbacks['personas']['show'] = function(params){
})();
