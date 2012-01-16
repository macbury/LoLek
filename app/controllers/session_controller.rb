class SessionController < ApplicationController
  
  def bot
    redirect_to login_path(bot: 1)
  end

  def new
    perms = Facebook::PERMS
    if params[:bot]
      perms << "offline_access"
      perms << "manage_pages"
    end
    redirect_to Koala::Facebook::OAuth.new.url_for_oauth_code(:callback => callback_url(bot: params[:bot]), :permissions => perms.join(","))
  end
  
  def create
    access_token = Koala::Facebook::OAuth.new(callback_url(bot: params[:bot])).get_access_token(params[:code]) if params[:code]
    self.current_user = User.login!(access_token)
    self.current_user.bot! if params[:bot]
    redirect_to profile_path(id: self.current_user.id)
  end
  
  def async
    if Rails.env == "development"
      self.current_user = User.first
      redirect_to root_path
    else
      render text: "False"
    end
  end

  def destroy
    session.delete(:user_id)
    
    redirect_to root_path
  end
  
end
