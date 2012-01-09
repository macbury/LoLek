require "badge"
class Achievement
  include Mongoid::Document
  include Mongoid::Timestamps

  field :type, type: String, default: nil
  field :readed, type: Boolean, default: false
  field :processed, type: Boolean, default: false

  scope :is_processed, where(processed: true)
  scope :unreaded, where(readed: false).is_processed
  belongs_to :user

  First100Users = :register
  FirstDayLike = :first_day_like
  FirstLink = :first_link
  SchoolAccess = :school_access
  BossKey = :boss_key
  
  after_create :build_image

  def build_image
    tmp = File.join(Rails.root, "public", "badges")
    Dir.mkdir(tmp) rescue nil 
    path = File.join(tmp, filename)
    badge = Badge.new(name, description, self.user.fb_id)
    badge.image.write(path)
    self.processed = true
    self.save
  end

  handle_asynchronously :build_image!, priority: Delay::Badge

  def filename
    "#{self.id}.png"
  end

  def name
    I18n.t("achievements.#{self.type}.name")
  end

  def description
    I18n.t("achievements.#{self.type}.description")
  end

  def read!
    self.readed = true
    self.save
  end
end