class ImageDownloaderWorker < Struct.new(:obj)
  def perform
    i = Image.new(:url => obj[:url])
    i.alt = obj[:alt]
    i.publish_at = Time.now + (1.day * rand)
    saved = i.save
  end
end