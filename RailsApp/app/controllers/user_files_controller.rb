class UserFilesController < ApplicationController

  include S3UploadHelper

  before_action :set_user_file, only: [
    :edit, :update, :destroy, :mark_as_uploaded
  ]

  before_filter :set_select
  before_filter :set_count

  def index
    
  end

  def __user_files
    @user_files = paginate(visible_user_files.with_deleted)
    js false # to prevent Paloma from beind added to the html segment
    render layout: false
  end

  def __select_user_files
    @user_files = paginate(visible_user_files.uploaded)
    js false # to prevent Paloma from beind added to the html segment
    render layout: false
  end

  def __suppression_user_files
    @user_files = paginate(visible_user_files.uploaded)
    js false # to prevent Paloma from beind added to the html segment
    render layout: false
  end

  def create
    @user_file = UserFile.new(user_file_params)
    @user_file.user = current_user

    respond_to do |format|
      if @user_file.save
        format.json { render action: 'show', status: :created, location: @user_file }
      else
        format.json { render json: @user_file.errors, status: :unprocessable_entity }
      end
    end
  end

  def mark_as_uploaded
    if @user_file.mark_as_uploaded && @user_file.save
      head :ok
    else
      head :unprocessable_entity
    end
  end

  def destroy
    @user_file.really_destroy!
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def soft_destroy
    @user_file = UserFile.find_by(id: params[:id])
    key = "#{@user_file.user.email}/uploads/#{@user_file.name}"
    respond_to do |format|
      if can_soft_destroy? && remove_s3_key(key) && @user_file.destroy
        flash.now[:success] = 'File was successfuly removed!'
        format.js { }
      else
        flash.now[:error] = 'Could not remove the file'
        @user_file.errors.add(:base, 'Could not remove the file')
        @errors = @user_file.errors
        format.js { render 'shared/ajax/flash_errors', status: :unprocessable_entity }
      end
    end
  end

  private
    def set_user_file
      @user_file = UserFile.find(params[:id])
    end

    def can_soft_destroy?
      @user_file.present? && !@user_file.used?
    end

    def user_file_params
      params.require(:user_file).permit(
        :name
      )
    end

    def set_select
      @select = Select.find(params[:select_id]) if params[:select_id]
    end

    def set_count
      @count = Count.find(params[:count_id]) if params[:count_id]
    end


    def paginate(relation)
      relation
        .order(id: :desc)
        .page(params[:page])
        .per_page((params[:per_page] || WillPaginate.per_page).to_i)
    end

end
