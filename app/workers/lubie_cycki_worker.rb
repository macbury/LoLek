class LubieCyckiWorker < Struct.new(:nil)
  Url = "http://lubiecycki.tumblr.com/"
  
  attr_accessor :list, :images, :urls
  
  def perform
    @agent = Mechanize.new
    @agent.open_timeout = 10
    self.list = []
    self.images = []
    self.urls = []
    @agent.read_timeout = 10
    @agent.keep_alive = true
    @agent.user_agent_alias = 'Mac Safari'
    
    check_url = LubieCyckiWorker::Url
    
    scrap_url(check_url)
    load_images
  end
  
  def scrap_url(check_url)
    return if urls.include?(check_url)
    @agent.get(check_url) do |page|
      urls << check_url
      puts "=======> Opening: #{check_url}"
      page.search(".post a").each do |url|
        puts url["href"]
        Delayed::Job.enqueue LubieCyckiImageDownloaderWorker.new(url["href"])
      end
      puts "Going to next page"
      next_page_link = page.search("#nextpage")
      
      if next_page_link.nil? || next_page_link.empty?
        puts "End of page"
        check_url = nil
      else
        check_url = File.join(LubieCyckiWorker::Url, next_page_link.first["href"])
        scrap_url(check_url)
      end
    end
  end

  
end
