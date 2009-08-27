require File.dirname(__FILE__) + '/spec_helper'

describe 'easy_profiler' do
  it 'should pass block results outside' do
    easy_profiler('test') { 1 }.should == 1
    easy_profiler('test') { 'xxx' }.should == 'xxx'
  end
end