Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 5
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 15.minutes
Delayed::Worker.delay_jobs = !Rails.env.test?

module Delay
  Observer = -1
  Like = -4
  Badge = -2
  UserRank = -3
  UserFriend = -5

  ImportPipline = 10
end


DelayedJobWeb.use Rack::Auth::Basic do |username, password|
  username == App::Config["admin"]["user"]
  password == App::Config["admin"]["password"]
end
