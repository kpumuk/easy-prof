module EasyProfiler
  class Profile
    def self.enable_profiling
      @@enable_profiling
    end
    
    def self.enable_profiling=(value)
      @@enable_profiling = value
    end

    def self.print_limit
      @@print_limit
    end

    def self.print_limit=(value)
      @@print_limit = value.to_f
    end

    @@enable_profiling = false
    @@print_limit      = 0.01
    @@profile_results  = {}
  
    def self.start(name, options = {})
      if @@profile_results[name]
        raise ArgumentError.new("EasyProfiler::Profile.start() collision! '#{name}' is already started.")
      end

      options[:enabled] ||= self.enable_profiling
      options[:limit]   ||= self.print_limit
      
      klass = options[:enabled] ? ProfileInstance : NoProfileInstance
      instance = klass.new(name, options)
    
      @@profile_results[name] = instance
    end
  
    def self.stop(name)
      instance = @@profile_results.delete(name)
      unless instance
        raise ArgumentError.new("EasyProfiler::Profile.stop() error! '#{name}' is not started yet.")
      end
   
      return unless instance.options[:enabled]
    
      total = instance.total
    
      if total > instance.options[:limit]
        instance.buffer_checkpoint("results: %0.4f seconds" % total)
        instance.dump_results
      end
    end
  end
end