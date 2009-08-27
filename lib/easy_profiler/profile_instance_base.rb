module EasyProfiler
  class ProfileInstanceBase
    attr_reader :name, :options
  
    def initialize(name, options = {})
      @name = name
      @options = options
      @start = @progress = Time.now.to_f
      @buffer = []
    end
  
    def progress(message)
    end

    def debug(message)
    end
  end
end