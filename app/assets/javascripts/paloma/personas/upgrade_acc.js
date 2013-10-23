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


  Paloma.callbacks['personas']['upgrade_acc'] = function(params){
    // Do something here.
    $(document).ready( function() {

      //add subscription package to cart, and then ask for CC info
      $('#buy_premium_form').on( 'ajax:beforeSend', function(){
        $('#purchase_premium_btn').button('loading');
      }).on( 'ajax:complete', function(){
        $('#purchase_premium_btn').button('reset');
      });
    });
  }; // Paloma.callbacks['personas']['upgrade_acc'] = function(params){
})();
