class CountsController < ApplicationController

  include S3UploadHelper

  before_action :set_count, only: [
                              :show, :edit, :update, :destroy, :rename,
                              :__status_and_result,
                              :__breakdown_result,
                              :__suppression_orders,
                              :add_suppression_order,
                              :remove_suppression_order,
                              :clone, :__clone_status,
                              :ignore_clone, :retry_clone, :new_clone
                            ]

  before_action :set_job_status_params,
                :check_count_lock,
                only: :edit

  before_action :check_count_allowed_for_user, only: [:edit, :show, :clone]

  def index
    if current_user.sysadmin?
      @counts = Count.filtered_sorted(filter_params)
    else
      @counts =
        Count.by_company(current_user.company_id).filtered_sorted(filter_params)
    end

    unless @counts.empty?
      validate_page_number!(@counts, filter_params[:page])
      @counts = @counts.paginate(page: filter_params[:page])
    end
    
    respond_to do |format|
      format.html { render 'index' }
      format.js { render 'index_table' }
    end
  end

  def show
    @order = Order.find_by(count_id: @count )
  end

  def new
    @count = Count.new
    @datasources = current_user.allowed_datasources.order(id: :desc)
  end

  def create
    @count = Count.new(count_params)
    if @count.save
      flash[:success] = "A new count has been created!"
      redirect_to id: @count.id, action: :edit
    else
      render 'new'
    end
  end

  def rename
    #@count.name = count_params[:name]

    if @count.update(count_params)#@count.save
      head :ok
    else
      @errors = @count.errors
      render 'shared/ajax/flash_errors', status: :unprocessable_entity
    end
  end
  
  def __status_and_result
    @job = @count.last_count_job
    js false # to prevent Paloma from beind added to the html segment
    render layout: false
  end

  def server_time
    render text: Time.at(*Resque.redis.redis.time)
  end
  
  def __breakdown_result
    js false # to prevent Paloma from beind added to the html segment
    render layout: false
  end

  def __suppression_orders
    @orders = visible_orders.order("id DESC")
    js false # to prevent Paloma from beind added to the html segment
    render layout: false
  end

  def new_clone
    @datasources = current_user.allowed_datasources.order(id: :desc)
  end

  def clone
    conflicts = @count.check_datasource_compatibility(count_params[:datasource])

    if conflicts.empty?
      @new_count = @count.clone(count_params)

      if @new_count.save
        @new_count.inherit_values
        flash[:success] = "A count has been successfully cloned!"
        redirect_to id: @new_count.id, action: :edit
      else
        flash[:error] = "An error occurred when cloning this count"
        redirect_to id: @count.id, action: :edit
      end
    else
      flash[:error] = "The selected datasource is not compatible"
      redirect_to id: @count.id, action: :new_clone
    end
  end

  def ignore_clone
    job = @count.clone_job
    job.mark_as(:killed)
    redirect_to id: @count.id, action: :edit
  end

  def retry_clone
    @count.inherit_values
    redirect_to id: @count.id, action: :edit
  end

  def __clone_status
    @job = @count.clone_job
    js false # to prevent Paloma from beind added to the html segment
    render layout: false
  end

  def add_suppression_order
    order_id = count_params[:order_id]
    attempt_to_change_and_save do
      @count.add_suppression_order(order_id)
    end
  end

  def remove_suppression_order
    order_id = count_params[:order_id]

    attempt_to_change_and_save do
      !@count.remove_suppression_order(order_id).nil?
    end
  end

  private
    def set_count
      @count = Count.find(params[:id])
      js params: {id: @count.id}
    end

    def set_job_status_params
      count_job = @count.last_count_job
      clone_job = @count.clone_job
      job_status = {}

      job_status['count_job'] = job_status_hash(count_job) if count_job.present?
      job_status['clone_job'] = job_status_hash(clone_job) if clone_job.present?

      js params: job_status
    end

    def job_status_hash(job)
      {
        is_active: job.active?,
        status:    job.status,
        job_id:    job.id
      }
    end

    def count_params
      count_params = params.require(:count).permit(
                                              :name,
                                              :datasource,
                                              :user,
                                              :select,
                                              :enter_values_text,
                                              :breakdown,
                                              :order_id
                                            )
      
      if(count_params[:user])
        count_params[:user] = User.find(count_params[:user])
      end
      
      if(count_params[:datasource])
        count_params[:datasource] = Datasource.find(count_params[:datasource])
      end     
      
      count_params
    end

    def filter_params
      return @filter_params if defined?(@filter_params)

      @filter_params = params.permit(*allowed_filter_params)

      allowed_sorting_values.each do |sort_option, valid_values|
        unless valid_values.include?(@filter_params[sort_option])
          @filter_params[sort_option] = valid_values.first
        end
      end
      
      @filter_params[:page] ||= '1' # Has to be a string for #replace to work
                                    # https://www.ruby-forum.com/topic/151806

      @filter_params
    end

    def allowed_filter_params
      [
        :sort_column,
        :sort_direction,
        :name,
        :datasource_name,
        :user_name,
        :page
      ]
    end

    def allowed_sorting_values
      {
        sort_column: [
          'count_id',
          'name',
          'datasource_name',
          'user_name',
          'most_recent_job_updated_at'
        ],
        sort_direction: ['desc', 'asc']
      }
    end

    def validate_page_number!(records, page_value)
      last_valid_page = ((records.count - 1) / records.model.per_page) + 1
      page_value.replace([page_value.to_i, last_valid_page].min.to_s)
    end

    def check_count_lock
      redirect_to @count if @count.locked?
    end

    def check_count_allowed_for_user
      unless @count.allowed_for_user?(current_user.id)
        flash[:error] = "Access to count datasource is restricted"
        redirect_to(counts_url)
      end
    end

    def attempt_to_change_and_save(&block)
      if block_given? && yield && @count.save! && @count.set_dirty(true)
        render 'change_suppression_order'
      else
        head :unprocessable_entity
      end
    end
end
