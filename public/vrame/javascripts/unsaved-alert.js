/* Unsaved Alert */

jQuery(function ($) {
  if (typeof(vrame) == 'undefined') {vrame = {};}
  // Remember wether the current page contains unsaved changes
  vrame.unsavedChanges = false;
  
  var rteContents = {};
  $('iframe').load(function(){
    rteContents[this.id] = $(this).contents().find('body').html();
  });
  
  // Tell wether the content of the RTEs was changed
  var rtesChanged = function() {
    var changed = false;
    $('iframe').each(function(){
      var content = $(this).contents().find('body').html();
      var textarea_content = rteContents[this.id];
      changed = changed || (content != textarea_content);
    })
    return changed;
  };
  
  var onBeforeUnloadHandler = function() {
    if (vrame.unsavedChanges || rtesChanged())  {
      return 'If you leave this page without submitting the form, none of the changes you made will be saved.';
    }
  };
  
  var onChangeHandler = function() {
    vrame.unsavedChanges = true;
  };
  
  var onSubmitHandler = function() {
    window.onbeforeunload = null;
  };
  
  // Install handlers if we're on a page that is a 'new' or 'edit' form
  if (!!document.body.className.match(/va_edit|va_new/)) {
    $('input, textarea, select').change(onChangeHandler);
    $('form').submit(onSubmitHandler);
    window.onbeforeunload = onBeforeUnloadHandler;
  }
});