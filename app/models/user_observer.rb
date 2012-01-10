class UserObserver < Mongoid::Observer
  observe :user
  
  def after_create(user)
    Delayed::Job.enqueue UserObserverWorker.new(user), priority: Delay::Observer
  end

  def after_update(user)
    Delayed::Job.enqueue UserObserverWorker.new(user), priority: Delay::Observer
  end
end
