module EasyProfiler
  # Class used when profiling is disabled.
  class ProfileInstance < ProfileInstanceBase
    # Sets a profiling checkpoint (block execution time will be printed).
    #
    # Parameters:
    # * message -- a message to associate with a check point.
    def progress(message)
      progress = (now = Time.now.to_f) - @progress
      @progress = now

      ar_instances_count = if @options[:count_ar_instances]
        ar_instances_delta = (ar_instances = active_record_instances_count) - @current_ar_instances
        @current_ar_instances = ar_instances
        ", #{ar_instances_delta} AR objects"
      end

      memory_usage_value = if @options[:count_memory_usage]
        memory_usage_delta = (memory_usage = process_memory_usage) - @current_memory_usage
        @current_memory_usage = memory_usage
        ", #{format_memory_size(total_memory_usage)}"
      end

      buffer_checkpoint("progress: %0.4f s#{ar_instances_count}#{memory_usage_value} [#{message}]" % progress)
    end

    # Sets a profiling checkpoint without execution time printing.
    #
    # Parameters:
    # * message -- a message to associate with a check point.
    def debug(message)
      @progress = Time.now.to_f
      buffer_checkpoint("debug: #{message}")
    end

    # Dumps results to the log.
    def dump_results
      t = total

      if options[:live_logging] || false === @options[:limit] || t > @options[:limit].to_f
        log_header(true)
        @buffer.each { |message| log_line(message) }
        log_footer(t)
      end
    end

    private

      # Gets a total profiling time.
      def total
        Time.now.to_f - @start
      end

      # Gets a number of total AR objects instantiated number.
      def total_ar_instances
        active_record_instances_count - @start_ar_instances
      end

      # Gets a total amount of memory used.
      def total_memory_usage
        process_memory_usage - @start_memory_usage
      end

      # Buffers a profiling checkpoint.
      def buffer_checkpoint(message)
        log_header
        if options[:live_logging]
          log_line(message)
        else
          @buffer << message
        end
      end

      # Write a header to the log.
      def log_header(force = false)
        if (options[:live_logging] && !@header_printed) || (!options[:live_logging] && force)
          log_line("Benchmark results:")
          @header_printed = true
        end
      end

      # Write a footer with summary stats to the log.
      def log_footer(total_time)
        ar_instances_count = if @options[:count_ar_instances]
          ", #{total_ar_instances} AR objects"
        end

        memory_usage_value = if @options[:count_memory_usage]
          ", #{format_memory_size(total_memory_usage)}"
        end

        log_line("results: %0.4f s#{ar_instances_count}#{memory_usage_value}" % total_time)
      end

      # Write a log line.
      def log_line(line)
        profile_logger.info("[#{@name}] #{line}")
      end

      # Gets a logger instance.
      #
      # When profiler is started inside Rails application,
      # creates a "log/profile.log" files where all profile
      # logs will be places. In regular scripts dumps
      # information directly to STDOUT. You can use
      # <tt>EasyProfiler::Profile.logger</tt> to set another
      # logger.
      def profile_logger
        return @profile_logger if @profile_logger

        @profile_logger = if Object.const_defined?(:RAILS_ROOT)
          Logger.new("#{RAILS_ROOT}/log/profile.log")
        else
          Logger.new($stdout)
        end
        @profile_logger
      end
    end
end