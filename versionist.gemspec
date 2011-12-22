# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'versionist/version'

Gem::Specification.new do |s|
  s.name = 'versionist'
  s.version = Versionist::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ['Brian Ploetz']
  s.summary = "versionist-#{Versionist::VERSION}"
  s.description = 'A plugin for versioning Rails 3 based RESTful APIs.'
  s.files = Dir['lib/**/*']
  s.rdoc_options = ['--charset=UTF-8']
  s.require_paths = ['lib']
  s.required_rubygems_version = '>= 1.3.6'

  s.add_dependency('rails', '~> 3.0')

  s.add_development_dependency('rake', '>= 0.9.2')
  s.add_development_dependency('rspec', '2.7.0')
  s.add_development_dependency('rspec-rails', '2.7.0')
  s.add_development_dependency('generator_spec', '0.8.4')
  s.add_development_dependency('rails', '~> 3.0')
  s.add_development_dependency('rdoc', '>= 3.11')
  s.add_development_dependency('simplecov', '0.5.4')
end
