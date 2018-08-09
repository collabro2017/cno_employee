class OutputsController < ApplicationController
  before_action :set_output, only: [:destroy, :update]
  
  def show
  end

  def create
  end

  def destroy
  end

  def update
  end

  private
    def set_output
      @output = Output.find(params[:id])
    end

    def output_params
      params.require(:output).permit(:concrete_field, :position)
    end

end
