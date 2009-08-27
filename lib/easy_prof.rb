module EasyProfiler
end

require 'logger'

base_dir = File.dirname(__FILE__)
require "#{base_dir}/easy_profiler/profile"
require "#{base_dir}/easy_profiler/profile_instance_base"
require "#{base_dir}/easy_profiler/profile_instance"
require "#{base_dir}/easy_profiler/no_profile_instance"

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
    yield EasyProfiler::Profile.start(name, options)
  ensure
    EasyProfiler::Profile.stop(name)
  end
end
