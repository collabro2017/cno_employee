class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include SessionsHelper
  include PermissionsHelper

  before_action :validate_session
  before_action :update_activity_time

  rescue_from ActionController::InvalidAuthenticityToken,
    :with => :validate_session

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

end
