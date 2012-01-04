class Like
  include Mongoid::Document
  field :user_id, :type => Integer
  field :link_id, :type => Integer

  belongs_to :user
  belongs_to :link
end
