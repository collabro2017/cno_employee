(->
  Paloma.callbacks['forms'] = {}
  locals = Paloma.locals['forms'] = {}

  locals.setBindings = () ->
    $('form').on "click", ".mark-errors", (e) ->
      field = $(@).data "field"
      $(@).closest(field).find(field+'_errors').slideToggle()

  Paloma.inheritLocals({from : '/', to : 'forms'})
)()
