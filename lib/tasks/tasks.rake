namespace :lolek do
  
  desc "Fetch all info from channels"
  task :fetch => :environment do
    dev = Rails.env == "developement" ? 0 : 1
    [LubieCyckiWorker, DilbertWorker,StripfieldWorker, TheMovieWorker, CiekawostkiWorker, RefreshWorker, GlosyGlowaWorker, AndrzejRysujeWorker, ForGifsWorker, MemyWorker, PrzyslowiaCytatyWorker, BashWorker, TwistedWorker].uniq.each do |klass|
      time = Time.now.at_beginning_of_day + (dev * (15.hours * rand))
      Delayed::Job.enqueue klass.new(nil), run_at: time, priority: Delay::ImportPipline
      puts "Will run #{klass.inspect} on #{time}"
    end
    RssImageWorker.refresh
    CiteWorker.refresh
    GryskopWorker.refresh
    GameNodeWorker.refresh
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

  desc "Fetch chata"
  task :andrzej => :environment do
    Delayed::Job.enqueue AndrzejRysujeWorker.new(nil)
  end

  desc "Fetch chata"
  task :forgifs => :environment do
    Delayed::Job.enqueue ForGifsWorker.new(nil)
  end

  desc "Fetch chata"
  task :mems => :environment do
    Delayed::Job.enqueue MemyWorker.new(nil)
  end

  desc "Fetch chata"
  task :rss => :environment do
    RssImageWorker.refresh
  end

  desc "Fetch chata"
  task :cites => :environment do
    CiteWorker.refresh
  end

  desc "Fetch chata"
  task :games => :environment do
    GryskopWorker.refresh
  end

  desc "Fetch chata"
  task :node => :environment do
    GameNodeWorker.refresh
  end

  desc "Fetch chata"
  task :bash => :environment do
    Delayed::Job.enqueue BashWorker.new(nil)
  end
  
  desc "Fetch chata"
  task :przyslowia => :environment do
    Delayed::Job.enqueue PrzyslowiaCytatyWorker.new(nil)
  end

  desc "Fetch chata"
  task :dilbert => :environment do
    Delayed::Job.enqueue DilbertWorker.new(nil)
  end

  desc "Fetch chata"
  task :ciekawostki => :environment do
    Delayed::Job.enqueue CiekawostkiWorker.new(nil)
  end

  desc "Fetch chata"
  task :strips => :environment do
    Delayed::Job.enqueue StripfieldWorker.new(nil)
  end

  desc "Fetch chata"
  task :movie => :environment do
    Delayed::Job.enqueue TheMovieWorker.new(nil)
  end

  desc "Fetch chata"
  task :twisted => :environment do
    Delayed::Job.enqueue TwistedWorker.new(nil)
  end

  desc "Wikary"
  task :wikary => :environment do
    Dir["/home/wikary_php/org/**/*.*"].each do |filename|
      i = Image.new
      i.file = File.open(filename, "r+")
      i.publish_at = Time.now + 2.months * rand
      i.save
      puts "#{i.publish_at}: "+filename
    end
  end
  
  desc "Spam"
  task :spam => :environment do
    User.spam!
  end

  desc "Calculate user ranks"
  task :rank => :environment do
    User.all({ :timeout => false }).each(&:calculate_rank!)
  end

  desc "Calculate Position"
  task :position => :environment do
    User.calculate_position!
  end  

  desc "Randomize"
  task :randomize => :environment do
    Link.all(:timeout => false).each do |link|
      link.randomize
      link.save
    end
  end
end
