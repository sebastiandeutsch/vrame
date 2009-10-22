/* New Field and Slug Generator */

jQuery(function ($) {
	
	$('#schema-builder').bind('schemaFieldAdded', setupSlugGenerator);
	
	$('#add-schema-field').populateRow(
		/* Clone from Source*/
		'#schema-field-prototype tr',
		/* Append to Destination */
		'#schema-builder tbody',
		{
			removeParentSelector : 'tr',
			add : schemaFieldAdded
		}
	);
	
	function schemaFieldAdded () {
		$('#schema-builder').trigger('schemaFieldAdded');
	}
	
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
		
		input.closest('td').find('input.name').val(slug);
	}
	
	function setupSlugGenerator (clone) {
		clone
			.find('input.title')
			.keydown(slugGenerator)
			.keyup(slugGenerator)
			.focus(slugGenerator)
			.blur(slugGenerator);
	}
	
});

/* Required Field */

jQuery(function ($) {
	
	$('#schema-builder label.required').click(toogleRequiredField);
	
	function toogleRequiredField (e) {
		var label = $(this),
			checked = label.find('input').attr('checked') ? '1' : '0';
		label.closest('td').find('input.required-field').val(checked);
	}
	
});

/* Options */

jQuery(function ($) {

	var fieldTypeBehavior = {
		'File' : {
			rowPrototype    : '#asset-styles-prototype tr',
			optionButton    : 'tr.asset-styles a.add-asset-style',
			optionPrototype : 'li:first',
			optionTarget    : 'ul:first'
		},
		'Collection' : {
			rowPrototype    : '#asset-styles-prototype tr',
			optionButton    : 'tr.asset-styles a.add-asset-style',
			optionPrototype : 'li:first',
			optionTarget    : 'ul:first'
		},
		'Select' : {
			rowPrototype    : '#select-options-prototype tr',
			optionButton    : 'tr.select-fields a.add-select-field',
			optionPrototype : 'li:first',
			optionTarget    : 'ul:first'
		},
		'Multiselect' : {
			rowPrototype    : '#multiselect-options-prototype tr',
			optionButton    : 'tr.multiselect-fields a.add-select-field',
			optionPrototype : 'li:first',
			optionTarget    : 'ul:first'
		}
	};
	
	$('#schema-builder select.type').change(addFieldOptions);
	setupOptionPopulation();
	
	function setupOptionPopulation (tr) {
		for (var key in fieldTypeBehavior) {
			var o = fieldTypeBehavior[key], buttons;
			if (!o.optionButton) continue;
			buttons = $(o.optionButton)
				/* Don't treat a button twice, set and check a flag */
				.filter(function () {
					return !$(this).data('populateRow');
				})
				.data('populateRow', true)
				/* It's complicated because populateRow doesn't support relative sources/destinations atm */
				.each(function () {
					var button = $(this),
						tr = tr || button.closest('tr');
					/* Setup event handling */
					button.populateRow(
						/* Clone from Source */
						tr.find(o.optionPrototype),
						/* Append to Destination */
						tr.find(o.optionTarget)
					);
				});
			
		}
	}
	
	function addFieldOptions () {
		var o = fieldTypeBehavior[this.value],
			tr = $(this).closest('tr');
		if (o && o.rowPrototype) {
			cloneFieldOptions(tr, o);
		} else {
			removeFieldOptions(tr, o);
		}
	}
	
	function cloneFieldOptions (tr, o) {
		var klass = 'has-field-options';
		if (tr.hasClass(klass)) return;
		/* Clone and insert */
		tr.addClass(klass);
		var clone = $(o.rowPrototype).clone().insertAfter(tr);
		/* Restore event handlers */
		setupOptionPopulation(clone);
	}
	
	function removeFieldOptions (tr, o) {
		tr.removeClass('has-field-options').next('.field-options').remove();
	}
	
});
