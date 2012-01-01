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
      redirect_to @link, notice: 'Link was successfully created.'
    else
      render action: "new" 
    end
  end
end
