class UserObserver < Mongoid::Observer
  observe :user
  
  def after_create(user)
    user.gain!(Achievement::First100Users) if User.count < 100
  end

end
