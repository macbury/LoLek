require "open-uri"
require File.join(Rails.root, "lib/render_text")

class CiekawostkiWorker < BaseWorker
  @queue = Delay::Import
  
  def perform
    tmp_path = File.join(Rails.root, "tmp", "cites")
    Dir.mkdir(tmp_path) rescue nil

    (10+(50*rand)).to_i.times do
      puts "Opening news"
      begin
        cie = JSON.parse(open("http://cziki.pl/?format=json").read)
      rescue Exception => e
        puts e.to_s
        next
      end
      text = cie["content"]
      puts text
      Delayed::Job.enqueue CiteRenderWorker.new(text), priority: Delay::ImportPipline
    end
    
  end
  
end
