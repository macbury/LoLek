class UserObserver < Mongoid::Observer
  observe :user
  
  def after_create(user)
    Resque.enqueue(UserObserverWorker, user.id)
  end

  def after_update(user)
    Resque.enqueue(UserObserverWorker, user.id)
  end
end
