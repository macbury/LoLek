class Link
  include Mongoid::Document
  include Mongoid::Timestamps
  
  validates :url, :uniqueness => true, :presence => true, :if => :check_url?, :on => :create
  
  field :url, type: String
  field :likes, type: Integer
  field :processed, type: Boolean, default: false
  field :publish_at, type: DateTime
  
  scope :is_processed, where(processed: true)
  scope :is_published, where(:publish_at.lt => Time.now).is_processed
  
  belongs_to :user
  
  def check_url?
    true
  end
  
  def processed!
    self.publish_at ||= Time.now
    self.processed = true
  end
  
  def self.import(params)
    if params[:image]
      return Image.new(:file => params[:image])
    elsif params[:url] =~ Video::YouTubeRegexp
      return Video.new(:url => params[:url])
    elsif params[:url]
      return Image.new(:url => params[:url])
    else
      return Link.new
    end
  end
end
