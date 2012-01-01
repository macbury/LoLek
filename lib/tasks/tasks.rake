namespace :lolek do
  
  desc "Fetch all info from channels"
  task :fetch => :environment do
    5.times do
      Delayed::Job.enqueue LubieCyckiWorker.new(nil), :run_at => Time.now + 1.day * rand
      Delayed::Job.enqueue RefreshWorker.new(nil), :run_at => Time.now + 1.day * rand
      Delayed::Job.enqueue ChataWorker.new(nil), :run_at => Time.now + 1.day * rand\
    end
  end
  
  desc "Fetch cycki"
  task :cycki => :environment do
    Delayed::Job.enqueue LubieCyckiWorker.new(nil)
  end

  desc "Fetch chata"
  task :chata => :environment do
    Delayed::Job.enqueue ChataWorker.new(nil)
  end
end