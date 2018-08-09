(->
  _x = Paloma.variableContainer
  _L = Paloma.locals
  _l = _L["user_files"]
  
  Paloma.callbacks["user_files"]["index"] = (params) ->
    _l.attachEventHandlers()
    _l.asyncLoad()
)()
