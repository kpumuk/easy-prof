module EasyProfiler
  # Contains global profiling parameters and methods to start and
  # stop profiling.
  class Profile
    # Gets a value indicating whether profiling is globally enabled.
    def self.enable_profiling
      @@enable_profiling
    end
    
    # Sets a value indicating whether profiling is globally enabled.
    def self.enable_profiling=(value)
      @@enable_profiling = value
    end

    # Gets a minimum time period which should be reached to dump profile to the log.
    def self.print_limit
      @@print_limit
    end

    # Sets a minimum time period which should be reached to dump profile to the log.
    def self.print_limit=(value)
      @@print_limit = value.to_f
    end
    
    # Gets a logger.
    def self.logger
      @logger
    end

    # Sets a logger.
    def self.logger=(value)
      @logger = value
    end

    @@enable_profiling = false
    @@print_limit      = 0.01
    @@logger           = nil
    @@profile_results  = {}
  
    # Starts a profiling session.
    #
    # Parameters:
    # * +name+ -- session name.
    # * +options+ -- a +Hash+ of options.
    #
    # Possible options:
    # * <tt>:enabled</tt> -- value indicating whether profiling is enabled.
    # * <tt>:limit</tt> -- minimum time period which should be reached to print profiling log.
    # * <tt>:logger</tt> -- a +Logger+ instance.
    #
    # Returns:
    # * an instance of profiler (descendant of the <tt>EasyProfiler::ProfileInstanceBase</tt> class).
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

    # Finishes a profiling session and dumps results to the log.
    #
    # Parameters:
    # * +name+ -- session name, used in +start+ method.
    def self.stop(name)
      instance = @@profile_results.delete(name)
      unless instance
        raise ArgumentError.new("EasyProfiler::Profile.stop() error! '#{name}' is not started yet.")
      end
    
      instance.dump_results
    end
  end
end