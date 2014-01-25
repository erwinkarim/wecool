var indicator = {};

//some spinning picture to indicate the pictures are comming
//arguments: target => required. which accordion to put the load in
//            position => required. to prepend or append the load icons
//            css_float => optional. css float property. defaults to 'left'
//            css_display => optional. css display property. defaults to 'block'
indicator.load = function(target, position, css_float, css_display ){
  css_float = typeof css_float !== 'undefined' ? css_float : 'left';
  css_display = typeof css_display !== 'undefined' ? css_display : 'block';
    
	spin = '<div class="loading" style="float:'+ css_float + '; display:' + css_display + 
    '"><i class="fa fa-spinner fa-4x fa-spin"></i></div>';
  if ($(target).find('.carousel').length == 0) {
    //if there's nothing inside, just append inside
    $(target).append(spin);
  } else if ( position == 'before') {
		handle = $(target).find('.carousel:first');
		handle.before(spin);
	} else if ( position == 'after') {
		handle = $(target).find('.carousel:last');
		handle.after(spin);
	};
};

//indicate loading at tag index page
indicator.tagLoad = function( target ){
  spin = '<tr class="loading"><td><i class="fa fa-spinner fa-4x fa-spin"></i></td></tr>';

  if( $(target).find('tr').length == 0 ) {
    $(target).append(spin);
  } else {
    $(target).find('tr:last').after(spin);
  };
};

