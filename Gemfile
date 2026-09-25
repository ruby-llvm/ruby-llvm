# frozen_string_literal: true

source "https://rubygems.org"

gemspec

# sorbet-static publishes gems only for x86_64-linux, aarch64-linux, and universal-darwin
# (tapioca pulls it in via sorbet-static-and-runtime) -- nothing for Windows or Cygwin.
# Gem.win_platform? is false on Cygwin, so guarding on it leaves sorbet-static in the
# dependency graph there and `bundle install` stalls in resolution. Bundler still
# *resolves* a gem in a `without` group (it only skips installing it), so a plain group
# + BUNDLE_WITHOUT cannot avoid that either; guard by platform so it is absent from the
# graph. Kept in a group so it can still be skipped explicitly (e.g. for a faster
# install) where it does build.
if RUBY_PLATFORM.match?(/darwin|(?:x86_64|aarch64)-linux/)
  group :typecheck do
    gem "sorbet-static"
    gem "tapioca", "~> 0.16.11"
  end
end
