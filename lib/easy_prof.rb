require 'logger'

module EasyProfiler
  autoload :Configuration,              'easy_profiler/configuration'
  autoload :Profile,                    'easy_profiler/profile'
  autoload :ProfileInstanceBase,        'easy_profiler/profile_instance_base'
  autoload :ProfileInstance,            'easy_profiler/profile_instance'
  autoload :NoProfileInstance,          'easy_profiler/no_profile_instance'
  autoload :FirebugLogger,              'easy_profiler/firebug_logger'
  autoload :ActionControllerExtensions, 'easy_profiler/action_controller_extensions'

  module ClassMethods
    def configure(force = false)
      yield configuration(force)
    end

    def configuration(force = false)
      if !@configuration || force
        @configuration = Configuration.new
      end
      @configuration
    end
    alias :config :configuration
  end
  extend ClassMethods
end

if Object.const_defined?(:ActionController)
  ActionController::Base.send(:include, EasyProfiler::ActionControllerExtensions)
end

module Kernel
  # Wraps code block into the profiling session.
  #
  # See the <tt>EasyProfiler::Profile.start</tt> method for
  # parameters description.
  #
  # Example:
  #   easy_profiler('sleep', :enabled => true) do |p|
  #     sleep 1
  #     p.progress('sleep 1')
  #     p.debug('checkpoint reached')
  #     sleep 2
  #     p.progress('sleep 2')
  #   end
  def easy_profiler(name, options = {})
    profiler = EasyProfiler::Profile.start(name, options)
    yield profiler
  ensure
    EasyProfiler::Profile.stop(name) if profiler
  end
end
