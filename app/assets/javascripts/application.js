// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require indicator
//= require jquery.endless-scroll
//= require best_in_place
//= require paloma
//= require spark-md5
//

$(document).ready( function(){
	$('#feedback-box').find('a').popover(
		{
			html: true,
			content: function(){
				var theContent = $('<form/>', 
          { 
            action:'/static/feedback', 'data-remote':true, id:'feedback-box-form', style:'z-index:1;', 
            method:'post' 
          } 
        ).append( 
          $('<label/>', { 
            text:'We appreciate your feedback. Please tell us know how we can improve sirap.co for you.' 
          })
        ).append(
          $('<input/>', { name:'source-page', type:"hidden", value:window.location.pathname })
        ).append(
          $('<textarea/>', { name:'comment', cols:30, rows:5 } )
        ).append(
          $('<button/>', 
            { type:'submit', class:'btn btn-primary', id:'send-feedback-btn', text:'Send' }
          ).bind( 'click', function(){
            $('#feedback-box-form').fadeTo( 'fast', 0.33).after(
              $('<i/>', {
                class:'fa fa-spinner fa-4x fa-spin', id:'sending-feedback', 
                style:'position:absolute; top:50%; left:50%; z-index:2; margin-left:-24px; margin-top:-27px;' 
              })
            )
          })
        ).after(
          $('<div/>', { test:'test' })
        );
				return theContent;
			}
		}
	).bind('click', function(event){
    event.preventDefault();
		$(this).parent().toggleClass('span2');
		$(this).parent().toggleClass('span3');
	});
});
