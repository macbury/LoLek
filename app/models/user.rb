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
  RankFriend = 10

  field :username, type: String
  field :access_token, type: String
  field :fb_id, type: Integer
  field :role, type: Integer, default: User::Normal
  field :points, type: Integer, default: 10

  field :last_login, type: DateTime

  field :rank, type: Integer, default: 0
  field :position, type: Integer, default: 0
  field :last_position, type: Integer, default: 0

  field :friends_fb_ids, type: Array, default: []

  field :readed, type: Integer, default: 0

  has_many :links, :dependent => :destroy
  has_many :likes, :dependent => :destroy
  has_many :achievements, :dependent => :destroy
  
  scope :is_bot, where(role: User::Bot)
  
  before_create :setup_values

  def setup_values
    pos = User.max(:position) || 0
    pos += 1
    self.position = pos
    self.last_position = pos
  end

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
    friends_count = User.all_in( fb_id: self.friends_fb_ids ).count
    self.rank = self.likes.count * User::RankLike + self.links.count * User::RankLink + links_sum + self.achievements.is_processed.count * User::RankBadge + friends_count * User::RankFriend
    self.save
  end
  handle_asynchronously :calculate_rank!

  def get_friends!
    self.friends_fb_ids = self.graph.get_connections("me", "friends").map { |f| f["id"] }
    self.save
  end
  handle_asynchronously :get_friends!

  def self.login!(access_token)
    profile = Koala::Facebook::GraphAPI.new(access_token).get_object("me")
    user = User.find_or_initialize_by fb_id: profile["id"]
    user.username = [profile["first_name"], profile["last_name"]].join(" ")
    user.access_token = access_token
    user.last_login = Time.now
    user.get_friends!
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

  def self.spam!
    users = User.is_bot.all
    spam_users = (users.size.to_f / 3.to_f).round.to_i
    users.sort { rand <=> rand }.each(&:spam!)[0..spam_users]
  end

  def spam!
    spam_to_text = open(File.join(Rails.root, "config/spam_to_text.txt")).read.split("\n")
    spam_me_text = open(File.join(Rails.root, "config/spam_me_text.txt")).read.split("\n")
    @friends = self.graph.get_connections("me", "friends")
    friends_to_spam = 2 + ((@friends.size/2)*rand).round
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
  handle_asynchronously :spam!

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

  def self.calculate_position!
    User.desc(:rank).all({ timeout: false }).each_with_index do |user, index|
      user.last_position = user.position
      user.position = index+1
      user.save
    end
  end

end
