require 'rubygems'
require 'active_record'
require File.join(File.dirname(__FILE__), "../lib/easy_prof")

def mock_profile_start(name, options = {})
  config = EasyProfiler.configuration.merge(options)
  profiler = mock 'MockProfiler', :name => name, :config => config
  EasyProfiler::Profile.send(:class_variable_get, :@@profile_results)[name] = profiler
end