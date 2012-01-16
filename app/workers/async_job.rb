class AsyncJob < BaseWorker
  @queue = :actions
  def self.perform(the_method, serialized_obj, *args)
    puts "=====> #{the_method}"
    obj = YAML.load(serialized_obj)
    obj.send the_method, *args
  end
end