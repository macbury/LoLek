module UsersHelper

  def position_image(user)
    if user.last_position == user.position
      image_tag "blank_badge_blue.png"
    elsif user.position > user.last_position
      image_tag "stock_index_down.png"
    else
      image_tag "stock_index_up.png"
    end
  end

end
