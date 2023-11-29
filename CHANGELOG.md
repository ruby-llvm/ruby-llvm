## [Unreleased]
### Changed
### Added

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
