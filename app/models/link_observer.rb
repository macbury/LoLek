class LinkObserver < Mongoid::Observer
  observe :link

  def after_create(link)
    Delayed::Job.enqueue LinkObserverWorker.new(link), priority: Delay::Observer
  end
end
