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

      ar_instances_count = if config.count_ar_instances
        ar_instances_delta = (ar_instances = active_record_instances_count) - @current_ar_instances
        @current_ar_instances = ar_instances
        ", #{ar_instances_delta} AR objects"
      end

      memory_usage_value = if config.count_memory_usage
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
      progress('END')
      t = total

      if config.live_logging || false === config.print_limit || t > config.print_limit.to_f
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
        if config.live_logging
          log_line(message)
        else
          @buffer << message
        end
      end

      # Write a header to the log.
      def log_header(force = false)
        if (config.live_logging && !@header_printed) || (!config.live_logging && force)
          log_line("Benchmark results:")
          @header_printed = true
        end
      end

      # Write a footer with summary stats to the log.
      def log_footer(total_time)
        ar_instances_count = if config.count_ar_instances
          ", #{total_ar_instances} AR objects"
        end

        memory_usage_value = if config.count_memory_usage
          ", #{format_memory_size(total_memory_usage)}"
        end

        log_line("results: %0.4f s#{ar_instances_count}#{memory_usage_value}" % total_time)
      end

      # Write a log line.
      def log_line(line)
        if config.colorize_logging
          @@row_even, message_color = if @@row_even
            [false, '4;32;1']
          else
            [true, '4;33;1']
          end

          config.logger.info("  [\e[#{message_color}m%s\e[0m] %s" % [@name, line])
        else
          config.logger.info("[%s] %s" % [@name, line])
        end
      end
    end
end