class ImageDownloaderWorker < Struct.new(:url)
  def perform
    puts url.inspect
    i = Image.new(:url => url)
    i.publish_at = Time.now + (1.day * rand)
    i.start_rate = Link::RateThreshold
    saved = i.save
  end
end