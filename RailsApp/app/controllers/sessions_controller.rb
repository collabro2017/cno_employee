class SessionsController < ApplicationController

  TC_PATH = "#{File.dirname(__FILE__)}/../assets/text/terms-conditions.txt"
  before_action :set_terms, only: [:new, :create]
  before_action :valid_activation_token, only: [:activate_account, :new_password]

  skip_before_action :verify_authenticity_token, except: [:destroy]
  skip_before_action  :validate_session,
                      only: [
                              :new,
                              :create,
                              :new_password,
                              :reset_password,
                              :set_password,
                              :confirm_email,
                              :activate_account,
                              :confirm_account
                            ]

  skip_before_action :update_activity_time, except: [:create]

  def create
    user = User.find_by(userid: user_email_param)

    if user && user.authenticate(params[:session][:password])
      if cookies[:mfa].present?
        case user.status.to_s
        when 'active'
          flash[:success] = "Welcome back #{user.name}!"
          sign_in user
          redirect_back_or user
        when 'pending'
          render :layout => 'landing', action: 'confirm'
        when 'blocked'
          flash.now[:error] = "Oops! Your account is blocked. Contact the " \
            "company admin."
          render :layout => 'landing', action: 'new'
        end
      else
        user.generate_auth_tokens!
        UserMailer.send_auth_token(user).deliver
        redirect_to "/two_factor_auth?auth_token=#{user.auth_token}"
      end


    else
      flash.now[:error] = "Oops! Invalid credentials"
      render :layout => 'landing', action: 'new'
    end
  end

  def new
    if signed_in?
      redirect_to current_user
    else
      render :layout => 'landing'
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end

  def new_password
    render :layout => 'landing', action: 'new_password'
  end

  def reset_password
    render :layout => 'landing', action: 'reset_password'
  end

  def confirm_email
    user = User.where(email: user_email_param).first
    
    if user.present? && user.status == 'active'
      user.reset_activation_token
      user.save
      send_email(user)
      render :layout => 'landing', action: 'email_sent_confirmation'
    else
      flash.now[:error] = "Oops! No user registered with that email."
      render :layout => 'landing', action: 'reset_password'
    end
  end

  def set_password
    token = user_params[:activation_token]
    @user = User.where(activation_token: token).first

    if @user.update_attributes(user_params.symbolize_keys)
      sign_in @user
      flash[:success] = "Welcome #{@user.name}!"
      redirect_to @user
    else
      render :layout => 'landing', action: 'new_password'
    end
  end

  def activate_account
    render :layout => 'landing', action: 'activate_account'
  end

  def confirm_account
    #TO-DO Verifications: activation_expires_at and status = pending
    token = user_params[:activation_token]
    @user = User.where(activation_token: token).first

    altered_params = {status: 'active'}
    if user_params['password'].blank?
      # Set a non-blank value so that length validation applies
      altered_params.merge!(password: 'x', password_confirmation: 'x')
    end

    if @user.update_attributes(user_params.merge(altered_params))
      sign_in @user
      flash[:success] = "Welcome #{@user.name}!"
      redirect_to @user
    else
      render :layout => 'landing', action: 'activate_account'
    end
  end

  def check_time_left
    get_session_time_left
    if @session_time_left > 0
      render js, :layout=>false
    else
      sign_out
      deny_access 'Your session has timed out. Please log back in.'
    end
  end

  private

    def user_email_param
      params[:session][:email].downcase
    end

    def user_params
      params.require(:user).permit(
        :email,
        :password, 
        :password_confirmation,
        :activation_token
      )
    end

    def valid_activation_token
      token = params[:activation_token]
      message = 'Your activation token is missing or invalid'
      @user = User.where(activation_token: token).first

      deny_access(message) unless !token.empty? || @user.present?
    end

    def set_terms
      @terms = File.open(TC_PATH).read
    end

    def send_email(user)
      sender = "#{ENV['ACTIVATION_EMAIL_FROM']}@#{request.domain}"
      url = url_for(
        only_path:  false,
        controller: 'sessions',
        action:     'new_password'
      )

      UserMailer.password_reset_email(user, sender, url).deliver
    end
end
