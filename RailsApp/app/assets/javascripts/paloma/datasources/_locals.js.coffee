(->
  Paloma.callbacks['datasources'] = {}
  locals = Paloma.locals['datasources'] = {}

  locals.attachModalEvents = (datasourceId) ->
    
    jsonObj = {}
    $('#restricted_companies').typeahead
      minLength: 2
      source: (query, process) ->
        url = '/companies/restricted_by_datasource'
        companies = []
        data =  company: {
                  datasource_id: parseInt(datasourceId)
                }

        $.get(url, data).success (data) ->
          $.each data, (i, company) ->
            jsonObj[company.name] = company
            companies.push company.name
          process companies
      updater: (data) ->
        url = '/datasource_restricted_companies'

        $.ajax
          type: 'POST'
          url: url
          data: datasource_restricted_company:
            datasource_id: datasourceId
            company_id: jsonObj[data].id
          dataType: 'script'

    # Prevents form submission when entering an invalid company
    $(document).on 'keydown', '#restricted_companies', (event) ->
      if event.keyCode == 13
        event.preventDefault()

    $('#access_level_modal').unbind()
    $('#access_level_modal').on 'change', 'select#datasource_access_level', (e) ->
      selectedValue = $('select#datasource_access_level :selected').val()
      url = $('form.edit_datasource').attr('action')

      messageHandle = 'header-wrapper'
      message = 'The datasource access level is set to ' + selectedValue
      messageType = 'success'

      $.ajax
        type: "PUT"
        url: url
        data: { datasource: { access_level: selectedValue } }
        dataType: "script"

        success: ->
          if selectedValue == 'restricted'
            $('#restricted-companies-form').removeClass 'hidden'
          else
            $('#access_level_modal').modal('hide')

        fail: ->
          messageType = 'error'
          message = 'An error occurred while updating the datasource'

      locals.setAlert messageHandle, message, messageType

  Paloma.inheritLocals({from : '/', to : 'datasources'})
)()
