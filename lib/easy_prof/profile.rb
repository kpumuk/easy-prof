module EasyProfiler
  # Contains global profiling parameters and methods to start and
  # stop profiling.
  class Profile
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
    # * <tt>:colorize_logging</tt> -- indicating whether profiling log lines should be colorized.
    # * <tt>:live_logging</tt> -- indicating whether profiler should flush logs on every checkpoint.
    #
    # Returns:
    # * an instance of profiler (descendant of the <tt>EasyProfiler::ProfileInstanceBase</tt> class).
    def self.start(name, config = nil)
      if @@profile_results[name]
        raise ArgumentError.new("EasyProfiler::Profile.start() collision! '#{name}' is already started.")
      end

      config = Configuration.parse(config)

      klass = config.enabled? ? ProfileInstance : NoProfileInstance
      instance = klass.new(name, config)

      @@profile_results[name] = instance

      # Disable garbage collector to get more precise results
      GC.disable if instance.config.disable_gc?

      instance
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
      GC.enable if instance.config.disable_gc?
    end

    def self.reset!
      @@profile_results = {}
    end
  end
end
