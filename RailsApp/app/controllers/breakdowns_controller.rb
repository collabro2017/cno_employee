class BreakdownsController < ApplicationController
  before_action :set_breakdown, only: [:destroy, :update]

  def create
  	count = Count.find(breakdown_params[:count_id])
  	concrete_field = ConcreteField.find(breakdown_params[:concrete_field_id])
    position = breakdown_params[:position]
    @breakdown = count.breakdowns.build(concrete_field: concrete_field, position: position)

    if @breakdown.save
      render js
    else
      head :unprocessable_entity
    end
  end

  def destroy
    if @breakdown.destroy
      render js
    else
      head :unprocessable_entity
    end
  end

  def update
    if @breakdown.update_attributes(breakdown_params.symbolize_keys)
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private
    def set_breakdown
      @breakdown = Breakdown.find(params[:id])
    end

    def breakdown_params
      params.require(:breakdown).permit(  :concrete_field_id,
                                          :count_id,
                                          :breakdown,
                                          :position
                                        )
    end
end
