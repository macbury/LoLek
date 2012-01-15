class UserObserverWorker
  @queue = Delay::Actions

  def self.perform(user_id)
    user = User.find(user_id)
    user.gain!(Achievement::First100Users) if User.count < 100

    day_beginning = Time.now.at_beginning_of_day
    if user.last_login >= day_beginning + 8.hours && user.last_login <= day_beginning + 14.hours && (1..5).include?(Time.now.wday)
      user.gain!(Achievement::SchoolAccess)
    end
  end

end