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
    path = File.join(tmp, "#{name.to_s}.gif")
    return if Rails.env == "development" && File.exists?(path)
    badge = Badge.new($achievements_list[name.to_s]["name"], $achievements_list[name.to_s]["description"])
    badge.image.write(path)
  end

  def filename
    "#{self.type}.gif"
  end

  def name
    $achievements_list[self.type.to_s]["name"]
  end

  def description
    $achievements_list[self.type.to_s]["description"]
  end

  def read!
    self.readed = true
    self.save
  end

  def self.list
    $achievements_list
  end

  def self.build!
    $achievements_list = YAML.load_file(Rails.root.join("config/achievements.yml"))
    $achievements_list.each do |key, val|
      Achievement.const_set key.to_s.camelize.to_sym, key.to_sym
      Achievement.build_image!(key)
    end
  end
end

Achievement.build!
