class LikeObserverWorker < Struct.new(:like)

  def perform
    if Like.where( :created_at.gt => Time.now.at_beginning_of_day ).count == 1
      like.user.gain!(Achievement::FirstDayLike)
    end
  end

end