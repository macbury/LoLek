class LikeObserver < Mongoid::Observer
  observe :like

  def after_create(like)
    if Like.where( :created_at.gt => Time.now.at_beginning_of_day ).count == 1
      like.user.gain!(Achievement::FirstDayLike)
    end
  end
end
