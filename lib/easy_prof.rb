require 'logger'

module EasyProfiler
  autoload :Configuration,              'easy_prof/configuration'
  autoload :Profile,                    'easy_prof/profile'
  autoload :ProfileInstanceBase,        'easy_prof/profile_instance_base'
  autoload :ProfileInstance,            'easy_prof/profile_instance'
  autoload :NoProfileInstance,          'easy_prof/no_profile_instance'
  autoload :FirebugLogger,              'easy_prof/firebug_logger'
  autoload :ActionControllerExtensions, 'easy_prof/action_controller_extensions'

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
