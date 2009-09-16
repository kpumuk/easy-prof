module EasyProfiler
  module ActionControllerExtensions
    def self.included(base) #:nodoc:
      base.send :include, InstanceMethods

      base.class_eval do
        after_filter :dump_firebug_profile
      end
    end
    
    module InstanceMethods 
      # Exposes firebug variable where logs can be submitted.
      #
      #   class UserController < ApplicationController
      #     def index
      #       firebug.debug 'Why I can be easily debugging with this thing!'
      #     end
      #   end
      def firebug_logger
        @_firebug_logger ||= FirebugLogger.new
      end
      
      def dump_firebug_profile
        return if firebug_logger.logs.empty?

        logs = firebug_logger.logs.collect do |message|
          # We have to add any escape characters
          "console.info('#{self.class.helpers.escape_javascript(message)}');"
        end.join("\n")

        response.body << self.class.helpers.javascript_tag(logs)
      end
    end
  end
end