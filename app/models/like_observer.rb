class LikeObserver < Mongoid::Observer
  observe :like

  def after_create(like)
    Resque.enqueue(LikeObserverWorker, like.id)
  end
end
