class User
  include Mongoid::Document
  Normal = 0
  Moderator = 1
  Admin = 2

  field :username, :type => String
  field :access_token, :type => String
  field :fb_id, :type => Integer
  field :role, type: Integer, default: User::Normal
  has_many :links, :dependent => :destroy
  
  after_create :post_info
  after_save :check_if_admin
  
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
end
