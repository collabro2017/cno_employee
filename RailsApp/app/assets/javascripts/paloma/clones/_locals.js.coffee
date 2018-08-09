(->
  Paloma.callbacks['clones'] = {}
  locals = Paloma.locals['clones'] = {}
  _L = Paloma.locals

## CLONE JOB STATUS CHANGES ---------------------------------------------------

  locals.updateJobStatus = (job) ->
    status = job['status']

    if status == 'completed'
      window.location.reload()
    else if status == 'working' || status == 'queued'
      locals.refreshStatus()

  locals.refreshStatus = ->
    $('#clone-status').slideUp ->
      $('#dropzone-lock').find('.async-div').reloadContent()

  locals.refreshCountdownTimer = ->
    console.log 'n/a'

  locals.showRetryPolling = ->
    container = $('#retry-clone-polling')
    container.siblings().addClass('hidden')
    container.removeClass('hidden')

#===============================================================================
  Paloma.inheritLocals({from : '/', to : 'clones'})
)()
