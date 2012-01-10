class LinkObserver < Mongoid::Observer
  observe :link

  def after_create(link)
    return if link.user.nil?
    Delayed::Job.enqueue LinkObserverWorker.new(link), priority: Delay::Observer
  end
end
