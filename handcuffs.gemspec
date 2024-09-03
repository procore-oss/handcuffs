
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'handcuffs/version'

Gem::Specification.new do |spec|
  spec.name          = "handcuffs"
  spec.version       = Handcuffs::VERSION
  spec.authors       = ["Procore Technologies, Inc."]
  spec.email         = ["opensource@procore.com"]

  spec.summary       = %q{A Ruby gem for running Active Record migrations in phases}
  spec.description   = %q{Allows you to define a phase on Active Record migrations and provides rake tasks for running only migrations tagged with a certain phase}
  spec.homepage      = "https://github.com/procore-oss/handcuffs/"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new('>= 3.0')

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
    spec.metadata['rubygems_mfa_required'] = 'true'
    spec.metadata['homepage_uri'] = spec.homepage
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "pg"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rspec-rails", "~> 7.0"
  spec.add_development_dependency "simplecov"

  spec.add_runtime_dependency "rails", ">= 6.1"
end
