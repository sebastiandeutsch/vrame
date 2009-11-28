jQuery(function ($) {
  
  /* New Field */
  
  $('#add-schema-field').populateRow(
    /* Clone from Source*/
    '#schema-field-prototype tr',
    /* Append to Destination */
    '#schema-builder tbody',
    {
      removeParentSelector : 'tr',
      add : fieldAdded,
      remove : fieldRemoved
    }
  );
  
  /* Insert schema attribute name into all inputs before sending the form */
  $('form.new_category, form.edit_category').submit(function () {
    replaceFieldNames('#schema-builder');
  });
  
  /* Field addition and deletion */
  
  function fieldAdded (tr) {
    //console.log('schema builder: field added', tr);
    
    /* Setup event handling on clone */
    setupSlugGenerator(tr);
    
    /* Get the selected type for the new field */
    var internalFieldType = setFieldType(tr);
    
    /* Add corresponding field options */
    addFieldOptions(tr, internalFieldType);
  }
  
  function fieldRemoved (tr) {
    //console.log('schema builder: field removed');
    removeFieldOptions(tr);
  }
  
  /* Insert schema attribute name into input names */
  function replaceFieldNames(schema_builder) {
    var schema_attribute = $(schema_builder).attr('data-schema-attribute');
    
    $(schema_builder).find('input, textarea, select').each(function () {
      var field = $(this);
      field.attr('name', field.attr('name').replace(/\{schema_attribute\}/, schema_attribute));
    });
  }
  
  /* Slug Generation */
  
  function setupSlugGenerator (clone) {
    clone
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
    
    input.closest('td').find('input.name').val(slug);
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
  
  /* Field Type */
  
  function setFieldType (tr) {
    var select = $('#add-schema-field-type').get(0),
      selectedOption = select.options[select.selectedIndex],
      visibleFieldType = selectedOption.innerHTML,
      internalFieldType = selectedOption.value;
    
    /* Set the type accordingly */
    tr.find('input.internal-field-type').val(internalFieldType);
    tr.find('p.visible-field-type').html(visibleFieldType);
    
    return internalFieldType;
  }
  
  /* Field Options, Field Options Population */
  
  var fieldTypeBehavior = {
    'JsonObject::Types::Asset' : {
      rowPrototype    : '#asset-styles-prototype tr',
      optionButton    : 'a.add-asset-style',
      optionPrototype : 'li:first',
      optionTarget    : 'ul:first'
    },
    'JsonObject::Types::Collection' : {
      rowPrototype    : '#asset-styles-prototype tr',
      optionButton    : 'a.add-asset-style',
      optionPrototype : 'li:first',
      optionTarget    : 'ul:first'
    },
    'JsonObject::Types::Select' : {
      rowPrototype    : '#select-options-prototype tr',
      optionButton    : 'a.add-select-field',
      optionPrototype : 'li:first',
      optionTarget    : 'ul:first'
    },
    'JsonObject::Types::MultiSelect' : {
      rowPrototype    : '#multiselect-options-prototype tr',
      optionButton    : 'a.add-select-field',
      optionPrototype : 'li:first',
      optionTarget    : 'ul:first'
    }
  },
  hasFieldOptions = 'has-field-options';
  
  /* Field options addition and deletion */
  
  function addFieldOptions (tr, internalFieldType) {
    //console.log('addFieldOptions', internalFieldType, 'for', tr, ', type options:');
    var o = fieldTypeBehavior[internalFieldType];
    
    if (!o) {
      //console.log('this type doesn\'t have field options. :-/');
      return;
    }
    //console.log('this type has field options! =)', o);
    
    /* Add has-field-options class */
    tr.addClass(hasFieldOptions);
    
    /* Clone and insert the field options */
    var clone = $(o.rowPrototype).clone().insertAfter(tr);
    
    /* Setup event handling on the clone*/
    setupOptionPopulation(clone);
    
  }
  
  function removeFieldOptions (tr, o) {
    //console.log('removeFieldOptions', tr);
    tr.removeClass(hasFieldOptions).next('.field-options').remove();
  }
  
  /* Field Options Population */
  
  setupOptionPopulation();
  
  function setupOptionPopulation (tr) {
    //console.log('setupOptionPopulation', tr);
    var schemaBuilderPrototypes = $('#schema-builder-prototypes');
    /* Collect buttons */
    
    for (var key in fieldTypeBehavior) {
      var o = fieldTypeBehavior[key];
      if (!o.optionButton) continue;
      var container = tr || schemaBuilderPrototypes,
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