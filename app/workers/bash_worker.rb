require "open-uri"
require File.join(Rails.root, "lib/render_text")
class BashWorker < Struct.new(:nil)
  
  def perform
    tmp_path = File.join(Rails.root, "tmp", "cites")
    Dir.mkdir(tmp_path) rescue nil
    cites = open("http://bash.org.pl/text").read.split("%").map { |c| c.split("\n")[1..-1] }.compact
    cites.each do |text|
      next if text.nil? || text.empty?
      puts "Cite:"
      text = text[1..-1].join("\n")
      puts text
      hash = Digest::MD5.hexdigest(text)
      puts "Digest is: #{hash}"
      
      next unless Image.where(hash: hash).empty?
      
      file_name = File.join(tmp_path, "#{hash}.gif")
      
      puts "Storing in: #{file_name}"
      
      text = TextImage.new(text)
      text.save(file_name)
      i = Image.new
      i.file = File.open(file_name)
      i.publish_at = Time.now + 1.day * rand
      i.hash = hash
      i.save
      puts i.errors.full_messages.join("\n")
    end
  end
  
end
