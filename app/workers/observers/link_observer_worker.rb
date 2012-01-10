class LinkObserverWorker < Struct.new(:link)

  def perform
    if link.user && link.user.links.count == 1
      link.user.gain!(Achievement::FirstLink)
    end
  end

end