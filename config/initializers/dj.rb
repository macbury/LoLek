require File.join(Rails.root, "lib/resque")
module Delay
  Observer = -1
  Like = -4
  Badge = -2
  UserRank = -3
  UserFriend = -5

  ImportPipline = 10
  Actions = :actions
  Import = :import
  Download = :download
end

Resque::Server.use(Rack::Auth::Basic) do |username, password|
  username == App::Config["admin"]["user"]
  password == App::Config["admin"]["password"]
end

Resque::AsyncHandling.enabled = true