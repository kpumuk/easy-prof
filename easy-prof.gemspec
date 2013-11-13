# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'easy_prof/version'

Gem::Specification.new do |s|
  s.name        = 'easy-prof'
  s.version     = EasyProfiler::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Dmytro Shteflyuk']
  s.email       = ['kpumuk@kpumuk.info']
  s.homepage    = 'http://github.com/kpumuk/easy-prof'
  s.summary     = %q{Simple and easy to use Ruby code profiler.}
  s.description = %q{Simple Ruby code profiler to use both in Rails applications and generic Ruby scripts.}

  s.add_development_dependency 'activerecord', '~> 3.2.15'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'bluecloth'

  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {spec}/*`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extra_rdoc_files = ['README.md']
  s.rdoc_options     = ['--charset=UTF-8']
  s.require_paths    = ['lib']
end
