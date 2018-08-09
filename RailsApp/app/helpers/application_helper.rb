module ApplicationHelper

  class CustomLinkRenderer < WillPaginate::ActionView::BootstrapLinkRenderer
    private    
      def link(text, target, attributes = {})
        if target.is_a? Fixnum
          attributes[:rel] = rel_value(target)
          attributes["data-page"] = target
          target = url(target)
        end
        attributes[:href] = target
        tag(:a, text, attributes)
      end
  end

	def async_div_for(url, params: {}, spin: true, refresh: true)
		content_tag(
      :div, nil,
      data: {url: url, params: params, refresh: refresh, spin: spin},
      class:"async-div"
    )
	end

  # change the default link renderer for will_paginate
  def will_paginate(collection_or_options = nil, options = {})
    if collection_or_options.is_a? Hash
      options, collection_or_options = collection_or_options, nil
    end
    unless options[:renderer]
      options = options.merge :renderer => CustomLinkRenderer
    end
    super *[collection_or_options, options].compact
  end

  def human_date(date)
    ret = nil
    if date
      if Time.now.to_date == date.to_date
        if (Time.now - date).to_i < 60
          ret = "less than one minute ago"
        else
          ret = date.strftime("%l:%M %P").strip
        end
      elsif Time.now.year == date.year
        ret = date.strftime("%b #{date.day.ordinalize}")
      else
        ret = date.strftime("%Y-%m-%d")
      end
    end
    ret
  end

  def link_to_add_fields(name, f, association, hidden=false)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |fields|
               render("#{association.to_s.singularize}_fields", f: fields)
             end
    link_to(
      name, '#', class: "add_fields #{hidden ? 'hidden' : ''}",
      data: {id: id, fields: fields.gsub("\n", '')}
    )
  end

  def id_or_object_id(object)
    object.new_record? ? object.object_id : object.id
  end

  def paranoia_tag_for(tag_name, single_or_multiple_records, deleted_class = '',
    prefix = nil, options = nil, &block
  )
    options, prefix = prefix, nil if prefix.is_a?(Hash)
  
    Array(single_or_multiple_records).map do |single_record|
      if single_record.deleted_at?
        if options
          options[:class] = "#{options[:class]} #{deleted_class}".strip
        else
          options = { :class => deleted_class }
        end
      end

      content_tag_for_single_record(tag_name, single_record, prefix, options, &block)
    end.join("\n").html_safe
  end

end

