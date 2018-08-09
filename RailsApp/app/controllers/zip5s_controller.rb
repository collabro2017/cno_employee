class Zip5sController < ApplicationController

  def index
    @zip5s = SupportDatabase::Zip5.all
  end

  def search
    scope = SupportDatabase::Zip5.where(state: zip_params[:state]).search(zip_params[:city])
    page = 1
    if params[:page].present?
      page =  params[:page]
    end
    @zip5s = scope.paginate(page: page)

    @select = Select.find(zip_params[:select_id])
    @saved = @select.saved_lookup_values(@zip5s, :zip5).values_array

    if @zip5s
      render js
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def zip_params
      params.require(:zip5).permit(:state, :city, :page, :select_id)
    end
end
