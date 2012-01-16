require "open-uri"
require 'fileutils'
class ImageDownloaderWorker
  @queue = Delay::Download

  def self.perform(url, alt)
    unless Image.where(url: url).empty?
      puts "URL: #{url} exists! Skiping..."
      return
    end
    tmp_path = File.join(Rails.root, "tmp", "images")
    Dir.mkdir(tmp_path) rescue nil

    hash = Digest::MD5.hexdigest(url)
    ext = File.extname(url)

    path = File.join(tmp_path, "#{hash}#{ext}")
    puts "Downloading to #{path} from #{url}"
    puts `wget -O #{path} "#{url}"`

    if ext.blank? && ext = self.detect_extension(path)
      puts "Detected extension for image - #{ext}"
      old_path = path
      path = path + ".#{ext}"
      FileUtils.move old_path, path
      file = File.open(path)
    else
      file = File.open(path)
      puts "File have ext: #{ext}"
    end

    cmd = "identify -format \"%wx%h\" #{path}"
    puts cmd
    res = `#{cmd}`.split(/x/)
    width, height = res.first, res.last
    puts "Dimension: #{width}x#{height}"

    if width.to_i < 100 || height.to_i < 100
      throw "Image dimension invalid! #{url}"
    end

    i = Image.new
    i.write_attribute :url, url
    i.file = file
    i.publish_at = Time.now + (1.day * rand)
    i.random_rate!
    i.description = alt

    i.save!
    
  end
  
  def self.detect_extension(file_name)
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