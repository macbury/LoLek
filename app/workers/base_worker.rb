class BaseWorker

  def self.perform(*args)
    new.perform(*args)
  end

  def perform
    throw "define body for base worker"
  end

end