class Game < Link
  field :file, type: String
  field :width, type: Integer
  field :height, type: Integer
  
  mount_uploader :file, FlashUploader
  validates :file, :presence => true
end