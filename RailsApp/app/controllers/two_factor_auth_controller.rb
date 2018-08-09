class TwoFactorAuthController < ApplicationController
  skip_before_action  :validate_session
  
  layout 'landing'

  def index
    @auth_token = params[:auth_token]
    @users = User.where(auth_token: @auth_token)
        
    @masked_email = @users.first.masked_email
    unless @users.any?
      redirect_to "/signin", notice: "Invalid authentication token."
    end
  end

  def create
    user = User.where(auth_token: params[:auth_token], auth_code: params[:auth_code])
    if user.any?
      user = user.first
      
      # Reset auth values
      user.update_attributes(auth_code: nil, auth_token: nil)
      
      # Login user
      sign_in user

      # Set cookies
      if params[:remember_me].present?
        cookies[:mfa] = {
         :value => Time.now.to_i.to_s,
         :expires => ENV["COOKIE_EXPIRY"].to_i.days.from_now
       }
      end

      # Redirect to dashboard
      redirect_to "/users/" + user.id.to_s
    else
      redirect_to "/two_factor_auth?auth_code=#{params[:auth_token]}", notice: "Invalid authentication code."
    end
  end

  def resend_code
    auth_token = params[:auth_token]
    user = User.where(auth_token: params[:auth_token]).first
    
    # Regenerate auth tokens
    user.generate_auth_tokens!

    UserMailer.resend_auth_token(user).deliver

    redirect_to "/two_factor_auth?auth_token=#{user.auth_token}"
  end
end