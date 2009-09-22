(function($) {
	var noop = function() { };
	
    $.fn.html5sortable = function(opts) {
		var list = $(this);
	
        opts = $.extend({
				itemSelector      : 'li.item',
				onDrop			  : noop
			},
			opts || {}
		);

		var animateHelpers = function() {
			$('li.helper', list).each(function(i, el) {
				var el = $(el);
				var height = el.get(0).myHeight;
				var toHeight = el.get(0).toHeight;
				
				height = height + ( toHeight - height ) / 5;
				
				el.get(0).myHeight = height;
				el.css('height', Math.floor(height) + 'px');
				el.css('display', 'block');
			});
		}
		var animateHandler = null;

		var createHelpers = function() {
			var dragOverFunction = function(e) {				
				return false;
			};
			
			$(opts.itemSelector, list).each(function(i, el) {
				if(i == 0) $(el).before('<li class="helper">&nbsp;</li>');
				$(el).after('<li class="helper">&nbsp;</li>');
			});
			
			$('li.helper', list).each(function(i, el) {
				var el = $(el);
				el.get(0).myHeight = 0;
				el.get(0).toHeight = 0;
								
				el.attr('draggable', 'true');
				
				el.bind('dragover', dragOverFunction).bind('dragenter', dragOverFunction);
				
				// define drop
				el.bind('drop', function (e) {
				    if (e.originalEvent.stopPropagation) e.originalEvent.stopPropagation(); // stops the browser from redirecting...why???
					
					if(e.sortableInsert == 'before') {
						var id = $(this).prev().attr('id');
					} else {
						var id = $(this).prev().attr('id');
					}
					
					var e1 = $('#' + id);
					var e2 = $('#' + e.originalEvent.dataTransfer.getData('Text'));

					var clone = e2.clone();
					makeElementSortable(clone);

					if(e1.get(0).sortableInsert == 'before') {
						e1.before(clone);
					} else {
						e1.after(clone);
					}
					e2.remove();

					var bgColor = clone.css('backgroundColor');
					clone.css({'backgroundColor' : '#ff0'});
					clone.animate({'backgroundColor' : bgColor}, 600);
					
					removeHelpers();

					opts.onDrop();

				    return false;
				});				
			});
			
			animateHandler = setInterval(animateHelpers, 1000/100);
		}
		
		var removeHelpers = function() {
			clearInterval(animateHandler);
			
			$('li.helper', list).each(function(i, el) {
				$(el).remove();
			});
		}
		
		var makeElementSortable = function(el) {
			var currentEl = null;

			// make the item draggable
			el.attr('draggable', 'true');
			
			
			// define dragstart
			el.bind('dragstart', function(e) {
				createHelpers();

				e.originalEvent.dataTransfer.effectAllowed = 'move';
				e.originalEvent.dataTransfer.setData('Text', this.id); // required otherwise doesn't work				
			});
			
			var dragOverHelperFunction = function(e) {
				// disable all helpers
				$('li.helper', list).each(function(i, el) {
					$(el).get(0).toHeight = 0;
				});
				
				// decide where to drop the item
				if(e.originalEvent.target.id != "") {
					var target = $('#' + e.originalEvent.target.id);
					if(target.get(0)) {
						var targetY = target.get(0).offsetTop;
						var targetH = target.height() * 2; // @TODO, why 2* height?
					
						if(e.pageY-targetY < targetH/2) {
							target.prev().css({'display' : 'block'});
							target.prev().get(0).toHeight = targetH;
							target.prev().sortableInsert = 'before';
							target.next().get(0).toHeight = 0;
							target.next().get(0).myHeight = 0;
						} else {
							target.prev().get(0).toHeight = 0;
							target.prev().get(0).myHeight = 0;
							target.next().css({'display' : 'block'});
							target.next().get(0).toHeight = targetH;
							target.next().sortableInsert = 'after';
						
						}
					}
				}
				
				return false;
			};
			
			// define dragover
			el.bind('dragover', dragOverHelperFunction).bind('dragenter', dragOverHelperFunction);
			
			el.bind('drop', function (e) {	
				if (e.originalEvent.stopPropagation) e.originalEvent.stopPropagation(); // stops the browser from redirecting...why???
				
				removeHelpers();
				
				return false;
			});
			
			el.bind('dragend', function (e) {
				removeHelpers();
			});
		};

		var items = $(opts.itemSelector, list);

		// make all elements sortable
		items.each(function(i, el) {
			makeElementSortable($(el));
		});
	};
})(jQuery);