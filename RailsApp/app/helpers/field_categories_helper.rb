module FieldCategoriesHelper
  def generate_field_category_accordion(field_category, order, display_type)
    accordion_container_class = 'span12'

    if order.present? && display_type == 'output'
      accordion_container_class = 'span11'

      button_container = content_tag(:div, class: 'span1') {
        button_to nil, class: 'btn add-category-btn pull-right', title: 'Add category' do
          fa_icon('plus')
        end
      }
    end

    accordion_container = content_tag(:div, class: accordion_container_class) {
      link_to field_category.name,
              "##{dom_id(field_category, :collapse)}",
              data: {toggle: 'collapse'},
              class: 'accordion-toggle'
    }

    capture do
      concat(accordion_container)
      concat(button_container) if order.present? && display_type == 'output'
    end
  end
end
