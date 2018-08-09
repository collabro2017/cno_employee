(->
  Paloma.callbacks['suppression_user_files'] = {}
  locals = Paloma.locals['suppression_user_files'] = {}

  locals.add = (userFileId, countId, concreteFieldId) ->
    params = {
      counts_user_file: {
        user_file_id: userFileId,
        count_id: countId,
        concrete_field_id: concreteFieldId
      }
    }

    $.ajax(
      type: "POST",
      url: "/counts_user_files",
      data: params
    )

  locals.destroy = (countsUserFileId) ->
    $.post("/counts_user_files/#{countsUserFileId}", {_method: 'delete'})

  locals.updateCriteria = (countUserFileId, value) ->
    params = {
      counts_user_file: {
        concrete_field_id: value
      }
    }

    $.ajax(
      type: "PUT",
      url: "/counts_user_files/#{countUserFileId}/",
      data: params,
      dataType: "script"
    )
)()

