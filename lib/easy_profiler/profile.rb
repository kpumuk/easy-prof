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
    
    def self.logger
      @logger
    end

    def self.logger=(value)
      @logger = value
    end

    @@enable_profiling = false
    @@print_limit      = 0.01
    @@logger           = nil
    @@profile_results  = {}
  
    def self.start(name, options = {})
      if @@profile_results[name]
        raise ArgumentError.new("EasyProfiler::Profile.start() collision! '#{name}' is already started.")
      end

      options[:enabled] = self.enable_profiling if options[:enabled].nil?
      options[:limit]   = self.print_limit      if options[:limit].nil?
      options[:logger]  = self.logger           if options[:logger].nil?
      
      klass = options[:enabled] ? ProfileInstance : NoProfileInstance
      instance = klass.new(name, options)
    
      @@profile_results[name] = instance
    end
  
    def self.stop(name)
      instance = @@profile_results.delete(name)
      unless instance
        raise ArgumentError.new("EasyProfiler::Profile.stop() error! '#{name}' is not started yet.")
      end
    
      instance.dump_results
    end
  end
end