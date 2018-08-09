class UsersController < ApplicationController
  before_action :correct_user, only: :show
  before_action :set_user, only: [  :show,
                                    :edit,
                                    :update,
                                    :resend_activation_email
                                  ]

  def index
    tmp_users = User
    tmp_users = tmp_users.by_company(current_user.company_id) unless
                    current_user.sysadmin?

    @users = tmp_users.order(:first_name)
                .paginate(page: params[:page])
  end

  def new
    if current_user.admin? || current_user.sysadmin?
      @user = User.new
    else
      not_found
    end
  end

  def create
    tmp_password = SecureRandom.base64(6)

    additional_params = {
      status: 'pending',
      password: tmp_password,
      password_confirmation: tmp_password,
      activation_token: SecureRandom.urlsafe_base64
    }

    unless current_user.sysadmin?
      additional_params.merge!({company_id: current_user.company.id})
    end
    
    @user = User.new(user_params.merge(additional_params))

    if @user.save
      if send_activation_email 
        flash[:success] = "A new user has been created and an activation " \
          "email has been sent"
      else
        flash[:warning] = "A new user has been created but could not send the" \
          " activation email"
      end
      redirect_to users_path
    else
      render 'new'
    end
  end

  def resend_activation_email
    @user.activation_token = SecureRandom.urlsafe_base64

    if @user.status == 'pending' && @user.save && send_activation_email
      render js
    else
      head :unprocessable_entity
    end
  end

  def show
    @user_counts ||= @user.counts.with_summary.order('"count_id" desc').limit(5)
    @user_orders ||= Order.where(user_id: @user).order('id desc').limit(5)
  end

  def edit
    valid_admin =
      current_user.admin? && (@user.company_id == current_user.company_id)

    unless valid_admin || current_user.sysadmin? || current_user?(@user)
      not_found
    end
  end

  def update
    if @user.update_attributes(user_params.symbolize_keys)
      flash[:success] = "The user information has been updated!"
      redirect_to users_path
    else
      render 'edit'
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(
        :first_name,
        :last_name,
        :userid,
        :email,
        :company_id,
        :password, 
        :password_confirmation,
        :activation_token,
        :admin,
        :status
      )
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user? (@user)
    end

    def send_activation_email
      #changed this for now and removed request.domain 
      #switch this back when we have a real domain and not AWS IP
      sender = "#{ENV['ACTIVATION_EMAIL_FROM']}"
      url = url_for(
              only_path: false,
              controller: 'sessions',
              action: 'activate_account'
            )

      begin
        UserMailer.activation_email(@user, sender, url).deliver
        true
      rescue Net::ProtocolError => e
        $stderr.puts(
          "*** Error trying to send activation email - #{e.class} #{e.message}"
        )
        false
      end
    end

end
