/*
 * Droppy 0.1.2
 * (c) 2008 Jason Frame (jason@onehackoranother.com)
 */
$.fn.droppy = function(options) {
    
  options = $.extend({speed: 250}, options || {});
  
  this.each(function() {
    
    var root = this,
        zIndex = 1000;
    
    function getSubnav(ele) {
      if (ele.nodeName.toLowerCase() == 'li') {
        var subnav = $('> ul', ele);
        return subnav.length ? subnav[0] : null;
      } else {
        return ele;
      }
    }
    
    function getActuator(ele) {
      if (ele.nodeName.toLowerCase() == 'ul') {
        return $(ele).parents('li')[0];
      } else {
        return ele;
      }
    }
    
    function hide(e) {
      var subnav = getSubnav(this);
      if (!subnav) return;
      $.data(subnav, 'cancelHide', false);
      setTimeout(function () {
        doHide(subnav);
      }, 600);
    }
    
    function doHide (subnav) {
      if (!$.data(subnav, 'cancelHide')) {
        $(subnav).slideUp(options.speed);
      }
    }
  
    function show() {
      var subnav = getSubnav(this);
      if (!subnav) return;
      
      $.data(subnav, 'cancelHide', true);
      $(subnav)
        .css({zIndex: zIndex++})
        .slideDown(options.speed);
      
      var nodeName = this.nodeName.toLowerCase();
      if (nodeName == 'ul') {
        
        var li = getActuator(this);
        $(li).addClass('hover');
        $('> a', li).addClass('hover');
      
      } else if (nodeName == 'li') {
      
        /* Hide sibling subnavigations immediately */
        $(this)
          .siblings()
          .each(function () {
            var siblingSubnav = getSubnav(this);
            if (siblingSubnav) {
              siblingSubnav.style.display = 'none';
            }
          });
      }
    }
    
    $('ul, li', this).hover(show, hide);
    $('li', this).hover(
      function() {
        $(this).addClass('hover');
        $('> a', this).addClass('hover');
      },
      function() {
        $(this).removeClass('hover');
        $('> a', this).removeClass('hover');
      }
    );
    
  });
  
};