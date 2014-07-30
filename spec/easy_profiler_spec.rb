require File.dirname(__FILE__) + '/spec_helper'

describe 'easy_profiler' do
  it 'should pass block results outside' do
    expect(easy_profiler('test') { 1 }).to eq(1)
    expect(easy_profiler('test') { 'xxx' }).to eq('xxx')
  end
end
