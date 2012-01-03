class LinksController < ApplicationController

  def index
    @tab = :newest
    @links = Link.is_published.is_hot.is_newest.page(params[:page]).per(10)
  end

  def pending
    @tab = :pending
    @links = Link.is_published.is_pending.is_newest.page(params[:page]).per(10)
    render action: "index"
  end

  def popular
    @tab = :popular
    @links = Link.is_published.is_popular.page(params[:page]).per(10)
    render action: "index"
  end

  def show
    @link = Link.find(params[:id])
    redirect_to @link
  end

  def new
    @link = Link.new
  end

  def create
    @link = Link.import(params)
    @link.user = self.current_user if logged_in?
    if @link.save
      redirect_to root_path, notice: t("notices.created")
    else
      render action: "new" 
    end
  end
end
