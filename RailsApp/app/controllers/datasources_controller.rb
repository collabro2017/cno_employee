class DatasourcesController < ApplicationController
  before_filter :user_with_privileges
  before_action :set_datasource, 
                only: [:show, :edit, :update, :destroy, :edit_access_level]

  def index
    @datasources = Datasource.with_deleted.order(created_at: :desc)
      .paginate(page: params[:page])
  end

  def new
    @datasource = Datasource.new
  end

  def create
    @datasource = Datasource.new(datasource_params)

    respond_to do |format|
      if @datasource.save
        format.html { redirect_to @datasource }
        format.json { render action: 'show', status: :created, location: @datasource }
      else
        format.html { render action: 'new' }
        format.json { render json: @datasource.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @datasource.update(datasource_params)
        format.html { redirect_to @datasource }
        format.json { head :no_content }
        format.js
      else
        @errors = @datasource.errors
        format.html { render action: 'edit' }
        format.json { render json: @errors, status: :unprocessable_entity }
        format.js { render 'shared/ajax/flash_errors', status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @datasource.destroy
    respond_to do |format|
      format.html { redirect_to datasources_url }
      format.json { head :no_content }
      format.js { render js }
    end
  end

  def edit_access_level
    render js
  end

  private
    def set_datasource
      @datasource = Datasource.with_deleted.find(params[:id])
    end

    def datasource_params
      params.require(:datasource).permit(:name, :deleted_at, :access_level)
    end
end
