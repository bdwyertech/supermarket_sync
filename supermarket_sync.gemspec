# Encoding: UTF-8

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'supermarket_sync/version'

Gem::Specification.new do |spec|
  spec.name          = 'supermarket_sync'
  spec.version       = SupermarketSync::VERSION
  spec.authors       = ['Brian Dwyer']
  spec.email         = ['chef@broadridge.com']

  spec.summary       = 'Utility to synchronize Chef Supermarkets'
  spec.homepage      = 'https://github.com/bdwyertech/supermarket_sync'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata) # rubocop: disable GuardClause
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # => Dependencies
  spec.add_runtime_dependency 'knife', '>= 17.1', '< 19.0'
  spec.add_runtime_dependency 'mixlib-cli', '>= 2.1.1', '< 3.0'
  spec.add_runtime_dependency 'slack-notifier', '~> 2.4.0'

  # => Development Dependencies
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '= 1.60.1'
end
