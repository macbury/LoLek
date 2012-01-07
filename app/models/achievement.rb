class Achievement
  include Mongoid::Document
  include Mongoid::Timestamps

  field :type, type: String, default: nil
  field :readed, type: Boolean, default: false
  embedded_in :user

  def name
    throw "this is base"
  end

  def description
    throw "this is base"
  end
end