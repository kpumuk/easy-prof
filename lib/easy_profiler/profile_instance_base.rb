module EasyProfiler
  # Base class for profilers.
  class ProfileInstanceBase
    attr_reader :name, :config, :buffer

    @@row_even = true

    # Initializes a new instance of +ProfileInstanceBase+ class.
    #
    # Parameters:
    # * name -- session name.
    # * options -- a +Hash+ of options (see <tt>EasyProfiler::Profile.start</tt> for details).
    def initialize(name, config = nil)
      @name = name
      @config = Configuration.parse(config)

      @start = @progress = Time.now.to_f

      # Initial number of ActiveRecord::Base objects
      if @config.count_ar_instances
        @start_ar_instances = @current_ar_instances = active_record_instances_count
      end

      # Initial amount of memory used
      if @config.count_memory_usage
        @start_memory_usage = @current_memory_usage = process_memory_usage
      end

      # A buffer where all log messeges will be stored till the
      # end of the profiling block. We need this because not every
      # profiling log will be printed (see EasyProf::Configuration.print_limit).
      @buffer = []
    end

    # Sets a profiling checkpoint (block execution time will be printed).
    #
    # Parameters:
    # * message -- a message to associate with a check point.
    #
    def progress(message)
    end

    # Sets a profiling checkpoint without execution time printing.
    #
    # Parameters:
    # * message -- a message to associate with a check point.
    #
    def debug(message)
    end

    # Start a group with a specified name.
    #
    # Parameters:
    # * name -- a name of the group.
    #
    def group(name, options = {}, &block)
      self
    end

    def end_group
    end

    # Dumps results to the log.
    def dump_results
    end

    protected

      # Returns a number of ActiveRecord instances in the Object Space.
      #
      def active_record_instances_count
        count = 0
        ObjectSpace.each_object(::ActiveRecord::Base) { count += 1 }
        count
      end

      # Returns an amount of memory used by current Ruby process.
      #
      def process_memory_usage
        `ps -o rss= -p #{$$}`.to_i
      end

      # Formats an amount of memory to print.
      #
      def format_memory_size(number)
        if number > 10 ** 9
          number = number.to_f / (10 ** 9)
          suffix = 'G'
        elsif number > 10 ** 6
          number = number.to_f / (10 ** 6)
          suffix = 'M'
        elsif number > 10 ** 3
          number = number.to_f / (10 ** 3)
          suffix = 'K'
        else
          suffix = 'B'
        end
        "%.2f#{suffix}" % number
      end
  end
end
