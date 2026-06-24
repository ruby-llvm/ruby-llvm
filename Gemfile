# frozen_string_literal: true

source "https://rubygems.org"

gemspec

# No Windows/mingw build of sorbet-static exists (only x86_64-linux,
# aarch64-linux, universal-darwin, java), so it can't live in the gemspec's
# unconditional development group without breaking `bundle install` on Windows.
gem "sorbet-static", group: :development unless Gem.win_platform?

group :devtools, optional: true do
  # LD_LIBRARY_PATH=/usr/lib/llvm-14/lib
  # gem "ghazel-ffi_gen", "1.3.9.2"
  gem "ffi_gen"
end
