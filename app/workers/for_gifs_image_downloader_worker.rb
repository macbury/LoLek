class ForGifsImageDownloaderWorker < Struct.new(:url)
  
  def perform
    @agent = Mechanize.new
    @agent.open_timeout = 10
    
    @agent.read_timeout = 10
    @agent.keep_alive = true
    @agent.user_agent_alias = 'Mac Safari'
    
    puts "GET: #{url}"
    
    @agent.get(url) do |page|
      img = page.search("#gsImageView img")[1]
      unless img.nil?
        obj = { src: img["src"], alt: img["alt"] }
        puts obj.inspect
        Delayed::Job.enqueue ImageDownloaderWorker.new(File.join("http://forgifs.com/", img["src"]))
      end
    end
    
    

  end
end