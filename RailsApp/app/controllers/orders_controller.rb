class OrdersController < ApplicationController
  before_action :set_order, only: [
                                    :show, :edit, :update, :destroy,
                                    :__order_result, :place
                                  ]
  before_action :check_count_allowed_for_user, only: [:edit, :show]
  before_action :set_job_status_params, only: [:show]

  def index
    @orders = visible_orders.order("id DESC").paginate(page: params[:page])
  end

  def create
    @order = Order.new(order_params)

    respond_to do |format|
      if @order.save
        flash[:success] = "A new order has been created!"
        format.js { }
      else
        format.js do
          @errors =  @order.errors
          render 'shared/ajax/flash_errors', status: :unprocessable_entity
        end
      end
    end
  end

  def place
    enqueue_order_job
    redirect_to @order
  end

  def update
    respond_to do |format|
      if @order.update(order_params)
        format.js { }
      else
        format.js do
          render status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url }
      format.json { head :no_content }
    end
  end

  def __order_result
    @job = @order.jobs.last
    js false # to prevent Paloma from beind added to the html segment
    render layout: false  
  end

  private
    def set_order
      @order = Order.find(params[:id])
    end

    # TO-DO: this probably fits better in the Order model
    def enqueue_order_job
      type = Job.type_from_sym('order')
      @job = Job.new(count: @order.count, order: @order, type: type, user: current_user)
      @job.enqueue
    end

    def set_job_status_params
      order_job = @order.jobs.last

      if order_job.present?
        js params:
          {
            order_job:
              {
                is_active: order_job.active?,
                status:  order_job.status,
                job_id:  order_job.id
              }
          }
      end
    end

    def order_params
      #TO-DO: Research about pro's and con's of using 'fetch' vs using 'permit'
      ret = params.fetch(:order, params).permit(
                                           :count,
                                           :user,
                                           :cap_type,
                                           :total_cap,
                                           :po_number,
                                           outputs_attributes: [
                                             :id,
                                             :concrete_field_id,
                                             :position,
                                             :_destroy
                                           ],
                                           sorts_attributes: [
                                             :id,
                                             :concrete_field_id,
                                             :position,
                                             :descending,
                                             :_destroy
                                           ]
                                         )
      
      if(ret[:count])
        ret[:count] = Count.find(ret[:count])
      end      
      
      if(ret[:user])
        ret[:user] = User.find(ret[:user])
      end      

      ret
    end

    def check_count_allowed_for_user
      redirect_to(orders_url) unless @order.allowed_for_user?(current_user.id)
    end

end

