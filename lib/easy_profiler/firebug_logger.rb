module EasyProfiler
  # A logger used to output logs to the Firebug console.
  #
  # Based on http://rails.aizatto.com/category/plugins/firebug-logger/
  class FirebugLogger
    attr_accessor :logs
    
    def initialize #:nodoc:
      @logs = []
    end

    # Clear the logs.
    def clear
      @logs = []
    end

    # Adds a line to the log.
    #
    # == arguments
    # * +message+ -- log message to be logged
    # * +block+  -- optional. Return value of the block will be the message that will be logged.
    def info(message = nil)
      message = yield if message.nil? && block_given?
      @logs << message
    end
  end
end