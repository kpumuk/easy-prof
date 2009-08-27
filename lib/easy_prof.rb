module EasyProfiler
end

base_dir = File.dirname(__FILE__)
require "#{base_dir}/easy_profiler/profile"
require "#{base_dir}/easy_profiler/profile_instance_base"
require "#{base_dir}/easy_profiler/profile_instance"
require "#{base_dir}/easy_profiler/no_profile_instance"

module Kernel
  def easy_profiler(name, options = {})
    yield EasyProfiler::Profile.start(name, options)
  ensure
    EasyProfiler::Profile.stop(name)
  end
end
