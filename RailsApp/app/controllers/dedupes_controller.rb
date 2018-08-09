class DedupesController < ApplicationController
  before_action :set_dedupe, only: [:destroy, :update]

  def create
  	count = Count.find(dedupe_params[:count_id])
  	concrete_field = ConcreteField.find(dedupe_params[:concrete_field_id])
    position = dedupe_params[:position]
    @dedupe = count.dedupes.build(concrete_field: concrete_field, position: position)

    if @dedupe.save && count.set_dirty(true)
      render js
    else
      head :unprocessable_entity
    end
  end

  def destroy
    if @dedupe.destroy && @dedupe.count.set_dirty(true)
      render js
    else
      head :unprocessable_entity
    end
  end

  def update
    if @dedupe.update_attributes(dedupe_params.symbolize_keys)
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private
    def set_dedupe
      @dedupe = Dedupe.find(params[:id])
    end

    def dedupe_params
      params.require(:dedupe).permit( :concrete_field_id,
                                      :count_id,
                                      :dedupe,
                                      :position,
                                      :tiebreak
                                    )
    end
end
