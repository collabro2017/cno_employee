class ConcreteFieldsController < ApplicationController
  before_action :set_concrete_field, only: [:show, :edit, :update, :destroy]

  def index
    order = concrete_field_params[:order]
    count = concrete_field_params[:count]

    if order.present?
      @order = Order.find(order)
      @count = @order.count
    else
      @count = Count.find(count)
    end    

    @field_categories = @count.datasource.field_categories
    @display_type = concrete_field_params[:display_type]

    js false # to prevent Paloma from beind added to the html segment
    render layout: false
  end

  def new
    @concrete_field = ConcreteField.new
  end

  def create
    @concrete_field = ConcreteField.new(concrete_field_params)

    respond_to do |format|
      if @concrete_field.save
        format.html { redirect_to @concrete_field, notice: 'Concrete field was successfully created.' }
        format.json { render action: 'show', status: :created, location: @concrete_field }
      else
        format.html { render action: 'new' }
        format.json { render json: @concrete_field.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @concrete_field.update(concrete_field_params)
        format.html { redirect_to @concrete_field, notice: 'Concrete field was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @concrete_field.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @concrete_field.destroy
    respond_to do |format|
      format.html { redirect_to concrete_fields_url }
      format.json { head :no_content }
    end
  end

  private
    def set_concrete_field
      @concrete_field = ConcreteField.find(params[:id])
    end

    def concrete_field_params
      params.require(:concrete_field).permit( :datasource_id,
                                              :field_id,
                                              :position,
                                              :caption,
                                              :filterable,
                                              :count,
                                              :order,
                                              :display_type
                                            )
    end
end
