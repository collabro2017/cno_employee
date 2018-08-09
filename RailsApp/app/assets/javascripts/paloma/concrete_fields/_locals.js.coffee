(->
  Paloma.callbacks["concrete_fields"] = {}
  locals = Paloma.locals["concrete_fields"] = {}

  locals.setBindings = ->
    ops = {
        height: 'auto'
        railVisible: true
        alwaysVisible: true
        railOpacity: 0.1
      }

    $("#accordions").slimScroll(ops)
    locals.adjustConcreteFieldsScrollArea()

  locals.adjustConcreteFieldsPane = ->
    pane = $('#concrete-fields-pane')
    refPane = $('#concrete-fields-pane-ref')
    
    if pane.length
      newOffset = pane.offset()
      newOffset.left = refPane.offset().left
      pane.width(refPane.width()).offset(newOffset)
      
    setTimeout(locals.adjustConcreteFieldsPane, 200)

  locals.setFilterBindings = ->
    textbox = $('#textbox')
    advancedFiltersToggle = $('.advanced-filters-toggle')

    #Clear filter by clicking the 'X'
    $('#searchbox').on "click", "i", (e) ->
      textbox.val('').focus()
      $(@).removeClass('on')
      locals.applyFilters()

    #Filter's typeahead
    textbox.on "keyup", ->
      icon = $('#searchbox i')
      
      if $(@).val() != ''
        icon.addClass('on')
      else
        icon.removeClass('on')
      
      locals.applyFilters()

    # Filter concrete fields
    advancedFiltersToggle.hover (->
      toggle = $(@)
      toggle.addClass "btn btn-mini"
      toggle.removeClass "minimal"
    ), ->
      unless $(@).hasClass('active')
        $(@).removeClass "btn btn-mini"
        $(@).addClass "minimal"
    
    advancedFiltersToggle.on 'click', (e) ->
      e.preventDefault()
      toggle = $(@)
      pane = $('.advanced-filters-pane')
      filterOptions = $('#filter-options')
      
      if toggle.hasClass('active')
        toggle.removeClass('active')
        toggle.children('span.monospace').html('+')
        filterOptions.slideUp()
        pane.addClass "minimal"
      else
        toggle.addClass('active')
        toggle.children('span.monospace').html('-')
        filterOptions.slideDown()
        pane.removeClass "minimal"

    $('.filter-option').on "click", (e) ->
      e.preventDefault()
      filterOption = $(@)

      filterOption.toggleClass "apply-filter"
      advancedFiltersToggle.children(filterOption.data("selector")).toggle()

      if filterOption.hasClass "apply-filter"
        $(filterOption.data("selector")).removeClass "off"
      else
        $(filterOption.data("selector")).addClass "off"

      locals.applyFilters()

######### Set button bindings ##################################################

  locals.setButtonBindings = ->
    $('#concrete-fields-pane').on 'click', '.add-field-btn', (e) ->
      e.preventDefault()
      button = $(@)
      concreteFieldId = parseInt(button.getContainerId('.concrete_field'))

      if button.hasClass 'breakdown'
        if Paloma.locals.breakdowns.isValid(concreteFieldId)
          button.closest('form.button_to').submit()

      else if button.hasClass 'dedupe'
        if Paloma.locals.dedupes.isValid(concreteFieldId)
          button.closest('form.button_to').submit()

      else if button.hasClass 'select'
        button.closest('form.button_to').submit()

############ Filter auxiliary methods ##########################################
  locals.applyFilters = ->
    selector = locals.filterOptionsSelector()
    $('.field').addClass 'inactive'
    $(selector).removeClass 'inactive'
    locals.refreshAccordions()

  locals.filterOptionsSelector = ->
    selector = ".field"
    typedText = $("#textbox").val()

    if typedText != ""
      selector += ".field:containsIgnoreCase(" + typedText + ")"
    
    $('.filter-option.apply-filter').each ->
      selector += ".field:has(" + $(@).data('selector') + ":not(.hidden))"
    
    selector

  locals.refreshAccordions = ->
    $("#accordions").find('.accordion-inner').each ->
      accordionInner = $(@)
      categoryContainer = accordionInner.parent().parent()
      
      categoryContainer.show()
      
      if accordionInner.children(':not(:hidden)').length == 0
        categoryContainer.hide()
      else 
        locals.expandAccordion(accordionInner.parent())

  locals.expandAccordion = (parent) ->
    parent.siblings('.accordion-heading').children('a').removeClass('collapsed')
    parent.addClass('in')
    parent.css('height','auto')

  locals.collapseAccordion = (parent) ->
    parent.siblings('.accordion-heading').children('a').addClass('collapsed')
    parent.removeClass('in')
    parent.css("height","0")

################################################################################
    
  locals.adjustConcreteFieldsScrollArea = ->
    scrollPosition = $(document).scrollTop()
    footerYOffset = $('.footer').offset().top - 20
    viewPortEnd = scrollPosition + $(window).height()    
    visibleFooterHeight = Math.max(0, viewPortEnd - footerYOffset)
    accordions = $('#accordions')

    if accordions.length
      yOffset = accordions.offset().top
      margins = (yOffset - scrollPosition) + visibleFooterHeight
      newHeight = $(window).height() - margins
      
      $('#accordions, #concrete-fields-pane .slimScrollDiv').each ->
        overhead = $(this).outerHeight() - $(this).height()
        $(this).height(newHeight - overhead)

      locals.adjustScrollBarHeight()
    
    setTimeout(locals.adjustConcreteFieldsScrollArea, 2000)

  locals.adjustScrollBarHeight = ->
    minBarHeight = 30
    scrollContent = $('#accordions')
    bar = $('#concrete-fields-pane .slimScrollBar')
    
    barHeight = Math.max((scrollContent.outerHeight() / scrollContent[0].scrollHeight) * scrollContent.outerHeight(), minBarHeight);
    bar.css({ height: barHeight + 'px' });    


  locals.reloadConcreteFieldPane = (displayType) ->
    concreteFieldAsyncDiv = $('div#concrete-fields-pane').find('.async-div')
    asyncParams = concreteFieldAsyncDiv.data('params')

    asyncParams['concrete_field']['display_type'] = displayType
    concreteFieldAsyncDiv.updateData('params', asyncParams)
    concreteFieldAsyncDiv.reloadContent()

    locals.asyncBindings('#accordions', locals.setBindings)

  # Remove this line if you don't want to inherit locals defined
  # on parent's _locals.js
  Paloma.inheritLocals
    from: "/"
    to: "concrete_fields"
)()
