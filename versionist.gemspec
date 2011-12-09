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
  s.description = 'A Rails 3 plugin which allows you to easily version your Rails 3 based Web Service APIs'
  s.files = Dir['lib/**/*']
  s.rdoc_options = ['--charset=UTF-8']
  s.require_paths = ['lib']
  s.required_rubygems_version = '>= 1.3.6'

  s.add_dependency('rake', '>= 0.9.2')
  s.add_dependency('activesupport', '~> 3.0')

  s.add_development_dependency('rspec', '2.7.0')
  s.add_development_dependency('rdoc', '>= 3.11')
  s.add_development_dependency('simplecov', '0.5.4')
end
