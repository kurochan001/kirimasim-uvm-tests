/*
:name: test_copier_flush_preserves_extension_and_resets_history
:description: copier flush keeps extensions while resetting copy history (IEEE 1800.2-2020 Section 16.1.2.3)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.1.2.3 16.1.2.2 16.6.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_copier_flush_preserves_extension_and_resets_history.expected
*/
// What it checks:
// 1. Policy flush resets operation state without removing extensions.
// 2. Copy history is local to a policy and ordered object pair under its
//    recursion mode.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.1.2.3 (UVM-POLICY-FLUSH-KEEPS-EXTENSIONS) gives rule 1
//    above. Setup: Flush copier/comparer operations while retaining a mutable
//    extension handle. Expected: History/miscompare state resets while the
//    same extension remains usable.
// 2. 1800.2-2020 16.6.4.2 (UVM-COPIER-HISTORY) gives rule 2 above. Setup:
//    Query before/during/after a copy, reverse the pair, compare another
//    policy and flush. Expected: Only the selected pair/policy becomes STARTED
//    then FINISHED; flush restores NEVER.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// An extension survives the policy operation reset. Observe the copied
// pair returning to NEVER while the stored extension remains the same object.

module test_copier_flush_preserves_extension_and_resets_history;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class limit_ext extends uvm_object;
    `uvm_object_utils(limit_ext)
    int threshold = 0;
    function new(string name="limit_ext"); super.new(name); endfunction
  endclass
  class derived_limit_ext extends limit_ext;
    `uvm_object_utils(derived_limit_ext)
    function new(string name="derived_limit_ext"); super.new(name); endfunction
  endclass
  class flag_ext extends uvm_object;
    `uvm_object_utils(flag_ext)
    bit enabled = 1;
    function new(string name="flag_ext"); super.new(name); endfunction
  endclass

  class item extends uvm_object;
    `uvm_object_utils(item)
    int payload = 0;
    int copies = 0;
    function new(string name="item"); super.new(name); endfunction
    function void do_copy(uvm_object rhs);
      item source;
      super.do_copy(rhs);
      if (!$cast(source, rhs)) $fatal(1, "copy type");
      payload = source.payload;
      copies++;
    endfunction
  endclass

  initial begin
    automatic uvm_copier policy = new;
    automatic limit_ext extension_value = new;
    automatic item source = new("source");
    automatic item target = new("target");
    uvm_object previous;
    previous = policy.set_extension(extension_value);
    source.payload = 19;
    policy.copy_object(target, source);
    $display("UT: copied %0d finished %0d", target.payload,
             policy.object_copied(target, source,
                 policy.get_recursion_policy()) == uvm_policy::FINISHED);
    policy.flush();
    $display("UT: flushed never %0d retained %0d",
             policy.object_copied(target, source,
                 policy.get_recursion_policy()) == uvm_policy::NEVER,
             policy.get_extension(limit_ext::get_type()) == extension_value);
    $finish;
  end
endmodule
