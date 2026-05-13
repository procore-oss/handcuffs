lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'handcuffs/version'

Gem::Specification.new do |spec|
  spec.name          = "handcuffs"
  spec.version       = Handcuffs::VERSION
  spec.authors       = ["Procore Technologies, Inc."]
  spec.email         = ["opensource@procore.com"]

  spec.summary       = 'A Ruby gem for running Active Record migrations in phases'
  spec.description   = 'Allows you to define a phase on Active Record migrations and provides rake tasks for running only migrations tagged with a certain phase'
  spec.homepage      = "https://github.com/procore-oss/handcuffs/"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new('>= 3.2')

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  raise "RubyGems 2.0 or newer is required to protect against public gem pushes." unless spec.respond_to?(:metadata)

  spec.metadata['allowed_push_host'] = "https://rubygems.org"
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['homepage_uri'] = spec.homepage

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 7.1"
  spec.add_dependency "activesupport", ">= 7.1"
  spec.add_dependency "json"
  spec.add_dependency "railties", ">= 7.1"
end
