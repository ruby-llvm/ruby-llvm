AC_INIT([ruby-llvm-support], [2.9.2], [jvoorhis@gmail.com])
AM_INIT_AUTOMAKE([-Wall -Werror foreign])
LT_INIT([shared])

AC_PROG_CXX
AC_CONFIG_FILES([
  Makefile
  src/Makefile
])

dnl RubyGems passes the gem's first requirable path as the --prefix.
dnl This installs the shared library directly into ruby-llvm's lib dir.
libdir='$(prefix)'
AC_SUBST(libdir)

AC_OUTPUT
