class LubieCyckiWorker < Struct.new(:nil)
  Url = "http://lubiecycki.tumblr.com/"
  
  attr_accessor :list, :images
  
  def perform
    @agent = Mechanize.new
    @agent.open_timeout = 10
    self.list = []
    self.images = []
    @agent.read_timeout = 10
    @agent.keep_alive = true
    @agent.user_agent_alias = 'Mac Safari'
    
    check_url = LubieCyckiWorker::Url
    while check_url
      @agent.get(check_url) do |page|
        puts "=======> Opening: #{check_url}"
        page.search(".post a").each do |url|
          puts url["href"]
          self.list << url["href"]
        end
        puts "Going to next page"
        next_page_link = page.search("#nextpage")
        
        if next_page_link.nil? || next_page_link.empty?
          puts "End of page"
          check_url = nil
        else
          check_url = File.join(LubieCyckiWorker::Url, next_page_link.first["href"])
        end
      end
    end
    
    load_images
  end
  
  def load_images
    puts "=> Loading images urls:"
    self.list.each do |url|
      @agent.get(url) do |page|
        img = page.search("#photo img").first
        unless img.nil?
          obj = { src: img["src"], alt: img["alt"] }
          puts obj.inspect
          Delayed::Job.enqueue ImageDownloaderWorker.new(obj)
        end
      end
    end
  end
  
end
