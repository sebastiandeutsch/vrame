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