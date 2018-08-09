module UsersHelper

  def set_popover_error_message(form, field)
    
    popover_html = ""
    if form.object.present? && form.object.errors[field].present?
      popover_html = render(
                            :partial => 'shared/popover_errors',
                            :locals  => {
                                          errors: form.object.errors[field],
                                          field:  field
                                        }
                           )
    end

    data = {
      content: "#{popover_html}",
      original_title: 'Errors',
      placement: 'right',
      trigger: 'hover',
      toggle: 'popover',
      html: true
    }

    fa_icon("question-circle", class: 'mark-errors', data: data)
  end

  def resend_button(user)
    klass = 'btn btn-primary btn-resend btn-link-container'
    klass << ' hidden' if user.status != 'pending'
    url = resend_activation_email_user_path(user.id)
    
    button_tag class: klass do
      link_to 'Resend', url, class: 'btn-link'
    end
  end

end
