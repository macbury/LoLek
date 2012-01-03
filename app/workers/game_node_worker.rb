require "open-uri"
require "nokogiri"
class GameNodeWorker < Struct.new(:url)
  Url = "http://www.gamenode.com/"
  
  def perform
    puts "Starting: #{self.url}"
    hash = Digest::MD5.hexdigest(self.url)
    puts "Digest is: #{hash}"
    
    return unless Link.where(hash: hash).empty?
    
    tmp_path = File.join(Rails.root, "tmp", "swfs")
    Dir.mkdir(tmp_path) rescue nil
    @agent = Mechanize.new
    @agent.open_timeout = 10
    @agent.read_timeout = 10
    @agent.keep_alive = true
    @agent.user_agent_alias = 'Mac Safari'
    
    puts "Opening: #{self.url}"
    @agent.get(self.url) do |page|
      object = page.search("#gameobject object embed").first
      swf_file = object["src"]
      width = object["width"]
      height = object["height"]
      puts "Resolution: #{width}x#{height}"
      swf_url = File.join(self.url, swf_file)
      puts "Downloading #{swf_url}"
      file_name = File.join(tmp_path, "#{hash}.swf")
      `wget -O #{file_name} "#{swf_url}"`
      game = Game.new
      game.file = File.open(file_name)
      game.publish_at = Time.now + 1.day * rand
      game.hash = hash
      game.width = width
      game.height = height
      game.url = self.url
      game.processed!
      game.random_rate!
      game.save
      puts game.errors.full_messages.join("\n")
    end
  end
  
  def self.refresh
    url = "http://www.gamenode.com/rss/"
    puts "Opening Channel: #{url}"
    
    rss = Nokogiri::XML(open(url))
    rss.xpath('//item').each do |item|
      puts "Opening item"
      flash_url = item.xpath('link').inner_text
      puts "#{flash_url}"
      Delayed::Job.enqueue GryskopWorker.new(flash_url)
    end
  end

end