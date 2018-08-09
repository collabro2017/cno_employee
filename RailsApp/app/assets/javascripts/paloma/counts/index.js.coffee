(->
  _x = Paloma.variableContainer
  _L = Paloma.locals
  _l = _L['counts']

  Paloma.callbacks['counts']['index'] = (params) ->
    _l.indexEvents()
)()
