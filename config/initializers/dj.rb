module Delay
  Observer = -1
  Like = -4
  Badge = -2
  UserRank = -3
  UserFriend = -5

  ImportPipline = 10
end

Resque::Server.use(Rack::Auth::Basic) do |username, password|
  username == App::Config["admin"]["user"]
  password == App::Config["admin"]["password"]
end

module Resque
  module AsyncHandling
    # To disable (in config.after_initialize):
    # Resque::AsyncHandling.enabled = false
    mattr_accessor :enabled
    self.enabled = true
    
    def handle_asynchronously(original_method, params = { })
      if enabled
        now_method = "#{ original_method }_now"
        later_method = "#{ original_method }_later"

        metaclass = class << self; self; end
      
        metaclass.send(:define_method, later_method) do |*args|
          unless params[:when].present?
            Resque.enqueue "#{ params[:in].to_s.singularize.classify }Job".constantize, self.to_s, now_method, *args
          else
            Resque.enqueue_at params[:when].call, "#{ params[:in].to_s.singularize.classify }Job".constantize, self.to_s, now_method, *args
          end
        end

        metaclass.send :alias_method, now_method, original_method
        metaclass.send :alias_method, original_method, later_method
      end
    end
    
    class AsyncJob
      def self.perform(the_class_name, the_method, *args)
        the_class = the_class_name.constantize
        the_class.send the_method, *args
      end
    end
  end
end