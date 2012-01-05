namespace :lolek do
  
  desc "Fetch all info from channels"
  task :fetch => :environment do
    dev = Rails.env == "developement" ? 0 : 1
    Delayed::Job.enqueue LubieCyckiWorker.new(nil), run_at: Time.now.at_beginning_of_day + (dev * (15.hours * rand))
    Delayed::Job.enqueue RefreshWorker.new(nil), run_at: Time.now.at_beginning_of_day + (dev * (15.hours * rand))
    Delayed::Job.enqueue GlosyGlowaWorker.new(nil), run_at: Time.now.at_beginning_of_day + (dev * (15.hours * rand))
    Delayed::Job.enqueue AndrzejRysujeWorker.new(nil), run_at: Time.now.at_beginning_of_day + (dev * (15.hours * rand))
    Delayed::Job.enqueue ForGifsWorker.new(nil), run_at: Time.now.at_beginning_of_day + (dev * (15.hours * rand))
    Delayed::Job.enqueue MemyWorker.new(nil), run_at: Time.now.at_beginning_of_day + (dev * (15.hours * rand))
    Delayed::Job.enqueue BashWorker.new(nil), run_at: Time.now.at_beginning_of_day + (dev * (15.hours * rand))
    Delayed::Job.enqueue PrzyslowiaCytatyWorker.new(nil), run_at: Time.now.at_beginning_of_day + (dev * (15.hours * rand))
    RssImageWorker.refresh
    CiteWorker.refresh
    GryskopWorker.refresh
    GameNodeWorker.refresh
    Delayed::Job.enqueue CiekawostkiWorker.new(nil), run_at: Time.now.at_beginning_of_day + (dev * (15.hours * rand))
    Delayed::Job.enqueue DilbertWorker.new(nil), run_at: Time.now.at_beginning_of_day + (dev * (15.hours * rand))
    Delayed::Job.enqueue StripfieldWorker.new(nil), run_at: Time.now.at_beginning_of_day + (dev * (15.hours * rand))
    Delayed::Job.enqueue TheMovieWorker.new(nil), run_at: Time.now.at_beginning_of_day + (dev * (15.hours * rand))
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
    User.is_bot.each(&:spam!)
  end

  desc "Calculate user ranks"
  task :rank => :environment do
    User.all.each(&:calculate_rank!)
  end

  desc "Randomize"
  task :randomize => :environment do
    Link.all.each do |link|
      if Rails.env == "development"
        link.publish_at = Time.now - 1.day * rand
      else
        link.publish_at = Time.now + 2.months * rand
      end
      link.save
    end
  end
end