class ImageDownloaderWorker < Struct.new(:url)
  def perform
    return unless Image.where(url: url).empty?
    puts "Downloading: #{url}"
    file = open(url)
    
    path = file.path
    ext = File.extname(path)

    if ext.blank? && ext = detect_extension(path)
      puts "Detected extension for image - #{ext}"
      path = path + ".#{ext}"
      FileUtils.mv(file.path, path)
      file = File.open(path)
    else
      puts "File have ext: #{ext}"
    end

    i = Image.new
    i.write_attribute :url, url
    i.file = file
    i.publish_at = Time.now + (1.day * rand)
    i.random_rate!
    saved = i.save
  end
  
  def detect_extension(file_name)
    mime_type = %x(file --mime-type #{file_name}|cut -f2 -d' ').gsub("\n", "")
    case mime_type
    when 'image/jpeg'
      'jpg'
    when 'image/jpg'
      'jpg'
    when 'image/png'
      'png'
    when 'image/gif'
      'gif'
    end
  end
end