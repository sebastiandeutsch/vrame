(function () {
	
	var ap = Array.prototype,
		fp = Function.prototype;
	
	function convert (obj, sliceStart) {
		return ap.slice.apply(obj, sliceStart);
	};
	
	if (!fp.curry) {
		fp.curry = f_Function_prototype_curry;
	}
	
	if (!fp.bind) {
		fp.bind = f_Function_prototype_bind;
	}
	
	function f_Function_prototype_curry () {
		if (arguments.length == 0) {
			return this;
		}
		var method = this,
			bindArgs = convert(arguments);
		return function f_curried_function () {
			var mergedArgs = bindArgs.concat( convert(arguments) );
			return method.apply(this, mergedArgs);
		};
	}
	
	function f_Function_prototype_bind (context) {
		var length = arguments.length,
			method = this,
			bindArgs;
		if (length == 0) {
			return this;
		}
		bindArgs = length > 1 ? convert(arguments, 1) : [];
		return function f_bound_function () {
			var mergedArgs = bindArgs.concat( convert(arguments) );
			return method.apply(context, mergedArgs);
		};
	}
	
})();

jQuery(function($) {
	
	/* Main Navigation */
	$('#nav').droppy({ speed: 0 });
	
	/* News flashes */
	$('.flash').click(function() {
		$(this).fadeOut();
	});
	
	/* Expandable sections */
	$('.expandable').click(function() {
		$($(this).attr('href')).slideToggle();
		return false;
	});
	
	/* Tooltips */
	$('.tooltip').tipsy({ gravity: 'w' });
	
	/* Rich Text Editing Textareas */
	$('.rte-zone').rte({
		media_url : '/vrame/images/rte/',
		content_css_url: '/vrame/stylesheets/rte.css'
	});
	
	/* Date picker */
	if ($('.datepicker').size() > 0) {
		$('.datepicker').datepicker({
			duration: '',  
			showTime: true,  
			constrainInput: false
		});
	}
	
	/* Input field placeholder text */
	$('input[type=text][placeholder], textarea[placeholder]').placeholder();
	
	/* give window.name a unique id */
	function generateUUID () {
		return +new Date;
	}
	
	if(!window.name) {
		window.name = generateUUID();
	}
});
