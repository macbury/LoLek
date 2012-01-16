module Resque
  module AsyncHandling
    # To disable (in config.after_initialize):
    # Resque::AsyncHandling.enabled = false
    mattr_accessor :enabled
    self.enabled = true
    module ClassMethods
      def handle_asynchronously(original_method, params = { })
        if enabled
          met, sign = original_method.to_s.sub(/([?!=])$/, ''), $1
          now_method = "#{ met }_now#{sign}"
          later_method = "#{ met }_later#{sign}"
          params[:in] ||= :async
          metaclass = self
        
          metaclass.send(:define_method, later_method) do |*args|
            unless params[:when].present?
              Resque.enqueue "#{ params[:in].to_s.singularize.classify }Job".constantize, now_method, self.to_yaml, *args
            else
              Resque.enqueue_at params[:when].call, "#{ params[:in].to_s.singularize.classify }Job".constantize, now_method, self.to_yaml, *args
            end
          end

          metaclass.send :alias_method, now_method, original_method
          metaclass.send :alias_method, original_method, later_method
        end
      end
    end

    
    class AsyncJob
      @queue = :actions
      def self.perform(the_method, serialized_obj, *args)
        puts "=====> #{the_method}"
        obj = YAML.load(serialized_obj)
        obj.send the_method, *args
      end
    end
  end
end

Object.send(:include, Resque::AsyncHandling)
Module.send(:include, Resque::AsyncHandling::ClassMethods)

module Delayed
  module MessageSending
    def send_later(method, *args)
      Delayed::Job.enqueue Delayed::PerformableMethod.new(self, method.to_sym, args)
    end
    
    module ClassMethods
      def handle_asynchronously(method)
        without_name = "#{method}_without_send_later"
        define_method("#{method}_with_send_later") do |*args|
          send_later(without_name, *args)
        end
        alias_method_chain method, :send_later
      end
    end
  end                               
end

module CarrierWave
  module Uploader
    module Versions
      
      def full_filename(for_file)
        parent_name = super(for_file)
        ext         = File.extname(parent_name)
        base_name   = parent_name.chomp(ext)
        $type_versions ||= {}
        v = version_name
        v ||= "original"
        $type_versions[v] ||= Base64.encode64(v.to_s).strip.gsub(/[^a-z0-9]+/i, "").downcase
        [$type_versions[v], base_name].compact.join('') + ext
      end

      def full_original_filename
        parent_name = super
        ext         = File.extname(parent_name)
        base_name   = parent_name.chomp(ext)
        $type_versions ||= {}
        v = version_name
        v ||= "original"
        $type_versions[v] ||= Base64.encode64(v.to_s).strip.gsub(/[^a-z0-9]+/i, "").downcase
        [$type_versions[v], base_name].compact.join('') + ext
      end
    end
  end
end