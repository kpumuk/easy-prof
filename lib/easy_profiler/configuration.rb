module EasyProfiler
  class Configuration
    # Value indicating whether profiling is globally enabled.
    attr_reader :enable_profiling
    
    # Minimum time period which should be reached to dump
    # profile to the log.
    attr_reader :print_limit

    # Value indicating whether profiler should log an
    # approximate number of instantiated ActiveRecord objects.
    attr_reader :count_ar_instances

    # Value indicating whether profiler should log an
    # approximate amount of memory used.
    attr_reader :count_memory_usage

    # Accepts a logger conforming to the interface of Log4r or the
    # default Ruby 1.8+ Logger class, which is then passed
    # on to any profiler instance made.
    attr_writer :logger

    attr_reader :colorize_logging

    # Value indicating whether profiler should flush
    # logs on every checkpoint.
    attr_reader :live_logging

    def initialize
      @enable_profiling   = false
      @print_limit        = 0.01
      @count_ar_instances = false
      @count_memory_usage = false
      @logger             = nil
      @colorize_logging   = true
      @live_logging       = false
    end
    
    # Sets a value indicating whether profiling is globally enabled.
    def enable_profiling=(value)
      @enable_profiling = !!value
    end

    # Sets a minimum time period which should be reached to dump
    # profile to the log.
    def print_limit=(value)
      @print_limit = FalseClass === value ? false : value.to_f
    end

    # Sets a value indicating whether profiler should log an
    # approximate number of instantiated ActiveRecord objects.
    def count_ar_instances=(value)
      @count_ar_instances = !!value
    end

    # Sets a value indicating whether profiler should log an
    # approximate amount of memory used.
    # 
    # @param Boolean value
    #   identifies whether memory profiling should be enabled.
    # 
    def count_memory_usage=(value)
      @count_memory_usage = !!value
    end

    def colorize_logging=(value)
      @colorize_logging = !!value
    end

    # Sets a value indicating whether profiler should flush
    # logs on every checkpoint.
    # 
    def live_logging=(value)
      @live_logging = !!value
    end

    # Gets a logger instance.
    #
    # When profiler is started inside Rails application,
    # creates a "log/profile.log" files where all profile
    # logs will be places. In regular scripts dumps
    # information directly to STDOUT. You can use
    # <tt>EasyProfiler.configuration.logger</tt> to set another
    # logger.
    # 
    def logger
      unless @logger
        @logger = if Object.const_defined?(:Rails)
          Logger.new(File.join(Rails.root, 'log', 'profile.log'))
        else
          Logger.new($stdout)
        end
      end
      @logger
    end

    def merge(options = {})
      config = self.dup
      config.enable_profiling   = options[:enabled]            if options.has_key?(:enabled)
      config.enable_profiling   = options[:enable_profiling]   if options.has_key?(:enable_profiling)
      config.print_limit        = options[:limit]              if options.has_key?(:limit)
      config.print_limit        = options[:print_limit]        if options.has_key?(:print_limit)
      config.count_ar_instances = options[:count_ar_instances] if options.has_key?(:count_ar_instances)
      config.count_memory_usage = options[:count_memory_usage] if options.has_key?(:count_memory_usage)
      config.logger             = options[:logger]             if options.has_key?(:logger)
      config.colorize_logging   = options[:colorize_logging]   if options.has_key?(:colorize_logging)
      config.live_logging       = options[:live_logging]       if options.has_key?(:live_logging)
      
      config
    end
    
    def disable_gc?
      count_ar_instances or count_memory_usage
    end
    
    def enabled?
      enable_profiling
    end
  end
end