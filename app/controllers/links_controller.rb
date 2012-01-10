class LinksController < ApplicationController

  def feed
    @links = Image.is_published.is_hot.is_newest.limit(10)
    
    respond_to do |format|
      format.rss
    end
  end

  def like
    @link = Link.is_published.find(params[:id])
    authorize! :like, @link

    @link.check_status!
    liked = false
    liked = self.current_user.like!(@link) if logged_in?

    render json: { liked: liked, logged_in: logged_in?, id: @link.id }.to_json
  end

  def index
    @tab = :newest
    @links = Link.is_published.is_hot.is_newest.page(params[:page]).per(10)
    authorize! :index, Link
  end

  def pending
    @tab = :pending
<<<<<<< HEAD
    page = params[:page]
    page ||=1
    page = page.to_i

    @links = Link.is_published.is_pending.is_newest.includes(:user).page(page).per(10)
    if page == 1
      @random = @links.random(10).limit(10)
    end
    cookies[:readed] = Link.is_published.is_pending.count
=======
    @links = Link.is_published.is_pending.is_newest.includes(:user).page(params[:page]).per(10)
    cookies[:readed] = @links.count
    self.current_user.update_attributes(readed: @links.count) if logged_in? 
>>>>>>> fdf4b9c8df5ab1a2138e1c01179556d2c1508870
    authorize! :index, Link
  end

  def popular
    @tab = :popular
    @links = Link.is_published.is_popular.page(params[:page]).per(10)
    authorize! :index, Link
    render action: "index"
  end

  def show
    @link = Link.is_published.find(params[:id])
    @links = Link.is_published.is_pending.includes(:user).random(10)
    authorize! :read, @link
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

  def accept
    @link = Link.find(params[:id])
    authorize! :accept, @link
    @link.accept!

    redirect_to params[:return_to] || root_path
  end

  def destroy
    @link = Link.find(params[:id])
    authorize! :destroy, @link

    @link.ban!
    @link.save
    
    redirect_to params[:return_to] || root_path
  end
end
