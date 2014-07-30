require File.dirname(__FILE__) + '/spec_helper'

describe EasyProfiler::ProfileInstance do
  it 'should receive name and options in initialize' do
    profiler = EasyProfiler::ProfileInstance.new('myprofiler1')
    expect(profiler.name).to eq('myprofiler1')
    expect(profiler.config).to be(EasyProfiler.configuration)

    profiler = EasyProfiler::ProfileInstance.new('myprofiler2', :print_limit => 100)
    expect(profiler.name).to eq('myprofiler2')
    expect(profiler.config.print_limit).to eq(100)

    config = EasyProfiler::Configuration.new
    config.print_limit = 100
    profiler = EasyProfiler::ProfileInstance.new('myprofiler3', config)
    expect(profiler.name).to eq('myprofiler3')
    expect(profiler.config).to be(config)
  end

  it 'should not change global configuration options' do
    EasyProfiler.config.print_limit = 10

    profiler = EasyProfiler::ProfileInstance.new('myprofiler1', :print_limit => 100)
    expect(profiler.config.print_limit).to eq(100)

    expect(EasyProfiler.config.print_limit).to eq(10)
  end

  it 'should respond to :progress' do
    profiler = EasyProfiler::ProfileInstance.new('myprofiler')
    expect(profiler).to respond_to(:progress)
    expect {
      profiler.progress('message')
      expect(profiler.buffer.size).to eq(2)
      expect(profiler.buffer[1][0]).to match(/progress: \d+\.\d+ s \[message\]/)
      expect(profiler.buffer[1][1]).to eq('myprofiler')
    }.to_not raise_error
  end

  it 'should respond to :debug' do
    profiler = EasyProfiler::ProfileInstance.new('myprofiler')
    expect(profiler).to respond_to(:debug)
    expect {
      profiler.debug('message')
      expect(profiler.buffer.size).to eq(2)
      expect(profiler.buffer[1][0]).to match(/debug: message/)
      expect(profiler.buffer[1][1]).to eq('myprofiler')
    }.to_not raise_error
  end

  it 'should respond to :dump_results' do
    logger = double('MockLogger')
    profiler = EasyProfiler::ProfileInstance.new('myprofiler', :logger => logger, :enabled => true, :limit => false, :colorize_logging => false)
    expect(profiler).to respond_to(:dump_results)

    profiler.progress('progress message')
    profiler.debug('debug message')

    expect(logger).to receive(:info).ordered.with(/\[myprofiler\] Benchmark results:/)
    expect(logger).to receive(:info).ordered.with(/\[myprofiler\] progress: \d+\.\d+ s \[progress message\]/)
    expect(logger).to receive(:info).ordered.with(/\[myprofiler\] debug: debug message/)
    expect(logger).to receive(:info).ordered.with(/\[myprofiler\] progress: \d+\.\d+ s \[END\]/)
    expect(logger).to receive(:info).ordered.with(/\[myprofiler\] results: \d+\.\d+ s/)

    profiler.dump_results
  end

  it 'should render nothing when time limit not reached' do
    logger = double('MockLogger')
    profiler = EasyProfiler::ProfileInstance.new('myprofiler', :logger => logger, :enabled => true, :limit => 20)
    expect(logger).to_not receive(:info)
    profiler.dump_results
  end

  context 'when live logging is enabled' do
    before :each do
      @logger = double('MockLogger').as_null_object
      @profiler = EasyProfiler::ProfileInstance.new('myprofiler', :logger => @logger, :enabled => true, :live_logging => true, :colorize_logging => false)
    end

    it 'should print header when progress called first time' do
      expect(@logger).to receive(:info).with(/\[myprofiler\] Benchmark results:/)
      @profiler.progress('progress message')
    end

    it 'should print header when debug called first time' do
      expect(@logger).to receive(:info).with(/\[myprofiler\] Benchmark results:/)
      @profiler.debug('progress message')
    end

    it 'should not print header in dump_results' do
      @profiler.debug('progress message')
      expect(@logger).to_not receive(:info).with(/\[myprofiler\] Benchmark results:/)
      @profiler.dump_results
    end

    it 'should print foter in dump_results' do
      @profiler.debug('progress message')
      expect(@logger).to receive(:info).ordered.with(/\[myprofiler\] results: \d+\.\d+ s/)
      @profiler.dump_results
    end

    it 'should flush logs on every checkpoing if live logging is enabled' do
      expect(@logger).to receive(:info).with(/\[myprofiler\] Benchmark results:/)
      expect(@logger).to receive(:info).ordered.with(/\[myprofiler\] progress: \d+\.\d+ s \[progress message\]/)
      expect(@logger).to receive(:info).ordered.with(/\[myprofiler\] debug: debug message/)
      @profiler.progress('progress message')
      @profiler.debug('debug message')
    end

    it 'should print footer in dump_results' do
      expect(@logger).to receive(:info).with(/\[myprofiler\] results: \d+\.\d+ s/)
      @profiler.dump_results
    end

    it 'should print header in dump_results if did not already' do
      expect(@logger).to receive(:info).with(/\[myprofiler\] Benchmark results:/)
      expect(@logger).to receive(:info).with(/\[myprofiler\] results: \d+\.\d+ s/)
      @profiler.dump_results
    end
  end
end
