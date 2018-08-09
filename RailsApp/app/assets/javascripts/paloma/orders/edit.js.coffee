(->
  _x = Paloma.variableContainer
  _L = Paloma.locals
  _l = _L["orders"]

  Paloma.callbacks["orders"]["edit"] = (params) ->
    _L.concrete_fields.adjustConcreteFieldsPane()
    _L.concrete_fields.setFilterBindings()
    _l.setDropHeight()
    _l.setSortableBindings()
    _l.setFieldButtonBindings()
    _l.setCategoryButtonBindings()
    _l.asyncLoad()
    _l.asyncBindings('#accordions', _L.concrete_fields.setBindings)

    _l.setTextboxTooltips()

    # Displays the first tab (default)
    $("#count-design-pane-tabs a:first").tab "show"

    # Event for displaying the selected tab
    $("#count-design-pane-tabs a").click (e) ->
      e.preventDefault()
      $(@).tab "show"

      activePaneId = $(".count-tab-pane.active").attr('id')
      displayType = activePaneId.split('-')[0]

      if displayType == 'sort' || displayType == 'output'
        _L.concrete_fields.reloadConcreteFieldPane(displayType)
        $('#expand-collapse-pane-link').show()
      else
        $('#expand-collapse-pane-link').hide()

    # Expand collapse icon
    $(document).on 'click', '#expand-collapse-pane-link', (e) ->
      e.preventDefault()
      $('#concrete-fields-pane').toggleClass 'expanded'
      $('#expand-collapse-pane-link > i')
        .toggleClass 'fa-angle-double-right fa-angle-double-left'

      $('div#order-workspace > div').toggleClass('span3 span9')
      $('#moving-right-pane').toggleClass 'collapsed'

    # Remove a nested attribute clicking on close
    $(".nested-attributes-drop").on "click", ".dropped-item-header a.select-close", (event) ->
      container = $(@).closest('.deletable')
      attributeName = container.getModelName()
      id = container.getId()
      _l.removeNestedAttribute(attributeName, id)
      event.preventDefault()

    # Change sort direction
    $("#sort-tab").on "click", ".sort-header .order-sort", (event) ->
      sortId = $(@).getContainerId(".sort")
      _l.toggleSortDirection(sortId)
      event.preventDefault()

    # Add fields hidden link
    $('form').on 'click', '.add_fields', (event) ->
      _locals.materializeFieldset(@)
      event.preventDefault()


    ################################# TEXTBOX ##################################

    $('#header').on 'click', '.editable-text', (e) ->
      textbox = $(@).closest('.textbox')
      _l.startTextboxEditing(textbox)
      $(textbox).find('input').select()

    $('#caps-tab').on 'change keyup paste', '#order_total_cap', (e) ->
      if $(@).attr('value') != $(@).val()
        _l.startTextboxEditing($(@).closest('.textbox'))

    $(document).on 'click', '.textbox .fa-check-circle', (e) ->
      input = $(@).parent().siblings('input').first()
      _l.acceptTextboxChanges(input)

    $(document).on 'click', '.textbox .fa-times-circle', (e) ->
      input = $(@).parent().siblings('input').first()
      _l.cancelTextboxChanges(input)

    $(document).on 'keyup', '.textbox input', (e) ->
      if event.which is 27
        _l.cancelTextboxChanges($(@))
      else if event.which is 13
        _l.acceptTextboxChanges($(@))

    # Prevent form submission
    $(document).on 'keypress', '.textbox input', (e) ->
      e.preventDefault() if e.keyCode is 13

)()
