require File.join(File.dirname(__FILE__), "../lib/easy_prof")

def mock_profile_start(name, options = {})
  options[:enabled] = EasyProfiler::Profile.enable_profiling if options[:enabled].nil?
  options[:limit]   = EasyProfiler::Profile.print_limit      if options[:limit].nil?
  profiler = mock 'MockProfiler', :name => name, :options => options
  EasyProfiler::Profile.send(:class_variable_get, :@@profile_results)[name] = profiler
end