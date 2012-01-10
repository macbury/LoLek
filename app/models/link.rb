class Link
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Random
  RateThreshold = 5

  validates :url, :uniqueness => true, :presence => true, :if => :check_url?, :on => :create
  
  field :url, type: String
  field :processed, type: Boolean, default: false
  field :publish_at, type: DateTime
  
  field :start_rate, type: Integer, default: 0
  
  field :hash, type: String
  
  field :store_token, type: String

  field :likes, type: Integer, default: 0
  field :rate, type: Integer, default: 0
  
  field :banned, type: Boolean, default: false

  scope :not_banned, where( banned: false )
  scope :is_processed, where(processed: true).not_banned
  scope :is_published, where(:publish_at.lt => Time.now).is_processed
  scope :is_not_published, where(:publish_at.gt => Time.now).is_processed
  scope :is_pending, where(:rate.lt => Link::RateThreshold)
  scope :is_hot, where(:rate.gte => Link::RateThreshold)
  scope :is_popular, desc(:rate, :publish_at).is_hot
  scope :is_newest, desc(:publish_at)

  has_many :likes, :dependent => :destroy
  belongs_to :user

  after_create :update_user!

  def update_user!
    self.user.calculate_rank! if self.user
  end

  def check_url?
    true
  end
  
  def store_token
    toc = read_attribute :store_token
    if toc.nil?
      toc = Digest::MD5.hexdigest(self.id.to_s)
      begin
        write_attribute :store_token, toc 
      rescue Exception => e 
        Rails.logger.error e.to_s
      end
    end
    toc
  end

  def processed!
    self.publish_at ||= Time.now
    self.processed = true
  end
  
  def random_rate!
    self.start_rate = (Link::RateThreshold / 3) + (Link::RateThreshold * rand)
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
  
  def game?
    self.class == Game
  end

  def image?
    self.class == Image
  end

  def video?
    self.class == Video
  end

  def to_opengraph
    { title: I18n.t("title"), type: "article", description: I18n.t("summary") }
  end

  def ban!
    self.banned = true
    self.save
  end

  def good?
    self.rate >= Link::RateThreshold
  end

  def accept!
    self.start_rate = Link::RateThreshold
    self.save
    self.check_status!
  end

  def check_status!
    @graph = Koala::Facebook::GraphAPI.new(nil)
    info = @graph.get_object(File.join(App::Config["url"], "/links/#{self.id}"))
    
    self.rate = [info["shares"], info["likes"], self.start_rate].compact.inject(0) { |sum, likes| sum += likes } || 0
    self.save
    update_user!
  end

  handle_asynchronously :check_status!, run_at: -> { 5.seconds.from_now }, priority: Delay::Like
end
