jQuery.fn.populateRow = function(source, dest, options) {
	var defaults = {
	    add : function() {},
	    remove : function() {},
		removeSelector : 'a.remove',
		fx : 'fadeIn'
	};
	
	var opts = jQuery.extend(defaults, options);

	if(opts.removeSelector != null) {
		jQuery(dest).find(opts.removeSelector).click(function(e) {
			jQuery(this).parent().remove();
			e.preventDefault();
		});
	}
	
	jQuery(this).click(function() {
		var cloneDiv = jQuery(source).clone(true);
		if(opts.fx != null) {
			cloneDiv.hide();
		}
		
		jQuery(dest).append(cloneDiv);
		if(opts.fx != null) {
			cloneDiv[opts.fx]();
		}
		
		if(opts.removeSelector != null) {
			jQuery(opts.removeSelector, cloneDiv).click(function (e) {
				if(opts.remove(cloneDiv) !== false) {
					cloneDiv.remove();
				}
			});
			return false;
		}
		opts.add(cloneDiv);
		
		return false;
	});
}
