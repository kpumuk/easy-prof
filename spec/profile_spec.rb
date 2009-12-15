require File.dirname(__FILE__) + '/spec_helper'

describe EasyProfiler::Profile do
  after :each do
    EasyProfiler::Profile.enable_profiling   = false
    EasyProfiler::Profile.print_limit        = 0.01
    EasyProfiler::Profile.count_ar_instances = false
    EasyProfiler::Profile.count_memory_usage = false
    EasyProfiler::Profile.send :class_variable_set, :@@profile_results, {}
  end
  
  context '.start' do
    it 'should pass name to profile instance' do
      EasyProfiler::Profile.start('myprofiler').name.should == 'myprofiler'
    end

    it 'should pass options to profile instance' do
      options = { :a => 10 }
      EasyProfiler::Profile.start('myprofiler', options).options.should == options
    end

    it 'should create a ProfileInstance object when enabled' do
      options = { :enabled => true }
      EasyProfiler::Profile.start('myprofiler', options).class.should == EasyProfiler::ProfileInstance
    end

    it 'should create a NoProfileInstance object when disabled' do
      options = { :enabled => false }
      EasyProfiler::Profile.start('myprofiler', options).class.should == EasyProfiler::NoProfileInstance
    end

    it 'should raise an error when two profilers with the same name started' do
      EasyProfiler::Profile.start('myprofiler')
      lambda {
        EasyProfiler::Profile.start('myprofiler')
      }.should raise_error(ArgumentError)
    end

    it 'should use global :enabled value' do
      EasyProfiler::Profile.start('myprofiler1').options[:enabled].should be_false
      EasyProfiler::Profile.enable_profiling = true
      EasyProfiler::Profile.start('myprofiler2').options[:enabled].should be_true
    end

    it 'should use global :limit value' do
      EasyProfiler::Profile.start('myprofiler1').options[:limit].should == 0.01
      EasyProfiler::Profile.print_limit = 10
      EasyProfiler::Profile.start('myprofiler2').options[:limit].should == 10.0
    end

    it 'should use global :count_ar_instances value' do
      EasyProfiler::Profile.start('myprofiler1').options[:count_ar_instances].should be_false
      EasyProfiler::Profile.count_ar_instances = true
      EasyProfiler::Profile.start('myprofiler2').options[:count_ar_instances].should be_true
    end

    it 'should use global :count_memory_usage value' do
      EasyProfiler::Profile.start('myprofiler1').options[:count_memory_usage].should be_false
      EasyProfiler::Profile.count_memory_usage = true
      EasyProfiler::Profile.start('myprofiler2').options[:count_memory_usage].should be_true
    end

    it 'should use global :logger value' do
      EasyProfiler::Profile.start('myprofiler1').options[:logger].should be_nil
      logger = mock('MockLogger')
      EasyProfiler::Profile.logger = logger
      EasyProfiler::Profile.start('myprofiler2').options[:logger].should be(logger)
    end

    it 'should use global :live_logging value' do
      EasyProfiler::Profile.start('myprofiler1').options[:live_logging].should be_false
      EasyProfiler::Profile.live_logging = true
      EasyProfiler::Profile.start('myprofiler2').options[:live_logging].should be_true
    end
    
    it 'should disable garbage collector when needed' do
      options = { :enabled => true, :count_ar_instances => true }
      GC.should_receive(:disable)
      EasyProfiler::Profile.start('myprofiler1', options)

      options = { :enabled => true, :count_memory_usage => true }
      GC.should_receive(:disable)
      EasyProfiler::Profile.start('myprofiler2', options)
    end
  end

  context '.stop' do
    it 'should raise an error when profiler is not started' do
      lambda {
        EasyProfiler::Profile.stop('myprofiler')
      }.should raise_error(ArgumentError)
    end

    it 'should call dump_results method on profiler' do
      profiler = mock_profile_start('myprofiler', :enabled => true)
      profiler.should_receive(:dump_results)
      EasyProfiler::Profile.stop('myprofiler')
    end

    it 'should enable back garbage collector when needed' do
      profiler = mock_profile_start('myprofiler1', :enabled => true, :count_ar_instances => true)
      profiler.stub!(:dump_results)
      GC.should_receive(:enable)
      EasyProfiler::Profile.stop('myprofiler1')

      profiler = mock_profile_start('myprofiler2', :enabled => true, :count_memory_usage => true)
      profiler.stub!(:dump_results)
      GC.should_receive(:enable)
      EasyProfiler::Profile.stop('myprofiler2')
    end
  end
end