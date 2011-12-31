class User
  include Mongoid::Document
  field :username, :type => String
  field :access_token, :type => String
  field :fb_id, :type => Integer
  field :bot, :type => Boolean
  
  has_many :links, :dependent => :destroy
  
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
end
