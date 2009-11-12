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
	
	/* give window.name a unique id */
	function generateUUID () {
		return +new Date;
	}
	
	if(!window.name) {
		window.name = generateUUID();
	}
});

/* Category view */

jQuery(function($) {
	$('.category-button').click(function() {
		var categoryId = $(this).attr('rel');
		
		$('.categories ul li div').removeClass('active');
		$('#category-' + categoryId).addClass('active');
		
		$(document).scrollTo( {top:'0px', left:'0px'}, 200 );
		$('#ajax-loading-bar').fadeIn('fast');
		$.ajax({
			url: '/vrame/categories/' + categoryId + '/documents/',
			cache: false,
			success: function(html) {
				$('#items').html(html);
				$('#ajax-loading-bar').stop().fadeOut('fast');
			},
			error: function(msg) {
				console.log(msg);
			}
		});
		
		return false;
	});
});

/* Input field placeholder text */

jQuery(function ($) {
	$('input[type=text][placeholder], textarea[placeholder]').placeholder();
});

jQuery.fn.placeholder = function () {
	if (jQuery.fn.placeholder.supported) {
		return;
	}
	return this.each(function () {
		var field = jQuery(this),
			placeholder = field.attr('placeholder');
		
		if (!placeholder) {
			return;
		}
		
		field
			.blur(function () {
				var field = jQuery(this);
				if (field.val() == '') {
					field.val(placeholder);
				}
			})
			.focus(function () {
				var field = jQuery(this);
				if (field.val() == placeholder) {
					field.val('');
				}
			})
			.blur();
		
		jQuery(field.attr('form')).submit(function () {
			if (field.val() == placeholder) {
				field.val('');
			}
		});
	});
};

jQuery.fn.placeholder.supported = (function () {
	return typeof document.createElement('input').placeholder == 'string';
})();

/* Unsaved Alert */

jQuery(function ($) {
  if (typeof(vrame) == 'undefined') {vrame = {};}
  // Remember wether the current page contains unsaved changes
  vrame.unsavedChanges = false;
  
  var rteContents = {};
  $('iframe').each(function(){
    rteContents[this.id] = $(this).contents().find('body').html();
  });
  
  // Tell wether the content of the RTEs was changed
  var rtesChanged = function() {
    var changed = false;
    $('iframe').each(function(){
      var content = $(this).contents().find('body').html();
      var textarea_content = rteContents[this.id];
      changed = changed || (content != textarea_content);
    })
    return changed;
  };
  
  var onBeforeUnloadHandler = function() {
    if (vrame.unsavedChanges || rtesChanged())  {
      return 'If you leave this page without submitting the form, none of the changes you made will be saved.';
    }
  };
  
  var onChangeHandler = function() {
    vrame.unsavedChanges = true;
  };
  
  var onSubmitHandler = function() {
    window.onbeforeunload = null;
  };
  
  // Install handlers if we're on a page that is a 'new' or 'edit' form
  if (!!document.body.className.match(/va_edit|va_new/)) {
    $('input, textarea, select').change(onChangeHandler);
    $('form').submit(onSubmitHandler);
    window.onbeforeunload = onBeforeUnloadHandler;
  }
});