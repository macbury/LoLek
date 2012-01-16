class RefreshWorker < BaseWorker
  @queue = Delay::Import
  def perform
    Video.refresh_channel
  end
end