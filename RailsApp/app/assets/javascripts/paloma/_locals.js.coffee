(->
  locals = Paloma.locals["/"] = {}

  locals.setAlert = (selector, message, type) ->
    id = Math.floor(Math.random() * 1000)
    html = "<div class='alert alert-#{type} fade in' id='alert-message-#{id}'>#{message}<a class='close' data-dismiss='alert'>&times;</a></div>"
    div = "#" + selector  #TO-DO: Remove. We're forcing it to be an id, why?
    $(div).append(html)

    window.setTimeout (->
      $("#alert-message-#{id}").fadeTo(500, 0).slideUp 500, ->
        $(@).remove()
    ), 3000

  locals.closestAncestorId = (origin, endpoint) ->
    origin.closest(endpoint).attr('id').replace(/[^\d]/g, '')

  jQuery.fn.extend
    getId: ->
      @.attr('id').replace(/[^\d]/g, '')

  jQuery.fn.extend
    getModelName: ->
      @.attr('id').replace(/_[\d]+$/g, '')

  jQuery.fn.extend
    getContainerId: (container) ->
      @.closest(container).getId()

  jQuery.fn.extend
    getForm: ->
      $(@.get(0).form)

  jQuery.fn.extend
    changeTop: (delta) ->
      newOffset = @.offset()
      newOffset.top += delta
      @.offset(newOffset)

  jQuery.fn.extend
    updateData: (field, value) ->
      @.data(field, value)
      @.attr('data-' + field, JSON.stringify(value))

  locals.dateToInteger = (date) ->
    value = date.replace(/-/g, '')
    parseInt(value)

  locals.handleScroll = ->
    header = $('#header')
    threshold = $('#navbar').height()
    newScroll = $(document).scrollTop()

    adjustedLast = Math.min(threshold, locals.lastScroll) 
    adjustedNew = Math.min(threshold, newScroll)

    $("#navbar, #header-wrapper, #concrete-fields-pane").each ->
      $(this).changeTop(adjustedLast - adjustedNew)    

    if (newScroll >= threshold) && (locals.lastScroll < threshold)
      header.addClass('raised')

    else if (newScroll < threshold) && (locals.lastScroll >= threshold)
      header.removeClass('raised')

    locals.lastScroll = newScroll

  jQuery.fn.extend
    reloadContent: ->
      asyncDiv = @
      if asyncDiv.is(".async-div[data-refresh='false']")
        url = asyncDiv.data('url')
        params = asyncDiv.data('params')
        spin = asyncDiv.data('spin')
        
        if spin
          asyncDiv.html(locals.spinner())
        
        $.ajax(
          type: 'GET',
          url: url,
          data: params,
          dataType: 'html'
        ).done((data) -> 
          asyncDiv.html(data)
        ).fail( ->
          locals.setAlert('header-wrapper', 'An error occured while loading the data.', 'error')
        )
      else
        throw "Object does not support the 'reloadContent' function"

  locals.asyncLoad = ->
    $(".async-div[data-refresh='true']").each ->
      asyncDiv = $(@)
      asyncDiv.updateData('refresh', false) # flag it for not loading it again
      asyncDiv.reloadContent()

    setTimeout ( ->
      locals.asyncLoad()
    ), 500

  locals.asyncBindings = (selector, bindingFunction) ->
    if $(selector).size() > 0
      bindingFunction()
    else
      setTimeout ( ->
        locals.asyncBindings(selector, bindingFunction)
      ), 2000

  locals.spinner = (target) ->
    opts =
      lines: 9
      length: 6
      width: 8
      radius: 10
      corners: 1.0
      rotate: 0
      trail: 50
      speed: 0.7
      direction: 1
      color: "#333"
      className: 'spinner'
      hwaccel: on
    (new Spinner(opts).spin()).el

  locals.isNumber = (val) ->
     !isNaN(parseFloat(val)) && isFinite(val)

  locals.serverTime = ->
    time = new Date()
    $.ajax(
      url: "/server_time"
      async: false
      dataType: "text"
    ).done((data) ->
      time = new Date(data)
    )
    time

  $(document).ready ->
    locals.lastScroll = $(document).scrollTop()
    $(window).scroll(locals.handleScroll)

    # Check for session activity
    Paloma.locals["sessions"].checkTimeLeft(0)

    # Selector for searching contents ignoring the case
    $.expr[":"].containsIgnoreCase = (object, index, meta, stack) ->
      jQuery(object).text().toUpperCase().indexOf(meta[3].toUpperCase()) >= 0

    Paloma.locals["alerts"].setBindings()
    Paloma.locals["alerts"].showAlert(true)
    Paloma.locals["alerts"].setStyle()
)()
