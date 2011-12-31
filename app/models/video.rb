class Video < Link
  YouTubeRegexp = /http:\/\/(www.)?youtube\.com\/watch\?v=([A-Za-z0-9._%-]*)(\&\S+)?/i
  field :youtube_id, field: String
  field :title, field: String
  field :keywords, field: Array
  after_create :fetch_info
  
  validates :youtube_id, :uniqueness => true, :presence => true, :on => :create
  
  def youtube?
    !youtube_id.nil?
  end
  
  def url=(new_url)
    write_attribute :url, new_url
    self.youtube_id = $2 if new_url =~ Video::YouTubeRegexp
  end
  
  def fetch_info
    info = YoutubeClient.video_by(youtube_id)
    self.keywords = info.keywords
    self.title = info.title
    processed!

    save
  end
  
  handle_asynchronously :fetch_info

  def youtube_preview
    "http://img.youtube.com/vi/#{self.youtube_id}/0.jpg"
  end
  
  def embed_url
    "http://www.youtube.com/embed/#{self.youtube_id}"
  end
  
  def self.refresh_channel
    channels = YAML.load(File.open(File.join(Rails.root, "config/channels/youtube.yml")))
    channels.each do |name, user|
      @videos = YoutubeClient.videos_by(:user => user).videos
      @videos.each do |video|
        puts video.player_url
        v = Video.new(:url => video.player_url)
        v.publish_at = Time.now + (1.day * rand)
        v.save
      end
    end
  end
end