class BadgesController < ApplicationController
  respond_to :png

  def show
    @badge = Achievement.find(params[:id])
    send_data @badge.build_image.to_blob
  end

end
