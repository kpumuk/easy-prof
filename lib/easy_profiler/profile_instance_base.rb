module EasyProfiler
  class ProfileInstanceBase
    attr_reader :name, :options
  
    def initialize(name, options = {})
      @name = name
      @options = options
      @profile_logger = @options[:logger]
      @start = @progress = Time.now.to_f
      @buffer = []
    end
  
    def progress(message)
    end

    def debug(message)
    end
    
    def dump_results
    end
  end
end