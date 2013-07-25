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


  Paloma.callbacks['personas']['index'] = function(params){
    // Do something here.
   
    callback_fn = function( first){
      $.ajax({
        url: '/personas/get_more/' + $('.endless_scroll_inner_wrap').attr('last') ,
        data: { includeFirst:first },
        beforeSend: indicator.load('.last-div', 'after'),
        dataType: 'script'
      });
    };

    //get the first few personas
    callback_fn( true );

    //keep loading personas until the end
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
            data: { includeFirst:false },
            beforeSend: indicator.load('.last-div', 'after'),
            dataType: 'script'
          });
      }, 
    });

    $(document).ready( function(){
      $('#load-more-personas').click( function(){
        $.ajax({
          url: '/personas/get_more/' + $('.endless_scroll_inner_wrap').attr('last') ,
          data: { includeFirst:false },
          beforeSend: indicator.load('.last-div', 'after'),
          dataType: 'script'
        });
      });
    });
  };
})();
