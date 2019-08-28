# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fabric/version'

Gem::Specification.new do |gem|
  gem.name          = "fabric"
  gem.version       = Fabric::VERSION
  gem.authors       = ['Daniel Arnold', 'Evan Berquist', 'Jarrett Lusso']
  gem.email         = ['dan@cacheventures.com', 'evan@cacheventures.com', 'jarrett@cacheventures.com']

  gem.summary       = 'A framework for integrating Rails and Stripe.'
  gem.description   = 'A framework for integrating Rails and Stripe.'
  gem.homepage      = "http://cacheventures.com/"
  gem.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if gem.respond_to?(:metadata)
    gem.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  gem.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|gem|features)/})
  end
  gem.bindir        = "exe"
  gem.executables   = gem.files.grep(%r{^exe/}) { |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_dependency 'enumerize'
  gem.add_dependency 'mongoid'
  gem.add_dependency 'stripe'
  gem.add_dependency 'stripe_event'
  gem.add_dependency 'sidekiq'

  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'minitest-reporters'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'awesome_print'
end
