jQuery(function ($) {

  var schemaBuilder = $('#schema-builder');
  
  /* ------------------------------------------------ */
  
  /* Field addition and deletion */
  
  $('#add-schema-field').populateRow(
    /* Clone from Source */
    '#schema-field-prototype > div',
    /* Append to Destination */
    '#schema-builder',
    {
      removeParentSelector : '.schema-field',
      add    : fieldAdded,
      remove : fieldRemoved
    }
  );
  
  function fieldAdded (field) {
    //console.log('schema builder: field added', field);
    
    /* Get the selected type for the new field */
    var internalFieldType = setFieldType(field);
    
    /* Setup event handling on clone */
    setupSlugGenerator(field);
    
    /* Add corresponding field options */
    addFieldOptions(field, internalFieldType);
  }
  
  function fieldRemoved (field) {
    //console.log('schema builder: field removed');
    removeFieldOptions(field);
  }
  
  /* ------------------------------------------------ */
  
  /* Insert schema attribute name into all inputs before sending the form */
  $('form.new_category, form.edit_category').submit(replaceFieldNames);
  
  /* Insert schema attribute name into input names */
  function replaceFieldNames (schemaBuilderId) {
    var schemaBuilder = $(schemaBuilderId);
    var schemaAttribute = schemaBuilder.attr('data-schema-attribute');
    
    schemaBuilder.find('input, textarea, select').each(function () {
      this.name = this.name.replace(/\{schema_attribute\}/, schemaAttribute);
    });
  }
  
  /* ------------------------------------------------ */
  
  /* Slug Generation */
  
  function setupSlugGenerator (field) {
    field
      .find('input.title')
      .keydown(slugGenerator)
      .keyup(slugGenerator)
      .focus(slugGenerator)
      .blur(slugGenerator);
  }
  
  function slugGenerator () {
    var input = $(this),
      title = input.val(),
      slug = sluggify(title);
    
    input.closest('.schema-field').find('input.name').val(slug);
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
  
  /* ------------------------------------------------ */
  
  /* Field Type */
  
  function setFieldType (field) {
    /* Get the selected type */
    var select = $('#add-schema-field-type').get(0),
      selectedOption = select.options[select.selectedIndex],
      visibleFieldType = selectedOption.innerHTML,
      internalFieldType = selectedOption.value;
    
    /* Set the type accordingly */
    field.find('input.internal-field-type').val(internalFieldType);
    field.find('p.visible-field-type').html(visibleFieldType);
    
    return internalFieldType;
  }
  
  /* ------------------------------------------------ */
  
  /* Toggle additional field options */
  
   $('#schema-builder .toggle-additional a').live('click', toggleAdditionalOptions);
   
   function toggleAdditionalOptions () {
    $(this).closest('p').next().slideToggle('fast');
   }
  
  /* Field Options, Field Options Population */
  
  var fieldTypeBehavior = {
    'JsonObject::Types::Asset' : {
      rowPrototype    : '#asset-styles-prototype > div',
      optionButton    : 'a.add-asset-style',
      optionPrototype : 'li:first',
      optionTarget    : 'ul:first'
    },
    'JsonObject::Types::Collection' : {
      rowPrototype    : '#asset-styles-prototype > div',
      optionButton    : 'a.add-asset-style',
      optionPrototype : 'li:first',
      optionTarget    : 'ul:first'
    },
    'JsonObject::Types::Select' : {
      rowPrototype    : '#select-options-prototype > div',
      optionButton    : 'a.add-select-field',
      optionPrototype : 'li:first',
      optionTarget    : 'ul:first'
    },
    'JsonObject::Types::MultiSelect' : {
      rowPrototype    : '#multiselect-options-prototype > div',
      optionButton    : 'a.add-select-field',
      optionPrototype : 'li:first',
      optionTarget    : 'ul:first'
    }
  },
  hasFieldOptions = 'has-field-options';
  
  /* Field options addition and deletion */
  
  function addFieldOptions (field, internalFieldType) {
    //console.log('addFieldOptions', internalFieldType, 'for', field, ', type options:');
    var o = fieldTypeBehavior[internalFieldType];
    
    if (!o) {
      //console.log('this type doesn\'t have field options. :-/');
      return;
    }
    //console.log('this type has field options! =)', o);
    
    /* Add has-field-options class */
    field.addClass(hasFieldOptions);
    
    /* Clone and insert the field options */
    var target = field.find('div.additional');
    var clone = $(o.rowPrototype).clone().appendTo(target);
    
    /* Setup event handling on the clone*/
    setupOptionPopulation(clone);
    
  }
  
  function removeFieldOptions (field, o) {
    //console.log('removeFieldOptions', field);
    field.removeClass(hasFieldOptions).next('.field-options').remove();
  }
  
  /* ------------------------------------------------ */
  
  /* Field Options Population */
  
  setupOptionPopulation();
  
  function setupOptionPopulation (field) {
    //console.log('setupOptionPopulation', field);
    //var schemaBuilderPrototypes = $('#schema-builder-prototypes');
    
    for (var key in fieldTypeBehavior) {
      var o = fieldTypeBehavior[key];
      if (!o.optionButton) continue;
      
      /* Collect buttons */
      var container = field || schemaBuilder,
        buttons = container.find(o.optionButton);
      
      //console.log(container, o.optionButton, '>', buttons);
      buttons
        /* Don't treat a button twice, set and check a flag */
        .filter(function () {
          return !$(this).data('populateOption');
        })
        /* Attach the options to the button */
        .data('populateOption', o)
        /* Setup event handling */
        .click(populateOption);
    }
    
  }
  
  function populateOption () {
    //console.log('populateOption');
    var button = $(this),
      o = button.data('populateOption'),
      container = button.closest('.additional'),
      target = container.find(o.optionTarget);
    
    container.find(o.optionPrototype).clone().appendTo(target);
  }
  
  /* ------------------------------------------------ */
  
  /* Required Field: Set hidden input field */

  schemaBuilder.find('label.required').live('click', toogleRequiredField);
  
  function toogleRequiredField (e) {
    var label = $(this),
      checked = label.find('input').attr('checked') ? '1' : '0';
    label.closest('.required').find('input.required-field').val(checked);
  }
  
  /* ------------------------------------------------ */
  
});