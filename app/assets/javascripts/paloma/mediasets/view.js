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


  Paloma.callbacks['mediasets']['view'] = function(params){
    // Do something here.
    var loadConditions= {limit:10, size:'small', includeFirst:'true', mediatype:'mediaset',
      mediaset_id:params['mediaset_id'] , featured:['true', 'false'] };
    $('.last-div').css('min-height', $(window).height() + 'px');
    $.ajax({
      url: '/photos/get_more/1',
      data: loadConditions, 
      beforeSend: indicator.load('.last-div', 'after'),
      dataType: 'script'
    });

    $(document).ready( function(){

       //handle showing all/features photos
       $('.view-mode').click( function(event){
          event.preventDefault();
          $('#mediaset-show-all-photos').toggleClass('active');
          $('#mediaset-show-featured-photos').toggleClass('active');
          
          loadConditions['featured'] = $('#mediaset-show-all-photos').hasClass('active') ? 
            ['true', 'false'] : 'true';
          loadConditions['includeFirst'] = true;
          $('.last-div').find('.carousel').detach();
          $('.endless-photos').attr('last', '0');
          $.ajax({
            url: '/photos/get_more/0',
            data: loadConditions, 
            beforeSend: indicator.load('.last-div', 'after'),
            dataType: 'script'
          });
        });  
    });
    //load first 10

    //load the rest as you scroll
    $(document).endlessScroll({
      fireOnce: true,
      fireDelay: 500, 
      bottomPixels: 50, 
      intervalFrequency: 100, 
      ceaseFireOnEmpty: false, 
      ceaseFire: function(){
        return $('.last-div').length ? false : true ;
      }, 
      loader: '<div>loading...</div>', 
      callback: function(){
        loadConditions['includeFirst'] = false;
        $.ajax({
          url: '/photos/get_more/'+$('.endless-photos').attr('last'), 
          beforeSend: indicator.load('.last-div', 'after'),
          dataType: 'script', 
          data: loadConditions
        });
      }, 
      ceaseFire: function(s){
        s<5 ? false : true;
      }
    });

  };
})();
