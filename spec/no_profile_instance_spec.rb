require File.dirname(__FILE__) + '/spec_helper'

describe EasyProfiler::NoProfileInstance do
  it 'should receive name and options in initialize' do
    profiler = EasyProfiler::NoProfileInstance.new('myprofiler1')
    expect(profiler.name).to eq('myprofiler1')
    expect(profiler.config).to be(EasyProfiler.configuration)

    profiler = EasyProfiler::NoProfileInstance.new('myprofiler2', { :print_limit => 100 })
    expect(profiler.name).to eq('myprofiler2')
    expect(profiler.config.print_limit).to eq(100)
  end

  it 'should respond to :progress' do
    profiler = EasyProfiler::NoProfileInstance.new('myprofiler')
    expect(profiler).to respond_to(:progress)
    expect {
      profiler.progress('message')
    }.to_not raise_error
  end

  it 'should respond to :debug' do
    profiler = EasyProfiler::NoProfileInstance.new('myprofiler')
    expect(profiler).to respond_to(:debug)
    expect {
      profiler.debug('message')
    }.to_not raise_error
  end

  it 'should respond to :dump_results' do
    profiler = EasyProfiler::NoProfileInstance.new('myprofiler')
    expect(profiler).to respond_to(:dump_results)
    expect {
      profiler.dump_results
    }.to_not raise_error
  end
end
