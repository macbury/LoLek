class ProfilesController < ApplicationController
  before_filter :setup_tab

  def index
    @users = User.limit(70).desc(:rank)
  end

  def show
    @user = User.find(params[:id])
  end

  protected
    def setup_tab
      @tab = :profiles
    end
end
