module SelectsHelper

  def active_blanks_option(status)
    status ?  '' : 'display:none'
  end

  def active_toggle_button(select)
    select.blanks == 'blanks' ?  'active' : ''
  end

  def active_radio_button(select, criterion)
    'active' if select.blanks.to_s == criterion
  end

  def binary_caption(value)
    (value.nil? || value.blank?) ? '(Blank)' : value.to_s
  end

  def binary_active(saved_binary_value, expected_value)
    (saved_binary_value == expected_value) ? ' active' : ''
  end

  def active_exclude(active)
    title = active ? 'Select' : 'Exclude'

    content_tag(:a, title: title, class: 'exclude-switch') do
      if active
        concat(content_tag(:div, fa_icon('toggle-on'), class: 'exclusion-on'))
        concat(content_tag(:div, 'EXCLUDING', class: 'exclusion-on-text'))
      else
        concat(content_tag(:div, fa_icon('toggle-off'), class: 'exclusion-off'))
        concat(content_tag(:div, 'EXCLUDING', class: 'exclusion-off-text'))
      end
    end
  end

  def year_range(select)
    min = Date.parse(select.valid_min.to_s).year
    max = Date.parse(select.valid_max.to_s).year
    "#{min}:#{max}"
  end

  def select_vertical_tabs(select, input_method)
    type = input_method.input_method_type.to_s
    href = "##{type}_select_#{select.id}"
    href << "_#{input_method.position}" if custom_lookups.include?(type)

    title = "Select by #{type.humanize(capitalize: false)}"
    klass = "#{type}-tab-link"

    data = { toggle: 'tab', toggle2:'tooltip', placement: 'right' }
    data['loaded'] = false if type == 'enter_value'

    content_tag(:li) do
      concat(
        content_tag(:a, href: href, title: title, class: klass, data: data) do
          concat(tab_icon(input_method))
        end
      )
    end
  end

  def select_vertical_tabs_content(select, input_method)
    type = input_method.input_method_type.to_s
    partial_name = "#{type}"
    locals = {select: select, input_method: input_method}

    partial_name = 'custom_lookup' if custom_lookups.include?(type)

    path = "selects/vertical_tab_content/#{partial_name}"
    render partial: path, locals: locals
  end

  def render_lookup_header(select, lookup_class)
    prefix = "lookups"
    partial_name = 'default_header'
    
    custom_prefix = "#{prefix}/custom_header_partials"
    custom_partial_name = "#{lookup_class.type}_header"
    if lookup_context.exists?(custom_partial_name, custom_prefix, true)
      partial_name = custom_partial_name
      prefix = custom_prefix
    end

    full_partial_name =  "#{prefix}/#{partial_name}"
    render(partial: full_partial_name,
            locals: { select: select, lookup_class: lookup_class }
      )
  end

  private
    def custom_lookups
      @custom_lookups ||=
        Lookups::Custom.constants.map{ |custom| "#{custom.to_s.underscore}" }
    end

    def tab_icon(input_method)
      if custom_lookups.include?(input_method.input_method_type.to_s)
        fa_icon input_method.lookup_class.icon
      else
        fa_icon input_method.input_method_type.icon
      end
    end
    
end
