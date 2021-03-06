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


  Paloma.callbacks['photos']['view'] = function(params){
    // Do something here.

    $('.best_in_place').best_in_place(); 

    //load normal photos
    $.ajax({
      url: '/photos/get_more/' + params['photo_id'],
      data: { size:'square100', showCaption:false, targetDiv:'#photostream', photoCountDiv:'#photostream', 
        includeFirst:true, author:params['screen_name'], showIndicators:false, highlight:true, limit:4 ,
        photoFocusID:params['photo_id'] },
      beforeSend: indicator.load('#photostream', 'after'),
      dataType: 'script'
    });
    $.ajax({
      url: '/photos/get_more/' + params['photo_id'],
      data: { size:'square100', showCaption:false, targetDiv:'#photostream', photoCountDiv:'#photostream', 
        author:params['screen_name'], showIndicators:false, highlight:true, limit:3, direction:'reverse' },
      dataType: 'script'
    });


    if (params['featured_photo']) {
      //load featured photos
      $.ajax({
        url: '/photos/get_more/' + params['photo_id'],
        data: { size:'square100', showCaption:false, targetDiv:'#featuredPhotos', photoCountDiv:'#featuredPhotos', 
          featured:true, includeFirst:true, author:params['screen_name'], mediatype:'featured', showIndicators:false, highlight:true, limit:4, photoFocusID:params['photo_id'] },
        beforeSend: indicator.load('#featuredPhotos', 'after'),
        dataType: 'script'
      });
      $.ajax({
        url: '/photos/get_more/' + params['photo_id'],
        data: { size:'square100', showCaption:false, targetDiv:'#featuredPhotos', photoCountDiv:'#featuredPhotos', 
          featured:true, author:params['screen_name'], mediatype:'featured', showIndicators:false, 
          highlight:true, direction:'reverse', limit:3 },
        dataType: 'script'
      });
    }

		//should optimize this, load only when necessary
    //load each mediaset
    for(i = 0; i < params['mediaset_ids'].length; i++){
      //load mediaset photos
      $.ajax({
        url: '/photos/get_more/' + $('#mediaset-' + params['mediaset_ids'][i] ).attr('last') ,
        data: { size:'square100', showCaption:false, targetDiv:'#mediaset-' + params['mediaset_ids'][i], 
          photoCountDiv:'#mediaset-' + params['mediaset_ids'][i], 
          mediaset_id:params['mediaset_ids'][i],  includeFirst:true, mediatype:'mediaset', showIndicators:false, 
          highlight:true, limit:3, photoFocusID:params['photo_id'] },
        beforeSend: indicator.load('#mediaset-' + params['mediaset_ids'][i], 'after'),
        dataType: 'script'
      });
      $.ajax({
        url: '/photos/get_more/' + $('#mediaset-' + params['mediaset_ids'][i] ).attr('last') ,
        data: { size:'square100', showCaption:false, targetDiv:'#mediaset-' + params['mediaset_ids'][i] , 
          photoCountDiv:'#mediaset-' + params['mediaset_ids'][i] , mediaset_id:params['mediaset_ids'][i] ,  
          mediatype:'mediaset', showIndicators:false, highlight:true, limit:3, direction:'reverse' },
        dataType: 'script'
      });
    }

    //load related photos
    $.ajax({
        url: '/photos/get_more/0',
        data: { size:'square100', showCaption:false, targetDiv:'#related-photos', 
          photoCountDiv:'#related-photos', mediatype:'related', showIndicators:false, limit:7,
          focusPhotoID:params['photo_id'] },
        beforeSend: indicator.load('#related-photos', 'after'),
        dataType: 'script'
    });

    //for normal users 
    $(document).ready(function(){
				var add_spinner = function(){
					$(document).find('.active').find('img').fadeTo(400, 0.5).after( $('<i/>', 
						{ class:'fa fa-spinner fa-spin fa-4x', 
              style:'z:index-2; position:absolute; top:50%; left:50%; margin-left:-25px; margin-top:-28px; ' } 
            )
					);
          if($('#editMenu').parent().hasClass('open') ){
            $('#editMenu').dropdown('toggle');
          };
          
				};
				var remove_spinner = function(){
					$(document).find('.active').find('img').fadeTo(400, 1);
					$(document).find('.active').find('.fa-spinner').remove();
				};

        //hide the caption and control, appear on mouse hover
        $('.carousel-caption').hide();
        $('.carousel-control').hide();
        $('.carousel-indicators').hide().bind('ajax:before', add_spinner).bind('ajax:complete', remove_spinner);
        $('#rotate-left').bind('ajax:before', add_spinner).bind('ajax:complete', remove_spinner);
        $('#rotate-right').bind('ajax:before', add_spinner).bind('ajax:complete', remove_spinner);
        $('.carousel').hover(
          function(){ 
            $('.carousel-caption').fadeIn('slow');
            $('.carousel-control').fadeIn('slow');
            $('.carousel-indicators').fadeIn('slow');
          }, function(){ 
            $('.carousel-caption').fadeOut('slow');
            $('.carousel-control').fadeOut('slow');
            $('.carousel-indicators').fadeOut('slow');
          }
        );

				//add title and description of the photo

				//add visibility button if picture owner
        if( $('.isFeatured').hasClass('fa-star') ){
          $('#visibilityBox').find('a').popover();
        }
        

				//bind the rest of the buttons that is visible
        $('#loadPrevPhotosBtn').click( function(){
          //load more
          $.ajax({
            url: '/photos/get_more/' + $('#photostream').attr('first'), 
            data: { size:'square100', showCaption:false, targetDiv:'#photostream', photoCountDiv:'#photostream', 
              author:params['screen_name'], showIndicators:false, direction:'reverse' },
            beforeSend: indicator.load('#photostream', 'before'),
            dataType: 'script'
          })
        });

        $('#loadMorePhotosBtn').click( function(){
          //load more
          $.ajax({
            url: '/photos/get_more/' + $('#photostream').attr('last'), 
            data: { size:'square100', showCaption:false, targetDiv:'#photostream', photoCountDiv:'#photostream', 
              author:params['screen_name'], showIndicators:false},
            beforeSend: indicator.load('#photostream', 'after'),
            dataType: 'script'
          });
        });

        $('#loadNewerFeaturedBtn').click( function(){
          $.ajax({
            url: '/photos/get_more/' + $('#featuredPhotos').attr('first'), 
            data: { size:'square100', showCaption:false, targetDiv:'#featuredPhotos', 
              photoCountDiv:'#featuredPhotos', featured:true, author:params['screen_name'], mediatype:'featured', 
              showIndicators:false, direction:'reverse' },
            beforeSend: indicator.load('#featuredPhotos', 'before'),
            dataType: 'script'
          });
        });

        $('#loadOlderFeaturedBtn').click( function(){
          //load more
          $.ajax({
            url: '/photos/get_more/' + $('#featuredPhotos').attr('last'), 
            data: { size:'square100', showCaption:false, targetDiv:'#featuredPhotos', 
              photoCountDiv:'#featuredPhotos', featured:true, author:params['screen_name'], mediatype:'featured', 
              showIndicators:false },
            beforeSend: indicator.load('#featuredPhotos', 'after'),
            dataType: 'script'
          });
        });

        $.each( params['mediaset_ids'], function(i,v) {
          $('#loadNewerMediaset-' + v + '-btn').click( function(){
            $.ajax({
              url: '/photos/get_more/' + $('#mediaset-' + v ).attr('first') ,
              data: { size:'square100', showCaption:false, targetDiv:'#mediaset-' + v, 
                photoCountDiv:'#mediaset-' + v , mediaset_id:v, 
                mediatype:'mediaset', showIndicators:false, direction:'reverse' },
              beforeSend: indicator.load('#mediaset-' + v, 'before'),
              dataType: 'script'
            });

          });

          $('#loadOlderMediaset-' + v + '-btn').click( function(){
            $.ajax({
              url: '/photos/get_more/' + $('#mediaset-' + v).attr('last') ,
              data: { size:'square100', showCaption:false, targetDiv:'#mediaset-' + v,  
                photoCountDiv:'#mediaset-' + v,  mediaset_id:v,   
                mediatype:'mediaset', showIndicators:false },
              beforeSend: indicator.load('#mediaset-' + v,  'after'),
              dataType: 'script'

            });
          });
        });

        $('#loadMoreRelatedBtn').click( function(){
          $.ajax({
              url: '/photos/get_more/' + $('#related-photos').attr('last'),
              data: { size:'square100', showCaption:false, targetDiv:'#related-photos', 
                photoCountDiv:'#related-photos', mediatype:'related', showIndicators:false, limit:7,
                focusPhotoID:params['photo_id'] },
              beforeSend: indicator.load('#related-photos', 'after'),
              dataType: 'script'
          });
        })

    }); //$(document).ready(){}

		//configure keypress for the page
    $(document).keydown(function (e) {
      var keyCode = e.keyCode || e.which,
          arrow = {left: 37, up: 38, right: 39, down: 40 };

      switch (keyCode) {
        case arrow.left:
          $(location).attr('href', params['prev_photo_path'] );
        break;
        case arrow.right:
          $(location).attr('href', params['next_photo_path'] );
        break;
      }
    });

  }; // Paloma.callbacks['photos']['view'] = function(params){

})();
