module LinksHelper
  
  def nk(opts)
    "new nk_fajne(#{opts.to_json})"
  end
  
  def unread_count
    total = Link.is_published.is_pending.is_newest.count
    if logged_in?
      readed = self.current_user.readed
    else
      readed = cookies[:readed]
      readed ||= 0
    end

    total - readed.to_i
  end

end
