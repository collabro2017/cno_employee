(-> 
  # Initializes the main container for all filters and skippers for this
  # specific scope.
  filter = new Paloma.FilterScope('clones')
  
  # The _x object is also available on callbacks.
  # You can make a variable visible on callbacks by using _x here.
  #
  # Example:
  # _x.visibleOnCallback = "I'm a shared variable"
  _x = Paloma.variableContainer
  _L = Paloma.locals["/"]

  # ~> Start definitions here and remove this line.


)()