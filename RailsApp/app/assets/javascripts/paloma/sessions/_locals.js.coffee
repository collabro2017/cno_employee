(->
  # Initializes callbacks container for the this specific scope.
  Paloma.callbacks['sessions'] = {}

  # Initializes locals container for this specific scope.
  # Define a local by adding property to 'locals'.
  #
  # Example:
  # locals.localMethod = function(){};
  locals = Paloma.locals['sessions'] = {}
  
  # ~> Start local definitions here and remove this line. 

  locals.checkTimeLeft = (seconds) ->
    setTimeout ( ->
      $.getScript '/sessions/check_time_left'
    ), seconds * 1000

  locals.showExpireAlert = (seconds) ->
    $('#expiration-modal').modal(backdrop: 'static', keyboard: false)
    $('#expiration-timer').countdown({until: seconds, format: 'S', layout: '{s<}{sn}{s>}'})
    $('#expiration-confirm-btn').bind 'click', locals.hideModal

  locals.hideModal = (e) ->
    e.preventDefault()
    locals.serverTime()
    $('#expiration-modal').modal('hide')
    $('#expiration-timer').countdown('destroy')
    $('#expiration-confirm-btn').unbind 'click', locals.hideModal

  # Remove this line if you don't want to inherit locals defined
  # on parent's _locals.js
  Paloma.inheritLocals({from : '/', to : 'sessions'})
)()

