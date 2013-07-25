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
  var _l = _L['tags'];


  Paloma.callbacks['tags']['show'] = function(params){
		//get the first few
		if ( params['persona'] == '' ){
			var params = { mediatype:'tagset', tag:params['tag'] , includeFirst:true, size:'small' }
		} else {
			var params = { mediatype:'tagset', tag:params['tag'] , includeFirst:true, size:'small', 
			author:params['persona'] }
		}

		$.ajax({
			url: '/photos/get_more/0',
			data: params,  
			beforeSend: indicator.load('.last-div', 'after'),
			dataType: 'script'
		});

		//keep loading until the end
		$(document).endlessScroll({
			fireOnce: true,
			fireDelay: 500, 
			bottomPixels: 250, 
			intervalFrequency: 100, 
			ceaseFireOnEmpty: false, 
			ceaseFire: function(){
				return $('.last-div').length ? false : true;
			}, 
			loader: '<div class="pull-left">loading...</div>', 
			callback: function(){
					$.ajax({
						url: '/photos/get_more/'+$('.endless-photos').attr('last'), 
						data: params,
						beforeSend: indicator.load('.last-div', 'after'),
						dataType: 'script'
					});
			}, 
			ceaseFire: function(s){
				s<5 ? false : true;
			}
		});

		//load more photos
		$(document).ready( function(){
			$('#load-more-photos').click( function(){
				$.ajax({
					url: '/photos/get_more/' + $('.endless-photos').attr('last') ,
					data: params,
					beforeSend: indicator.load('.last-div', 'after'),
					dataType: 'script'
				});
			});  

			$('#photoSelector li').click( function(event){
				event.preventDefault();
				$(this).parent().children().toggleClass('active');
				//reload the photos according the featured or not...
				params['featured'] = $('#featuredPhoto').hasClass('active') ? 'true' : ['true','false'];

				$('.last-div').children().detach();
				$('.endless-photos').attr('last','0');
				$.ajax({
					url: '/photos/get_more/' + $('.endless-photos').attr('last') ,
					data: params,
					beforeSend: indicator.load('.last-div', 'after'),
					dataType: 'script'
				});
			});
		});
  }; // Paloma.callbacks['tags']['show'] = function(params){
})();
