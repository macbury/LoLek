class StripfieldWorker < Struct.new(:nil)
  Url = "http://www.stripfield.cba.pl/newestPL.html"
  
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
    @index = 80
    scrap_url(StripfieldWorker::Url)
  end
  
  def scrap_url(check_url)
    return if urls.include?(check_url)
    @agent.get(check_url) do |page|
      urls << check_url
      puts "=======> Opening: #{check_url}"
      img = page.search("table p img").first
      puts img
      return if img.nil?
      url = File.join("http://www.stripfield.cba.pl/", img["src"])
      Delayed::Job.enqueue ImageDownloaderWorker.new(url)
      puts url
      return
      next_page_link = page.xpath('//td/a[@name="arrowleft"]')
      
      if next_page_link.nil? || next_page_link.empty? || @index <= 0
        puts "End of page"
        check_url = nil
      else
        check_url = next_page_link[-2]["href"]
        puts "Going to next page: #{check_url}"
        scrap_url(File.join("http://www.stripfield.cba.pl", check_url))
        @index -= 1
      end
    end
  end

  
end