Ruby-LLVM
=========

This package contains Ruby bindings to the LLVM api, enabling users to
make use of LLVM's optimization passes and JIT compilation for
implementing compiled DSLs, callback functions, or fast Ruby method
implementations.

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
