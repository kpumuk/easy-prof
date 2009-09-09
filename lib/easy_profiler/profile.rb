module EasyProfiler
  # Contains global profiling parameters and methods to start and
  # stop profiling.
  class Profile
    class << self
      # Gets a value indicating whether profiling is globally enabled.
      def enable_profiling
        @@enable_profiling
      end
    
      # Sets a value indicating whether profiling is globally enabled.
      def enable_profiling=(value)
        @@enable_profiling = value
      end

      # Gets a minimum time period which should be reached to dump
      # profile to the log.
      def print_limit
        @@print_limit
      end

      # Sets a minimum time period which should be reached to dump
      # profile to the log.
      def print_limit=(value)
        @@print_limit = value.to_f
      end

      # Gets a value indicating whether profiler should log an
      # approximate number of instantiated ActiveRecord objects.
      def count_ar_instances
        @@count_ar_instances
      end
      
      # Sets a value indicating whether profiler should log an
      # approximate number of instantiated ActiveRecord objects.
      def count_ar_instances=(value)
        @@count_ar_instances = value
      end
      
      # Gets a value indicating whether profiler should log an
      # approximate amount of memory used.
      def count_memory_usage
        @@count_memory_usage
      end
      
      # Sets a value indicating whether profiler should log an
      # approximate amount of memory used.
      def count_memory_usage=(value)
        @@count_memory_usage = value
      end
    
      # Gets a logger.
      def logger
        @logger
      end

      # Sets a logger.
      def logger=(value)
        @logger = value
      end
    end

    @@enable_profiling   = false
    @@print_limit        = 0.01
    @@count_ar_instances = false
    @@count_memory_usage = false
    @@logger             = nil
    @@profile_results    = {}
  
    # Starts a profiling session.
    #
    # Parameters:
    # * +name+ -- session name.
    # * +options+ -- a +Hash+ of options.
    #
    # Possible options:
    # * <tt>:enabled</tt> -- value indicating whether profiling is enabled.
    # * <tt>:limit</tt> -- minimum time period which should be reached to print profiling log.
    # * <tt>:count_ar_instances</tt> —- indicating whether profiler should log an approximate number of instantiated ActiveRecord objects.
    # * <tt>:count_memory_usage</tt> —- indicating whether profiler should log an approximate amount of memory used.
    # * <tt>:logger</tt> -- a +Logger+ instance.
    #
    # Returns:
    # * an instance of profiler (descendant of the <tt>EasyProfiler::ProfileInstanceBase</tt> class).
    def self.start(name, options = {})
      if @@profile_results[name]
        raise ArgumentError.new("EasyProfiler::Profile.start() collision! '#{name}' is already started.")
      end

      options[:enabled]            = self.enable_profiling   if options[:enabled].nil?
      options[:limit]              = self.print_limit        if options[:limit].nil?
      options[:count_ar_instances] = self.count_ar_instances if options[:count_ar_instances].nil?
      options[:count_memory_usage] = self.count_memory_usage if options[:count_memory_usage].nil?
      options[:logger]             = self.logger             if options[:logger].nil?
      
      # Disable garbage collector to get more precise results
      GC.disable if options[:count_ar_instances] or options[:count_memory_usage]
      
      klass = options[:enabled] ? ProfileInstance : NoProfileInstance
      instance = klass.new(name, options)
    
      @@profile_results[name] = instance
    end

    # Finishes a profiling session and dumps results to the log.
    #
    # Parameters:
    # * +name+ -- session name, used in +start+ method.
    def self.stop(name)
      unless instance = @@profile_results.delete(name)
        raise ArgumentError.new("EasyProfiler::Profile.stop() error! '#{name}' is not started yet.")
      end
    
      instance.dump_results

      # Enable garbage collector which has been disabled before
      options = instance.options
      GC.enable if options[:count_ar_instances] or options[:count_memory_usage]
    end
  end
end