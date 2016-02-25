# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'masqueraide/version'

Gem::Specification.new do |spec|
  spec.name          = 'masqueraide'
  spec.version       = Masqueraide::VERSION
  spec.authors       = ['Wesley Hill']
  spec.email         = ['wesley@hakobaito.co.uk']
  spec.summary       = 'Masqueraide is an AI/Bot library designed to run on social networks.'
  spec.description   = 'Masqueraide is an AI/Bot library designed to run on social networks.'
  spec.homepage      = ''
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'rake', '~> 10.0'
end
