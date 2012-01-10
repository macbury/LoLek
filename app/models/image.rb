class Image < Link
  field :file, type: String
  field :file_processing, type: Boolean, default: true
  
  field :description, type: String
  field :width, type: Integer
  field :height, type: Integer

  mount_uploader :file, ImageUploader
  
  process_in_background :file
  
  validates_integrity_of :file
  validates_processing_of :file
  validates :file, :presence => true
  
  attr_accessor :skip_extension_check
  
  def check_url?
    url.present?
  end
  
  def processing?
    !processed
  end
  
  def gif?
    (File.extname(self.file.path) =~ /.gif/i) rescue false
  end
  
  def url=(new_url)
    Rails.logger.debug "New url: #{new_url}"
    self.remote_file_url = new_url
    write_attribute :url, new_url
  end

  def seo_description
    self.description
  end

  def to_opengraph
    super.merge({ image: File.join(App::Config["url"], self.file.facebook.url) })
  end
end