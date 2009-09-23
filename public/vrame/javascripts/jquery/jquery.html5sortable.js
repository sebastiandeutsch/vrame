(function($) {
	var noop = function() { };
	
    $.fn.html5sortable = function(opts) {
		var list = $(this);
	
        opts = $.extend({
				itemSelector      : 'li.item',
				droppableSelector : 'li.droppable',
				onDrop			  : noop
			},
			opts || {}
		);
		opts.droppableClass = opts.droppableSelector.match(/\.([^ ]+)/)[1];

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
				$(el).before('<li class="helper" data-relative="before" data-id="' + el.id + '">&nbsp;</li>');
				$(el).after('<li class="helper" data-relative="after" data-id="' + el.id + '">&nbsp;</li>');
			});

			$(opts.droppableSelector, list).each(function(i, el) {
				$(el).after('<li class="helper" data-relative="after" data-id="' + el.id + '">&nbsp;</li>');
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
					
					var target = $(this);
					var reference = $('#' + target.attr('data-id'));
					var elementId = e.originalEvent.dataTransfer.getData('Text');
					
					if(elementId && elementId != "") {
						var element = $('#' + elementId);
						var clone = element.clone();
						makeElementSortable(clone);

						if(target.attr('data-relative') == 'before') {
							reference.before(clone);
						} else {
							reference.after(clone);
						}
						element.remove();

						var bgColor = clone.css('backgroundColor');
						
						clone.css({'backgroundColor' : '#ff0'});
						clone.animate({'backgroundColor' : bgColor}, 600, function() {
							clone.css({'backgroundColor' : bgColor});
						});
				
						removeHelpers();

						opts.onDrop({
							element  : clone,
							target   : reference,
							relative : target.attr('data-relative')
						});
					}

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
		
		var makeElementDraggable = function(el) {
			// make the item draggable
			el.attr('draggable', 'true');
			
			
			// define dragstart
			el.bind('dragstart', function(e) {
				createHelpers();

				e.originalEvent.dataTransfer.effectAllowed = 'move';
				e.originalEvent.dataTransfer.setData('Text', this.id); // required otherwise doesn't work				
			});
		}
		
		var makeElementDroppable = function(el) {
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
						
						if(target.hasClass(opts.droppableClass)) {
							target.next().css({'display' : 'block'});
							target.next().get(0).toHeight = targetH;
							target.get(0).sortableInsert = 'after';
						} else {
							if(e.pageY-targetY < targetH/2) {
								target.prev().css({'display' : 'block'});
								target.prev().get(0).toHeight = targetH;
								target.next().get(0).toHeight = 0;
								target.next().get(0).myHeight = 0;
								target.get(0).sortableInsert = 'before';
							} else {
								target.prev().get(0).toHeight = 0;
								target.prev().get(0).myHeight = 0;
								target.next().css({'display' : 'block'});
								target.next().get(0).toHeight = targetH;
								target.get(0).sortableInsert = 'after';
							}							
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
		}
		
		var makeElementSortable = function(el) {
			makeElementDraggable(el);
			makeElementDroppable(el);
		};

		// make all elements sortable
		$(opts.itemSelector, list).each(function(i, el) {
			makeElementSortable($(el));
		});
		
		// make some elements droppable
		$(opts.droppableSelector, list).each(function(i, el) {
			makeElementDroppable($(el));
		});
	};
})(jQuery);