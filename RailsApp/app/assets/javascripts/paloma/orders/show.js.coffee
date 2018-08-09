(->
  
  # You access variables from before/around filters from _x object.
  # You can also share variables to after/around filters through _x object.
  _x = Paloma.variableContainer
  
  # We are using _L as an alias for the locals container.
  # Use either of the two to access locals from other scopes.
  #
  # Example:
  # _L.otherController.localVariable = 100;
  _L = Paloma.locals
  
  # Access locals for the current scope through the _l object.
  #
  # Example:
  # _l.localMethod(); 
  _l = _L["orders"]
  Paloma.callbacks["orders"]["show"] = (params) ->

    _l.asyncLoad()
    _L.jobs.pollActiveJob(params['order_job'], _l)
    
    $(document).on 'click', '#retry-order-polling-link', (e) ->
      e.preventDefault()
      _l.updateJobStatus(params['order_job'])
      _L.jobs.pollActiveJob(params['order_job'], _l)

)()
