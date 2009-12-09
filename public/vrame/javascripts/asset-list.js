/* Asset list behavior */

jQuery(function ($) {
    
    var assetListSelector = '.asset-list',
        textareaSelector = 'textarea[name=title]';
    
    /* Event Handling */
    
    var assetLists = $(assetListSelector)
    
        /* Asset deletion */
        .find('a.delete')
            .live('click', deleteAsset)
            .end()
        
        /* Image fullview */
        .find('.image-wrapper')
            .attr('title', 'Klicken zum Vergrößern')
            .live('click', loadFullview)
            .end()
        
        /* Title editing and saving */
        .find(textareaSelector)
            .live('keypress', saveTitle)
            .end()
        /* Event delegation with bubbling focusout */
        .bind('focusout', saveTitle)
        /* Event delegation with capturing blur */
        .each(captureTextareaBlur);
    
    /* Asset deletion */
    
    function deleteAsset (e) {
        e.preventDefault();
        
        if (!confirm('Wirklich löschen?')) {
            return false;
        }
        
        var deleteLink = $(this);
        
        /* Hide corresponding asset list item */
        deleteLink.closest('li').hide();
        
        /* Remove asset id from hidden input field */
        var uploadContainer = deleteLink.closest('div.file-upload');
        var uploadType = uploadContainer.attr('data-upload-type');
        if (uploadType == 'asset') {
            //vrame.unsavedChanges = true;
            uploadContainer.find('input.asset-id').val('');
        }
        
        /* Send DELETE request */
        $.post(deleteLink.attr('href'), {
            _method: 'delete',
            authenticity_token: deleteLink.attr('data-authenticity-token')
        });
    }
    
    /* Image fullview */
    
    var image = $('<img>')
            .attr('id', 'asset-fullview')
            .attr('title', 'Vollansicht schließen')
            .click(hideFullview)
            .load(showFullview)
            .css('display', 'none')
            .appendTo(document.body),
        wrapperWidth,
        wrapperHeight,
        wrapperOffset;
        
    function hideFullview () {
        image.css('display', 'none');
    }
    
    function loadFullview () {
        var wrapper = jQuery(this),
            fullUrl = wrapper.attr('fullurl');
        if (!fullUrl) {
            return;
        }
        wrapperWidth = wrapper.width();
        wrapperHeight = wrapper.height();
        wrapperOffset = wrapper.offset();
        image.attr('src', fullUrl);
    }
    
    function showFullview () {
        image.css({
            left : Math.max(0, wrapperOffset.left - (image.attr('width') - wrapperWidth) / 2),
            top : Math.max(0, wrapperOffset.top - (image.attr('height') - wrapperHeight) / 2),
            //left : wrapperOffset.left,
            //top : wrapperOffset.top,
            display : 'block'
        });
    }
    
    /* Title editing and saving */
    
    function captureTextareaBlur () {
        if (this.addEventListener) {
            this.addEventListener('blur', saveTitle, true);
        }
    }
    
    function saveTitle (e) {
        //console.log('saveTitle', e.type);
        var textarea = $(e.target),
            saveInterval,
            closure = function () {
                sendTitle(textarea);
            };
        if (!textarea.is(textareaSelector)) {
            return;
        }
        clearInterval(textarea.data('saveInterval'));
        if (e.type == 'keypress') {
            saveInterval = setTimeout(closure, 2000);
            textarea.data('saveInterval', saveInterval);
        } else {
            closure();
        }
    }
    
    function sendTitle (textarea) {
        //console.log('sendTitle');
        var assetId = textarea.attr('data-asset-id');
        $('#ajax-loading-bar').fadeIn('fast');
        $.post(
            '/vrame/assets/' + assetId,
            {
                'asset[title]' : textarea.val(),
                '_method' : 'put',
                'authenticity_token' : textarea.attr('data-authenticity-token')
            },
            function (responseData) {
                titleSent(responseData, textarea);
            }
        );
    }
    
    function titleSent (responseData, textarea) {
        //console.log('titleSent', responseData);
        $('#ajax-loading-bar').stop().fadeOut('fast');
        var originalBackgroundColor = textarea.css('backgroundColor');
        textarea
            .css('backgroundColor', '#ffb')
            .animate({'backgroundColor' : originalBackgroundColor}, 800);
    }
    
});