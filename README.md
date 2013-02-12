Ruby-LLVM
=========

Ruby-LLVM is a Ruby language binding to the LLVM compiler infrastructure
library. LLVM allows users to create just-in-time (JIT) compilers, ahead-of-time
(AOT) compilers for multiple architectures, code analyzers and more. LLVM
bindings can also be used to speed up Ruby code by compiling and loading
computationally intensive algorithms on the fly.

Requirements
------------
* LLVM 3.2, including libLLVM-3.2 (compile LLVM with --enable-shared).
* In order to ensure the usability of JIT features (i.e. create_jit_compiler), compile LLVM with --enable-jit as well.

About version numbers
---------------------

The first two digits of ruby-llvm's version number refer to the required
major and minor version of LLVM. The third digit refers to the ruby-llvm
release itself. Because LLVM's api changes often, this coupling between
LLVM and ruby-llvm versions is useful.

Homebrew
--------
LLVM can be installed with Homebrew by executing `brew install llvm --shared`

Caveats:

LLVM 3.2 ships with an unresolved
[bug](http://llvm.org/bugs/show_bug.cgi?id=14715) in which its version string is
"3.2svn" rather than "3.2". Some package maintainers have patched the version
string before building LLVM. The Homebrew maintainers, however, have decided not
to maintain a patch set (see this
[thread](https://github.com/mxcl/homebrew/issues/17034).) Unfortunately, the bug
breaks ruby-llvm's FFI bindings.

A patched formula for LLVM has been created by
[thoughtpolice](https://github.com/thoughtpolice). This formula is unsupported,
but if you would like to give it a shot, use the following command.

```bash
    brew install https://raw.github.com/ruby-llvm/ruby-llvm/650c2636aee00dd17debdf96c03f962f7288bf33/misc/homebrew/llvm-3.2.rb --shared --with-clang
```

See Also
--------
* [The LLVM project](http://llvm.org)
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
