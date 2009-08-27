module EasyProfiler
  class ProfileInstance < ProfileInstanceBase
    def progress(message)
      progress = (now = Time.now.to_f) - @progress
      @progress = now
      buffer_checkpoint("progress: %0.4f s [#{message}]" % progress)
    end
  
    def debug(message)
      @progress = Time.now.to_f
      buffer_checkpoint("debug: #{message}")
    end

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
  
      def total
        Time.now.to_f - @start
      end
  
      def buffer_checkpoint(message)
        @buffer << message
      end

      def profile_logger
        return @profile_logger if defined?(:@profile_logger)
        
        root = Object.const_defined?(:RAILS_ROOT) ? "#{RAILS_ROOT}/log" : File.dirname(__FILE__)
        @profile_logger = Logger.new(root + '/profile.log')
      end
    end
end