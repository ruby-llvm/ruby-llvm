# frozen_string_literal: true

source "https://rubygems.org"

gemspec

# No Windows/mingw build of sorbet-static exists (only x86_64-linux,
# aarch64-linux, universal-darwin, java), so it can't live in the gemspec's
# unconditional development group without breaking `bundle install` on Windows.
gem "sorbet-static" unless Gem.win_platform?

# tapioca depends on sorbet-static-and-runtime -> sorbet-static, same problem.
gem "tapioca", "~> 0.16.11" unless Gem.win_platform?

group :devtools, optional: true do
  gem "ffi_gen", source: "https://gem.coop/@uvlad7"
end
