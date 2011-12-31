namespace :lolek do
  
  desc "Fetch all info from channels"
  task :fetch => :environment do
    Delayed::Job.enqueue LubieCyckiWorker.new(nil)
    #Delayed::Job.enqueue RefreshWorker.new(nil)
  end
  
end