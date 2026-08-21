# frozen_string_literal: true
# typed: strict

module LLVM
  LLVM_VERSION = "22"
  LLVM_REQUIRED_VERSION = "22.1"
  RUBY_LLVM_VERSION = "22.1.0"

  # Candidate names for the shared library, tried in order by ffi_lib until one
  # loads. Each entry targets a different platform/packaging scheme, so the
  # ones that miss on any given system are expected, not dead weight:
  #
  #   LLVM-22           undecorated; FFI.map_library_name adds the platform
  #                     form -- libLLVM-22.dylib on macOS, libLLVM-22.so on
  #                     Linux. The only entry that can match on macOS, since
  #                     the others are literal .so names. Moved to the front in
  #                     ec556af (LLVM 19), alongside homebrew CI support.
  #   libLLVM.so.22     openSUSE layout. Added in 9246958 (LLVM 10) --
  #                     "Support libLLVM.so.<version> as used in openSUSE".
  #   libLLVM.so.22.1   Debian/Ubuntu layout since LLVM 19, and the real file on
  #                     current systems; added in ec556af to work around the
  #                     LLVM 19 packaging change.
  LIB_NAMES = [
    "LLVM-#{LLVM_VERSION}",
    "libLLVM.so.#{LLVM_VERSION}",
    "libLLVM.so.#{LLVM_REQUIRED_VERSION}",
  ].freeze #: Array[String]
end
