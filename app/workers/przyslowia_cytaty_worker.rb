require "open-uri"
require File.join(Rails.root, "lib/render_text")

class PrzyslowiaCytatyWorker < Struct.new(:nil)
  Url = "http://www.przyslowia-cytaty.com/"
  
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
    
    scrap_url(PrzyslowiaCytatyWorker::Url)

  end
  
  def scrap_url(check_url)
    return if urls.include?(check_url)
    tmp_path = File.join(Rails.root, "tmp", "cites")
    Dir.mkdir(tmp_path) rescue nil
    @agent.get(check_url) do |page|
      urls << check_url
      puts "=======> Opening: #{check_url}"
      page.search(".entry .entry-content").each do |entry|
        cite = entry.search("h2.title a").first.inner_text
        author = entry.search(".author a").first.inner_text
        text = [cite.inspect, "- #{author}"].join("\n")
        puts "Cite: \n#{text}"
        hash = Digest::MD5.hexdigest(text)
        puts "Digest is: #{hash}"
        
        next unless Image.where(hash: hash).empty?
        
        file_name = File.join(tmp_path, "#{hash}.png")
        
        puts "Storing in: #{file_name}"
        
        text = TextImage.new(text)
        text.save(file_name)
        i = Image.new
        i.file = File.open(file_name)
        i.publish_at = Time.now + 1.day * rand
        i.hash = hash
        i.description = text
        i.save
        puts i.errors.full_messages.join("\n")
      end
      
      next_page_link = page.search(".pagination .alignleft a")
      
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
