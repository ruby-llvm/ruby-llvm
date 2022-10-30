[![Known Vulnerabilities](https://snyk.io/test/github/ruby-llvm/ruby-llvm/badge.svg)](https://snyk.io/test/github/ruby-llvm/ruby-llvm)
[![Code Climate Maintainability](https://codeclimate.com/github/ruby-llvm/ruby-llvm/badges/gpa.svg)](https://codeclimate.com/github/ruby-llvm/ruby-llvm)
[![Code Climate Issue Count](https://codeclimate.com/github/ruby-llvm/ruby-llvm/badges/issue_count.svg)](https://codeclimate.com/github/ruby-llvm/ruby-llvm/issues)

Ruby-LLVM
=========

Ruby-LLVM is a Ruby language binding to the LLVM compiler infrastructure
library. LLVM allows users to create just-in-time (JIT) compilers, ahead-of-time
(AOT) compilers for multiple architectures, code analyzers and more. LLVM
bindings can also be used to speed up Ruby code by compiling and loading
computationally intensive algorithms on the fly.

Current version
---------------

This library currently binds to LLVM-15 (specifically llvm-c 15).

About version numbers
---------------------

The first two digits of ruby-llvm's version number refer to the required
major and minor version of LLVM. The third digit refers to the ruby-llvm
release itself. Because LLVM's api changes often, this coupling between
LLVM and ruby-llvm versions is useful.

Debian/Ubuntu
-------------

[LLVM Debian/Ubuntu Packages](https://apt.llvm.org/)

Homebrew
--------

LLVM can be installed with Homebrew by executing `brew install llvm --shared`

Source and other binaries
-------------------------

* [LLVM Download Page](https://releases.llvm.org/download.html)
* If compiling from source the --enable-shared and --enable-jit flags may be needed.

See Also
--------
* [The LLVM project](http://llvm.org)
* [Mirror of llvm-c on github](https://github.com/llvm-mirror/llvm/tree/master/include/llvm-c)
* [ffi-gen](https://github.com/neelance/ffi-gen) – Generate
  [FFI](https://github.com/ffi/ffi) bindings with LLVM and Clang

License
-------
Ruby-LLVM is available under the BSD 3-clause (see LICENSE), Copyright (c) 2010-2013 Jeremy Voorhis

Ruby-LLVM is possible because of its contributors:

* Evan Phoenix
* David Holroyd
* Takanori Ishikawa
* Ronaldo M. Ferraz
* Mac Malone
* Chris Wailes
* Ary Borenszweig
* Richard Musiol
* Juan Wajnerman
* Steven Farlie
* Peter Zotov
* Austin Seipp
* Torsten Rüger
* Nathaniel Barnes
