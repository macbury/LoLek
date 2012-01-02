# encoding: utf-8
require 'RMagick'

class TextImage
  include Magick
  
  def initialize(text, width=700, height=460, padding=10)
    image = render_cropped_text(text, 700, 460) do |img|
      img.fill = "#ffffff"
      img.background_color = "transparent"
      img.pointsize = 18
    end
    
    color = Image.new(720, image.rows + 20) do
      self.background_color = "#000000"
    end
    
    @image = color.composite(image, CenterGravity, OverCompositeOp)
  end
  
  def save(filename)
    @image.write filename
  end

  def render_cropped_text(caption_text, width_constraint, height_constraint, &block)
      image = render_text(caption_text, width_constraint, &block)
      if height_constraint < image.rows
          percent = height_constraint.to_f / image.rows.to_f
          end_index = (caption_text.size * percent).to_i  # takes a leap into cropping
          image = render_text(caption_text[0..end_index] + "...", width_constraint, &block)
          while height_constraint < image.rows && end_index > 0 # reduce in big chunks until within range
              end_index -= 80
              image = render_text(caption_text[0..end_index] + "...", width_constraint, &block)
          end
          while height_constraint > image.rows                  # lengthen in smaller steps until exceed
              end_index += 10
              image = render_text(caption_text[0..end_index] + "...", width_constraint, &block)
          end
          while height_constraint < image.rows && end_index > 0 # reduce in baby steps until fit
              end_index -= 1
              image = render_text(caption_text[0..end_index] + "...", width_constraint, &block)
          end
      end
      image
  end

  def render_text(caption_text, width_constraint, &block)
      Magick::Image.read("caption:#{caption_text.to_s}") {
          # this wraps the text to fixed width
          self.size = width_constraint
          # other optional settings
          block.call(self) if block_given?
      }.first
  end

end

some_text = "Gdyby kózka, kwiecień plecień, to by ślimak, kocham Cię"

#http://www.statusiki.pl/rss_descs.xml
text = TextImage.new(some_text)
text.save("test.gif")
