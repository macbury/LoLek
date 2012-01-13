require "open-uri"
require File.join(Rails.root, "lib/render_text")
class BashWorker < BaseWorker
  @queue = Delay::Import
  
  def perform
    cites = open("http://bash.org.pl/text").read.split("%").map { |c| c.split("\n")[1..-1] }.compact
    cites.each do |text|
      if text.nil? || text.empty?
        puts "Skip"
      else
        puts "Cite:"
        text = text[1..-1].join("\n")
        Delayed::Job.enqueue CiteRenderWorker.new(text), priority: Delay::ImportPipline
      end
    end
  end
  
end
