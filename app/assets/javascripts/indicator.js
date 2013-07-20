var indicator = {};

//some spinning picture to indicate the pictures are comming
//arguments: target => which accordion to put the load in
//            position => to prepend or append the load icons
indicator.load = function(target, position){
	spin = '<div class="loading" style="float:left;"><i class="icon-spinner icon-4x icon-spin"></i></div>';
	if ( position == 'before') {
		handle = $(target).find('.carousel:first');
		handle.before(spin);
	} else if ( position == 'after') {
		handle = $(target).find('.carousel:last');
		handle.after(spin);
	};
};

