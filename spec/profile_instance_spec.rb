require File.dirname(__FILE__) + '/spec_helper'

describe EasyProfiler::ProfileInstance do
  it 'should receive name and options in initialize' do
    profiler = EasyProfiler::ProfileInstance.new('myprofiler1')
    profiler.name.should == 'myprofiler1'
    profiler.options.should == {}

    profiler = EasyProfiler::ProfileInstance.new('myprofiler2', { :a => 1 })
    profiler.name.should == 'myprofiler2'
    profiler.options.should == { :a => 1 }
  end

  it 'should respond to :progress' do
    profiler = EasyProfiler::ProfileInstance.new('myprofiler')
    profiler.should respond_to(:progress)
    lambda {
      profiler.progress('message')
      buffer = profiler.instance_variable_get(:@buffer)
      buffer.should have(1).item
      buffer.first.should match(/progress: \d+\.\d+ s \[message\]/)
    }.should_not raise_error
  end

  it 'should respond to :debug' do
    profiler = EasyProfiler::ProfileInstance.new('myprofiler')
    profiler.should respond_to(:debug)
    lambda {
      profiler.debug('message')
      buffer = profiler.instance_variable_get(:@buffer)
      buffer.should have(1).item
      buffer.first.should match(/debug: message/)
    }.should_not raise_error
  end

  it 'should respond to :dump_results' do
    logger = mock('MockLogger')
    profiler = EasyProfiler::ProfileInstance.new('myprofiler', :logger => logger, :enabled => true, :limit => false)
    profiler.should respond_to(:dump_results)

    profiler.progress('progress message')
    profiler.debug('debug message')

    logger.should_receive(:info).ordered.with(/\[myprofiler\] Benchmark results:/)
    logger.should_receive(:info).ordered.with(/\[myprofiler\] progress: \d+\.\d+ s \[progress message\]/)
    logger.should_receive(:info).ordered.with(/\[myprofiler\] debug: debug message/)
    logger.should_receive(:info).ordered.with(/\[myprofiler\] results: \d+\.\d+ s/)

    lambda {
      profiler.dump_results
    }.should_not raise_error
  end

  it 'should render nothing when time limit not reached' do
    logger = mock('MockLogger')
    profiler = EasyProfiler::ProfileInstance.new('myprofiler', :logger => logger, :enabled => true, :limit => 20)
    logger.should_not_receive(:info)
    profiler.dump_results
  end
end