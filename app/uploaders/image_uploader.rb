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
    "bucket/#{model.store_token[0..1]}/#{model.store_token[2..3]}"
  end

  version :thumb, :if => :not_gif? do
    process :resize_to_limit => [720, 18_000]
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
    logo = Magick::Image.read(File.join(Rails.root, "app/assets/images/watermark.png")).first
      
 
    manipulate! do |img|
      black_bg = Magick::Image.new(img.columns, img.rows+32) do
        self.background_color = '#fff'
      end
      
      img = black_bg.composite(img, 0, 0, Magick::OverCompositeOp)
      img = img.composite(logo, Magick::SouthEastGravity, Magick::OverCompositeOp)
    end
  end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :scale => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    model.skip_extension_check ? nil : %w(jpg jpeg gif png)
  end

  def filename
    @name ||= "#{model.store_token}.#{file.extension}" if original_filename.present?
  end
end
