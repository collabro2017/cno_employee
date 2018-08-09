(->
  Paloma.callbacks["jobs"] = {}

  # Equivalent of 185 seconds of active status checks
  MAX_NUMBER_CHECKS = 34
  
  locals = Paloma.locals["jobs"] = {}
  _L = Paloma.locals
  
  locals.checkStatus = (id, currentStatus, checksCount, namespaceLocals) ->
    if checksCount < MAX_NUMBER_CHECKS
      $.getJSON "/jobs/#{id}/check_status"
        .done((job) ->
          status = job['status']

          if status != currentStatus
            namespaceLocals.updateJobStatus(job)

          if job['is_active']
            namespaceLocals.refreshCountdownTimer()
            setTimeout ( ->
              locals.checkStatus(id, status, checksCount + 1, namespaceLocals)
            ), locals.nextInterval(checksCount)            
        )
        .fail( ->
          console.log 'Error retrieving job status'
        )
    else
      namespaceLocals.showRetryPolling()

  locals.pollActiveJob = (job, namespaceLocals) ->
    if job && job['is_active']
      locals.checkStatus(job['job_id'], job['status'], 0, namespaceLocals)

  locals.nextInterval = (checksCount) ->
    (Math.floor((1 + Math.sqrt(1 + 8 * checksCount)) / 2)) * 1000

  Paloma.inheritLocals
    from: "/"
    to: "jobs"
)()
