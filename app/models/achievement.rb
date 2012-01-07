require "badge"
class Achievement
  include Mongoid::Document
  include Mongoid::Timestamps

  field :type, type: String, default: nil
  field :readed, type: Boolean, default: false
  belongs_to :user

  First100Users = :register

  def build_image
    tmp = File.join(Rails.root, "public", "badges")
    Dir.mkdir(tmp) rescue nil 
    path = File.join(tmp, filename)
    badge = Badge.new(name, description, self.user.fb_id)
    badge.image.write(path)
    badge.image
  end

  def filename
    "#{self.id}.png"
  end

  def name
    I18n.t("achievements.#{self.type}.name")
  end

  def description
    I18n.t("achievements.#{self.type}.description")
  end

end