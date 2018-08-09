$('document').ready -> 
  $("i.mark-errors").popover()
  
  $('#terms-conditions-link').click (e) ->
    e.preventDefault()
    $('#terms-modal').modal('toggle')

  $('#signin-form .btn-new').click (e) ->
    checkbox = $('#tos-checkbox')
    e.preventDefault()
    isChecked = checkbox.prop('checked')

    if isChecked
      $('form').submit()
    else
      checkbox.tooltip('show')
