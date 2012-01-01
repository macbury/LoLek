# -*- encoding : utf-8 -*-
class GlosyGlowaWorker < Struct.new(:nil)
  Url = "http://www.glosywmojejglowie.pl/2011/04/04/taniec-przyjazni-2/"
  
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

    scrap_url(GlosyGlowaWorker::Url)
  end
  
  def scrap_url(check_url)
    return if urls.include?(check_url)
    @agent.get(check_url) do |page|
      urls << check_url
      puts "=======> Opening: #{check_url}"
      page.search(".comicpane img").each do |img|
        puts img["src"]
        Delayed::Job.enqueue ImageDownloaderWorker.new(img["src"])
      end
      
      next_page_link = page.search("a.navi.navi-next")
      
      if next_page_link.nil? || next_page_link.empty?
        puts "End of page"
        check_url = nil
      else
        check_url = next_page_link.first["href"]
        puts "Going to next page: #{check_url}"
        scrap_url(check_url)
      end
    end
  end

  
end
