Unsupported integer literal https://srb.help/3002
- large integer literals ruby supports and used successfully in testing
- could use conversion to or from strings to handle this, but it is less precise

This code is unreachable https://srb.help/7006
- dynamic code handling issues that would be caught by type checker if used

Splats are only supported where the size of the array is known statically https://srb.help/7019
- "#: as untyped" does not seem to work consistently

Method does not exist on https://srb.help/7003
- This is due to FFI creating large numbers of these
