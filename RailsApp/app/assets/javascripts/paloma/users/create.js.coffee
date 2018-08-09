(->
  # You access variables from before/around filters from _x object.
  # You can also share variables to after/around filters through _x object.
  _x = Paloma.variableContainer

  # We are using _L as an alias for the locals container.
  # Use either of the two to access locals from other scopes.
  #
  # Example:
  # _L.otherController.localVariable = 100
  _L = Paloma.locals

  # Access locals for the current scope through the _l object.
  #
  # Example:
  # _l.localMethod() 
  _l = _L['users']

  Paloma.callbacks['users']['create'] = (params) ->
    # Do something here.
    _L.forms.setBindings()
  
)()