class LookupsController < ApplicationController

  def filtered_values
    @select = Select.find(lookup_params[:select_id])
    
    lookup_class = ConcreteFieldInputMethod.lookup_class(
                     lookup_params[:lookup_type],
                     concrete_field: @select.concrete_field
                   )

  	column_name = lookup_class.value_column

    first = lookup_params[:first_filter]
    fuzzy = lookup_params[:fuzzy_filter]
    
    scope = lookup_class.filter(first, fuzzy).default_order.non_blanks

    page = params[:page].present? ? params[:page] : 1
    @lookups = scope.paginate(page: page)

    @saved = @select.saved_lookup_values(@lookups, column_name).values_array

    if @lookups
      js false
      render layout: false
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def lookup_params
      params.require(:lookup).permit(:first_filter,
                                     :fuzzy_filter,
                                     :page,
                                     :select_id,
                                     :lookup_type)
    end
end
