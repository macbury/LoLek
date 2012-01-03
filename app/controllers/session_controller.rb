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
    redirect_to Koala::Facebook::OAuth.new.url_for_oauth_code(:callback => CGI.escape(callback_url(bot: 1)), :permissions => perms.join(","))
  end
  
  def create
    access_token = Koala::Facebook::OAuth.new(callback_url).get_access_token(params[:code]) if params[:code]
    self.current_user = User.login!(access_token)
    self.current_user.bot!
    redirect_to root_path
  end
  
  def destroy
    session.delete(:user_id)
    
    redirect_to root_path
  end
  
end
