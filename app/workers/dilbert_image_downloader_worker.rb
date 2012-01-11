class DilbertImageDownloaderWorker < Struct.new(:url)
  def perform
    @agent = Mechanize.new
    @agent.open_timeout = 10
    
    @agent.read_timeout = 10
    @agent.keep_alive = true
    @agent.user_agent_alias = 'Mac Safari'
    
    @agent.get(url) do |page|
      img = page.search(".dm_img").first
      unless img.nil?
        obj = { src: img["src"], alt: img["alt"] }
        puts obj.inspect
        Delayed::Job.enqueue ImageDownloaderWorker.new(img["src"], "dilbert wersja polska komiksu"), priority: Delay::ImportPipline
      end
    end
  end
end