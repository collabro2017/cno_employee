class SortsController < ApplicationController
  before_action :set_sort, only: [:destroy, :update]
  
  def show
  end

  def create
  end

  def destroy
  end

  def update
  end

  private
    def set_sort
      @sort = Sort.find(params[:id])
    end

    def sort_params
      params.require(:sort).permit(:concrete_field, :position, :descending)
    end

end
