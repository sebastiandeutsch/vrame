/* Category view */

jQuery(function($) {
	
	var activeCategory = null,
		activeCategoryClass = 'active-category';
	
	$('.content-view .category-button').click(categoryClick);
	
	function categoryClick (e) {
		e.preventDefault();
		
		var link = $(this),
			activeCategory = link.closest('.category'),
			activeCategoryId = activeCategory.attr('data-category-id');
		
		/* Set active category */
		$('.content-view .' + activeCategoryClass).removeClass(activeCategoryClass);
		activeCategory.addClass(activeCategoryClass);
		
		/* Load documents */
		$(document).scrollTo({ top: 0, left: 0 }, 200);
		$('#ajax-loading-bar').fadeIn('fast');
		$.ajax({
			url: '/vrame/categories/' + activeCategoryId + '/documents/?tab_id=' + window.name,
			cache: false,
			success: documentsLoaded,
			error: function(msg) {
				console.log(msg);
			}
		});
		
		updateButtons(activeCategoryId);
	}
	
	function documentsLoaded (html) {
		$('#content-view #items').html(html);
		$('#ajax-loading-bar').stop().fadeOut('fast');
	}
	
	function updateButtons (activeCategoryId) {
		/* Update button targets */
		$('#active-category-edit')        .attr('href', '/vrame/categories/' + activeCategoryId + '/edit');
		$('#active-category-new-document').attr('href', '/vrame/categories/' + activeCategoryId + '/documents/new');
		$('#active-category-new-category').attr('href', '/vrame/categories/' + activeCategoryId + '/categories/new');
	}
});