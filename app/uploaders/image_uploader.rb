# encoding: utf-8
class ImageUploader < CarrierWave::Uploader::Base
  include ::CarrierWave::Backgrounder::DelayStorage
  # Include RMagick or ImageScience support:
  include CarrierWave::RMagick
  # include CarrierWave::ImageScience
  permissions 0777

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :s3

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "bucket/#{mounted_as}/#{model.id}"
  end

  version :thumb, :if => :not_gif? do
    process :resize_to_limit => [636, 8000]
    process :watermark
  end  

  version :facebook, :if => :not_gif? do
    process :resize_to_fill => [60, 60]
  end  
  
  process :mark_as_processed
  
  def not_gif?(new_file)
    !(File.extname(new_file.path) =~ /gif/i)
  end
  
  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  #process :scale => [200, 300]
  #
  
  def mark_as_processed
    model.processed!
  end
  
  def watermark
    manipulate! do |img|
      white_bg = Magick::Image.new(img.columns, img.rows) do
        self.background_color = '#444'
      end
      
      img = white_bg.composite(img, 0, 0, Magick::OverCompositeOp)
      
      mark = Magick::Image.new(img.columns, 20) do
        self.background_color = 'none'
      end
      gc = Magick::Draw.new
      gc.annotate(mark, 0, 0, 0, 0, "LoLek.pl") do
        self.gravity = Magick::WestGravity
        self.pointsize = 16
        self.fill = "white"
        self.stroke = "transparent"
        self.font_family = "Helvetica"
      end
      
      img = img.watermark(mark, 0.80, 0, Magick::SouthGravity)
    end
  end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :scale => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    ["jpg", "jpeg", "png", "gif"]
  end

  # Override the filename of the uploaded files:
  # def filename
  #   "something.jpg" if original_filename
  # end
end
