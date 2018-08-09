(->
  # Initializes callbacks container for the this specific scope.
  Paloma.callbacks['alerts'] = {};

  # Initializes locals container for this specific scope.
  # Define a local by adding property to 'locals'.
  #
  # Example:
  # locals.localMethod = function(){}
  locals = Paloma.locals['alerts'] = {}

  # ~> Start local definitions here and remove this line.
  locals.setBindings = () ->
    $(".flash-alert").on "click", "a.close", (e) ->
      e.preventDefault()
      $(@).closest(".flash-alert").remove()

  locals.showAlert = (shouldHide) ->
    flashHeight = $(".flash-alert").outerHeight()
    $(".flash-alert").animate("top": "0px", 1200, ->
        locals.hideAlert(5) if shouldHide
      )

  locals.hideAlert = (time) ->
    if time == 0
      flashHeight = $(".flash-alert").outerHeight()
      $(".flash-alert").animate("top": "-=" + flashHeight, ->
        $(@).remove())
    else
      window.setTimeout (->
        locals.hideAlert time - 1
      ), 1000
    
  locals.setStyle = () ->
    navbarWidth = $("#navbar").width()
    alertWidth = navbarWidth/2
    alertLeft = (navbarWidth/4)

    $('.flash-alert').css("width", alertWidth).css("left", alertLeft)

  # Remove this line if you don't want to inherit locals defined
  # on parent's _locals.js
  Paloma.inheritLocals({from : '/', to : 'alerts'})
)()
