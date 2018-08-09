(->
  Paloma.callbacks['user_files'] = {}
  locals = Paloma.locals['user_files'] = {}
  
  #-----------------------------------------------------------------------------

  locals.attachEventHandlers = () ->
    $("#files-manager").on "change", "input:file.file-upload", (e) ->
        fileInput = $(@)
        locals.add(@.files[0].name)
          .success((result) -> 
            locals.upload fileInput, result, (fileInfo, asyncDiv) ->
          )
          .fail(->
            locals.setAlert('header-wrapper',
                            'An error occured when trying to add the file',
                            'error')
            fileInput.replaceWith(fileInput = fileInput.clone()) # To clear it
          )

    $("#files-manager").on "click", ".pagination a", (e) ->
      e.preventDefault()
      asyncDiv = $(@).closest('.async-div')
      params = asyncDiv.data('params')
      params['page'] = $(@).data('page')
      asyncDiv.updateData('params', params)
      asyncDiv.reloadContent()

    $("#files-manager").on 'ajax:error', "a[data-remote].remove-link", (e) ->
      asyncDiv = $(@).closest('.async-div')
      asyncDiv.reloadContent()

  #-----------------------------------------------------------------------------

  locals.add = (name) ->
    params = {
      user_file: {
        name: name
      }
    }

    $.ajax(
      type: "POST",
      url: "/user_files",
      data : JSON.stringify(params),
      contentType : 'application/json',
      dataType : 'json'
    )

  #-----------------------------------------------------------------------------

  locals.remove = (id) ->
    $.ajax(
      type: "DELETE",
      url: "/user_files/#{id}",
      contentType : 'application/json',
      dataType : 'json'
    )

  #-----------------------------------------------------------------------------

  locals.removeInsistently = (id, retries) ->
    locals.remove(id)
      .fail(->
        if retries > 0
          setTimeout (->
            locals.removeInsistently(id, retries - 1)
          ), 1000
      )

  #-----------------------------------------------------------------------------

  locals.markAsUploaded = (fileId) ->
    $.ajax(
      type: "PATCH",
      url: "/user_files/#{fileId}/mark_as_uploaded",
      dataType: "script"
    )

  #-----------------------------------------------------------------------------

  locals.upload = (fileInput, fileInfo, onSuccess) ->
    uploadFileHeader = fileInput.closest('div.upload-file-header')
    progressBar = uploadFileHeader.find('.progress-bar')
    progress = progressBar.find('.progress')
    bar = progress.find('.bar')

    fileInput.fileupload
      type: 'POST'
      autoUpload: false
      paramName: 'file'
      dataType: 'XML'

      add: (e, data) ->
        data.submit()

      progressall: (e, data) ->
        percentage = parseInt(data.loaded / data.total * 100, 10)
        bar.removeClass('no-transition')
        bar.css "width", "#{percentage}%"
        bar.text "Uploading '#{fileInfo.name}' - (#{percentage}%)"

      start: (e) ->
        progressBar.removeClass('hidden')

        progress.removeClass('progress-danger')
        progress.addClass('progress-striped active')
        
        bar.addClass('no-transition')
        bar.css("display", "block").css("width", "0%")
        bar.text ""
        
      always: (e, data) ->
        fileInput.fileupload('destroy')
        fileInput.replaceWith(fileInput.clone())

      done: (e, data) ->
        progress.removeClass('progress-striped active')
        bar.text "Finished uploading '#{fileInfo.name}' - (100%)"        
        progressBar.addClass('hidden')

        locals.markAsUploaded(fileInfo.id)
          .success(-> 
            asyncDiv = uploadFileHeader.next('.user-files-list').find('.async-div')
            asyncDiv.reloadContent()
              .done(->
                onSuccess(fileInfo, asyncDiv)
              )
          )

      fail: (e, data) ->
        percentage = parseInt(data.loaded / data.total * 100, 10)
        progress.removeClass('progress-striped active')
        progress.addClass('progress-danger')
        bar.css "width", "100%"
        bar.text "Failed uploading '#{fileInfo.name}' - (#{percentage}%)"

        locals.removeInsistently(fileInfo.id, 5)

    fileInput.fileupload 'add',
      fileInput: fileInput

  Paloma.inheritLocals({from : '/', to : 'user_files'})
)()
