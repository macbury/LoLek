namespace :lolek do
  
  desc "Fetch all info from channels"
  task :fetch => :environment do
    Delayed::Job.enqueue LubieCyckiWorker.new(nil)
    Delayed::Job.enqueue RefreshWorker.new(nil)
    Delayed::Job.enqueue GlosyGlowaWorker.new(nil)
  end
  
  desc "Fetch cycki"
  task :cycki => :environment do
    Delayed::Job.enqueue LubieCyckiWorker.new(nil)
  end

  desc "Fetch chata"
  task :chata => :environment do
    Delayed::Job.enqueue ChataWorker.new(nil)
  end
  
  desc "Fetch chata"
  task :glowa => :environment do
    Delayed::Job.enqueue GlosyGlowaWorker.new(nil)
  end
  
  desc "Wikary"
  task :wikary => :environment do
    Dir["/home/wikary_php/org/**/*.*"].each do |filename|
      i = Image.new
      i.file = File.open(filename, "r+")
      i.publish_at = Time.now + 30.days * rand
      i.save
      puts "#{i.publish_at}: "+filename
    end
  end
end