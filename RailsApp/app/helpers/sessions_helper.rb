module SessionsHelper
  def sign_in(user)
    cookies.permanent[:remember_token] = user.remember_token
    self.current_user = user
    update_activity_time
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    tmp_user = nil
    if cookies[:remember_token] 
      tmp_user = User.find_by(remember_token: cookies[:remember_token])
    end
    
    @current_user ||= tmp_user
  end

  def current_user?(user)
    user == current_user
  end

  def signed_in?
    !current_user.nil? && current_user.status == 'active'
  end

  def sign_out
    self.current_user = nil
    cookies.delete(:remember_token)
  end

  def redirect_back_or(default)
    redirect_to(session[:attempted_location] || default)
    session.delete(:attempted_location)
  end

  def store_attempted_location(location=request.url)
    session[:attempted_location] = location
  end

  def validate_session
    if signed_in?
      get_session_time_left
      unless @session_time_left > 0
        sign_out
        deny_access 'Your session has timed out. Please sign in again.'
      end
    else
      deny_access 'You have been signed out. Please sign in again.'
    end
  end

  def update_activity_time
    expiration = CNO::RailsApp.config.custom.expiration
    session[:expires_at] = expiration.session_minutes.minutes.from_now
  end

  def get_session_time_left
    expire_time = session[:expires_at] || Time.now
    @session_time_left = (expire_time - Time.now).to_i
  end

  def deny_access(message = nil)
    flash[:error] ||= message
    respond_to do |format|
      format.html {
        store_attempted_location
        redirect_to signin_url
      }
      format.js {
        store_attempted_location request.referer
        render 'sessions/redirect_to_signin_url', layout: false
      }
    end
  end

  def user_with_privileges
    unless current_user && current_user.sysadmin?
      not_found
    end
  end

  def checkbox_data
    {
      toggle: 'tooltip',
      title: "Please read our Terms and Conditions",
      delay: 250,
      animation: true,
      placement: 'bottom'
    }
  end
end
