require File.dirname(__FILE__) + '/spec_helper'

describe EasyProfiler::NoProfileInstance do
  it 'should receive name and options in initialize' do
    profiler = EasyProfiler::NoProfileInstance.new('myprofiler1')
    profiler.name.should == 'myprofiler1'
    profiler.config.should be(EasyProfiler.configuration)

    profiler = EasyProfiler::NoProfileInstance.new('myprofiler2', { :print_limit => 100 })
    profiler.name.should == 'myprofiler2'
    profiler.config.print_limit.should == 100
  end

  it 'should respond to :progress' do
    profiler = EasyProfiler::NoProfileInstance.new('myprofiler')
    profiler.should respond_to(:progress)
    lambda {
      profiler.progress('message')
    }.should_not raise_error
  end

  it 'should respond to :debug' do
    profiler = EasyProfiler::NoProfileInstance.new('myprofiler')
    profiler.should respond_to(:debug)
    lambda {
      profiler.debug('message')
    }.should_not raise_error
  end

  it 'should respond to :dump_results' do
    profiler = EasyProfiler::NoProfileInstance.new('myprofiler')
    profiler.should respond_to(:dump_results)
    lambda {
      profiler.dump_results
    }.should_not raise_error
  end
end