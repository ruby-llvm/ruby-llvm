## [Unreleased]
### Changed

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
