class RefreshWorker < Struct.new(:nil)
  def perform
    Video.refresh_channel
  end
end