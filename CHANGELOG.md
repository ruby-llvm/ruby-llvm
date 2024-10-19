## [Unreleased]

## [19.1.3] - 2024-11-02

### Added
- Value#from_ptr_kind handles const_expr -> ConstantExpr
- tests run on macos-15

### Changed
- Upgrade to 19.1.3
- use nobits and anybits where appropriate
- Fix bug in testing against macos

## [19.1.2] - 2024-10-15

### Changed
- fix multiple integer issues above 64 bits
- Upgrade to 19.1.2

## [19.1.0] - 2024-09-25

### Changed
- Upgrade to LLVM 19
- use LLVMStringInContext2

### Added 
- Add several passes:
  - expand_variadics!
  - pgo_force_function_attrs!
  - nsan!
  - pre_isel_intrinsic_lowering!
  - atomic_expand!
  - jump_table_to_switch!
  - lower_allow_check!
  - lower_invoke!
  - lower_guard_intrinsic!
  - lower_widenable_condition!
  - transform_warning!
  - trigger_crash_function!
  - trigger_verifier_error!
  - loop_idiom_vectorize!

## [18.2.0] - 2024-09-16

### Changed
- Align on alias_method over alias
- Fix atomic_rmw_bin_op symbols - potentially BREAKING
- Deprecate nuw_neg
- LLVM::Int32 will be instance of LLVM::IntType
- disentangle GlobalVariable and GlobalValue
- update ConstantInt const methods
- remove ConstantInt constructors - now responsibility of IntType
- deprecate const icmp and fcmp
- LLVM::Float will be instance of LLVM::RealType
- LLVM::Double will be instance of LLVM::RealType
- remove macos-12 from CI
- RuboCop cleanup
- Fix various bugs with gep (#251)
- Fix other bugs as revealed by testing
- Improve Value#allocated_type

### Added
- minitest-fail-fast dev dependency
- Types get #undef to create undef of that type
- LLVM .i .float .double .ptr .void
- Many tests
- Value#undef?
- Add tests for builder methods
- Value#gep_source_element_type
- implement Builder#ptr_diff2
- implement Builder#int_cast2
- add methods for setting / clearing nuw, nsw, exact flags

## [18.1.8] - 2024-06-29
### Changed
- Fixed segfault on invoke / invoke2 builder calls
- Upgrade to LLVM 18.1.8 minimum
- Fixed samples/fp.rb so it works with call2
### Added
- additional tests for PassBuilder
- experimental support for landing_pad, landing_pad_cleanup, personality_function get/set
- additional test helpers

## [18.1.7] - 2024-06-10
### Changed
- Upgrade to LLVM 18.1.7 minimum
### Added
- Enable CI for Mac OS 14

## [18.1.6] - 2024-05-21
### Changed
- Upgrade to LLVM 18.1.6 minimum
### Added
- Enable CI for Ubuntu 24.04

## [18.1.5] - 2024-05-09
### Changed
- Upgrade to LLVM 18.1.5 minimum

## [18.1.4] - 2024-04-22
### Changed
- Upgrade to LLVM 18.1.4 minimum
### Added
- partial_inliner! pass

## [18.1.3] - 2024-04-06
### Changed
- Deprecate unwind instruction
- Attribute to_s and inspect call LLVM Attribute::getAsString() for a better and more consistent string
- Switch to LLVM 18
    - Breaking changes to optimizing inline and always-inline 
    - Previously, an inliner-threshold of nil would be no inlining
    - Currently, always-inline and inline are included, matching O0-3, unless disabled by parameter
    - Changes to LLVM const functions
### Added
- LLVM::Module#clone_module to clone a module entirely.
- Attribute methods: readnone? readonly? writeonly? which work for new and old attributes
- Function methods: readnone? readonly? writeonly? which work for new and old attributes
- allow attribute comparisons to strings and symbols
- more attribute tests

## [17.0.0] - 2024-01-01
### Changed
- Switch to LLVM 17
### Added
- PassBuilder class for New Pass Manager (https://llvm.org/docs/NewPassManager.html)
### Breaking Changes
- PassManager most methods will raise exceptions
- PassManagerBuilder #build and #build_with_lto will raise exceptions
- Users must switch to PassBuilder

## [16.0.1] - 2023-12-11
### Changed
- Fix GenericValue.from_b. (@seven1m)
- Fix build issues. (@seven1m)
- Call instruction uses function calling convention by default.
- Call instructions can use function names instead of functions.
- Add test for invoke / invoke2.
### Added
- Added builder support for the fneg instruction.

## [16.0.0] - 2023-06-01
- Update to LLVM 16.
- Several other related things.

## [15.0.4] - 2022-05-14
### Changed
- Fixed segfaults when value type expected to be instruction but was globalvairable
- inspect values should be more useful than raw pointer for modules, functions, instructions
- Fixed tests 
- raise on use of deprecated constant expressions

### Added
- Add LLVM::Value#kind which calls LLVMGetValueKind and returns a symbol
- Add LLVM::Module.parse_ir and LLVM::Module#write_ir!
- More workflow tests - including ruby 3.2
- Several additional Target tests
- valid? method for modules and functions
- ConstantInt#trunc
- ConstantInt#ext alias for ConstantInt#sext
- ConstantInt#to_f to const convert to float type
- ConstantReal#to_i to const convert to int type
- ConstantReal#trunc
- ConstantReal#ext / ConstantReal#sext
- Many more tests

## [15.0.3] - 2022-02-24
### Added
- Tests for adding pass manager passes - catches pass removals and certain bugs
- Additional documentation for passes
- Missing passes:
  - dce!
  - bdce!
  - scalarizer!
  - mldst_motion!
  - new_gvn!
  - instsimplify!
  - loop_reroll!
  - loop_unroll_and_jam!
  - loweratomic!
  - partially_inline_libcalls!
  - verify!
  - early_cse_memssa!
  - scoped_noalias_aa!
  - lower_constant_intrinsics!
  - mergereturn!
  - lowerswitch!
  - add_discriminators!
  - called_value_propagation!
- Warnings on removed passes:
  - arg_promote!
  - ipcp! 
  - loop_unswitch! 
  - simplify_libcalls! 
  - constprop! 
  - bb_vectorize!
- Bug fixes for passes:
  - dae!
  - internalize!
  - scalarrepl_threshold!

## [15.0.2] - 2022-01-30
### Changed
### Added
- LLVM::Type.named(name) to get an existing type - Calls GetTypeByName2
- LLVM::Type packed_struct? opaque_struct? literal_struct?
- Tests for structs and named types
- error checking for array and vector sizes
- GitHub dependabot integration
- GitHub preliminary CI

## [15.0.1] - 2022-12-03
### Changed
- Fix to compiling ruby-llvm-support with clang++

## [15.0.0] - 2022-10-29
### Added
- debug gem
- add "2" version for several operations
    - build_load2, build_gep2, build_inbounded_gep2, build_struct_gep2, build_call2, build_invoke2

### Changed
- LLVM 15
- Pointers only support opaque mode
    - Type#element_type returns void for pointers 
- Order for building is now: clang++-15 clang++ g++
- updated various development gems: rubocop, minitest, etc

### Removed
- builder#build_with_lto

## [13.0.2] - 2022-06-02
### Changed
- ruby version is >= 2.7
- Error handling for Builder#ret
- Error handling for Builder#call
- Error handling for Builder#br
- Error handling for Builder#cond
- Error handling for extract element/value
- Error handling for insert element/value
- Error handling for position, position_at_end, position_before
- default to "ret void" for Builder#ret
- add Type#aggregate?

## [13.0.1] - 2021-12-21
### Changed
- LLVM::Type#to_s now shows LLVM IR type
- LLVM::Value#to_s now shows LLVM IR value
- added ConstantInt#zext
- added ConstantInt#sext
- added PassManager#mergefunc! pass

## [13.0.0] - 2021-10-21
### Changed
- LLVM Bindings upgraded to 13.0.0
- update gem dependencies

## [11.0.0] - 2020-12-07
### Changed
- LLVM Bindings upgraded to 11.0.0

## [10.0.0] - 2020-06-19
### Changed
- LLVM Bindings upgraded to 10.0.0
- update gem dependencies
- remove some bindings to functions which no longer exist in llvm-c

## [8.0.1] - 2019-03-28
### Changed
- MCJITCompiler initialized with code_model 0 again
- Allow PassManager.new to be called without a machine parameter
- PassManager.new warns on being called with a machine parameter

## [8.0.0] - 2019-03-21
### Changed
- LLVM Bindings upgraded to 8.0.0
