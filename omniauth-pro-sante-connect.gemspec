# coding: utf-8
require File.expand_path('../lib/omniauth-pro-sante-connect/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "omniauth-pro-sante-connect"
  spec.version       = Omniauth::ProSanteConnect::VERSION
  spec.authors       = ["Julien Meichelbeck"]
  spec.description   = %q{OmniAuth strategy for PRO Santé Connect}
  spec.summary       = %q{OmniAuth strategy for PRO Santé Connect}
  spec.homepage      = "https://github.com/doctolib/omniauth-pro-sante-connect.git"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'omniauth', '~> 1.5'
  spec.add_dependency 'omniauth-oauth2', '>= 1.4.0', '< 2.0'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "mocha"
end
