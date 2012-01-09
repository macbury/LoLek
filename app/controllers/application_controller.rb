class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :analyze_cookies

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, notice: I18n.t("flash.notice.access_denied")
  end

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
  
  def analyze_cookies
    return unless logged_in?
    if cookie[:boss_key]
      cookie.delete(:boss_key)
      self.current_user.gain!(Achievement::BossKey)
    end
  end
end
