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
  var _l = _L['mediasets'];


  Paloma.callbacks['mediasets']['form'] = function(params){
    // Do something here.

		$(document).ready(function (){
			var getConditions = {};
			getConditions = {limit:20, includeFirst:'true', size:'square100', 
					author:params['persona_screen_name'] , showCaption:'false', excludeMediaset:params['exclude_mediaset'] , 
					draggable:true, dragSortConnect:'#mediaset-photo-listing', enableLinks:false, 
					float:false, cssDisplay:'inline-block', showIndicators:false, multipleSelect:true
			};

			$.ajax({
				url: '/photos/get_more/' + params['photo_last_id'], 
				data: getConditions, 
				beforeSend: indicator.load('.last-div', 'after', 'none', 'inline-block'),
				dataType: 'script'
			});

			/*
				Function declarations
			*/
			var mediasetPhotoListingClick = function(){
				var imageHandle = $(this).parent();
				imageHandle.find('.photo-listings-select').prop(
				'checked', !imageHandle.find('.photo-listings-select').prop('checked')
				);
				imageHandle.find('img').toggleClass('highlightPhoto');
			}

			//track changes on the photo selection dropdown
			$('#photo-listing-selector').change( function() {
				//var getConditions = {};
				if ($(this).val() == 'photoNotInSet'){
					getConditions = {
						limit:50, includeFirst:'true', size:'square100', 
						author:params['persona_screen_name'] , showCaption:'false', enableLinks:false, 
						excludeMediaset:params['exclude_mediaset'], draggable:true, dragSortConnect:'#mediaset-photo-listing',
						float:false, cssDisplay:'inline-block', showIndicators:false, multipleSelect:true
					}
				} else if ($(this).val() == 'photoAll'){
					getConditions = {
						limit:50, includeFirst:'true', size:'square100', 
						author:params['persona_screen_name'], showCaption:'false', enableLinks:false,
						draggable:true, dragSortConnect:'#mediaset-photo-listing',
						float:false, cssDisplay:'inline-block', showIndicators:false, multipleSelect:true
					}
				} else if($(this).val().substring(0,7) == 'photoOn' ) {
					getConditions = {
						limit:50, includeFirst:'true', size:'square100', 
						author:params['persona_screen_name'],  showCaption:'false', 
						dateRange:$(this).val().split('photoOn')[1], enableLinks:false, 
						draggable:true, dragSortConnect:'#mediaset-photo-listing',
						float:false, cssDisplay:'inline-block', showIndicators:false, multipleSelect:true
					}
				} else if($(this).val() == 'photoFeatured'){
					getConditions = {
						limit:50, includeFirst:'true', size:'square100', featured:true,  
						author:params['persona_screen_name'],  showCaption:'false',  enableLinks:false,
						excludeMediaset:params['exclude_mediaset'],  draggable:true, dragSortConnect:'#mediaset-photo-listing',
						float:false, cssDisplay:'inline-block', showIndicators:false, multipleSelect:true
					}
				}

				if( $(this).val() != 'ignore' ){
					$('.endless_scroll_inner_wrap').empty();
					$.ajax({
						url: '/photos/get_more/' + params['photo_last_id'], 
						data: getConditions,
						dataType: 'script'
					});
				}
			});

			//click to load more photos
			$('#loadMorePhotos').click( function(){
				getConditions.includeFirst = 'false';
				$.ajax({
					url: '/photos/get_more/' + $('#photo-list').attr('last'),
					data: getConditions,
					beforeSend: indicator.load('.last-div', 'after', 'none', 'inline-block'),
					dataType: 'script'
				});
			});
			
			//allow photos to be dropped from pool to image-setlist (add photo to setlist)
			$('#mediaset-photo-listings').droppable({
				accept:'.endless_scroll_inner_wrap img',
				drop: function( event, ui ){
					//addPhotoToMediaset(ui.draggable);
					addPhotoToMediaset(ui.helper.children());
				}
			});

			//allow the selected imagelist to be sortable
			$('#mediaset-photo-listings').sortable({
				//later, allow multi select and sort multiple element
			});

			//allow photos in the setlist be dropped into the pool (remove photo from setlist) 
			$('#photo-list').droppable({
				accept:'#mediaset-photo-listings .selected-img', 
				drop: function (event, ui){
					//revertPhotoToPool(ui.draggable);
					revertPhotoToPool(ui.helper.children() );
				}
			});

			//handle photo being dropped into the image setlist
			function addPhotoToMediaset( $item ){
				//$item is <img src="..."/><img src="..." />
				$item.each( function() {
					var idToLook = '#'  + $(this).attr('id');
					if( $('#mediaset-photo-listings').find(idToLook).length != 0){
						//skip this phoot
						console.log('skipping '+ idToLook);
					} else {
						//bind the image and imbdue w/ proper behavior when the image is clicked
						$(this).wrap(
							$('<div/>', { id:idToLook.split('#')[1],  class:'pull-left selected-img',
								style:'margin:4px; position:relative;'} )
						);
						$(this).attr('id', idToLook.split('#')[1]);
						$(this).bind('click', mediasetPhotoListingClick );

						var handle = $(this).parent();
						handle.prepend(
							$('<input/>', {
								class:'photo-listings-select', id:idToLook.split('#')[1], name:'selected[]',
								style:'display:none;', type:'checkbox', value:idToLook.split('_')[1]
							})
						);
						handle.prepend(
							$('<input/>', {
								name:'photo[]', id:idToLook.split('#')[1], value:idToLook.split('_')[1], 
								type:'checkbox', checked:'true', style:'display:none;'
							})
						);
						//add value and taken_at attribute
						handle.attr('value', $(this).attr('value'));
						handle.attr('taken_at', $(this).attr('taken_at'));
						$('#mediaset-photo-listings').append( handle );
						$('#mediaset-photo-listings').find('img').removeClass('highlightPhoto');
						//remove from where it's being dragged
						$('.endless_scroll_inner_wrap').find('#carousel_'+idToLook.split('_')[1]).detach();
					}
				});
			}

			//handle photo being dropped into the imagelist
			function revertPhotoToPool( $item){
				//$item.detach();
				//$('#mediaset-photo-checkbox').find('#' + $item.attr('id')).remove();
				$('#mediaset-photo-listings').find('#'+ $item.attr('id')).detach();
			}

			//for the #photo-pool
			//select all button
			$('#selectAllButton').click( function(){
				$('#photo-pool').find('.carousel').each( function() {
					if (!$(this).find('input').prop('checked') ) {
						$(this).find('img').click();
					}
				});      
			});

			//deselect all button
			$('#deselectAllButton').click( function(){
				$('#photo-pool').find('.carousel').each( function() {
					if ($(this).find('input').prop('checked') ) {
						$(this).find('img').click();
					}
				});      
			});

			//for the #mediaset-photo-listings pool
			$('#mediaset-photo-listings').find('img').click( mediasetPhotoListingClick );

			$('#setlist-select-all').click( function() {
				$('#mediaset-photo-listings').find('.selected-img').each( function(){
					if(!$(this).find('.photo-listings-select').prop('checked') ) {
						$(this).find('img').click();
					}
				});
			});

			$('#setlist-deselect-all').click( function() {
				$('#mediaset-photo-listings').find('.selected-img').each( function(){
					if($(this).find('.photo-listings-select').prop('checked') ) {
						$(this).find('img').click();
					}
				});
			});

			$('#sort-newest-upload-first').click( function(event){
				event.preventDefault();
				var handle = $('#mediaset-photo-listings').children().remove();
				handle.sort( function(a,b){
					return $(a).attr('value') > $(b).attr('value') ? -1 : 1;
				});
				$('#mediaset-photo-listings').append(handle);
				handle.each( function(){
					$(this).find('img').bind('click', mediasetPhotoListingClick);
				});
			});

			$('#sort-oldest-upload-first').click( function(event){
				event.preventDefault();
				var handle = $('#mediaset-photo-listings').children().remove();
				handle.sort( function(a,b){
					return $(a).attr('value') > $(b).attr('value') ? 1 : -1;
				});
				$('#mediaset-photo-listings').append(handle);
				handle.each( function(){
					$(this).find('img').bind('click', mediasetPhotoListingClick);
				});
			});

			$('#sort-newest-taken-first').click( function(event){
				event.preventDefault();
				var handle = $('#mediaset-photo-listings').children().remove();
				handle.sort( function(a,b){
					return $(a).attr('taken_at') > $(b).attr('taken_at') ? -1 : 1;
				});
				$('#mediaset-photo-listings').append(handle);
				handle.each( function(){
					$(this).find('img').bind('click', mediasetPhotoListingClick);
				});
			});

			$('#sort-oldest-taken-first').click( function(event){
				event.preventDefault();
				var handle = $('#mediaset-photo-listings').children().remove();
				handle.sort( function(a,b){
					return $(a).attr('taken_at') > $(b).attr('taken_at') ? 1 : -1;
				});
				$('#mediaset-photo-listings').append(handle);
				handle.each( function(){
					$(this).find('img').bind('click', mediasetPhotoListingClick);
				});
			});

			$('#setlist-remove-selected').click( function() {
				$('#mediaset-photo-listings').find('.selected-img').each( function() {
					if($(this).find('.photo-listings-select').prop('checked') ) {
						$(this).detach();
					}
				});
			});

		});//$(document).ready()
	}; //Paloma.callbacks
})();
