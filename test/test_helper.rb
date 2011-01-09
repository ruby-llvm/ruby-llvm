$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require "test/unit"

require "llvm/core"
require "llvm/execution_engine"
require "llvm/transforms/scalar"
