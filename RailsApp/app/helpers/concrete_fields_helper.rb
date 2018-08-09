module ConcreteFieldsHelper

	def cf_tags(count, concrete_field)
		content_tag(:div, class: "concrete-fields-tags pad") do
			
			favorite_class = "filter-tag favorite off"
			unless concrete_field.favorite
				favorite_class += " hidden"
			end
			concat(content_tag(:span, class: favorite_class){ fa_icon "star" })

			binary_class = "filter-tag binary off"
			unless concrete_field.ui_data_type == 'binary'
				binary_class += " hidden"
			end
			concat(content_tag(:span, class: binary_class) { fa_icon "flag"})
			
			select_class = "filter-tag selectable off"
			unless count.selects.map(&:concrete_field_id).include?(concrete_field.id)
				select_class += " hidden"
			end
			concat(content_tag(:span, class: select_class) { fa_icon "tag"})
			
			breakdown_class = "filter-tag breakdown off"
			unless count.breakdowns.map(&:concrete_field_id).include?(concrete_field.id)
				breakdown_class += " hidden"
			end
			concat(content_tag(:span, class: breakdown_class) { fa_icon "tag"})

			dedupe_class = "filter-tag dedupe off"
			unless count.dedupes.map(&:concrete_field_id).include?(concrete_field.id)
				dedupe_class += " hidden"
			end
			concat(content_tag(:span, class: dedupe_class) { fa_icon "tag"})

		end
	end

	def add_concrete_field_button(count, concrete_field, display_type, html=nil)
		klass = "btn add-field-btn #{display_type}"
		klass << " #{html}" unless html.blank?
		path = {
			controller: display_type.pluralize,
			display_type.to_sym => {
				count_id: count.id,
				concrete_field_id: concrete_field.id
			}
		}
    
    button_to path, class: klass, title: 'Add to count', remote: true do
      fa_icon('plus')
    end
	end
end
