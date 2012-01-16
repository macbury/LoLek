class ProfilesController < ApplicationController
  before_filter :setup_tab

  def index
    @users = User.limit(50).asc(:position)
  end

  def show
    @user = User.find(params[:id])
    @friends = User.all_in( fb_id: @user.friends_fb_ids ).asc(:position)
  end

  protected
    def setup_tab
      @tab = :profiles
    end
end
