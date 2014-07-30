require File.dirname(__FILE__) + '/spec_helper'

describe EasyProfiler::Profile do
  after :each do
    EasyProfiler.configure do |config|
      config.enable_profiling   = false
      config.print_limit        = 0.01
      config.count_ar_instances = false
      config.count_memory_usage = false
      config.logger             = nil
      config.colorize_logging   = false
      config.live_logging       = false
    end
    EasyProfiler::Profile.reset!
  end

  context '.start' do
    it 'should pass name to profile instance' do
      expect(EasyProfiler::Profile.start('myprofiler').name).to eq('myprofiler')
    end

    it 'should pass options to profile instance' do
      options = { :print_limit => 100 }
      expect(EasyProfiler::Profile.start('myprofiler', options).config.print_limit).to eq(100)
    end

    it 'should not change global configuration options' do
      EasyProfiler.config.print_limit = 10

      profiler = EasyProfiler::Profile.start('myprofiler', :print_limit => 100)
      expect(profiler.config.print_limit).to eq(100)

      expect(EasyProfiler.config.print_limit).to eq(10)
    end

    it 'should create a ProfileInstance object when enabled' do
      options = { :enabled => true }
      expect(EasyProfiler::Profile.start('myprofiler', options).class).to eq(EasyProfiler::ProfileInstance)
    end

    it 'should create a NoProfileInstance object when disabled' do
      options = { :enabled => false }
      expect(EasyProfiler::Profile.start('myprofiler', options).class).to eq(EasyProfiler::NoProfileInstance)
    end

    it 'should raise an error when two profilers with the same name started' do
      EasyProfiler::Profile.start('myprofiler')
      expect {
        EasyProfiler::Profile.start('myprofiler')
      }.to raise_error(ArgumentError)
    end

    it 'should use global :enabled value' do
      expect(EasyProfiler::Profile.start('myprofiler1').config.enable_profiling).to be(false)
      EasyProfiler.config.enable_profiling = true
      expect(EasyProfiler::Profile.start('myprofiler2').config.enable_profiling).to be(true)
    end

    it 'should use global :limit value' do
      expect(EasyProfiler::Profile.start('myprofiler1').config.print_limit).to eq(0.01)
      EasyProfiler.config.print_limit = 10
      expect(EasyProfiler::Profile.start('myprofiler2').config.print_limit).to eq(10.0)
    end

    it 'should use global :count_ar_instances value' do
      expect(EasyProfiler::Profile.start('myprofiler1').config.count_ar_instances).to be(false)
      EasyProfiler.config.count_ar_instances = true
      expect(EasyProfiler::Profile.start('myprofiler2').config.count_ar_instances).to be(true)
    end

    it 'should use global :count_memory_usage value' do
      expect(EasyProfiler::Profile.start('myprofiler1').config.count_memory_usage).to be(false)
      EasyProfiler.config.count_memory_usage = true
      expect(EasyProfiler::Profile.start('myprofiler2').config.count_memory_usage).to be(true)
    end

    it 'should use global :logger value' do
      logger = double('MockLogger')
      EasyProfiler.config.logger = logger
      expect(EasyProfiler::Profile.start('myprofiler2').config.logger).to be(logger)
    end

    it 'should use global :live_logging value' do
      expect(EasyProfiler::Profile.start('myprofiler1').config.live_logging).to be(false)
      EasyProfiler.config.live_logging = true
      expect(EasyProfiler::Profile.start('myprofiler2').config.live_logging).to be(true)
    end

    it 'should disable garbage collector when needed' do
      options = { :enabled => true, :count_ar_instances => true }
      expect(GC).to receive(:disable)
      EasyProfiler::Profile.start('myprofiler1', options)

      options = { :enabled => true, :count_memory_usage => true }
      expect(GC).to receive(:disable)
      EasyProfiler::Profile.start('myprofiler2', options)
    end
  end

  context '.stop' do
    it 'should raise an error when profiler is not started' do
      expect {
        EasyProfiler::Profile.stop('myprofiler')
      }.to raise_error(ArgumentError)
    end

    it 'should call dump_results method on profiler' do
      profiler = mock_profile_start('myprofiler', :enabled => true)
      expect(profiler).to receive(:dump_results)
      EasyProfiler::Profile.stop('myprofiler')
    end

    it 'should enable back garbage collector when needed' do
      profiler = mock_profile_start('myprofiler1', :enabled => true, :count_ar_instances => true)
      allow(profiler).to receive(:dump_results)
      expect(GC).to receive(:enable)
      EasyProfiler::Profile.stop('myprofiler1')

      profiler = mock_profile_start('myprofiler2', :enabled => true, :count_memory_usage => true)
      allow(profiler).to receive(:dump_results)
      expect(GC).to receive(:enable)
      EasyProfiler::Profile.stop('myprofiler2')
    end
  end
end
