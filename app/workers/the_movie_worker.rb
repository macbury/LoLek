class TheMovieWorker < Struct.new(:url)
  Url = "http://nowas.nazwa.pl/belewicz/"
  attr_accessor :urls
  def perform
    @agent = Mechanize.new
    @agent.open_timeout = 10
    @agent.read_timeout = 10
    @agent.keep_alive = true
    self.urls = []
    @agent.user_agent_alias = 'Mac Safari'
    
    check_url = TheMovieWorker::Url
    
    scrap_url(check_url)
  end
  
  def scrap_url(check_url)
    return if urls.include?(check_url)
    @agent.get(check_url) do |page|
      urls << check_url
      puts "=======> Opening: #{check_url}"
      page.search("#comic img").each do |img|
        url = img["src"]
        puts url
        Delayed::Job.enqueue ImageDownloaderWorker.new(url, img["alt"])
      end
      puts "Going to next page"
      next_page_link = page.search(".nawigacja table td a").first
      
      if next_page_link.nil?
        puts "End of page"
        check_url = nil
      else
        check_url = next_page_link["href"]
        scrap_url(check_url)
      end
    end
  end

  
end