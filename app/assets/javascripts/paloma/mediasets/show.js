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


  Paloma.callbacks['mediasets']['show'] = function(params){
    // Do something here.
    if ( params['has_mediaset'] ) {
      isFeatured = true
      $.ajax({
        url: '/mediasets/get_more/' + params['mediaset_id'], 
        data: {includeFirst:true, persona:params['persona_id'] , featured:true }, 
        dataType: 'script'
      });
    }

    //endless scrolls of mediasets, hua hahahahahh
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
            data: { persona:params['persona_id'] , featured:isFeatured } ,
            dataType: 'script'
          });
      }, 
      ceaseFire: function(s){
        s<5 ? false : true;  
      }
    });

    $(document).ready( function(){
      $('.last-div').css('min-height', $(window).height());

      //handle nav bar 
      $('#mediasetTypeSelectorTab').find('.mediaset-selector').click( function(event){
        event.preventDefault(); 
        $(this).parent().find('.active').toggleClass('active');
        $(this).toggleClass('active');

        //empty out and repopulate
        $('.last-div').empty();
        isFeatured = $('#recentlyFeatured').hasClass('active') ? 'true' : ['true', 'false'];
        if (params['has_mediaset']){ 
          $('.endless-mediaset').attr('last', params['mediaset_id'] );
        }
        $.ajax({
          url: '/mediasets/get_more/'+ $('.endless-mediaset').attr('last'),
          data: { persona:params['persona_id'] , featured:isFeatured, includeFirst:true }, 
          dataType: 'script'
        });
      });

      //manually load more mediasets
      $('#getMoreSets').click( function(){
        $.ajax({
          url: '/mediasets/get_more/'+ $('.endless-mediaset').attr('last') , 
          data: { featured:isFeatured, persona:params['persona_id'] },
          dataType: 'script'
        });
      });

    });
  }; // Paloma.callbacks['mediasets']['show'] = function(params){
})();
