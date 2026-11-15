# frozen_string_literal: true

source "https://rubygems.org"

gemspec

# Not needed to run the tests. The CI test matrix sets BUNDLE_WITHOUT to skip
# these groups, so it does not compile their native extensions (prism, rbs,
# racc, debug and others) when its gem cache is empty.
group :lint do
  gem 'rubocop', '~> 1.92.2'
  gem 'rubocop-minitest'
  gem 'rubocop-performance'
  gem 'tapioca', '~> 0.16.11'
end

group :debug do
  gem 'debug'
end
