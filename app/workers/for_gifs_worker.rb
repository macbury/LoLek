class ForGifsWorker < BaseWorker
  @queue = Delay::Import
  Url = "http://forgifs.com/gallery/v/Girls/"
  
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
    
    check_url = ForGifsWorker::Url
    
    scrap_url(check_url)
  end
  
  def scrap_url(check_url)
    return if urls.include?(check_url)
    @agent.get(check_url) do |page|
      urls << check_url
      puts "=======> Opening: #{check_url}"
      page.search(".giItemCell a").each do |url|
        puts url["href"]
        Delayed::Job.enqueue ForGifsImageDownloaderWorker.new(File.join("http://forgifs.com/", url["href"])), priority: Delay::ImportPipline
      end
      puts "Going to next page"
      next_page_link = page.search(".next-and-last a.next")
      
      if next_page_link.nil? || next_page_link.empty?
        puts "End of page"
        check_url = nil
      else
        check_url = File.join("http://forgifs.com/", next_page_link.first["href"])
        scrap_url(check_url)
      end
    end
  end

  
end
