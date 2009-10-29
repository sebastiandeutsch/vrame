/* New Field, Slug Generator, Field Options */

jQuery(function ($) {
	
	/* New Field */
	
	$('#add-schema-field').populateRow(
		/* Clone from Source*/
		'#schema-field-prototype tr',
		/* Append to Destination */
		'#schema-builder tbody',
		{
			removeParentSelector : 'tr',
			add : function (tr) {
				//console.log('schema builder: field added');
				/* Setup event handling on clone*/
				setupSlugGenerator(tr);
				tr.find('select.type').change(controlFieldOptions);
			},
			remove : function (tr) {
				//console.log('schema builder: field removed');
				removeFieldOptions(tr);
			}
		}
	);
	
	/* Slug Generation */
	
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
	
	/* Field Options */
	
	var fieldTypeBehavior = {
		'Asset' : {
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
		'MultiSelect' : {
			rowPrototype    : '#multiselect-options-prototype tr',
			optionButton    : 'tr.multiselect-fields a.add-select-field',
			optionPrototype : 'li:first',
			optionTarget    : 'ul:first'
		}
	},
	hasFieldOptions = 'has-field-options';
	
	$('#schema-builder select.type').change(controlFieldOptions);
	
	function controlFieldOptions () {
		var select = $(this),
			type = select.val(),
			o = fieldTypeBehavior[type],
			tr = $(this).closest('tr');
		
		//console.log('new type:', type);
		if (o) {
			//console.log('this type has FO');
			insertFieldOptions(tr, o);
		} else {
			//console.log('this type doesn\'t have FO');
			removeFieldOptions(tr);
		}
	}
	
	function insertFieldOptions (tr, o) {
		//console.log('insertFieldOptions', tr, o);
		/* Clone and insert */
		var clone = $(o.rowPrototype).clone(),
			existingFieldOptions = tr.next('tr.field-options');
		if (existingFieldOptions.length) {
			//console.log('replace existing FO');
			existingFieldOptions.replaceWith(clone);
		} else {
			//console.log('insert FO');
			tr.after(clone);
		}
		tr.addClass(hasFieldOptions);
		/* Setup event handling on clone*/
		setupOptionPopulation();
	}
	
	function removeFieldOptions (tr) {
		//console.log('removeFieldOptions', tr);
		tr.removeClass(hasFieldOptions).next('.field-options').remove();
	}
	
	/* Field Options Population */
	
	setupOptionPopulation();
	
	function setupOptionPopulation () {
		for (var key in fieldTypeBehavior) {
			var o = fieldTypeBehavior[key];
			if (!o.optionButton) continue;
			$(o.optionButton)
				/* Don't treat a button twice, set and check a flag */
				.filter(function () {
					return !$(this).data('populateOption');
				})
				.data('populateOption', o)
				/* Setup event handling */
				.click(populateOption);
		}
	}
	
	function populateOption () {
		var button = $(this),
			o = button.data('populateOption'),
			tr = button.closest('tr'),
			target = tr.find(o.optionTarget);
		tr.find(o.optionPrototype).clone().appendTo(target);
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