class JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update, :destroy]

  # GET /jobs
  # GET /jobs.json
  def index
    tmp_jobs = Job
    tmp_jobs = tmp_jobs.by_company(current_user.company_id) unless
                    current_user.sysadmin?

    @jobs = tmp_jobs.order("id DESC")
                .paginate(page: params[:page])
  end

  # GET /jobs/1
  # GET /jobs/1.json
  def show
  end

  # GET /jobs/new
  def new
    @job = Job.new
  end

  # GET /jobs/1/edit
  def edit
  end

  # GET /jobs/1/status
  def check_status
    @status = Job.status(params[:id])
    @is_active = JobStatus.find(@status).active?
  end

  # POST /jobs
  # POST /jobs.json
  def create
    count, order = nil, nil

    if params[:count_id]
      count = Count.find(params[:count_id])
    elsif params[:order_id]
      order = Order.find(params[:order_id])
      count = order.count
    end

    type = Job.type_from_sym(params[:type])

    @job = Job.new(count: count, order: order, type: type, user: current_user)
    @job.enqueue

    respond_to do |format|
      if @job.save && count.set_dirty(false)
        format.html { redirect_to order }
        format.js { render "create" }
        format.json { render action: 'show', status: :created, location: @job }
      else
        format.html { render action: 'new' }
        format.js { head :precondition_failed }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /jobs/1
  # PATCH/PUT /jobs/1.json
  def update
    respond_to do |format|
      if @job.update(job_params)
        format.html { redirect_to @job }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.json
  def destroy
    @job.destroy
    respond_to do |format|
      format.html { redirect_to jobs_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_job
      @job = Job.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def job_params
      params.require(:job).permit(:type, :count_id, :count__result, :sql)
    end
end
