class LikeObserver < Mongoid::Observer
  observe :like

  def after_create(like)
    Delayed::Job.enqueue LikeObserverWorker.new(like), priority: Delay::Observer
  end
end
