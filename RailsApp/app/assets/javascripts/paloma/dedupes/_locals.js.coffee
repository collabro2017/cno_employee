(->
  Paloma.callbacks['dedupes'] = {}
  locals = Paloma.locals['dedupes'] = {}

  locals.add = (concreteField, countId, position) ->
    params = {
      dedupe: {
        concrete_field: concreteField, 
        count: countId, 
        position: position
      }
    }

    $.ajax(
      type: "POST",
      url: "/dedupes",
      data: params
      )

  locals.update = (dedupeId, property, value) ->

    params = {
      dedupe: {
        
      }
    }
    params["dedupe"][property] = value

    $.ajax(
      type: "PUT",
      url: "/dedupes/#{dedupeId}",
      data: params
      )

  #Remove select
  locals.destroy = (dedupeId) ->
    $.post("/dedupes/#{dedupeId}", {_method: 'delete'})

  #################################Auxiliary Functions##########################
  locals.isValid = (dedupeId) ->
    valid = false
    inUse = false

    currentFieldsCount = $('#dedupe-drop').children('.dedupe').length
    fieldPresence = $('.dedupe[data-cf-id='+dedupeId+']').length
    
    if fieldPresence != 0
      inUse = true

    if currentFieldsCount < 1
      if inUse == false
        valid = true
      else
        locals.setAlert('header-wrapper', 'The field was already added.', 'error')
    else
      locals.setAlert('header-wrapper', 'You cannot add more than 1 field for dedupe.', 'error')

    valid

  locals.inUse = ->
    dedupesInUse = $('#dedupe-drop').children('.dedupe').length
    noCheck = $('#count-dedupe a').children('i').length

    if dedupesInUse != 0
      if noCheck == 0
        $("#count-dedupe a").append('<i class="fa fa-check"></i>')
    else      
      $('#count-dedupe a').find('i').remove()
    
    setTimeout(locals.inUse, 200)

  locals.setBindings = ->
    $('#dedupe-tab').find('.switch-mini[data-loaded="false"]')
      .bootstrapSwitch()
      .attr('data-loaded', 'true')


  ##############################################################################
  Paloma.inheritLocals({from : '/', to : 'dedupes'})
)()
