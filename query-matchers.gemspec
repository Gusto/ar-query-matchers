# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ar_query_matchers/version'

Gem::Specification.new do |spec|
  spec.name          = 'ar-query-matchers'
  spec.version       = File.read(File.join(File.dirname(__FILE__), './VERSION'))
  spec.authors       = ['Matan Zruya']
  spec.email         = ['mzruya@gmail.com']

  spec.summary       = 'ruby test matchers for instrumenting ActiveRecord query counts'
  spec.description   = 'These RSpec matchers allows guarding against N+1 queries by specifying exactly how many queries we expect each of our models to perform.'
  spec.homepage      = 'https://github.com/Gusto/ar-query-matchers'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = spec.homepage
    spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/master/CHANGELOG.md"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir['README.md', 'lib/**/*']

  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activerecord',  '>= 4.0', '<= 6.0'
  spec.add_runtime_dependency 'activesupport', '>= 4.0', '<= 6.0'
  spec.add_runtime_dependency 'rspec', '~> 3.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'sqlite3', '~> 1.4'
end
