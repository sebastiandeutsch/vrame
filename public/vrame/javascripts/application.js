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
	window.name = generateUUID();
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

/* Schema Builder */

jQuery(function ($) {
	
	$('#add-schema-item').populateRow(
		'#schema-field-prototype tr',
		'#schema-builder tbody',
		{
			removeParentSelector : 'tr',
			add : setupSlugGenerator
		}
	);
	
	$('#schema-builder label.required').click(toogleRequiredField);
	
	function sluggify (string) {
		return string
			.toLowerCase()
			.replace(/ä/g, 'ae')
			.replace(/ö/g, 'oe')
			.replace(/ü/g, 'ue')
			.replace(/ß/g, 'ss')
			.replace(/^\d+/g, '')
			.replace(/[\s-]+/g, '_')
			.replace(/[^a-z\d_]+/g, '')
			.replace(/^_+|_+$/g, '');
	}
	
	function slugGenerator () {
		var input = $(this),
			title = input.val(),
			slug = sluggify(title);
		
		input.parents('td:first').find('input.name').val(slug);
	}
	
	function setupSlugGenerator (clone) {
		clone.find('input.title').keydown(slugGenerator).keyup(slugGenerator).focus(slugGenerator).blur(slugGenerator);
	}
	
	function toogleRequiredField (e) {
		var label = $(this),
			checked = label.find('input').attr('checked') ? '1' : '0';
		label.parents('td:first').find('input.required-field').val(checked);
	}
	
	/* $('#add-key-value').populateRow('#key-value-prototype tr', '#keys-values'); */
});

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