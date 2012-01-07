class Achievement
  include Mongoid::Document
  include Mongoid::Timestamps

  field :type, type: String, default: nil
  field :readed, type: Boolean, default: false
  embedded_in :user

  First100Users = :register

  def name
    I18n.t("achievements.#{self.type}.name")
  end

  def description
    I18n.t("achievements.#{self.type}.description")
  end

end