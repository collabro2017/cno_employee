(->
  Paloma.callbacks['lookups'] = {}
  locals = Paloma.locals['lookups'] = {}

  locals.lookupSearch = (container, firstFilter, fuzzyFilter, selectId, lookupType) ->
    asyncDiv = container.find('.async-div')
    
    params = {
      lookup: {
        first_filter: firstFilter,
        fuzzy_filter: fuzzyFilter,
        select_id: selectId,
        lookup_type: lookupType
      }
    }

    asyncDiv.updateData('params', params)
    asyncDiv.updateData('refresh', true)

  Paloma.inheritLocals({from : '/', to : 'lookups'})
)()
