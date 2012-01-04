class LinksController < ApplicationController

  def index
    @tab = :newest
    @links = Link.is_published.is_hot.is_newest.page(params[:page]).per(10)
    authorize! :index, Link
  end

  def pending
    @tab = :pending
    @links = Link.is_published.is_pending.is_newest.page(params[:page]).per(10)
    authorize! :index, Link
    render action: "index"
  end

  def popular
    @tab = :popular
    @links = Link.is_published.is_popular.page(params[:page]).per(10)
    authorize! :index, Link
    render action: "index"
  end

  def show
    @link = Link.is_published.find(params[:id])
    authorize! :index, Link
    redirect_to @link
  end

  def new
    @link = Link.new
    authorize! :new, Link
  end

  def create
    @link = Link.import(params)
    @link.user = self.current_user if logged_in?
    authorize! :create, Link
    if @link.save
      redirect_to root_path, notice: t("notices.created")
    else
      render action: "new" 
    end
  end

  def stats
    authorize! :read, :stats
  end

  def destroy
    @link = Link.find(params[:id])
    @link.banned = true
    @link.save
    authorize! :destroy, @link
    
    redirect_to params[:return_to] || root_path
  end
end
