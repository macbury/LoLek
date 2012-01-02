class LinksController < ApplicationController

  def index
    @tab = :newest
    @links = Link.is_published.is_hot.is_newest.page(params[:page]).per(10)
  end

  def pending
    @tab = :pending
    @page = params[:page] - 2
    @page ||= 0
    
    if @page < 0
      @page = 0
    elsif @page < 2
       Link.is_published.is_pending.random(10).limit(10)
    else
      @links = Link.is_published.is_pending.is_newest.page(@page).per(10)
    end
    
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

    if @link.save
      redirect_to root_path, notice: t("notices.created")
    else
      render action: "new" 
    end
  end
end
