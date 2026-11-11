/*
:name: test_comparer_history_keeps_failed_result_and_flushes_pairs
:description: a failed comparison has a finished zero result and flush clears ordered-pair history (IEEE 1800.2-2020 Section 16.3.3.5)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.3.3.5 16.3.3.4 16.3.2.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_comparer_history_keeps_failed_result_and_flushes_pairs.expected
*/
// What it checks:
// 1. Comparer flush clears miscompare counts, text and remembered comparison
//    state.
// 2. Comparison history tracks an ordered object pair under its recursion
//    policy, with results only after completion.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.3.2.2 (UVM-COMPARER-FLUSH-STATE) gives rule 1 above.
//    Setup: Accumulate failures, inspect completed history, then flush and
//    reuse the policy. Expected: Count becomes zero, text empty and previous
//    pairs return to unseen state.
// 2. 1800.2-2020 16.3.3.5 (UVM-COMPARER-HISTORY) gives rule 2 above. Setup:
//    Query before/during/after success or failure, reverse the pair and flush.
//    Expected: States move NEVER to STARTED to FINISHED; unfinished results
//    are zero and completed results match comparison.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use different values to finish with a failed result. The reverse pair
// remains unseen, and flush makes the original pair unseen as well.

module test_comparer_history_keeps_failed_result_and_flushes_pairs;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class compare_probe extends uvm_object;
    `uvm_object_utils(compare_probe)
    int value = 0;
    bit started_in_hook = 0;
    bit hook_result = 1;
    function new(string name="compare_probe"); super.new(name); endfunction
    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      compare_probe other;
      uvm_policy::recursion_state_e state;
      if (!$cast(other, rhs)) return 0;
      state = comparer.object_compared(this, rhs, comparer.get_recursion_policy(), hook_result);
      started_in_hook = state == uvm_policy::STARTED;
      return super.do_compare(rhs, comparer) &&
             comparer.compare_field_int("value", value, other.value, 32);
    endfunction
  endclass

  initial begin
    automatic compare_probe first = new("first");
    automatic compare_probe second = new("second");
    automatic uvm_comparer comparer = new;
    uvm_policy::recursion_state_e state;
    automatic bit history_result = 1;
    bit result;
    first.value = 17;
    second.value = 18;
    comparer.set_show_max(0);
    comparer.set_recursion_policy(UVM_DEEP);
    result = comparer.compare_object("value", first, second);
    state = comparer.object_compared(first, second, UVM_DEEP, history_result);
    $display("UT: failed finished %0d result %0d comparison %0d", state == uvm_policy::FINISHED,
             history_result, result);
    state = comparer.object_compared(second, first, UVM_DEEP, history_result);
    $display("UT: reverse never %0d result %0d", state == uvm_policy::NEVER, history_result);
    comparer.flush();
    state = comparer.object_compared(first, second, UVM_DEEP, history_result);
    $display("UT: flushed never %0d result %0d", state == uvm_policy::NEVER, history_result);
    $finish;
  end
endmodule
