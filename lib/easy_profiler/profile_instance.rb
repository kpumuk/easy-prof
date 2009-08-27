module EasyProfiler
  class ProfileInstance < ProfileInstanceBase
    def progress(message)
      progress = (now = Time.now.to_f) - @progress
      @progress = now
      buffer_checkpoint("progress: %0.4f seconds [#{message}]" % progress)
    end
  
    def debug(message)
      @progress = Time.now.to_f
      buffer_checkpoint("debug: #{message}")
    end
  
    def total
      Time.now.to_f - @start
    end
  
    def buffer_checkpoint(message)
      @buffer << message
    end
  
    def dump_results
      profile_logger.info("[#{@name}] Benchmark results:")
      @buffer.each do |message|
        profile_logger.info("[#{@name}] #{message}")
      end
    end

    def profile_logger
      root = Object.const_defined?(:RAILS_ROOT) ? "#{RAILS_ROOT}/log" : File.dirname(__FILE__)
      @profile_logger ||= Logger.new(root + '/profile.log')
    end
  end
end