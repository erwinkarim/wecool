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


  Paloma.callbacks['mediasets']['index'] = function(params){
    // Do something here.
    var isFeatured = true;
    var theView = 'normal'; 

    $.ajax({
      url: '/mediasets/get_more/' + params['last_id'] ,
      data: {includeFirst:true, limit:10, featured:isFeatured, viewType:theView },
      beforeSend: indicator.load('.last-div', 'after'),
      dataType: 'script'
    });

    $(document).endlessScroll({
      fireOnce: true,
      fireDelay: 500, 
      bottomPixels: 250, 
      intervalFrequency: 100, 
      ceaseFireOnEmpty: false, 
      ceaseFire: function(){
        return $('.last-div').length ? false : true;
      }, 
      loader: '<div>loading...</div>', 
      callback: function(){
          $.ajax({
            url: '/mediasets/get_more/'+$('.endless-mediaset').attr('last'), 
            data: { featured:isFeatured, viewType:theView  } ,
            beforeSend: indicator.load('.last-div', 'after'),
            dataType: 'script'
          });
      } 
    });

    $(document).ready ( function(){
      $('.last-div').css('min-height', $(window).height());

      //event when the type of mediaset is clicked
      $('#mediasetTypeSelectorTab li').click( function(event){
        event.preventDefault();
        $('.active').toggleClass('active');
        $(this).toggleClass('active'); 

        //empty out and repopulate
        $('.last-div').empty();
        //$('.endless-mediaset').attr('last', '<%= Mediaset.last.id %>');
        $('.endless-mediaset').attr('last', params['last_id'] );

        isFeatured = $('#recentlyFeatured').hasClass('active') ? 'true' : ['true', 'false'];
        if ( $('#recentlyTracked').hasClass('active') ) {
          theView = 'tracked'; 
        } else if ( $('#recentlyTrendy').hasClass('active') == true ) {
          theView = 'trending';
          $('.endless-mediaset').attr('last', '0');
        } else {
          theView = 'normal';
        }

        $.ajax({
          url: '/mediasets/get_more/'+ $('.endless-mediaset').attr('last') , 
          data: { featured:isFeatured, viewType:theView, includeFirst:true },
          beforeSend: indicator.load('.last-div', 'after'),
          dataType: 'script'
        });
      });

      //manually load more mediasets
      $('#getMoreSets').click( function(){
        $.ajax({
          url: '/mediasets/get_more/'+ $('.endless-mediaset').attr('last') , 
          data: { featured:isFeatured, viewType:theView },
          beforeSend: indicator.load('.last-div', 'after'),
          dataType: 'script'
        });
      });
    });
  };
})();
