(->
  _x = Paloma.variableContainer
  _L = Paloma.locals
  _l = _L['counts']

  Paloma.callbacks['counts']['new'] = (params) ->
    $('form.new_count').on 'click', '.select-datasource', (e) ->
      e.preventDefault()
      form = $(@).closest('form')
      form.find('input#count_datasource').val($(@).getId())
      form.submit()
)()
