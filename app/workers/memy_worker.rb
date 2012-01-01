class MemyWorker < Struct.new(:nil)
  Url = "http://pl.memgenerator.pl/"
  
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
    scrap_url(MemyWorker::Url)
  end
  
  def scrap_url(check_url)
    return if urls.include?(check_url)
    @agent.get(check_url) do |page|
      urls << check_url
      puts "=======> Opening: #{check_url}"
      page.search(".mem img").each do |url|
        puts url["src"]
        Delayed::Job.enqueue ImageDownloaderWorker.new(File.join("http://pl.memgenerator.pl/", url["src"]))
      end
      
      next_page_link = page.search(".pagination a")
      
      if next_page_link.nil? || next_page_link.empty? || @index <= 0
        puts "End of page"
        check_url = nil
      else
        check_url = next_page_link[-2]["href"]
        puts "Going to next page: #{check_url}"
        scrap_url(check_url)
        @index -= 1
      end
    end
  end

  
end
