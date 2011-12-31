class Image < Link
  field :file, type: String
  field :file_processing, type: Boolean, default: true
  
  field :description, type: String
  
  mount_uploader :file, ImageUploader
  process_in_background :file
  
  validates_integrity_of :file
  validates_processing_of :file
  validates :file, :presence => true
  
  def check_url?
    url.present?
  end
  
  def processing?
    !processed
  end
  
  def url=(new_url)
    Rails.logger.debug "New url: #{new_url}"
    self.remote_file_url = new_url
    write_attribute :url, new_url
  end
end