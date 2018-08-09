(->
  Paloma.callbacks['selects'] = {}
  locals = Paloma.locals['selects'] = {}

  ######################### Add, remove and sort ###############################

  locals.add = (concreteField, countId, position) ->
    params = {
      select: {
        concrete_field: concreteField,
        count: countId, 
        position: position
      }
    }

    $.ajax(
      type: "POST",
      url: "/selects",
      data: params
    )

  locals.update = (selectId, property, value) ->
    params = {
      select: {
      }
    }

    params["select"][property] = value

    $.ajax(
      type: "PUT",
      url: "/selects/#{selectId}",
      data: params
      dataType: "script"
    )

  locals.destroy = (selectId) ->
    $.post("/selects/#{selectId}", {_method: 'delete'})

  locals.updatePosition = (selectId, position) ->
    params = {select: {position: position}}

    $.ajax(
      type: "PATCH",
      url: "/selects/#{selectId}/update_position",
      data: params
      dataType: "script"
    )

  locals.actualPosition = (item) ->
    position = item.index()
    item.parent().children().slice(0, position).each (index, element) ->
      if $(element).hasClass('multi-column-group')
        position += $(element).find('.multi-column-select').size() - 1
    position

  ################################### Values Related ###########################

  locals.addValue = (selectId, value, inputMethod, lookupParams) ->
    params = {
      select: {
        value: value,
        input_method: inputMethod,
        lookup_params: lookupParams
      }
    }

    $.ajax(
      type: "PATCH",
      url: "/selects/#{selectId}/add_value",
      data: params,
      dataType: "script"
    )

  locals.removeValue = (selectId, value, inputMethod) -> 
    params = {
      select: {
        value: value,
        input_method: inputMethod
      }
    }

    $.ajax(
      type: "PATCH",
      url: "/selects/#{selectId}/remove_value",
      data: params,
      dataType: "script"
    )

  locals.addMultipleEnterValues = (selectId, value) ->
    params = {
      select: {
        value: value
      }
    }

    $.ajax(
      type: "PATCH",
      url: "/selects/#{selectId}/add_multiple_enter_values",
      data: params
      dataType: "script"
    )

  locals.getSavedEnterValues = (selectId) ->
    $.getScript("/selects/#{selectId}/get_saved_enter_values", null, null, "script")

  ###################################### RANGE #################################

  locals.setRange = (selectId, from, to) ->
    params = {
      select: {
        from: from,
        to: to
      }
    }

    $.ajax(
      type: "PATCH",
      url: "/selects/#{selectId}/set_range",
      data: params
    )

  locals.resetRange = (selectId) ->
    $.ajax(
      type: "PATCH",
      url: "/selects/#{selectId}/reset_range",
      dataType: "script"
    )

  ################################### DATES ####################################
  locals.setDate = (selectId, from, to) ->
    params = {
      select: {
        from: from,
        to: to
      }
    }

    $.ajax(
      type: "PATCH",
      url: "/selects/#{selectId}/set_date",
      data: params
    )

  locals.resetDate = (selectId) ->
    $.ajax(
      type: "PATCH",
      url: "/selects/#{selectId}/reset_date",
      dataType: "script"
    )

  #######################################Lookup#################################

  locals.handleMultipleLookupValues = (
    selectId, action, lookupType, firstFilter, fuzzyFilter, page
  ) ->
    params = {
      select: {
        lookup_type: lookupType,
        first_filter: firstFilter,
        fuzzy_filter: fuzzyFilter,
        page: page
      }
    }

    $.ajax(
      type: 'PATCH',
      url: "/selects/#{selectId}/#{action}_multiple_lookup_values",
      data: params,
      dataType: "script"
    )

  ####################################BLANKS####################################

  locals.setBlanks = (selectId, value) ->
    params = {
      select: {
        blanks: value
      }
    }

    $.ajax(
      type: 'PATCH',
      url: "/selects/#{selectId}/set_blanks"
      data: params,
      dataType: "script"
    )

  locals.resetBlanks = (selectId) ->
    $.ajax(
      type: 'PATCH',
      url: "/selects/#{selectId}/reset_blanks"
      dataType: "script"
    )

  locals.setExclude = (selectId) ->
    params = {
      select: {
        exclude: true
      }
    }

    $.ajax(
      type: 'PATCH',
      url: "/selects/#{selectId}/set_exclude",
      data: params,
      dataType: 'script'
    )

  locals.resetExclude = (selectId) ->
    $.ajax(
      type: 'PATCH',
      url: "/selects/#{selectId}/reset_exclude",
      dataType: 'script'
    )

################################### UserFiles Related ##########################

  locals.addUserFile = (selectId, userFileId) ->
    params = {
      select: {
        user_file_id: userFileId
      }
    }

    $.ajax(
      type: "PATCH",
      url: "/selects/#{selectId}/add_user_file",
      data: params,
      dataType: "script"
    )

  locals.removeUserFile = (selectId, userFileId) ->
    params = {
      select: {
        user_file_id: userFileId
      }
    }

    $.ajax(
      type: "PATCH",
      url: "/selects/#{selectId}/remove_user_file",
      data: params,
      dataType: "script"
    )

  ##############################################################################

  locals.validRange = (select, from, to) ->
    min = parseInt(select.find("#select-range-text-fields").data("min"))
    max = parseInt(select.find("#select-range-text-fields").data("max"))

    (min <= from && from <= to && to <= max)

  locals.validDateRange = (select, from, to) ->
    handle = select.find("#select-date-text-fields")
    min = locals.dateToInteger(handle.data("min"))
    max = locals.dateToInteger(handle.data("max"))

    (min <= from && from <= to && to <= max)

  locals.setBindings = ->
    $('#select-tab').find('.switch-regular[data-loaded="false"]')
      .bootstrapSwitch()
      .attr('data-loaded', 'true')

  locals.addLink = (selectId) ->
    $.ajax(
      type: "PATCH",
      url: "/selects/#{selectId}/add_link",
      dataType: "script"
    )

  locals.removeLink = (selectId) ->
    $.ajax(
      type: "PATCH",
      url: "/selects/#{selectId}/remove_link",
      dataType: "script"
    )

  ##############################################################################
  
  locals.inUse = (selectId) ->
    fieldPresence = $('.select[data-cf-id='+selectId+']').length

    unless fieldPresence == 0
      locals.setAlert(
        'header-wrapper',
        'The select field is already in use.',
        'warning'
      )

  Paloma.inheritLocals({from : '/', to : 'selects'})
)()
