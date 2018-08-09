(->
  _x = Paloma.variableContainer
  _L = Paloma.locals
  _l = _L['datasources']

  Paloma.callbacks['datasources']['index'] = (params) ->
    $('#content').on 'click', '.edit_access_level', (e) ->
      e.preventDefault()
      $.ajax
        type: "GET",
        url: @.href,
        dataType: "script"
)()
