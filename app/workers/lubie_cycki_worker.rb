class LubieCyckiWorker < Struct.new(:nil)
  Url = "http://lubiecycki.tumblr.com/"
  
  def perform
    url = URI.parse(LubieCyckiWorker::Url)
  end
  
end
