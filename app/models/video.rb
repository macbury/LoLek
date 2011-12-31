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
      @videos = YoutubeClient.videos_by(:user => user, :per_page => 50).videos
      @videos.reverse.each do |video|
        v = Video.new(:url => video.player_url)
        v.publish_at = Time.now + (1.day * rand)
        saved = v.save
        
        puts "#{saved.inspect}. #{user}: #{video.title} => #{video.player_url}"
      end
    end
  end
end