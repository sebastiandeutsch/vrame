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
	window.name = generateUUID();
});