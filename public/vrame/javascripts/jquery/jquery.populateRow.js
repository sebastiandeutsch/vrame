jQuery.fn.populateRow = function(source, dest, options) {
	var $ = window.jQuery,
		noop = new Function,
		defaults = {
			add : noop,
			remove : noop,
			removeSelector : 'a.remove',
			removeParentSelector : null,
			fx : 'fadeIn'
		},
		opts = $.extend(defaults, options);
	
	this.click(add);
	$(dest).find(opts.removeSelector).click(remove);
	
	return this;
	
	function add (e) {
		e.preventDefault();
		/* Current behavior: Do not copy event handlers */
		var clone = $(source).clone().appendTo(dest);
		clone[opts.fx]();
		clone.find(opts.removeSelector).click(remove);
		opts.add(clone);
	}
	
	function remove (e) {
		e.preventDefault();
		var removeButton = $(this), parent;
		if (opts.removeParentSelector) {
			parent = removeButton.parents(opts.removeParentSelector).eq(0);
		} else {
			parent = removeButton.parent();
		}
		var returnValue = opts.remove(parent);
		if (returnValue === undefined || returnValue) {
			parent.remove();
		}
	}
	
};