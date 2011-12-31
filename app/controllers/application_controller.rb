class ApplicationController < ActionController::Base
  protect_from_forgery
  
  protected
  
  helper_method :logged_in?, :current_user
  
  def current_user=(user)
    Rails.logger.debug "Setting session user for #{user.id}"
    session[:user_id] = user.id if user
    user
  end
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
    @current_user
  end

  
  def logged_in?
    self.current_user.present?
  end
  
  def login_required!
    redirect_to root_path unless logged_in?
  end
  
  def authenticate_admin_user!
    login_required!
  end
  
end
