(->
  Paloma.callbacks['breakdowns'] = {}
  locals = Paloma.locals['breakdowns'] = {}

  locals.add = (concreteField, countId, position) ->
    params = {
      breakdown: {
        concrete_field: concreteField, 
        count: countId, 
        position: position
      }
    }

    $.ajax(
      type: "POST",
      url: "/breakdowns",
      data: params
      )

  locals.update = (breakdownId, position) ->
    params = {
      breakdown: {
        position: position
      }
    }

    $.ajax(
      type: "PUT",
      url: "/breakdowns/#{breakdownId}",
      data: params
      )

  locals.destroy = (breakdownId) ->
    $.post("/breakdowns/#{breakdownId}", {_method: 'delete'})

  locals.isValid = (breakdownId) ->
    valid = false
    inUse = false

    currentFieldsCount = $('#breakdown-drop').children('.breakdown').length
    fieldPresence = $('.breakdown[data-cf-id='+breakdownId+']').length
    
    if fieldPresence != 0
      inUse = true

    if currentFieldsCount < 3
      if inUse == false
        valid = true
      else
        locals.setAlert('header-wrapper', 'The field was already added.', 'error')
    else
      locals.setAlert('header-wrapper', 'You cannot add more than 3 fields for breakdown.', 'error')

    valid

  Paloma.inheritLocals({from : '/', to : 'breakdowns'})
)()
