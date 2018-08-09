(->
  Paloma.callbacks['counts'] = {}
  locals = Paloma.locals['counts'] = {}
  _L = Paloma.locals

  locals.attachEventHandlers = () ->
    selectTab = $('#select-tab')
    suppressTab = $('#suppress-tab')

    $("#count-design-pane-tabs a").click (e) ->
      e.preventDefault()
      $(@).tab "show"

      activePaneId = $(".count-tab-pane.active").attr('id')
      displayType = activePaneId.split('-')[0]
      expandCollapseLink = $('#expand-collapse-pane-link')

      switch displayType
        when 'breakdown'
          locals.setupActionButton('breakdown')
          _L.concrete_fields.reloadConcreteFieldPane(displayType)
          expandCollapseLink.show()

        when 'select', 'dedupe'
          locals.setupActionButton('default')
          _L.concrete_fields.reloadConcreteFieldPane(displayType)
          expandCollapseLink.show()

        else
          locals.setupActionButton('default')
          expandCollapseLink.hide()

    $("#count-design-pane-tabs a:first").tab "show"

#- RUN BUTTON ------------------------------------------------------------------
    $("div.count-result-cell").on "click", '.run-btn', (e) ->
      e.preventDefault()
      if locals.activeSelection(@)
        $('.run-btn').attr('disabled', true)
        $(@).submit()
      else
        locals.validationErrorAlert(@)
#===============================================================================

#- ENTER VALUES ----------------------------------------------------------------
    # Event handler for checking length of enter values textarea
    selectTab.on "change", ".enter-values-input", (e) ->
      chars = @.value.length
      if chars == 16384
        locals.setAlert("header-wrapper",
          "The textbox is full. Therefore some values may have been truncated.",
          "warning")

    # Event handler for "enter values" tabs activation
    selectTab.on "click", ".enter-values-save", (e) ->
      handle = $(@)
      container = handle.closest('.select')
      selectId = handle.getContainerId('.select')
      textArea = container.find('textarea')
      button = container.find('button.enter-values-save')
      values = textArea.val()
      
      _L.selects.addMultipleEnterValues(selectId, values)
      .fail(->
        locals.setAlert('header-wrapper',
                        'An error occured while entering the values',
                        'error'))
      .done(-> button.attr "disabled", "true")

    # Event for enabling the save button for enter values
    selectTab.on "focus", ".enter-values-input", (e) ->
      container = $(@).closest('.select')
      button = container.find('button.enter-values-save')
      button.removeAttr "disabled"

    # Event handler for "enter values" tabs activation
    selectTab.on "click", ".enter-values-tab-link", (e) ->
      handle = $(@)
      selectId = handle.getContainerId('.select')
      button = $('#enter_values_select_'+selectId+' > button')

      unless handle.data("loaded") == "true"
        _L.selects.getSavedEnterValues(selectId)
        .fail(->
          locals.setAlert('header-wrapper',
                          'An error occured while retrieving the values',
                          'error'))
        .done(-> handle.data('loaded', "true"))
#===============================================================================


#- SELECT / BREAKDOWN / DEDUPE PANE ACTIONS ------------------------------------

    # Expand and collapse using the select handle and the +/-
    selectTab.on 'click', 'a.select-expand-collapse', (e) ->
      locals.expandOrCollapseSelect($(@).closest('.select'))
      e.preventDefault()

    selectTab.on "dblclick", "div.select-header", (e) ->
      locals.expandOrCollapseSelect($(@).closest('.select'))

    # Remove a select using close
    selectTab.on "click", "div.select-header a.select-close", (e) ->
      e.preventDefault()
      selectId = $(@).getContainerId(".select")
      cfId = $(@).closest('.select').data "cf-id"
      _L.selects.destroy(selectId)
      locals.removeInUseTag(cfId, '.selectable')

    # Remove a breakdown using close
    $("#breakdown-tab").on "click", "div.breakdown-header>a.select-close", (e) ->
      e.preventDefault()
      breakdownId = $(@).getContainerId(".breakdown")
      cfId = $(@).closest('.breakdown').data "cf-id"
      _L.breakdowns.destroy(breakdownId)
      locals.removeInUseTag(cfId, '.breakdown')

    # Remove a dedupe using close
    $("#dedupe-tab").on "click", "div.dedupe-header a.select-close", (e) ->
      e.preventDefault()
      dedupeId = $(@).getContainerId(".dedupe")
      cfId = $(@).closest('.dedupe').data "cf-id"
      _L.dedupes.destroy(dedupeId)
      locals.removeInUseTag(cfId, '.dedupe')

    # Activate popover for total records breakdown
    $("a.total-records").popover()
    selectTab.on "click", (e) ->
      $("[data-toggle=\"popover\"]").each ->
        $(this).popover "hide"  if not $(this).is(e.target) 
#===============================================================================


#- LOOKUPS FILTER ACTIONS ------------------------------------------------------
    selectTab.on "change", ".first-filter", (e) ->
      e.preventDefault()
      container = $(@).closest('.lookup_option')
      lookupClassName = container.data('class-name')
      selectId = $(@).getContainerId(".select")
      firstFilter = $(@).val()
      fuzzyFilter = container.find('.fuzzy-filter').val()
      _L.lookups.lookupSearch(container, firstFilter, fuzzyFilter, selectId, lookupClassName)

    selectTab.on "keyup", ".fuzzy-filter", (e) ->
      container = $(@).closest('.lookup_option')
      lookupClassName = container.data('class-name')
      selectId = $(@).getContainerId(".select")
      fuzzyFilter = $(@).val()
      firstFilter = container.find('.first-filter').val()
      _L.lookups.lookupSearch(container, firstFilter, fuzzyFilter, selectId, lookupClassName)
#===============================================================================


#- LOOKUPS ENTER TEXT FILTER ---------------------------------------------------
    selectTab.on "keyup, input", ".lookup-filter.react-to-keyup", (e) ->
      react = false
      
      isValid = $(@).prop('validity').valid
      newValue = if isValid then $(@).val() else ""

      reactThreshold = $(@).data('react-threshold')
      isEmpty = newValue.length == 0 && isValid

      wasValid = $(@).data('was-valid')
      oldValue = $(@).data('old-value')
      
      # Use them only if they are not nil, else asign defaults
      wasValid = true unless wasValid? 
      oldValue = "" unless oldValue? # use it only if it is not nil
      
      if reactThreshold
        if newValue.length < reactThreshold && !isEmpty
          newValue = ""  # treat it as if it changed to blank

      $(@).data('was-valid', isValid)
      if (newValue != oldValue)
        $(@).data('old-value', newValue)
        react = true
      
      if react # TO-DO: This should go into a separate method
        container = $(@).closest('.lookup_option')
        lookupClassName = container.data('class-name')
        selectId = $(@).getContainerId(".select")
        firstFilter = firstFilter = container.find('.first-filter').val()
        fuzzyFilter = fuzzyFilter = container.find('.fuzzy-filter').val()
        _L.lookups.lookupSearch(container, firstFilter, fuzzyFilter, selectId, lookupClassName)
#===============================================================================


#- LOOKUP CHECK BOXES ----------------------------------------------------------
    # Event for adding or removing a value
    selectTab.on "change", ".lookup-results input:checkbox", (e) ->
      handle = $(@)
      selectId = handle.getContainerId('.select')
      asyncDivParams = handle.closest('.async-div').data('params')['lookup']
      inputMethod = asyncDivParams['lookup_type']
      lookupParams = {}
      
      if inputMethod == 'zip5_distance'
        lookupParams['centroid'] = asyncDivParams['first_filter']

      if @checked
        _L.selects.addValue(selectId, @value, inputMethod, lookupParams)
          .fail(-> 
            locals.setAlert('header-wrapper',
                            'An error occured while adding the value',
                            'error')
            handle.prop "checked", false)
      else
        _L.selects.removeValue(selectId, @value, inputMethod)
          .fail(-> 
            locals.setAlert('header-wrapper',
                            'An error occured while removing the value',
                            'error')
            handle.prop "checked", true)

    # Event for selecting or deselecting multiple lookup values
    $('#select-tab').on "click", ".bulk-action", (e) ->
      e.preventDefault()
      handle = $(@)
      selectId = handle.getContainerId('.select')
      action = handle.data('action')
      allPages = handle.data('all-pages')
      
      container = handle.closest('.lookup_option')
      lookupClassName = container.data('class-name')

      firstFilter = container.find('.first-filter').val()
      fuzzyFilter = container.find('.fuzzy-filter').val() 
      page = container.find('.pagination li.active a').text() unless allPages

      _L.selects.handleMultipleLookupValues(
        selectId, action, lookupClassName, firstFilter, fuzzyFilter, page
      ).fail(->
        locals.setAlert(
          'header-wrapper',
          "An error occured while trying to #{action} the lookup values",
          'error'
        )
      ).done(-> locals.toggleLookupCheckboxes(container, action))
    
    $(".dropdown-toggle").dropdown()

    selectTab.on "click", ".pagination a", (e) ->
      e.preventDefault()
      asyncDiv = $(@).closest('.async-div')
      params = asyncDiv.data('params')
      params['page'] = $(@).data('page')
      asyncDiv.updateData('params', params)
      asyncDiv.reloadContent()

#===============================================================================


#- RANGES ----------------------------------------------------------------------
    # Event for saving select range
    selectTab.on "click", "#save_range", (e) ->
      select = $(@).closest('.select')
      selectId = $(@).getContainerId('.select')
      fromInput = select.find('input#from_')
      toInput = select.find('input#to_')
      fromValue = parseInt(fromInput.val())
      toValue = parseInt(toInput.val())

      if locals.isNumber(fromValue) && locals.isNumber(toValue)
        if _L.selects.validRange(select, fromValue, toValue)

          _L.selects.setRange(selectId, fromValue, toValue)
            .fail(->
              locals.setAlert('header-wrapper',
                              'An error occured while saving the range values',
                              'error')
            )
        else
          locals.setAlert('header-wrapper',
                          'Invalid values in range, please check your values',
                          'error')
      else
        locals.setAlert('header-wrapper',
                        'Invalid: values must be numbers ',
                        'error')

    selectTab.on "click", "#reset_range", (e) ->
      selectId = $(@).getContainerId('.select')
      
      _L.selects.resetRange(selectId)
        .fail(->
          locals.setAlert('header-wrapper',
                          'An error occured while resetting the range values',
                          'error')
        )

#===============================================================================


#- RANGES (DATE) ---------------------------------------------------------------
    # Initializer for the datepickers already added
    $('#date-fields .date-input').each ->
      select = $(@).closest('.select')
      locals.datepickerSetup(select)
    
    # Event for saving select range
    selectTab.on "click", "#save_date", (e) ->
      select = $(@).closest('.select')
      selectId = $(@).getContainerId('.select')
      fromInput = select.find('#date-fields input#from_'+selectId)
      toInput = select.find('#date-fields input#to_'+selectId)
      
      #Check for a validation method for dates
      fromValue = locals.dateToInteger(fromInput.val())
      toValue = locals.dateToInteger(toInput.val())

      if locals.isNumber(fromValue) && locals.isNumber(toValue)
        if _L.selects.validDateRange(select, fromValue, toValue)

          _L.selects.setDate(selectId, fromValue, toValue)
            .fail(->
              locals.setAlert('header-wrapper',
                              'An error occured while saving the date values',
                              'error')
            )
        else
          locals.setAlert('header-wrapper',
                          'Invalid values in range, please check your dates',
                          'error')
      else
        locals.setAlert('header-wrapper',
                        'Values must be numbers',
                        'error')

    selectTab.on "click", "#reset_date", (e) ->
      selectId = $(@).getContainerId('.select')
      
      _L.selects.resetDate(selectId)
        .fail(->
          locals.setAlert('header-wrapper',
                          'An error occured while resetting the date values',
                          'error')
        )    
#===============================================================================


#- BLANKS ----------------------------------------------------------------------    
    selectTab.on "click", "#blanks-radio button.set", (e) ->
      selectId = $(@).getContainerId('.select')
      value = $(@).val()
      hasClass = $(@).hasClass 'active'

      if hasClass
        _L.selects.resetBlanks(selectId)
          .fail(->
            locals.setAlert('header-wrapper',
                          'An error occured while resetting the blanks value',
                          'error')
          )
      else
        _L.selects.setBlanks(selectId, value)
          .fail(->
            locals.setAlert('header-wrapper',
                            'An error occured while setting the blanks value',
                            'error')
            )

    selectTab.on "click", "#blanks-radio button.reset", (e) ->
      selectId = $(@).getContainerId('.select')
      value = $(@).val()

      _L.selects.resetBlanks(selectId)
        .fail(->
          locals.setAlert('header-wrapper',
                          'An error occured while resetting the blanks value',
                          'error')
        )

    selectTab.on "click", "#blanks-toggle button.toggle", (e) ->
      selectId = $(@).getContainerId('.select')
      value = $(@).val()
      hasClass = $(@).hasClass 'active'

      if hasClass
        _L.selects.resetBlanks(selectId)
        .fail(->
          locals.setAlert('header-wrapper',
                          'An error occured while resetting the blanks value',
                          'error')
        )
      else
        _L.selects.setBlanks(selectId, value)
          .fail(->
            locals.setAlert('header-wrapper',
                            'An error occured while setting the blanks value',
                            'error')
          )
#===============================================================================


#- FILES UPLOAD ----------------------------------------------------------------

    $("#select-tab, #suppress-tab").on "change", "input:file.file-upload", (e) ->
      fileInput = $(@)

      _L.user_files.add(@.files[0].name)
        .success((result) -> 
          _L.user_files.upload fileInput, result, (fileInfo, asyncDiv) ->
            asyncDiv.find("tr[data-file-id=#{fileInfo.id}]")
              .find('input')
              .prop('checked', true)
              .trigger('change')

            otherAsyncDivs = $('.user-files-list>.async-div').not(asyncDiv)
            otherAsyncDivs.each (i) ->
              $(@).updateData('refresh', true)
        )
        .fail(->
          locals.setAlert('header-wrapper',
                          'An error occured when trying to add the file',
                          'error')
          fileInput.replaceWith(fileInput = fileInput.clone()) # To clear it
        )

    # Event for adding or removing a file to a select
    selectTab.on "change", ".user-file input:checkbox", (e) ->
      handle = $(@)
      selectId = handle.getContainerId('.select')
      if @checked
        _L.selects.addUserFile(selectId, @value)
          .fail(-> 
            locals.setAlert('header-wrapper',
                            'An error occured while adding the file',
                            'error')
            handle.prop "checked", false)
      else
        _L.selects.removeUserFile(selectId, @value)
          .fail(-> 
            locals.setAlert('header-wrapper',
                            'An error occured while removing the file',
                            'error')
            handle.prop "checked", true)

#===============================================================================


#- BINARY ----------------------------------------------------------------------
    selectTab.on 'change', '.binary-select-content input:checkbox', (e) ->
      handle = $(@)
      selectId = handle.getContainerId('.select')

      if @checked
        _L.selects.addValue(selectId, @value, 'binary', {})
          .fail(-> 
            locals.setAlert('header-wrapper',
                            'An error occured while adding the value',
                            'error')
            handle.prop "checked", false)
      else
        _L.selects.removeValue(selectId, @value, 'binary')
          .fail(-> 
            locals.setAlert('header-wrapper',
                            'An error occured while removing the value',
                            'error')
            handle.prop "checked", true)

    # Multi-column selects
    selectTab.on 'change', '.multi-column-select input:checkbox', (e) ->
      handle = $(@)
      selectId = handle.getContainerId('.multi-column-select')

      if @checked
        _L.selects.addValue(selectId, @value, 'binary', {})
          .fail(-> 
            locals.setAlert('header-wrapper',
                            'An error occured while adding the value',
                            'error')
            handle.prop "checked", false)
      else
        _L.selects.removeValue(selectId, @value, 'binary')
          .fail(-> 
            locals.setAlert('header-wrapper',
                            'An error occured while removing the value',
                            'error')
            handle.prop "checked", true)


    $('#select-tab').on 'click', ".can-link:not(.hidden) a", (e) ->
      selectId = $(@).closest('.can-link').data('selectId')

      _L.selects.addLink(selectId)
        .fail(->
          locals.setAlert('header-wrapper',
                          'An error occured while adding link',
                          'error')
        )
      e.preventDefault()


    $('#select-tab').on 'click', ".unlink a", (e) ->
      selectId = $(@).getContainerId('.multi-column-select')

      _L.selects.removeLink(selectId)
        .fail(->
          locals.setAlert('header-wrapper',
                          'An error occured while removing link',
                          'error')
        )
      e.preventDefault()


    $('#select-tab').on 'click', ".remove-multi-column a", (e) ->
      selectId = $(@).getContainerId('.multi-column-select')
      cfId = $(@).closest('.multi-column-select').data "cf-id"
      _L.selects.destroy(selectId)
      locals.removeInUseTag(cfId, '.selectable')
      e.preventDefault()

#===============================================================================


# INFO TAB ---------------------------------------------------------------------
       
    # $('#info-tab a').popover()
    # $('#info-tab').on 'click', 'a', (e) ->
    #   e.preventDefault()

#===============================================================================


# EXCLUDES SWITCH --------------------------------------------------------------

    $('#select-tab').on 'click', '.exclude-switch', (e) ->
      selectId = $(@).getContainerId('.select')
      status = $(@).find('div').hasClass('exclusion-on')

      if status
        _L.selects.resetExclude(selectId)
          .fail(->
            locals.setAlert(
              'header-wrapper',
              'An error occured while resetting the exclude value',
              'error'
            )
          )
      else
        _L.selects.setExclude(selectId)
          .fail(->
            locals.setAlert(
              'header-wrapper',
              'An error occured while resetting the exclude value',
              'error'
            )
          )

#---CLONE STATUS------------------------------------------------------------  

    locals.refreshDropzoneLock = () ->
      container = $('#dropzone-lock')
      id = container.data('id')

      if container.length
        $.getJSON "/jobs/#{id}/check_status"
          .done((job) ->
            if job['status'] == 'completed'
              window.location.reload();
            else
              setTimeout (-> locals.refreshDropzoneLock()), 3000
          )

#===============================================================================


#- SUPPRESSION CHECK BOXES ----------------------------------------------
    # Event for adding or removing suppression order
    suppressTab.on "change", ".suppression-order input:checkbox", (e) ->
      handle = $(@)
      countId = $('#count-title').getContainerId('.count')

      if @checked
        _L.suppression_orders.add(countId, @value)
          .fail(-> 
            locals.setAlert('header-wrapper',
                            'An error occured while adding the order',
                            'error')
            handle.prop "checked", false)
      else
        _L.suppression_orders.remove(countId, @value)
          .fail(-> 
            locals.setAlert('header-wrapper',
                            'An error occured while removing the order',
                            'error')
            handle.prop "checked", true)


    # Event for adding or removing suppression files
    suppressTab.on "change", ".suppression-file input:checkbox", (e) ->
      handle = $(@)
      countId = $('#count-title').getContainerId('.count')
      countsUserFileId = handle.closest('.data-row').data('countsUserFileId')
      criteriaSelect = handle.closest('.data-row').find('.criteria-select select')
      criteria = criteriaSelect.val()

      if @checked
        criteriaSelect.removeClass('invisible')

        _L.suppression_user_files.add(@value, countId, criteria)
          .fail(->
            locals.setAlert('header-wrapper',
                            'An error occured while adding the file',
                            'error')
            handle.prop "checked", false
            criteriaSelect.addClass('invisible')
          )
      else
        criteriaSelect.addClass('invisible')

        _L.suppression_user_files.destroy(countsUserFileId)
          .fail(->
            locals.setAlert('header-wrapper',
                            'An error occured while removing the file',
                            'error')
            handle.prop "checked", true
            criteriaSelect.removeClass('invisible')
          )


    suppressTab.on "change", ".criteria-select select", (e) ->
      handle = $(@)
      countsUserFileId = handle.closest('.data-row').data('countsUserFileId')
      value = handle.val()

      _L.suppression_user_files.updateCriteria(countsUserFileId, value)
        .done(->
          handle.updateData("previous", parseInt(value)))
        .fail(->
          locals.setAlert('header-wrapper',
                          'An error occured while setting criteria',
                          'error')
          handle.val(handle.attr("data-previous")))


    locals.updateSuppressionBadge = (suppressionType, count) ->
      # Expected suppression types are 'files' or 'orders'
      badge = $(".badge-#{suppressionType}")

      if count > 0
        badge.removeClass('hidden')
        badge.text(count)
        str = suppressionType
        if count == 1
          str = suppressionType.substring(0, suppressionType.length - 1)
        badge.attr('title', "#{count} #{str}")
      else
        badge.addClass('hidden')

#===============================================================================


#- SETUP DATE PICKER------------ -----------------------------------------------
  locals.datepickerSetup = (selector) ->
    handle = selector.find(' #select-date-text-fields')
    min = handle.data 'min'
    max = handle.data 'max'
    range = handle.data 'range'

    datepicker_ops = {
      changeYear: true,
      changeMonth: true,
      dateFormat: 'yy-mm-dd',
      showMonthAfterYear: true,
      minDate: min,
      maxDate: max,
      yearRange: range
    }

    handle.find('#date-fields .date-input').datepicker(datepicker_ops)

#===============================================================================


#- SORT & FILTER FOR COUNT INDEX -----------------------------------------------
  locals.indexEvents = ->
    content = $('#content')

    content.on "click", ".pagination a", (e) ->
      e.preventDefault()
      $.getScript @.href

    content.on "click", "th > a", (e) ->
      e.preventDefault()
      column = $('#filter_form').find('#sort_column')
      direction = $('#filter_form').find('#sort_direction')
      
      newSort = @.id
      currentSort = column.val()

      if currentSort == newSort
        if direction.val() == 'desc'
          direction.val('asc')
        else
          direction.val('desc') 
      
      else
        column.val(newSort)

      locals.submitIndexFilter()

    content.on "change", "select", (e) ->
      e.preventDefault()
      value = $(@).val()
      locals.submitIndexFilter()

    content.on "keyup", "input[type='text']", (e) ->
      input = $(@)
      value = input.val()
      icons = input.siblings('i')

      if value != ''
        icons.addClass('on')
      else
        icons.removeClass('on')

      locals.submitIndexFilter()

    #Clear filter textfield by clicking the 'X'
    content.on "click", "i.clear-text-icon", (e) ->
      icon = $(@)
      textfield = icon.siblings('.column-textfield').val('').focus()
      icon.removeClass('on')
      locals.submitIndexFilter()

  locals.submitIndexFilter = ->
    $('#filter_form').submit()

  locals.updateIndexTable = (table) ->
    $('.data-row').remove()
    $('.table>tbody').append(table)

  locals.updatePaginationSection = ->
    wrapper = $('.pagination-wrapper')
    pagination = wrapper.first().html()

    $('.pagination-placeholder').html(pagination)
    wrapper.remove()

  locals.updateIndexHeader = ->
    form = $('#filter_form')
    $("th > a").removeClass()
    direction = form.find('#sort_direction').val()
    column = form.find('#sort_column').val()
    $("th > a#" + column).addClass('current ' + direction)

  locals.updateUrl = (filterParams) ->
    url = "#{location.origin}#{location.pathname}?#{$.param(filterParams)}"
    window.history.pushState("", "", url)
#===============================================================================

  locals.expandOrCollapseSelect = (select) ->
    locals.hideExpandCollapseIcons(select)

    select.find('.select-content').slideToggle 'fast', ->
      anchor = select.find('a.select-expand-collapse')
      if select.hasClass('collapsed')
        select.removeClass('collapsed')
        locals.showExpandCollapseIcons(select, 'up')
        anchor.prop('title', 'Collapse')
      else
        select.addClass('collapsed')
        locals.showExpandCollapseIcons(select, 'down')
        anchor.prop('title', 'Expand')

  locals.hideExpandCollapseIcons = (select) ->
    icons = select.find('.select-expand-collapse>i')
    icons.fadeOut 'fast'

  locals.showExpandCollapseIcons = (select, direction) ->
    angleDouble = select.find("i[class^='fa fa-angle-double-']").first()
    chevron = select.find("i[class^='fa fa-chevron-']").first()

    angleDouble.fadeIn 'fast', ->
      angleDouble.removeClass()
      angleDouble.addClass "fa fa-angle-double-#{direction}"

    chevron.fadeIn 'fast', ->
      chevron.removeClass()
      chevron.addClass "fa fa-chevron-#{direction}"

  locals.toggleLookupCheckboxes = (parent, action) ->
    checked = (action == 'add')
    parent.find('.lookup-results input.checkbox').prop('checked', checked)

  locals.addInUseTag = (fieldId, type) ->
    selector = 'div#concrete_field_' + fieldId
    $(selector).find('span.filter-tag'+ type).removeClass("hidden")

  locals.removeInUseTag = (fieldId, type) ->
    selector = 'div#concrete_field_' + fieldId
    $(selector).find('span.filter-tag'+ type).addClass("hidden")

  locals.markActiveInputOptions = ->
    $("div.select-content").each ->
      content = $(@)
      content.find("ul>li:first").addClass("active")
      content.find("div.tab-content>div:first").addClass("active")

  locals.isEmpty = (selector) ->
    $(selector).children().length == 0

  locals.activeSelection = (caller) ->
    ret = true

    if locals.isEmpty '#selects-drop'
      ret = false
    else
      if ($(caller).hasClass('breakdown-action') && locals.isEmpty('#breakdown-drop'))
        ret = false
    
    ret

  locals.validationErrorAlert = (trigger) ->
    if $(trigger).hasClass 'breakdown-action'
      locals.setAlert(
        "header-wrapper",
        "There must be at least 1 active breakdown and select field",
        "error")
    else
      locals.setAlert(
        "header-wrapper",
        "There must be at least 1 active select field",
        "error")

  locals.setupActionButton = (selector) ->
    simpleCountButton = $('.run-btn.default-action')
    breakdownCountButton = $('.run-btn.breakdown-action')

    if selector == 'breakdown'
      simpleCountButton.addClass('hidden')
      breakdownCountButton.removeClass('hidden')
    else
      breakdownCountButton.addClass('hidden')
      simpleCountButton.removeClass('hidden')

  locals.setDropHeight = ->
    if $('#count-design-pane-tabs').length
      height = $(window).height()
      height -= $("[id^=count] .active").offset().top #Current active pane
      height -= ($('.footer').height() + 65)
      # TO-DO: Use a class for altering this property
      $('#selects-drop, #dedupe-drop, #suppression-lists').css('min-height', height)

    setTimeout(locals.setDropHeight, 200)


#- RENAME COUNT ----------------------------------------------------------------
  
  locals.startTextboxEditing = (textbox) ->
    $(textbox).addClass('editing')

  locals.stopTextboxEditing = (textbox) ->
    $(textbox).removeClass('editing')

  locals.acceptTextboxChanges = (input) ->
    if $(input).val() != $(input).attr('value')
      name = $.trim(input.val())

      $.ajax
        type: "PATCH",
        url: "rename",
        data: {count: {name: name}}
        dataType: "script"
        success: ()->
          $(input).attr('value', name)
          $('.editable-text').html(name)

    locals.stopTextboxEditing($(input).closest('.textbox.editing'))

  locals.cancelTextboxChanges = (input) ->
    locals.stopTextboxEditing($(input).closest('.textbox.editing'))
    input.val($(input).attr('value'))


## COUNT JOB STATUS CHANGES ---------------------------------------------------

  locals.updateJobStatus = (job) ->
    locals.refreshStatusAndResults(job['is_active'])

  locals.refreshStatusAndResults = (isActive) ->
    timer = $('#count-elapsed-time')

    if timer.length == 0
      locals.reloadCountStatus(isActive)
    else
      timer.slideUp ->
        timer.countdown('destroy')
        locals.reloadCountStatus(isActive)

    unless isActive
      $('#breakdown-result').find('.async-div').reloadContent()

    $('.run-btn').attr('disabled', isActive)

  locals.reloadCountStatus = (isActive) ->
    container = $('#count-status-and-result').find('.async-div')
    container.reloadContent()
      .done( ->
        locals.refreshCountdownTimer() if isActive
      )

  locals.refreshCountdownTimer = ->
    container = $('#count-elapsed-time')
    date = container.data('created-at')

    if date
      container.countdown({
        since: new Date(date),
        serverSync: Paloma.locals.counts.serverTime,
        labels: ['y', 'm', 'w', 'd', 'h', 'm', 's'],
        labels1: ['y', 'm', 'w', 'd', 'h', 'm', 's'],
        format: 'dhmS',
        layout: '{d<}{dn}{dl}{d>} {h<}{hn}{hl}{h>} {m<}{mn}{ml}{m>} {s<}{sn}{sl}{s>}',
      })

  locals.showRetryPolling = ->
    container = $('#retry-count-polling')
    container.siblings().addClass('hidden')
    container.removeClass('hidden')
    container.find('#last-count-time').text($('#count-elapsed-time').text())
    $('.polling-status-tooltip').tooltip()

#===============================================================================

  Paloma.inheritLocals({from : '/', to : 'counts'})
)()
