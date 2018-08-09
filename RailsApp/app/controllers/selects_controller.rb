class SelectsController < ApplicationController
  
  before_action :set_select, only: [
    :destroy,
    :update,
    :update_position,
    :add_value,
    :remove_value,
    :add_multiple_lookup_values,
    :remove_multiple_lookup_values,
    :add_multiple_enter_values,
    :get_saved_enter_values,
    :set_range,
    :reset_range,
    :set_date,
    :reset_date,
    :set_blanks,
    :reset_blanks,
    :set_exclude,
    :reset_exclude,
    :add_user_file,
    :remove_user_file,
    :add_link,
    :remove_link
  ]

  def show
  end

  def create
    count = Count.find(select_params[:count_id])
    concrete_field = ConcreteField.find(select_params[:concrete_field_id])
    position = select_params[:position]

    @select = count.selects.build(
                concrete_field: concrete_field,
                position: position
              )

    if @select.save
      # TO-DO: This logic belongs to the model
      if @select.ui_data_type == 'binary'
        @select.add_value(value: @select.binary_on_value, input_method: :binary)
        count.set_dirty(true) if @select.save
      end

      render js
    else
      head :unprocessable_entity 
    end
  end

  def destroy
    if @select.destroy && @select.count.set_dirty(true)
      render js
    else
      head :unprocessable_entity
    end
  end

  def update_position
    @select.position = select_params[:position].to_i
    if @select.save
      render js
    else
      head :unprocessable_entity
    end
  end

  def update
    if @select.update_attributes(select_params.symbolize_keys)
      head :ok
    else
      head :unprocessable_entity
    end
  end

  def add_value
    if @select.add_value(select_params.symbolize_keys) && @select.save
      render "refresh"
    else
      head :unprocessable_entity
    end
  end

  def remove_value
    if @select.remove_value(select_params.symbolize_keys) && @select.save
      render "refresh"
    else
      head :unprocessable_entity
    end
  end

  def add_multiple_lookup_values
    bulk_lookup_values_action('add')
  end
  
  def remove_multiple_lookup_values
    bulk_lookup_values_action('remove')
  end

  def add_multiple_enter_values
    if @select.add_multiple_enter_values(select_params[:value]) && @select.save
      @values = @select.saved_values.enter_value.values_array.join(',')
      render js
    else
      head :unprocessable_entity
    end
  end

  def get_saved_enter_values
    @values = @select.saved_values.enter_value.values_array.join(',')
    
    if @values
      render js, layout: nil
    else
      head :unprocessable_entity
    end
  end

  def set_range
    @select.update(select_params.symbolize_keys)
    if @select.save
      render js
    else
      head :unprocessable_entity
    end
  end

  def reset_range
    @select.reset_range
    if @select.save
      render js
    else
      head :unprocessable_entity
    end
  end

  def set_date
    @select.update(select_params.symbolize_keys)
    if @select.save
      render js
    else
      head :unprocessable_entity
    end
  end

  def reset_date
    @select.reset_range
    if @select.save
      render "reset_date"
    else
      head :unprocessable_entity
    end
  end

  def set_blanks
    @select.update(select_params.symbolize_keys)
    if @select.save
      render "refresh"
    else
      head :unprocessable_entity
    end
  end

  def reset_blanks
    @select.reset_blanks
    if @select.save
      render "refresh"
    else
      head :unprocessable_entity
    end
  end

  def set_exclude
    @select.update(select_params.symbolize_keys)
    if @select.save && @select.count.set_dirty(true)
      render "toggle_exclude"
    else
      head :unprocessable_entity
    end
  end

  def reset_exclude
    @select.reset_exclude
    if @select.save && @select.count.set_dirty(true)
      render "toggle_exclude"
    else
      head :unprocessable_entity
    end
  end

  def add_user_file
    if @select.add_user_file(select_params[:user_file_id]) && @select.save
      render "refresh"
    else
      head :unprocessable_entity
    end
  end

  def remove_user_file
    if @select.remove_user_file(select_params[:user_file_id]) && @select.save
      render "refresh"
    else
      head :unprocessable_entity
    end
  end

  def add_link
    if @select.link_to_next && @select.count.set_dirty(true)
      @enum = @select.enum_at_first_of_group
      render js
    else
      head :unprocessable_entity
    end
  end

  def remove_link
    if @select.unlink_from_group && @select.count.set_dirty(true)
      render js
    else
      head :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_select
      @select = Select.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def select_params
      @select_params ||=
        params.require(:select).permit(
                                      :concrete_field_id, 
                                      :count_id,
                                      :value,
                                      :input_method,
                                      :lookup_type,
                                      :page,
                                      :first_filter,
                                      :fuzzy_filter,
                                      :position,
                                      :from,
                                      :to, 
                                      :blanks,
                                      :exclude,
                                      :user_file_id,
                                      lookup_params: [:centroid]
                                      )
      @select_params[:value] = nil if @select_params[:value] == ''
      @select_params
    end
    
    def bulk_lookup_values_action(action)
      lookup_type = select_params[:lookup_type]
      lookup_class = ConcreteFieldInputMethod.lookup_class(
                                        lookup_type,
                                        concrete_field: @select.concrete_field
                                        )

      column_name = lookup_class.value_column

      first = select_params[:first_filter]
      fuzzy = select_params[:fuzzy_filter]
      page = select_params[:page]

      lookup_params = {}
      lookup_params['centroid'] = first if lookup_type == 'zip5_distance'
      
      @lookups = lookup_class.filter(first, fuzzy)
      @lookups = @lookups.paginate(page: page) if page.present?

      method = "#{action}_multiple_lookup_values"
      if @select.send(method,
                      @lookups,
                      column_name,
                      lookup_type,
                      lookup_params.to_json
                      )
        render "refresh" if @select.save
      else
        head :unprocessable_entity
      end
    end

end
