class LinkObserver < Mongoid::Observer
  observe :link

  def after_create(link)
    return if link.user.nil?
    
    Resque.enqueue(LinkObserverWorker, link.id)
  end
end
