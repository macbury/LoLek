class LinkObserverWorker
  @queue = Delay::Actions
  def self.perform(link_id)
    link = Link.find(link_id)
    if link.user && link.user.links.count == 1
      link.user.gain!(Achievement::FirstLink)
    end
  end

end