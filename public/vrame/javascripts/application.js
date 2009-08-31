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
		media_url : "/vrame/images/rte/",
		content_css_url: "/vrame/stylesheets/rte.css"
	});
	
	if (jQuery(".datepicker").size() > 0) {
		jQuery(".datepicker").datepicker({
			duration: '',  
			showTime: true,  
			constrainInput: false
		});
	}
	
	jQuery('.tooltip').tipsy({ gravity: 'w' });
		
	jQuery("input[type=text][placeholder], textarea[placeholder]").placeholder();
	
	(function () {
		var assetLists = jQuery(".asset-list")
		
		assetLists.
				find(".image-wrapper")
					.click(showFullview)
				.end()
				.find("a.delete")
					.click(deleteAsset);
		
		assetLists = undefined;
		
		function deleteAsset () {
			if (!confirm('Wirklich löschen?')) {
				return false;
			}
			
			var deleteLink = jQuery(this),
				url = deleteLink.attr('href'),
				params = {
					_method: 'delete',
					authenticity_token: deleteLink.attr("data-authenticity-token")
				};
			
			deleteLink.parents("li:eq(0)").hide();
			jQuery.post(url, params);
			
			return false;
		}
		
		var image = jQuery("<img />")
				.attr("id", "asset-fullview")
				.attr("title", "Vollansicht schließen")
				.click(hideImage)
				.load(fullviewLoaded)
				.css("display", "none")
				.appendTo(document.body),
			wrapperWidth,
			wrapperHeight,
			wrapperOffset;
			
		function hideImage () {
			image.css("display", "none");
		}
		
		function showFullview () {
			var wrapper = jQuery(this),
				fullUrl = wrapper.attr("fullurl");
			if (!fullUrl) {
				return;
			}
			wrapperWidth = wrapper.width();
			wrapperHeight = wrapper.height();
			wrapperOffset = wrapper.offset();
			image.attr("src", fullUrl);
		}
		
		function fullviewLoaded () {
			image.css({
				left : Math.max(0, wrapperOffset.left - (image.attr("width") - wrapperWidth) / 2),
				top : Math.max(0, wrapperOffset.top - (image.attr("height") - wrapperHeight) / 2),
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