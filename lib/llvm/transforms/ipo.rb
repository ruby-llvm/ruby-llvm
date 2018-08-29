# Interprocedural optimization (IPO)
require 'llvm'
require 'llvm/core'
require 'llvm/transforms/ipo_ffi'

module LLVM
  class PassManager
    # @LLVMpass arg_promotion
    def arg_promote!
      C.add_argument_promotion_pass(self)
    end

    # @LLVMpass const_merge
    def const_merge!
      C.add_constant_merge_pass(self)
    end

    # @LLVMpass dae
    def dae!
      C.add_dead_arg_elimination(self)
    end

    # @LLVMpass function_attrs
    def fun_attrs!
      C.add_function_attrs_pass(self)
    end

    # @LLVMpass inline
    def inline!
      C.add_function_inlining_pass(self)
    end

    # @LLVMpass always_inline
    def always_inline!
      C.add_always_inliner_pass(self)
    end

    # @LLVMpass gdce
    def gdce!
      C.add_global_dce_pass(self)
    end

    # @LLVMpass global_opt
    def global_opt!
      C.add_global_optimizer_pass(self)
    end

    # @LLVMpass ipcp
    def ipcp!
      C.add_ip_constant_propagation_pass(self)
    end

    # @LLVMpass prune_eh
    def prune_eh!
      C.add_prune_eh_pass(self)
    end

    # @LLVMpass ipsccp
    def ipsccp!
      C.add_ipsccp_pass(self)
    end

    # @LLVMpass internalize
    def internalize!(all_but_main = true)
      C.add_internalize_pass(self, all_but_main)
    end

    # @LLVMpass sdp
    def sdp!
      C.add_strip_dead_prototypes_pass(self)
    end

    # @LLVMpass strip
    def strip!
      C.add_strip_symbols_pass(self)
    end
  end
end
