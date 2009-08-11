jQuery(function() {
	
	jQuery(".flash").click(function() {
		jQuery(this).fadeOut();
	});
	
	jQuery(".expandable").click(function() {
		jQuery(jQuery(this).attr("href")).slideToggle();
		return false;
	});
	
	jQuery("#add-schema-item").populateRow("#schema-item-prototype", "#schema");
	jQuery("#add-key-value").populateRow("#key-value-prototype", "#keys-values");
	
	jQuery(".rte-zone").rte({
		media_url : "/images/rte/",
		content_css_url: "/stylesheets/admin/rte.css"
	});
	
    if (jQuery(".datepicker").size() > 0)
     jQuery(".datepicker").datepicker({
         duration: '',  
         showTime: true,  
         constrainInput: false
     });
    
    jQuery('.tooltip').tipsy({ gravity: 'w' });
		
	jQuery("input[type=text][placeholder], textarea[placeholder]").placeholder();
	
	if (document.getElementById("gallery-items")) (function () {
		
		var image = jQuery("<img />")
			.attr("id", "gallery-item-fullview")
			.attr("title", "Vollansicht schlieﬂen")
			.click(hideImage)
			.load(fullviewLoaded)
			.css("display", "none")
			.insertAfter("#gallery-items");
			
		jQuery("#gallery-items .image-wrapper").click(showFullview);
		
		function hideImage () {
			image.css("display", "none");
		}
		
		function showFullview () {
			var wrapper = jQuery(this),
				fullUrl = wrapper.attr("fullurl");
			if (!fullUrl) return;
			image.wrapperWidth = wrapper.width();
			image.wrapperHeight = wrapper.height();
			image.wrapperOffset = wrapper.offset();
			image.attr("src", fullUrl);
		}
		
		function fullviewLoaded () {
			image.css({
				left : image.wrapperOffset.left - (image[0].width - image.wrapperWidth) / 2,
				top : image.wrapperOffset.top - (image[0].height - image.wrapperHeight) / 2,
				display : "block"
			});
		}
	})();
	
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
			var field = jQuery(this);
			if (field.val() == placeholder) {
				field.val('');
			}
		});
	});
}

jQuery.fn.placeholder.supported = (function () {
	return typeof document.createElement('input').placeholder == 'string';
})();