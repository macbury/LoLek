class CiteRenderWorker < Struct.new(:text_to_render)
  
  def perform
    tmp_path = File.join(Rails.root, "tmp", "cites")
    Dir.mkdir(tmp_path) rescue nil
    puts text_to_render
    hash = Digest::MD5.hexdigest(text_to_render)
    puts "Digest is: #{hash}"
    
    return unless Image.where(:hash => hash).empty?
    
    file_name = File.join(tmp_path, "#{hash}.png")
    
    puts "Storing in: #{file_name}"
    
    text_render = TextImage.new(text_to_render)
    text_render.save(file_name)
    i = Image.new
    i.file = File.open(file_name)
    i.publish_at = Time.now + 1.day * rand
    i.hash = hash
    i.description = text_to_render
    i.random_rate!
    i.save
    puts i.errors.full_messages.join("\n")
  end
  
end
