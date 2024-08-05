# frozen_string_literal: true

module LLVM
  class PassBuilder # rubocop:disable Metrics/ClassLength
    extend FFI::Library
    ffi_lib ["libLLVM-19.so.1", "libLLVM.so.19", "LLVM-19"]

    attr_reader :passes
    attr_accessor :inliner_threshold, :merge_functions

    # rubocop:disable Layout/LineLength
    OPT_PASSES = {
      # :nocov:
      '0' => 'function(ee-instrument<>),always-inline,coro-cond(coro-early,cgscc(coro-split),coro-cleanup,globaldce),function(annotation-remarks),verify',
      '1' => 'annotation2metadata,forceattrs,inferattrs,coro-early,function<eager-inv>(ee-instrument<>,lower-expect,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;no-switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,sroa<modify-cfg>,early-cse<>),openmp-opt,ipsccp,called-value-propagation,globalopt,function<eager-inv>(mem2reg,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>),always-inline,require<globals-aa>,function(invalidate<aa>),require<profile-summary>,cgscc(devirt<4>(inline,function-attrs<skip-non-recursive-function-attrs>,function<eager-inv;no-rerun>(sroa<modify-cfg>,early-cse<memssa>,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,libcalls-shrinkwrap,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,reassociate,loop-mssa(loop-instsimplify,loop-simplifycfg,licm<no-allowspeculation>,loop-rotate<header-duplication;no-prepare-for-lto>,licm<allowspeculation>,simple-loop-unswitch<no-nontrivial;trivial>),simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,loop(loop-idiom,indvars,loop-deletion,loop-unroll-full),sroa<modify-cfg>,memcpyopt,sccp,bdce,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,coro-elide,adce,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>),function-attrs,function(require<should-not-run-function-passes>),coro-split)),deadargelim,coro-cleanup,globalopt,globaldce,elim-avail-extern,rpo-function-attrs,recompute-globalsaa,function<eager-inv>(float2int,lower-constant-intrinsics,loop(loop-rotate<header-duplication;no-prepare-for-lto>,loop-deletion),loop-distribute,inject-tli-mappings,loop-vectorize<no-interleave-forced-only;vectorize-forced-only;>,infer-alignment,loop-load-elim,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,simplifycfg<bonus-inst-threshold=1;forward-switch-cond;switch-range-to-icmp;switch-to-lookup;no-keep-loops;hoist-common-insts;sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,vector-combine,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,loop-unroll<O1>,transform-warning,sroa<preserve-cfg>,infer-alignment,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,loop-mssa(licm<allowspeculation>),alignment-from-assumptions,loop-sink,instsimplify,div-rem-pairs,tailcallelim,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;speculate-unpredictables>),globaldce,constmerge,cg-profile,rel-lookup-table-converter,function(annotation-remarks),verify',
      '2' => 'annotation2metadata,forceattrs,inferattrs,coro-early,function<eager-inv>(ee-instrument<>,lower-expect,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;no-switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,sroa<modify-cfg>,early-cse<>),openmp-opt,ipsccp,called-value-propagation,globalopt,function<eager-inv>(mem2reg,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>),always-inline,require<globals-aa>,function(invalidate<aa>),require<profile-summary>,cgscc(devirt<4>(inline,function-attrs<skip-non-recursive-function-attrs>,openmp-opt-cgscc,function<eager-inv;no-rerun>(sroa<modify-cfg>,early-cse<memssa>,speculative-execution<only-if-divergent-target>,jump-threading,correlated-propagation,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,aggressive-instcombine,libcalls-shrinkwrap,tailcallelim,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,reassociate,constraint-elimination,loop-mssa(loop-instsimplify,loop-simplifycfg,licm<no-allowspeculation>,loop-rotate<header-duplication;no-prepare-for-lto>,licm<allowspeculation>,simple-loop-unswitch<no-nontrivial;trivial>),simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,loop(loop-idiom,indvars,simple-loop-unswitch<no-nontrivial;trivial>,loop-deletion,loop-unroll-full),sroa<modify-cfg>,vector-combine,mldst-motion<no-split-footer-bb>,gvn<>,sccp,bdce,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,jump-threading,correlated-propagation,adce,memcpyopt,dse,move-auto-init,loop-mssa(licm<allowspeculation>),coro-elide,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;hoist-common-insts;sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>),function-attrs,function(require<should-not-run-function-passes>),coro-split)),deadargelim,coro-cleanup,globalopt,globaldce,elim-avail-extern,rpo-function-attrs,recompute-globalsaa,function<eager-inv>(float2int,lower-constant-intrinsics,loop(loop-rotate<header-duplication;no-prepare-for-lto>,loop-deletion),loop-distribute,inject-tli-mappings,loop-vectorize<no-interleave-forced-only;no-vectorize-forced-only;>,infer-alignment,loop-load-elim,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,simplifycfg<bonus-inst-threshold=1;forward-switch-cond;switch-range-to-icmp;switch-to-lookup;no-keep-loops;hoist-common-insts;sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,slp-vectorizer,vector-combine,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,loop-unroll<O2>,transform-warning,sroa<preserve-cfg>,infer-alignment,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,loop-mssa(licm<allowspeculation>),alignment-from-assumptions,loop-sink,instsimplify,div-rem-pairs,tailcallelim,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;speculate-unpredictables>),globaldce,constmerge,cg-profile,rel-lookup-table-converter,function(annotation-remarks),verify',
      '3' => 'annotation2metadata,forceattrs,inferattrs,coro-early,function<eager-inv>(ee-instrument<>,lower-expect,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;no-switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,sroa<modify-cfg>,early-cse<>,callsite-splitting),openmp-opt,ipsccp,called-value-propagation,globalopt,function<eager-inv>(mem2reg,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>),always-inline,require<globals-aa>,function(invalidate<aa>),require<profile-summary>,cgscc(devirt<4>(inline,function-attrs<skip-non-recursive-function-attrs>,argpromotion,openmp-opt-cgscc,function<eager-inv;no-rerun>(sroa<modify-cfg>,early-cse<memssa>,speculative-execution<only-if-divergent-target>,jump-threading,correlated-propagation,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,aggressive-instcombine,libcalls-shrinkwrap,tailcallelim,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,reassociate,constraint-elimination,loop-mssa(loop-instsimplify,loop-simplifycfg,licm<no-allowspeculation>,loop-rotate<header-duplication;no-prepare-for-lto>,licm<allowspeculation>,simple-loop-unswitch<nontrivial;trivial>),simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,loop(loop-idiom,indvars,simple-loop-unswitch<nontrivial;trivial>,loop-deletion,loop-unroll-full),sroa<modify-cfg>,vector-combine,mldst-motion<no-split-footer-bb>,gvn<>,sccp,bdce,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,jump-threading,correlated-propagation,adce,memcpyopt,dse,move-auto-init,loop-mssa(licm<allowspeculation>),coro-elide,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;hoist-common-insts;sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>),function-attrs,function(require<should-not-run-function-passes>),coro-split)),deadargelim,coro-cleanup,globalopt,globaldce,elim-avail-extern,rpo-function-attrs,recompute-globalsaa,function<eager-inv>(float2int,lower-constant-intrinsics,chr,loop(loop-rotate<header-duplication;no-prepare-for-lto>,loop-deletion),loop-distribute,inject-tli-mappings,loop-vectorize<no-interleave-forced-only;no-vectorize-forced-only;>,infer-alignment,loop-load-elim,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,simplifycfg<bonus-inst-threshold=1;forward-switch-cond;switch-range-to-icmp;switch-to-lookup;no-keep-loops;hoist-common-insts;sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,slp-vectorizer,vector-combine,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,loop-unroll<O3>,transform-warning,sroa<preserve-cfg>,infer-alignment,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,loop-mssa(licm<allowspeculation>),alignment-from-assumptions,loop-sink,instsimplify,div-rem-pairs,tailcallelim,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;speculate-unpredictables>),globaldce,constmerge,cg-profile,rel-lookup-table-converter,function(annotation-remarks),verify',
      's' => 'annotation2metadata,forceattrs,inferattrs,coro-early,function<eager-inv>(ee-instrument<>,lower-expect,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;no-switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,sroa<modify-cfg>,early-cse<>),openmp-opt,ipsccp,called-value-propagation,globalopt,function<eager-inv>(mem2reg,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>),always-inline,require<globals-aa>,function(invalidate<aa>),require<profile-summary>,cgscc(devirt<4>(inline,function-attrs<skip-non-recursive-function-attrs>,function<eager-inv;no-rerun>(sroa<modify-cfg>,early-cse<memssa>,speculative-execution<only-if-divergent-target>,jump-threading,correlated-propagation,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,aggressive-instcombine,tailcallelim,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,reassociate,constraint-elimination,loop-mssa(loop-instsimplify,loop-simplifycfg,licm<no-allowspeculation>,loop-rotate<header-duplication;no-prepare-for-lto>,licm<allowspeculation>,simple-loop-unswitch<no-nontrivial;trivial>),simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,loop(loop-idiom,indvars,simple-loop-unswitch<no-nontrivial;trivial>,loop-deletion,loop-unroll-full),sroa<modify-cfg>,vector-combine,mldst-motion<no-split-footer-bb>,gvn<>,sccp,bdce,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,jump-threading,correlated-propagation,adce,memcpyopt,dse,move-auto-init,loop-mssa(licm<allowspeculation>),coro-elide,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;hoist-common-insts;sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>),function-attrs,function(require<should-not-run-function-passes>),coro-split)),deadargelim,coro-cleanup,globalopt,globaldce,elim-avail-extern,rpo-function-attrs,recompute-globalsaa,function<eager-inv>(float2int,lower-constant-intrinsics,loop(loop-rotate<header-duplication;no-prepare-for-lto>,loop-deletion),loop-distribute,inject-tli-mappings,loop-vectorize<no-interleave-forced-only;no-vectorize-forced-only;>,infer-alignment,loop-load-elim,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,simplifycfg<bonus-inst-threshold=1;forward-switch-cond;switch-range-to-icmp;switch-to-lookup;no-keep-loops;hoist-common-insts;sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,slp-vectorizer,vector-combine,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,loop-unroll<O2>,transform-warning,sroa<preserve-cfg>,infer-alignment,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,loop-mssa(licm<allowspeculation>),alignment-from-assumptions,loop-sink,instsimplify,div-rem-pairs,tailcallelim,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;speculate-unpredictables>),globaldce,constmerge,cg-profile,rel-lookup-table-converter,function(annotation-remarks),verify',
      'z' => 'annotation2metadata,forceattrs,inferattrs,coro-early,function<eager-inv>(ee-instrument<>,lower-expect,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;no-switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,sroa<modify-cfg>,early-cse<>),openmp-opt,ipsccp,called-value-propagation,globalopt,function<eager-inv>(mem2reg,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>),always-inline,require<globals-aa>,function(invalidate<aa>),require<profile-summary>,cgscc(devirt<4>(inline,function-attrs<skip-non-recursive-function-attrs>,function<eager-inv;no-rerun>(sroa<modify-cfg>,early-cse<memssa>,speculative-execution<only-if-divergent-target>,jump-threading,correlated-propagation,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,aggressive-instcombine,tailcallelim,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,reassociate,constraint-elimination,loop-mssa(loop-instsimplify,loop-simplifycfg,licm<no-allowspeculation>,loop-rotate<no-header-duplication;no-prepare-for-lto>,licm<allowspeculation>,simple-loop-unswitch<no-nontrivial;trivial>),simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,loop(loop-idiom,indvars,simple-loop-unswitch<no-nontrivial;trivial>,loop-deletion,loop-unroll-full),sroa<modify-cfg>,vector-combine,mldst-motion<no-split-footer-bb>,gvn<>,sccp,bdce,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,jump-threading,correlated-propagation,adce,memcpyopt,dse,move-auto-init,loop-mssa(licm<allowspeculation>),coro-elide,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;hoist-common-insts;sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>),function-attrs,function(require<should-not-run-function-passes>),coro-split)),deadargelim,coro-cleanup,globalopt,globaldce,elim-avail-extern,rpo-function-attrs,recompute-globalsaa,function<eager-inv>(float2int,lower-constant-intrinsics,loop(loop-rotate<no-header-duplication;no-prepare-for-lto>,loop-deletion),loop-distribute,inject-tli-mappings,loop-vectorize<no-interleave-forced-only;vectorize-forced-only;>,infer-alignment,loop-load-elim,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,simplifycfg<bonus-inst-threshold=1;forward-switch-cond;switch-range-to-icmp;switch-to-lookup;no-keep-loops;hoist-common-insts;sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,vector-combine,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,loop-unroll<O2>,transform-warning,sroa<preserve-cfg>,infer-alignment,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,loop-mssa(licm<allowspeculation>),alignment-from-assumptions,loop-sink,instsimplify,div-rem-pairs,tailcallelim,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;speculate-unpredictables>),globaldce,constmerge,cg-profile,rel-lookup-table-converter,function(annotation-remarks),verify',
      # :nocov:
    }.freeze
    # rubocop:enable Layout/LineLength

    def initialize
      @passes = []
      @inliner_threshold = nil
      @merge_functions = nil
    end

    def add_function_pass
      pb = PassBuilder.new
      if block_given?
        yield pb
      end

      add_pass("function(#{pb.pass_string})")
    end

    # --O0 - Optimization level 0. Similar to clang -O0. Use -passes='default<O0>' for the new PM
    # --O1 - Optimization level 1. Similar to clang -O1. Use -passes='default<O1>' for the new PM
    # --O2 - Optimization level 2. Similar to clang -O2. Use -passes='default<O2>' for the new PM
    # --O3 - Optimization level 3. Similar to clang -O3. Use -passes='default<O3>' for the new PM
    # --Os - Like -O2 but size-conscious. Similar to clang -Os. Use -passes='default<Os>' for the new PM
    # --Oz - Like -O2 but optimize for code size above all else. Similar to clang -Oz. Use -passes='default<Oz>' for the new PM
    # @return self
    def o!(opt_level = '0', options = {})
      opt_level = opt_level.to_s
      expanded_pass = OPT_PASSES[opt_level]

      if expanded_pass.nil?
        return add_pass("default<O#{opt_level}>")
      end

      if options[:disable_inline]
        expanded_pass = expanded_pass.gsub('devirt<4>(inline,', 'devirt<4>(')
      end
      if options[:disable_always_inline]
        expanded_pass = expanded_pass.gsub('always-inline,', '')
      end
      add_pass(expanded_pass)
    end

    # @return self
    def add_pass(pass)
      passes << pass
      self
    end

    # @return self
    def dce!
      add_pass('dce')
    end

    # @return self
    def licm!
      add_pass('licm')
    end

    # A pass to simplify and canonicalize the CFG of a function.
    # This pass iteratively simplifies the entire CFG of a function. It may change
    # or remove control flow to put the CFG into a canonical form expected by
    # other passes of the mid-level optimizer. Depending on the specified options,
    # it may further optimize control-flow to create non-canonical form
    # https://llvm.org/doxygen/SimplifyCFG_8h_source.html
    # TODO: takes params
    # Options: simplifycfg<no-forward-switch-cond;forward-switch-cond;no-switch-range-to-icmp;switch-range-to-icmp;no-switch-to-lookup;switch-to-lookup;no-keep-loops;keep-loops;no-hoist-common-insts;hoist-common-insts;no-sink-common-insts;sink-common-insts;bonus-inst-threshold=N>
    # @return self
    def simplifycfg!
      add_pass('simplifycfg')
    end

    # @return self
    def scalarizer!
      add_pass('scalarizer')
    end

    # Merged Load Store Motion
    # @return self
    def mldst_motion!
      add_pass('mldst-motion')
    end

    # Global Value Numbering pass
    # https://llvm.org/doxygen/GVN_8h_source.html
    # TODO: takes params
    # @return self
    def gvn!
      add_pass('gvn')
    end

    # New Global Value Numbering pass
    # https://llvm.org/doxygen/NewGVN_8cpp.html#details
    # @return self
    def newgvn!
      add_pass('newgvn')
    end

    # hoists expressions from branches to a common dominator.
    # https://llvm.org/doxygen/GVNHoist_8cpp_source.html
    # @return self
    def gvn_hoist!
      add_pass('gvn-hoist')
    end

    # sink instructions into successors
    # https://llvm.org/doxygen/GVNSink_8cpp_source.html
    # @return self
    def gvn_sink!
      add_pass('gvn-sink')
    end

    # @return self
    def jump_threading!
      add_pass('jump-threading')
    end

    # @return self
    def indvars!
      add_pass('indvars')
    end

    # @return self
    def alignment_from_assumptions!
      add_pass('alignment-from-assumptions')
    end

    # @return self
    def loop_deletion!
      add_pass('loop-deletion')
    end

    # @return self
    def loop_idiom!
      add_pass('loop-idiom')
    end

    # @return self
    def loop_rotate!
      add_pass('loop-rotate')
    end

    # @return self
    def loop_reroll!
      deprecated('loop-reroll pass was removed in LLVM 19')
    end

    # @return self
    def loop_unroll!
      add_pass('loop-unroll')
    end

    # @return self
    def loop_unroll_and_jam!
      add_pass('loop-unroll-and-jam')
    end

    # @return self
    def simple_loop_unswitch!
      add_pass('simple-loop-unswitch')
    end

    # @return self
    def loop_unswitch!
      simple_loop_unswitch!
    end

    # TODO: takes params
    # @return self
    def loop_vectorize!
      add_pass('loop-vectorize')
    end

    # @return self
    def memcpyopt!
      add_pass('memcpyopt')
    end

    # @return self
    def sccp!
      add_pass('sccp')
    end

    # Combine instructions to form fewer, simple instructions.
    # This pass does not modify the CFG.
    # This pass is where algebraic simplification happens.
    # https://llvm.org/doxygen/InstructionCombining_8cpp_source.html
    # https://llvm.org/doxygen/InstCombineInternal_8h_source.html
    # @return self
    def instcombine!
      add_pass('instcombine')
    end

    # @return self
    def instsimplify!
      add_pass('instsimplify')
    end

    # @return self
    def lower_atomic!
      add_pass('lower-atomic')
    end

    alias loweratomic! lower_atomic!

    # @return self
    def partially_inline_libcalls!
      add_pass('partially-inline-libcalls')
    end

    # @return self
    def reassociate!
      add_pass('reassociate')
    end

    # @return self
    def tailcallelim!
      add_pass('tailcallelim')
    end

    # @return self
    def reg2mem!
      add_pass('reg2mem')
    end

    # @return self
    def mem2reg!
      add_pass('mem2reg')
    end

    # @return self
    def verify!
      add_pass('verify')
    end

    # @return self
    def module_summary!
      add_pass('require<module-summary>')
    end

    # @return self
    def no_op_module!
      add_pass('no-op-module')
    end

    # @return self
    def no_op_cgscc!
      add_pass('no-op-cgscc')
    end

    # @return self
    def no_op_function!
      add_pass('no-op-function')
    end

    # @return self
    def stack_safety!
      add_pass('require<stack-safety>')
    end

    # A simple and fast domtree-based CSE pass.
    #
    # This pass does a simple depth-first walk over the dominator tree,
    # eliminating trivially redundant instructions and using instsimplify to
    # canonicalize things as it goes. It is intended to be fast and catch obvious
    # cases so that instcombine and other passes are more effective. It is
    # expected that a later pass of GVN will catch the interesting/hard cases.
    # https://llvm.org/doxygen/EarlyCSE_8h_source.html
    # https://llvm.org/doxygen/EarlyCSE_8cpp.html
    # @return self
    def early_cse!
      add_pass('early-cse')
    end

    # A simple and fast domtree-based CSE pass.
    # https://llvm.org/doxygen/EarlyCSE_8h_source.html
    # https://llvm.org/doxygen/EarlyCSE_8cpp.html
    # @return self
    def early_cse_memssa!
      add_pass('early-cse<memssa>')
    end

    # @return self
    def lcssa!
      add_pass('lcssa')
    end

    # @return self
    def memoryssa!
      add_pass('require<memoryssa>')
    end

    # Scalar Replacement Of Aggregates
    # https://llvm.org/doxygen/SROA_8h_source.html
    # https://llvm.org/doxygen/SROA_8cpp.html
    # @return self
    def sroa!
      add_pass('sroa')
    end

    # @return self
    def lower_expect!
      add_pass('lower-expect')
    end

    # @return self
    def cvprop!
      correlated_propagation!
    end

    # @return self
    def correlated_propagation!
      add_pass('correlated-propagation')
    end

    # @return self
    def lower_constant_intrinsics!
      add_pass('lower-constant-intrinsics')
    end

    # @return self
    def slp_vectorize!
      slp_vectorizer!
    end

    # @return self
    def slp_vectorizer!
      add_pass('slp-vectorizer')
    end

    # @return self
    def add_discriminators!
      add_pass('add-discriminators')
    end

    # @return self
    def mergereturn!
      add_pass('mergereturn')
    end

    # @return self
    def mergeicmps!
      add_pass('mergeicmps')
    end

    # @return self
    def basic_aa!
      add_pass('require<basic-aa>')
    end

    alias basicaa! basic_aa!

    # @return self
    def objc_arc_aa!
      add_pass('require<objc-arc-aa>')
    end

    # @return self
    def scev_aa!
      add_pass('require<scev-aa>')
    end

    # @return self
    def scoped_noalias_aa!
      add_pass('require<scoped-noalias-aa>')
    end

    # @return self
    def tbaa!
      add_pass('require<tbaa>')
    end

    # @return self
    def gobals_aa!
      add_pass('require<globals-aa>')
    end

    # @return self
    def lower_switch!
      add_pass('lower-switch')
    end

    alias lowerswitch! lower_switch!

    # Inlines functions marked as "always_inline".
    # https://llvm.org/doxygen/AlwaysInliner_8h_source.html
    # https://llvm.org/doxygen/AlwaysInliner_8cpp_source.html
    # @return self
    def always_inline!
      add_pass('always-inline')
    end

    # This pass performs partial inlining, typically by inlining an if statement
    # that surrounds the body of the function.
    # https://llvm.org/doxygen/PartialInlining_8h_source.html
    # https://llvm.org/doxygen/PartialInlining_8cpp_source.html
    # https://llvm.org/doxygen/PartialInlining_8h.html
    # https://llvm.org/doxygen/PartialInlining_8cpp.html
    # @return self
    def partial_inliner!
      add_pass('partial-inliner')
    end

    # This pass looks for equivalent functions that are mergable and folds them.
    # https://llvm.org/docs/MergeFunctions.html
    # https://llvm.org/doxygen/MergeFunctions_8cpp_source.html
    # https://llvm.org/doxygen/MergeFunctions_8h_source.html
    # @return self
    def mergefunc!
      add_pass('mergefunc')
    end

    # Propagate called values
    # This file implements a transformation that attaches !callees metadata to
    # indirect call sites. For a given call site, the metadata, if present,
    # indicates the set of functions the call site could possibly target at
    # run-time. This metadata is added to indirect call sites when the set of
    # possible targets can be determined by analysis and is known to be small. The
    # analysis driving the transformation is similar to constant propagation and
    # makes uses of the generic sparse propagation solver.
    # https://llvm.org/doxygen/CalledValuePropagation_8h_source.html
    # @return self
    def called_value_propagation!
      add_pass('called-value-propagation')
    end

    # @return self
    def deadargelim!
      add_pass('deadargelim')
    end

    alias dae! deadargelim!

    # ConstantMerge is designed to build up a map of available constants and eliminate duplicates when it is initialized.
    # https://llvm.org/doxygen/ConstantMerge_8cpp_source.html
    # https://llvm.org/doxygen/ConstantMerge_8h_source.html
    # @return self
    def constmerge!
      add_pass('constmerge')
    end

    alias const_merge! constmerge!

    # Aggressive Dead Code Elimination
    # @return self
    def adce!
      add_pass('adce')
    end

    # @return self
    def function_attrs!
      add_pass('function-attrs')
    end

    alias fun_attrs! function_attrs!

    # @return self
    def strip!
      add_pass('strip')
    end

    # @return self
    def strip_dead_prototypes!
      add_pass('strip-dead-prototypes')
    end

    alias sdp! strip_dead_prototypes!

    # @return self
    # preserve_gv - true / false to support previous option of all_but_main
    # otherwise preserve_gv is assumed to be an array of global variable names
    # internalize<preserve-gv=GV>
    # tests showing usage: https://github.com/llvm/llvm-project/blob/a4b429f9e4175a06cc95f054c5dab3d4bc8fa690/llvm/test/Transforms/Internalize/lists.ll#L17
    def internalize!(preserve_gv = [])
      preserved = case preserve_gv
      when true
        ['main']
      when false
        []
      else
        preserve_gv
      end
      preserved_string = preserved.map { |gv| "preserve-gv=#{gv}" }.join(';')

      if preserved_string.empty?
        add_pass('internalize')
      else
        add_pass("internalize<#{preserved_string}>")
      end
    end

    # This pass implements interprocedural sparse conditional constant propagation and merging.
    # https://llvm.org/doxygen/IPO_2SCCP_8h_source.html
    # https://llvm.org/doxygen/IPO_2SCCP_8cpp_source.html
    # @return self
    # @todo accept parameters ipsccp<no-func-spec;func-spec>
    def ipsccp!
      add_pass('ipsccp')
    end

    # @return self
    def global_opt!
      add_pass('globalopt')
    end

    # Global Dead Code Elimination
    # TODO: takes params
    # @return self
    def globaldce!
      add_pass('globaldce')
    end

    alias gdce! globaldce!

    # Bit-Tracking Dead Code Elimination pass
    # @return self
    def bdce!
      add_pass('bdce')
    end

    # Dead Store Elimination
    # his file implements a trivial dead store elimination that only considers basic-block local redundant stores.
    # https://llvm.org/doxygen/DeadStoreElimination_8h_source.html
    # @return self
    def dse!
      add_pass('dse')
    end

    # @return self
    def argpromotion!
      add_pass('argpromotion')
    end

    alias arg_promote! argpromotion!

    # The inliner pass for the new pass manager.
    # https://llvm.org/doxygen/classllvm_1_1InlinerPass.html
    # https://llvm.org/doxygen/Inliner_8h_source.html
    # https://llvm.org/doxygen/Inliner_8cpp_source.html
    # @return self
    def inline!
      add_pass('inline')
    end

    # Thread Sanitizer
    # https://clang.llvm.org/docs/ThreadSanitizer.html
    # @return self
    def tsan!
      add_pass('tsan')
    end

    # Thread Sanitiver - Module
    # https://clang.llvm.org/docs/ThreadSanitizer.html
    # @return self
    def tsan_module!
      add_pass('tsan-module')
    end

    # Hardware Assisted Address Sanitiver
    # TODO: takes params
    # https://clang.llvm.org/docs/HardwareAssistedAddressSanitizerDesign.html
    # https://llvm.org/doxygen/HWAddressSanitizer_8cpp_source.html
    # @return self
    def hwasan!(_options = {})
      add_pass('hwasan')
    end

    # Address Sanitizer
    # TODO: takes params
    # https://clang.llvm.org/docs/AddressSanitizer.html
    # https://llvm.org/doxygen/AddressSanitizer_8h_source.html
    # https://llvm.org/doxygen/AddressSanitizer_8cpp_source.html
    # @return self
    def asan!(options = {})
      opt_str = options[:kernel] ? '<kernel>' : ''
      add_pass("asan#{opt_str}")
    end

    # Memory Sanitizer
    # TODO: takes params
    # https://llvm.org/doxygen/MemorySanitizer_8cpp.html
    # https://llvm.org/doxygen/MemorySanitizer_8h_source.html
    # https://clang.llvm.org/docs/MemorySanitizer.html
    # KernelMemorySanitizer only supports X86_64 and SystemZ at the moment.
    # @return self
    def msan!(options = {})
      opt_str = options[:kernel] ? '<kernel>' : ''
      add_pass("msan#{opt_str}")
    end

    # DataFlow Sanitizer
    # https://clang.llvm.org/docs/DataFlowSanitizer.html
    # @return self
    def dfsan!
      add_pass('dfsan')
    end

    # https://clang.llvm.org/docs/SanitizerCoverage.html
    # @return self
    def sancov_module!
      add_pass('sancov-module')
    end

    # https://llvm.org/docs/doxygen/SanitizerBinaryMetadata_8h_source.html
    # @return self
    def sanmd_module!
      add_pass('sanmd-module')
    end

    def run(mod, target)
      return self if passes.empty?

      error = with_options { |options| C.run_passes(mod, pass_string, target, options) }
      if !error.null?
        error_msg = C.get_error_message(error)
        # TODO: clone then dispose of error_msg, currently produces "munmap_chunk(): invalid pointer"
        # save_message = error_msg.clone
        # C.dispose_error_message(error_msg)
        raise ArgumentError, error_msg
      end
      self
    end

    def pass_string
      passes.join(',')
    end

    def ipcp!
      deprecated('ipcp! / LLVMAddIPConstantPropagationPass was removed from LLVM')
    end

    def prune_eh!
      deprecated('prune_eh! / LLVMAddPruneEHPass was removed in LLVM 16')
    end

    def simplify_libcalls!
      deprecated('simplify_libcalls! / LLVMAddSimplifyLibCallsPass was removed from LLVM')
    end

    # https://reviews.llvm.org/D21316
    def scalarrepl!
      deprecated('scalarrepl was removed from LLVM in 2016 - use sroa')
      sroa!
    end

    # https://reviews.llvm.org/D21316
    def scalarrepl_ssa!
      deprecated('scalarrepl_ssa was removed from LLVM in 2016 - use sroa')
      sroa!
    end

    # https://reviews.llvm.org/D21316
    def scalarrepl_threshold!(_threshold = 0)
      deprecated('scalarrepl_threshold was removed from LLVM in 2016 - use sroa')
      sroa!
    end

    def bb_vectorize!
      warn('bb_vectorize! / LLVMAddBBVectorizePass was removed from LLVM - replace with slp_vectorize!')
      slp_vectorize!
    end

    def constprop!
      warn('constprop! / LLVMAddConstantPropagationPass was removed from LLVM')
    end

    def expand_variadics!
      add_pass('expand-variadics')
    end

    def pgo_force_function_attrs!
      add_pass('pgo-force-function-attrs')
    end

    def nsan!
      add_pass('nsan')
    end

    def pre_isel_intrinsic_lowering!
      add_pass('pre-isel-intrinsic-lowering')
    end

    def atomic_expand!
      add_pass('atomic-expand')
    end

    def jump_table_to_switch!
      add_pass('jump-table-to-switch')
    end

    def lower_allow_check!
      add_pass('lower-allow-check')
    end

    def lower_invoke!
      add_pass('lower-invoke')
    end

    alias lowerinvoke! lower_invoke!

    def lower_guard_intrinsic!
      add_pass('lower-guard-intrinsic')
    end

    def lower_widenable_condition!
      add_pass('lower-widenable-condition')
    end

    def transform_warning!
      add_pass('transform-warning')
    end

    def trigger_crash_function!
      add_pass('trigger-crash-function')
    end

    def trigger_verifier_error!
      add_pass('trigger-verifier-error')
    end

    def loop_idiom_vectorize!
      add_pass('loop-idiom-vectorize')
    end

    private

    attr_writer :passes

    def deprecated(message)
      warn message
      self
    end

    # updates options parameter and returns it
    def build_options!(options)
      if inliner_threshold
        C.set_inliner_threshold(options, inliner_threshold)
      end

      if merge_functions
        C.set_merge_functions(options, !!merge_functions)
      end

      options
    end

    # wraps creation and disposal of options in block
    def with_options
      options = C.create_pass_builder_options
      build_options!(options)
      yield options
    ensure
      C.dispose_pass_builder_options(options)
    end
  end

  module C
    #
    # @method run_passes(pmb, opt_level)
    # @param [OpaquePassManagerBuilder] pmb
    # @param [Integer] opt_level
    # @return [nil]
    # @scope class
    # /**
    #  * Construct and run a set of passes over a module
    #  *
    #  * This function takes a string with the passes that should be used. The format
    #  * of this string is the same as opt's -passes argument for the new pass
    #  * manager. Individual passes may be specified, separated by commas. Full
    #  * pipelines may also be invoked using `default<O3>` and friends. See opt for
    #  * full reference of the Passes format.
    #  */
    # LLVMErrorRef LLVMRunPasses(LLVMModuleRef M, const char *Passes,
    #                            LLVMTargetMachineRef TM,
    #                            LLVMPassBuilderOptionsRef Options);

    attach_function :run_passes, :LLVMRunPasses, [:pointer, :string, :pointer, :pointer], :pointer

    attach_function :create_pass_builder_options, :LLVMCreatePassBuilderOptions, [], :pointer

    attach_function :dispose_pass_builder_options, :LLVMDisposePassBuilderOptions, [:pointer], :void

    attach_function(:get_error_message, :LLVMGetErrorMessage, [:pointer], :string)

    attach_function(:dispose_error_message, :LLVMDisposeErrorMessage, [:string], :void)

    attach_function(:set_inliner_threshold, :LLVMPassBuilderOptionsSetInlinerThreshold, [:pointer, :int], :void)

    attach_function(:set_merge_functions, :LLVMPassBuilderOptionsSetMergeFunctions, [:pointer, :bool], :void)
  end
end
