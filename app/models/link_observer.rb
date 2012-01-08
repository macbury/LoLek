class LinkObserver < Mongoid::Observer
  observe :link

  def after_create(link)
    if link.user && link.user.links.count == 1
      link.user.gain!(Achievement::FirstLink)
    end
  end
end
