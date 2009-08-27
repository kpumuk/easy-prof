require File.dirname(__FILE__) + '/spec_helper'

describe EasyProfiler::Profile do
  after :each do
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
  end

  context '.stop' do
    it 'should raise an error when profiler is not started' do
      lambda {
        EasyProfiler::Profile.stop('myprofiler')
      }.should raise_error(ArgumentError)
    end
  end
end