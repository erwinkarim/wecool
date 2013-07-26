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


  Paloma.callbacks['tags']['index'] = function(params){
    // Do something here.
    console.log('got called');
    $(document).ready( function(){
      $('#tagsResults').css('min-height', $(window).height()); 
      var sendParams = { mode: 'recent' } 

      //load initial content
      if ( params['persona'] != 0) {
        sendParams['persona_range'] = params['persona'];
      };

      $.ajax({
        url: '/tags/get_more',
        data: sendParams, 
        beforeSend: indicator.tagLoad('#tagcontent'),
        dataType: 'script'
      });

      //load more tags
      $('#loadMoreTags').click( function(){
        sendParams['offset'] = parseInt( $('#tagsResults').attr('results') );
        $.ajax({
          url: '/tags/get_more',
          data: sendParams, 
          beforeSend: indicator.tagLoad('#tagcontent'),
          dataType: 'script'
        });

      });

      //reload when the tab changes
      $('#trendytags li').click( function(event){
        event.preventDefault();
        $('.active').toggleClass('active');
        $(this).toggleClass('active');
        $('#tagsResults').attr('results', '0');
        sendParams['mode'] = $('#recentTags').hasClass('active') ? 'recent' : 'trending';

        if ( params['persona'] != 0) {
          sendParams['persona_range'] = params['persona'];
        };
        //reload tags
        $('#tagcontent').empty();
        $.ajax({
          url: '/tags/get_more',
          data: sendParams, 
          beforeSend: indicator.tagLoad('#tagcontent'),
          dataType: 'script'
        });
      });

    });
  }; // Paloma.callbacks['tags']['index'] = function(params){
})();
