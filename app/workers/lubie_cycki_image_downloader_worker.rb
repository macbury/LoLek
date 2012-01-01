class LubieCyckiImageDownloaderWorker < Struct.new(:url)
  def perform
    @agent = Mechanize.new
    @agent.open_timeout = 10
    
    @agent.read_timeout = 10
    @agent.keep_alive = true
    @agent.user_agent_alias = 'Mac Safari'
    
    @agent.get(url) do |page|
      img = page.search("#photo img").first
      unless img.nil?
        obj = { src: img["src"], alt: img["alt"] }
        puts obj.inspect
        i = Image.new(:url => img["src"])
        i.description = img["alt"]
        i.publish_at = Time.now + (1.day * rand)
        i.start_rate = Link::RateThreshold
        saved = i.save
      end
    end
    
    

  end
end