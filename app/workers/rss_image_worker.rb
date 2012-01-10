require "open-uri"
require "nokogiri"
class RssImageWorker < Struct.new(:url)
  
  def perform
    puts "Opening Channel: #{url}"
    rss = Nokogiri::HTML(open(self.url))
    rss.search("item").each do |item|
      puts "Opening item"
      item = Nokogiri::HTML(item.text)
      puts "Searching images"
      img = item.search("img").first
      return if img.nil?
      puts "Found: #{img["src"]}"
      Delayed::Job.enqueue ImageDownloaderWorker.new(img["src"], img["alt"])
    end
  end
  
  def self.refresh
    channels = YAML.load(File.open(File.join(Rails.root, "config/channels/rss.yml")))
    channels.each do |name, url|
      puts "Adding #{name} => #{url} to quee"
      Delayed::Job.enqueue RssImageWorker.new(url)
    end
  end
  
end
