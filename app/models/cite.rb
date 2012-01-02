class Cite < Link
  field :file, type: String
  field :hash, type: String
  field :text, type: String
  
  mount_uploader :file, CiteUploader
  
  validates :text, :presence => true, :uniqueness => true
  
  def check_url?
    false
  end
end