(->
  _x = Paloma.variableContainer
  _L = Paloma.locals
  _l = _L["counts"]
  
  Paloma.callbacks["counts"]["edit"] = (params) ->
    
    _l.attachEventHandlers()
    _L.jobs.pollActiveJob(params['count_job'], _l)
    _L.dedupes.inUse()
    _L.dedupes.setBindings()
    _L.selects.setBindings()
    _L.concrete_fields.adjustConcreteFieldsPane()
    _L.concrete_fields.setFilterBindings()
    _L.concrete_fields.setButtonBindings()
    _l.asyncLoad()
    _l.asyncBindings('#accordions', _L.concrete_fields.setBindings)
    _L.jobs.pollActiveJob(params['clone_job'], _L.clones)
    _l.setDropHeight()

    $('.breakdown-result-row').hide()

    $(document).on 'click', '#expand-collapse-pane-link', (e) ->
      e.preventDefault()
      $('#concrete-fields-pane').toggleClass 'expanded'
      $('#expand-collapse-pane-link > i')
        .toggleClass 'fa-angle-double-right fa-angle-double-left'

      $('div#count-workspace > div').toggleClass('span3 span9')
      $('#moving-right-pane').toggleClass 'collapsed'

#### Count Sortable

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
        ui.item.startPos = ui.item.index()
        ui.placeholder.height 20

      update: (event, ui) ->
        dragging = $(@)
        currentTarget = $(@).attr("id")
        position = _L.selects.actualPosition(ui.item)
        select = $(ui.item).attr('id')
        id = select.replace(/[^\d]/g, '')
        
        if position >= 0
          if currentTarget == "selects-drop"
            _L.selects.updatePosition(id, position)
            .fail(-> 
              dragging.sortable('cancel')
              _l.setAlert('header-wrapper', 'The position could not be saved.', 'error')
              )
          else if currentTarget == "breakdown-drop"
            _L.breakdowns.update(id, position)
            .fail(->
              dragging.sortable('cancel')
              _l.setAlert('header-wrapper', 'The position could not be saved.', 'error')
            )
          else if currentTarget == "dedupe-drop"
            _L.dedupes.update(id, "position", position)
            .fail(->
              dragging.sortable('cancel')
              _l.setAlert('header-wrapper', 'The position could not be saved.', 'error')
            )
    )

    #Switch funtionality for dedupe
    $('#dedupe-drop').on 'switch-change', '.switch-change', (e, data) ->
      check = data.value
      text = ""
      id = $(@).getContainerId('.dedupe')
      handle = $(@).closest('.dedupe')

      if check # Verifies if switch is ON
        text = handle.find('.switch-left').text()
      else # OFF
        text = handle.find('.switch-right').text()

      _L.dedupes.update(id, "tiebreak", text)
        .fail( ->
          _l.setAlert('header-wrapper', 'The tiebreak could not be saved.', 'error')
          handle.find(".switch-change").bootstrapSwitch("toggleState", true) # skip on change
        )

    #Tooltip for enter values tab
    $("[data-toggle2=tooltip]").tooltip();

    # TODO: DRY this thing up
    # To mark active ones on first page load
    
    _l.markActiveInputOptions()
   
#### Rename Count
    editableText = $('.editable-text')

    editableText.tooltip()
    $('.accept-cancel-buttons>.fa').tooltip(placement: 'bottom')

    editableText.on 'click', (e) ->
      textbox = $(@).closest('.textbox')
      _l.startTextboxEditing(textbox)
      $(textbox).find('input').select()

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

    # # Retry polling clone job status
    $(document).on 'click', '#retry-clone-polling-link', (e) ->
      e.preventDefault()
      _L.clones.updateJobStatus(params['clone_job'])
      _L.jobs.pollActiveJob(params['clone_job'], _L.clones)

    # Retry polling count/breakdown job status
    $(document).on 'click', '#retry-count-polling-link', (e) ->
      e.preventDefault()
      jobId = $('.jobs_count').first().getId()
      
      $.getJSON "/jobs/#{jobId}/check_status"
        .done((job) ->
          job['job_id'] = jobId
          _l.updateJobStatus(job)
          _L.jobs.pollActiveJob(job, _l)
        )
)()
