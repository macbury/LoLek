module VideosHelper
  def youtube_player(video, width = 1280)
    height = (width * 9/16) + 25
    "<object width='#{width}' height='#{height}'><param name='movie' value='http://www.youtube.com/v/#{video.youtube_id}?version=3&amp;hl=en_US'></param><param name='allowFullScreen' value='true'></param><param name='allowscriptaccess' value='always'></param><embed src='http://www.youtube.com/v/#{video.youtube_id}?version=3&amp;hl=en_US' type='application/x-shockwave-flash' width='#{width}' height='#{height}' allowscriptaccess='always' allowfullscreen='true'></embed></object>".html_safe
  end
end