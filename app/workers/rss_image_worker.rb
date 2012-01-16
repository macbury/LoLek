require "open-uri"
require "nokogiri"
class RssImageWorker
  @queue = Delay::Import

  def self.perform(url)
    puts "Opening Channel: #{url}"
    rss = Nokogiri::HTML(open(url))
    rss.search("item").each do |item|
      puts "Opening item"
      item = Nokogiri::HTML(item.text)
      puts "Searching images"
      img = item.search("img").first
      return if img.nil?
      puts "Found: #{img["src"]}"
      Resque.enqueue(ImageDownloaderWorker, img["src"], img["alt"])
    end
  end
  
  def self.refresh
    channels = YAML.load(File.open(File.join(Rails.root, "config/channels/rss.yml")))
    channels.each do |name, url|
      puts "Adding #{name} => #{url} to quee"
      Resque.enqueue(RssImageWorker, url)
    end
  end
  
end
