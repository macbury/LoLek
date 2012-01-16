class LikeObserverWorker
  @queue = Delay::Actions
  def self.perform(like_id)
    like = Like.find(like_id)
    if Like.where( :created_at.gt => Time.now.at_beginning_of_day ).count == 1
      like.user.gain!(Achievement::FirstDayLike)
    end
  end

end