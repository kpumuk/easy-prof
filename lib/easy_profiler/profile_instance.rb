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
      buffer_checkpoint("progress: %0.4f s [#{message}]" % progress)
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
  
      if false === @options[:limit] || t > @options[:limit].to_f
        profile_logger.info("[#{@name}] Benchmark results:")
        @buffer.each do |message|
          profile_logger.info("[#{@name}] #{message}")
        end
        profile_logger.info("[#{@name}] results: %0.4f s" % t)
      end
    end
  
    private
  
      # Gets a total profiling time.
      def total
        Time.now.to_f - @start
      end
  
      # Buffers a profiling checkpoint.
      def buffer_checkpoint(message)
        @buffer << message
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