require "open-uri"
require "nokogiri"
require File.join(Rails.root, "lib/render_text")
class CiteWorker < Struct.new(:url)
  
  def perform
    puts "Opening Channel: #{url}"
    tmp_path = File.join(Rails.root, "tmp", "cites")
    Dir.mkdir(tmp_path) rescue nil
    rss = Nokogiri::HTML(open(self.url))
    rss.search("item").each do |item|
      puts "Opening item"
      
      description = item.search("description").first
      title = item.search("title").first
      
      if description.nil? || description.inner_text.strip.empty?
        text = title.inner_text
      else
        text = description.inner_text
      end
      puts text
      
      
      hash = Digest::MD5.hexdigest(item.inner_text)
      puts "Digest is: #{hash}"
      
      next unless Image.where(hash: hash).empty?
      
      file_name = File.join(tmp_path, "#{hash}.gif")
      
      puts "Storing in: #{file_name}"
      
      text = TextImage.new(item.text)
      text.save(file_name)
      i = Image.new
      i.file = File.open(file_name)
      i.publish_at = Time.now + 1.day * rand
      i.hash = hash
      i.save
      puts i.errors.full_messages.join("\n")
    end
  end
  
  def self.refresh
    channels = YAML.load(File.open(File.join(Rails.root, "config/channels/cites.yml")))
    channels.each do |name, url|
      puts "Adding #{name} => #{url} to quee"
      Delayed::Job.enqueue CiteWorker.new(url)
    end
  end
  
end
