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

  def self.build_image!(name)
    tmp = File.join(Rails.root, "public", "badges")
    Dir.mkdir(tmp) rescue nil 
    path = File.join(tmp, "#{name.to_s}.png")
    return if Rails.env == "development" && File.exists?(path)
    badge = Badge.new(name, description)
    badge.image.write(path)
  end

  def filename
    "#{self.type}.png"
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

  def self.list
    Achievement.constants(false).map { |c| Achievement.const_get(c) }
  end

  def self.build!
    I18n.t("achievements").each do |key, val|
      Achievement.const_set key.to_s.camelize.to_sym, key.to_sym
      Achievement.build_image!(key)
    end
  end
end

Achievement.build!