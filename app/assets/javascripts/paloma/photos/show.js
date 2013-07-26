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


  Paloma.callbacks['photos']['show'] = function(params){
    // Do something here.
    var isFeatured = $('#featured-photos').hasClass('active') ? true : ['true', 'false'];

    //get the first few
    $.ajax({
      url: '/photos/get_more/' + params['last_photo_id'], 
      data: {limit:10, includeFirst:'true', size:'small', author:params['pesona'], 
        featured:isFeatured }, 
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
      loader: '<div>loading...</div>', 
      callback: function(){
          $.ajax({
            url: '/photos/get_more/'+$('.endless-photos').attr('last'), 
            data: {limit:10, size:'small', author:params['persona'], featured:isFeatured}, 
            beforeSend: indicator.load('.last-div', 'after'),
            dataType: 'script'
          });
      }, 
      ceaseFire: function(s){
        s<5 ? false : true;
      }
    });
    
    $(document).ready(function(){
    $('.last-div').css('min-height', $(window).height());

     $('.photoType').click( function(event){
        event.preventDefault();
        $(this).parent().find('.photoType').toggleClass('active');
        //reload the photos

        $('.carousel').detach();
        isFeatured = $('#featured-photos').hasClass('active') ? true : ['true', 'false'];

        $.ajax({
          url: '/photos/get_more/' + params['last_photo_id'], 
          data: {limit:10, includeFirst:'true', size:'small', 
            author:params['persona'] , featured:isFeatured }, 
          beforeSend: indicator.load('.last-div', 'after'),
          dataType: 'script'
        });
      }); 
    });
  }; // Paloma.callbacks['photos']['show'] = function(params){
})();
