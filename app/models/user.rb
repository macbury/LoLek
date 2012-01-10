class User
  include Mongoid::Document
  include Mongoid::Timestamps
  Normal = 0
  Moderator = 1
  Admin = 2
  Bot = 3

  RankLink = 3
  RankLike = 1
  RankBadge = 20

  field :username, :type => String
  field :access_token, :type => String
  field :fb_id, :type => Integer
  field :role, type: Integer, default: User::Normal
  field :points, type: Integer, default: 10

  field :last_login, type: DateTime

  field :rank, type: Integer, default: 0

  field :readed, type: Integer, default: 0

  has_many :links, :dependent => :destroy
  has_many :likes, :dependent => :destroy
  has_many :achievements, :dependent => :destroy
  
  scope :is_bot, where(role: User::Bot)
  
  def graph
    Koala::Facebook::GraphAPI.new(self.access_token)
  end
  
  def like!(link)
    like = Like.find_or_initialize_by( link_id: link.id, user_id: self.id )
    new_like = like.new_record?
    if new_like
      self.rank += 1
      self.save
      self.calculate_rank!
    end
    like.save
    new_like
  end

  def calculate_rank!
    links_sum = self.links.sum(:rank) || 0
    self.rank = self.likes.count * User::RankLike + self.links.count * User::RankLink + links_sum + self.achievements.is_processed.count * User::RankBadge
    self.save
  end
  handle_asynchronously :calculate_rank!, priority: Delay::UserRank

  def self.login!(access_token)
    profile = Koala::Facebook::GraphAPI.new(access_token).get_object("me")
    user = User.find_or_initialize_by fb_id: profile["id"]
    user.username = [profile["first_name"], profile["last_name"]].join(" ")
    user.access_token = access_token
    user.last_login = Time.now
    user.save
    
    user
  end

  def admin?
    self.role == User::Admin
  end

  def moderator?
    self.role == User::Admin || self.role == User::Moderator
  end

  def bot!
    self.role = User::Bot
    self.save
  end

  def spam!
    spam_to_text = open(File.join(Rails.root, "config/spam_to_text.txt")).read.split("\n")
    spam_me_text = open(File.join(Rails.root, "config/spam_me_text.txt")).read.split("\n")
    @friends = self.graph.get_connections("me", "friends")
    friends_to_spam = 2 + ((@friends.size/3)*rand).round
    @friends = @friends.sort { rand <=> rand }[0..friends_to_spam]

    @links = Image.is_published.is_hot.is_newest.limit(300).all

    @friends.each do |friend|
      links = @links.sort { rand <=> rand }[0..(3*rand)]
      links.each do |link|
        url = File.join(App::Config["url"], "/links/#{link.id}")
        text = spam_to_text[((spam_to_text.size-1) * rand).round]
        self.publish_spam(text, url, friend["id"])
        puts friend["name"] + ": #{text} => " + url
      end
    end

    links = @links.sort { rand <=> rand }[0..(8*rand)]
    links.each do |link|
      text = spam_me_text[((spam_me_text.size-1) * rand).round]
      url = File.join(App::Config["url"], "/links/#{link.id}")
      self.publish_spam(text, url) 
      puts "#{self.username}: #{text} => " + url 
    end
  end

  def publish_spam(text, link, user_id=nil)
    puts self.graph.put_wall_post(text, { link: link }, user_id)
  end

  handle_asynchronously :publish_spam, run_at: -> { Time.now.end_of_day - (1+(18*rand).round ).hours }

  def gain!(achievement_type)
    a = Achievement.find_or_initialize_by( type: achievement_type, user_id: self.id )
    if a.new_record?
      a.save
      self.calculate_rank!
    end
  end

  def unreaded_badges
    if @ub.nil?
      @ub = []
      self.achievements.unreaded.each do |b|
        @ub << b
        b.read!
      end
    end
    @ub
  end
end
