class CiteRenderWorker < Struct.new(:text)
  
  def perform
    tmp_path = File.join(Rails.root, "tmp", "cites")
    Dir.mkdir(tmp_path) rescue nil
    puts text
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
  
end
