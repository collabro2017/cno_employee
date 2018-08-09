(->
  Paloma.callbacks["orders"] = {}
  locals = Paloma.locals["orders"] = {}
  _L = Paloma.locals

  locals.setCategoryButtonBindings = ->
    $(document).on 'click', '.add-category-btn', (e) ->
      e.preventDefault()
      categoryId = parseInt($(@).getContainerId('.field_category'))
      locals.addFieldCategory(categoryId)

      $('form.edit_order').submit()

  locals.setFieldButtonBindings = ->
    $(document).on 'click', '.btn.output, .btn.sort', (e) ->
      e.preventDefault()
      button = $(@)
      id = parseInt(button.getContainerId('.concrete_field'))
      displayType = 'output'
      displayType = 'sort' if button.hasClass('sort')

      locals.addNestedAttribute(displayType, id, 1)
      $('form.edit_order').submit()

  locals.setSortableBindings = ->
    #Target area
    $(".target").sortable(
      revert: true
      placeholder: "drop-placeholder"
      handle: ".dropped-item-header"
      cursor: "move"
      tolerance: "pointer"

      over: (event, ui) ->
        $(@).addClass "drop-ready"
      out: (event, ui) ->
        $(@).removeClass "drop-ready"
      start: (event, ui) ->
        ui.placeholder.height 20
        if itemId? && ~itemId.indexOf('output')
          $("#available-selects-pane").css "overflow", ""  # Required for the drop zone to be seen
      update: (event, ui) ->
        attributeName = $(@).attr('id').replace('s-drop', '')

        locals.updateNestedAttributesPositions(attributeName)
        $('form.edit_order').submit()
        $('#accordions').css "overflow", "hidden"

    )

  locals.setDropHeight = ->
    height = $(window).height()
    height -= $('.nested-attributes-drop').offset().top
    height -= ($('.footer').height() + 65)
    $('.nested-attributes-drop').css('min-height', height)

    setTimeout(locals.setDropHeight, 200)

#- NESTED ATTRIBUTES (OUTPUTS &  SORTS)-----------------------------------------
  locals.addNestedAttribute = (attributeName, concreteFieldId, position) ->
    addLink = $("##{attributeName}s-fieldsets a.add_fields").first()
    fieldset = locals.materializeFieldset(addLink)
    concreteFieldInput = fieldset.find("input.concrete_field_id")
    concreteFieldInput.val(concreteFieldId)
    positionInput = fieldset.find("input.position")
    positionInput.val(position)

  locals.removeNestedAttribute = (attributeName, id) ->
    $("##{attributeName}_fieldset_#{id} input._destroy").val('true')
    $('form.edit_order').submit()

  locals.updateNestedAttributesPositions = (attributeName) ->
    $("##{attributeName}s-drop").children().each (i) ->
      $("##{attributeName}_fieldset_#{$(@).getId()} input.position").val(
        $(@).index()
      )

  locals.materializeFieldset = (link) ->
    time = new Date().getTime()
    regexp = new RegExp($(link).data('id'), 'g')
    $(link).before($(link).data('fields').replace(regexp, time))
    $(link).prev()

#- OUTPUTS----------------------------------------------------------------------
  locals.addFieldCategory = (categoryId) ->
    container = $("#field_category_#{categoryId} div.accordion-inner")
    container.children().each (i, element) ->
      locals.addNestedAttribute('output', $(element).getId(), i)

#- SORTS------------------------------------------------------------------------
  locals.toggleSortDirection = (sortId) ->
    input = $("#sort_fieldset_#{sortId} input.descending")
    currentValue = input.val()
    if currentValue == 't' or currentValue == 'true'
      input.val('false')
    else if currentValue == 'f' or currentValue == 'false' or currentValue == ''
      input.val('true')
    $('form.edit_order').submit()

#- TEXTBOX ---------------------------------------------------------------------

  locals.setTextboxTooltips = ->
    $('.editable-text').tooltip()
    $('.accept-cancel-buttons>.fa').tooltip(placement: 'bottom')

  locals.startTextboxEditing = (textbox) ->
    $(textbox).addClass('editing')

  locals.stopTextboxEditing = (textbox) ->
    $(textbox).removeClass('editing')

  locals.acceptTextboxChanges = (input) ->
    if $(input).val() != $(input).attr('value')
      $(input).getForm().submit()
    else
      locals.stopTextboxEditing($(input).closest('.textbox.editing'))

  locals.cancelTextboxChanges = (input) ->
    locals.stopTextboxEditing($(input).closest('.textbox.editing'))
    input.val($(input).attr('value'))

  ## ORDER JOB STATUS CHANGES ---------------------------------------------------

  locals.updateJobStatus = (status) ->
    locals.refreshStatus()

  locals.refreshStatus = ->
    $('#order-result').find('.async-div').reloadContent()

  locals.refreshCountdownTimer = ->
    console.log 'n/a'

  locals.showRetryPolling = ->
    container = $('#retry-order-polling')
    container.siblings().addClass('hidden')
    container.removeClass('hidden')

#===============================================================================

#-------------------------------------------------------------------------------
    
  # Remove this line if you don't want to inherit locals defined
  # on parent's _locals.js
  Paloma.inheritLocals
    from: "/"
    to: "orders"

)()
