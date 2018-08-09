class CountsUserFilesController < ApplicationController
  before_action :set_counts_user_file, only: [
    :update,
    :destroy
  ]

  def create
    @user_file = 
      UserFile.uploaded.find_by(id: counts_user_file_params[:user_file_id])
    @count = Count.find(counts_user_file_params[:count_id])

    @counts_user_file = CountsUserFile.create(
      count: @count,
      user_file: @user_file,
      concrete_field_id: counts_user_file_params[:concrete_field_id]
    ) unless @user_file.nil?

    if @counts_user_file.save && @count.save! && @count.set_dirty(true)
      render 'change_suppression_user_file'
    else
      head :unprocessable_entity
    end
  end

  def destroy
    if @counts_user_file.destroy && @counts_user_file.count.set_dirty(true)
      render 'change_suppression_user_file'
    else
      head :unprocessable_entity
    end
  end

  def update
    if @counts_user_file.update(counts_user_file_params) &&
       @counts_user_file.count.set_dirty(true)
      render 'change_suppression_user_file'
    else
      head :unprocessable_entity
    end
  end

  private
    def set_counts_user_file
      @counts_user_file = CountsUserFile.find(params[:id])
      js :params => {:id => @counts_user_file.id}
    end

    def counts_user_file_params
      params.require(:counts_user_file).permit(
                                          :concrete_field_id,
                                          :user_file_id,
                                          :count_id
                                        )
    end
end

