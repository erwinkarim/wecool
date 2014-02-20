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
        $('#get-more-jobs-row').before(
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
          ).append(
            $('<td/>', { text:data[i].attempts })
          )
        );
      }
      $('#get-more-jobs').attr('data-job-id', 
        Math.min.apply( Math, data.map( function(o) { return o.id }) )
      );
    };

    $(document).ready( function(){
      //start loading past jobs
			//TODO: auto refresh jobs table
      $.ajax( window.location.pathname + '/get_more', 
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
              
              populate_table(data);
            }
          }
        }
      );

			//setup refresh buttons
			$('.refresh-jobs-list').click(function(){
				//$('.refresh-jobs-list').find('i').addClass('fa-spin');
				$(this).find('i').addClass('fa-spin');
				$.ajax( window.location.pathname + '/get_more', 
					{
						dataType:'json',
						success: function(data, textStatus, jqXHR){
							//clear the table and repopulate the data
							if(data.length==0){
								$('#jobs-table').hide();
								$('#zero-jobs-display').show();
							} else {
								$('#jobs-table').show();
								$('#zero-jobs-display').hide();
								var getMoreHandle = $('#jobs-table').find('tbody').find('#get-more-jobs-row').detach();
								$('#jobs-table').find('tbody').empty();
								$('#jobs-table').find('tbody').append(getMoreHandle);
								populate_table(data);
							}
							$('.refresh-jobs-list').find('i').removeClass('fa-spin');
						}
					}
				);
			});
			
			//setup get more jobs button
			$('#get-more-jobs').on('click', function(event){
        event.preventDefault();
				$('#get-more-jobs-row').before(
					$('<tr/>', { id:'get-more-spinner' }).append(
						$('<td/>', { colspan:5, style:'text-align:center;'} ).append(
							$('<i/>', {class:'fa fa-spinner fa-4x fa-spin'})
						)
					)
				);
        $.ajax( $(this).attr('href'), {
          data:{ 'job-id': $(this).attr('data-job-id')  },
          dataType:'json'
        }).done(function( data, textStatus, jqXHR){
          //add new data
          $('#get-more-spinner').remove();
          if(data.length != 0){ 
            populate_table(data);
            $('#get-more-jobs').attr('data-job-id', data[data.length-1].id);
          }
        });
      }).on('ajax:before', function(){
      });

    }); // $(document).ready( function(){
  }; // Paloma.callbacks['jobs']['index'] = function(params){
})();
