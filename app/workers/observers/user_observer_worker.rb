class UserObserverWorker < Struct.new(:user)

  def perform
    user.gain!(Achievement::First100Users) if User.count < 100

    day_beginning = Time.now.at_beginning_of_day
    if user.last_login >= day_beginning + 8.hours && user.last_login <= day_beginning + 14.hours
      user.gain!(Achievement::SchoolAccess)
    end
  end

end