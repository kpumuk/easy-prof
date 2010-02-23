require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name        = 'easy-prof'
    gemspec.summary     = 'Simple and easy to use Ruby code profiler'
    gemspec.description = 'Simple Ruby code profiler to use both in Rails applications and generic Ruby scripts.'
    gemspec.email       = 'kpumuk@kpumuk.info'
    gemspec.homepage    = 'http://github.com/kpumuk/easy-prof'
    gemspec.authors     = ['Dmytro Shteflyuk']
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts 'Jeweler not available. Install it with: sudo gem install jeweler'
end

begin
  require 'spec/rake/spectask'

  desc 'Default: run unit tests.'
  task :default => :spec

  desc 'Test the easy-prof plugin.'
  Spec::Rake::SpecTask.new(:spec) do |t|
    t.libs << 'lib'
    t.pattern = 'spec/**/*_spec.rb'
    t.verbose = true
    t.spec_opts = ['-cfs']
  end
rescue LoadError
  puts 'RSpec not available. Install it with: sudo gem install rspec'
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new(:yard) do |t|
    t.options = ['--title', 'EasyProf Documentation']
    if ENV['PRIVATE']
      t.options.concat ['--protected', '--private']
    else
      t.options.concat ['--protected', '--no-private']
    end
  end
rescue LoadError
  puts 'Yard not available. Install it with: sudo gem install yard'
end
