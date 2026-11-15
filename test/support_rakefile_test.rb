# frozen_string_literal: true
# typed: true

require "test_helper"
require "fileutils"
require "open3"
require "tmpdir"

# Runs ext/ruby-llvm-support/Rakefile with rake --dry-run against a copy of its
# directory layout, so the real lib/llvm/config.rb is never touched.
class SupportRakefileTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_config_regenerated_when_version_rb_is_newer
    with_layout do |ext_dir, config_rb, version_rb|
      now = Time.now
      File.utime(now - 60, now - 60, config_rb)
      File.utime(now, now, version_rb)

      assert_includes dry_run(ext_dir, config_rb), "** Execute (dry run) #{config_rb}"
    end
  end

  private

  def with_layout
    Dir.mktmpdir do |tmp|
      dir = File.realpath(tmp)
      ext_dir = File.join(dir, "ext/ruby-llvm-support")
      FileUtils.mkdir_p(ext_dir)
      FileUtils.mkdir_p(File.join(dir, "lib/llvm"))
      FileUtils.cp(File.join(ROOT, "ext/ruby-llvm-support/Rakefile"), ext_dir)
      FileUtils.cp(File.join(ROOT, "lib/llvm/version.rb"), File.join(dir, "lib/llvm"))

      config_rb = File.join(dir, "lib/llvm/config.rb")
      File.write(config_rb, "# stale\n")

      yield ext_dir, config_rb, File.join(dir, "lib/llvm/version.rb")
    end
  end

  def dry_run(ext_dir, target)
    output, status = Open3.capture2e(Gem.ruby, Gem.bin_path("rake", "rake"), "-C", ext_dir, "--dry-run", target)
    assert_predicate status, :success?, output
    output
  end
end
