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

    profiler.dump_results
  end

  it 'should render nothing when time limit not reached' do
    logger = mock('MockLogger')
    profiler = EasyProfiler::ProfileInstance.new('myprofiler', :logger => logger, :enabled => true, :limit => 20)
    logger.should_not_receive(:info)
    profiler.dump_results
  end

  context 'when live logging is enabled' do
    before :each do
      @logger = mock('MockLogger').as_null_object
      @profiler = EasyProfiler::ProfileInstance.new('myprofiler', :logger => @logger, :enabled => true, :live_logging => true)
    end

    it 'should print header when progress called first time' do
      @logger.should_receive(:info).with(/\[myprofiler\] Benchmark results:/)
      @profiler.progress('progress message')
    end

    it 'should print header when debug called first time' do
      @logger.should_receive(:info).with(/\[myprofiler\] Benchmark results:/)
      @profiler.debug('progress message')
    end

    it 'should not print header in dump_results' do
      @profiler.debug('progress message')
      @logger.should_not_receive(:info).with(/\[myprofiler\] Benchmark results:/)
      @profiler.dump_results
    end

    it 'should print foter in dump_results' do
      @profiler.debug('progress message')
      @logger.should_receive(:info).ordered.with(/\[myprofiler\] results: \d+\.\d+ s/)
      @profiler.dump_results
    end

    it 'should flush logs on every checkpoing if live logging is enabled' do
      @logger.should_receive(:info).with(/\[myprofiler\] Benchmark results:/)
      @logger.should_receive(:info).ordered.with(/\[myprofiler\] progress: \d+\.\d+ s \[progress message\]/)
      @logger.should_receive(:info).ordered.with(/\[myprofiler\] debug: debug message/)
      @profiler.progress('progress message')
      @profiler.debug('debug message')
    end

    it 'should print footer in dump_results' do
      @logger.should_receive(:info).with(/\[myprofiler\] results: \d+\.\d+ s/)
      @profiler.dump_results
    end

    it 'should print header in dump_results if did not already' do
      @logger.should_receive(:info).with(/\[myprofiler\] Benchmark results:/)
      @logger.should_receive(:info).with(/\[myprofiler\] results: \d+\.\d+ s/)
      @profiler.dump_results
    end
  end
end