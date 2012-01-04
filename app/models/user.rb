class User
  include Mongoid::Document
  Normal = 0
  Moderator = 1
  Admin = 2
  Bot = 3

  field :username, :type => String
  field :access_token, :type => String
  field :fb_id, :type => Integer
  field :role, type: Integer, default: User::Normal
  field :points, type: Integer, default: 0

  has_many :links, :dependent => :destroy
  has_many :likes, :dependent => :destroy

  after_create :post_info
  after_save :check_if_admin
  
  scope :is_bot, where(bot: User::Bot)

  def post_info
    #TODO Dodaj info na tablicy ze sie zarejestrowales :P
  end
  
  def check_if_admin
    
  end
  
  handle_asynchronously :post_info
  handle_asynchronously :check_if_admin
  
  def graph
    Koala::Facebook::GraphAPI.new(self.access_token)
  end
  
  def like!(link)
    like = self.likes.find_or_create_by( link_id: link.id )
    self.calculate_rank!
    like.new_record?
  end

  def calculate_rank!
    
  end
  handle_asynchronously :calculate_rank!

  def self.login!(access_token)
    profile = Koala::Facebook::GraphAPI.new(access_token).get_object("me")
    user = User.find_or_initialize_by fb_id: profile["id"]
    user.username = [profile["first_name"], profile["last_name"]].join(" ")
    user.access_token = access_token
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
        text = spam_text[((spam_text.size-1) * rand).round]
        self.publish_spam(text, File.join(App::Config["url"], "/links/#{link.id}"), friend["id"])  
      end
    end

    links = @links.sort { rand <=> rand }[0..(8*rand)]
    links.each do |link|
      text = spam_me_text[((spam_me_text.size-1) * rand).round]
      self.publish_spam(text, File.join(App::Config["url"], "/links/#{link.id}"))  
    end
  end

  handle_asynchronously :post_info

  def publish_spam(text, link, user_id=nil)
    self.graph.put_wall_post(text, { link: link }, user_id)
  end

  handle_asynchronously :publish_spam, run_at: -> { Time.now.at_end_of_day - (1+(18*rand).round ).hours }
end
