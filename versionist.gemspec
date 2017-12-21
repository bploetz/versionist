# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'versionist/version'

Gem::Specification.new do |s|
  s.name = 'versionist'
  s.homepage = 'https://github.com/bploetz/versionist'
  s.version = Versionist::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ['Brian Ploetz']
  s.summary = "versionist-#{Versionist::VERSION}"
  s.description = 'A plugin for versioning Rails based RESTful APIs.'
  s.license = 'MIT'
  s.files = Dir['lib/**/*']
  s.rdoc_options = ['--charset=UTF-8']
  s.require_paths = ['lib']
  s.required_rubygems_version = '>= 1.3.6'

  s.add_dependency 'railties', '>= 3'
  s.add_dependency 'activesupport', '>= 3'

  s.add_dependency('yard', "~> 0.9.11")
end
