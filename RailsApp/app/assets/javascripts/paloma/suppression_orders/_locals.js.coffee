(->
  # Initializes callbacks container for the this specific scope.
  Paloma.callbacks['suppression_orders'] = {}

  # Initializes locals container for this specific scope.
  # Define a local by adding property to 'locals'.
  #
  # Example:
  # locals.localMethod = function(){};
  locals = Paloma.locals['suppression_orders'] = {}
  
  # ~> Start local definitions here and remove this line.

  locals.add = (countId, orderId) ->
    params = {
      count: {
        order_id: orderId
      }
    }

    $.ajax(
      type: "PATCH",
      url: "/counts/#{countId}/add_suppression_order",
      data: params,
      dataType: "script"
    )


  locals.remove = (countId, orderId) ->
    params = {
      count: {
        order_id: orderId
      }
    }

    $.ajax(
      type: "PATCH",
      url: "/counts/#{countId}/remove_suppression_order",
      data: params,
      dataType: "script"
    )

)()

