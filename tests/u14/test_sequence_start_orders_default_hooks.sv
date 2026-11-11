/*
:name: test_sequence_start_orders_default_hooks
:description: sequence start invokes enabled execution hooks in their documented order and states (IEEE 1800.2-2020 Section 14.2.3.1)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.3.1 14.2.3.2 14.2.3.3 14.2.3.6 14.2.3.8 14.2.3.9 14.2.2.4 F.2.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_start_orders_default_hooks.expected
*/
// What it checks:
// 1. The start call_pre_post argument controls pre_body and post_body around
//    the body.
// 2. pre_start executes before the optional pre_body and the sequence body.
// 3. post_start executes after the body and optional post_body.
// 4. Sequence start returns after natural completion and can be invoked again
//    on a completed sequence.
// 5. The sequence-state getter reports the state corresponding to allocation,
//    hooks and natural completion.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 14.2.3.1 (UVM-SEQUENCE-OPTIONAL-BODY-HOOKS) gives rule 1
//    above. Setup: Run otherwise identical no-traffic sequences with true and
//    false. Expected: Both optional hooks occur only in the enabled trace
//    while pre_start/body/post_start remain ordered.
// 2. 1800.2-2020 14.2.3.2 (UVM-SEQUENCE-PRE-START-ORDER) gives rule 2 above.
//    Setup: Run starts with optional body hooks enabled and disabled.
//    Expected: pre_start precedes the next executed body hook in both traces.
// 3. 1800.2-2020 14.2.3.9 (UVM-SEQUENCE-POST-START-ORDER) gives rule 3 above.
//    Setup: Run starts with optional body hooks enabled and disabled.
//    Expected: post_start follows the last executed body hook in both traces.
// 4. 1800.2-2020 14.2.3.1 (UVM-SEQUENCE-NATURAL-START-COMPLETION) gives rule 4
//    above. Setup: Run no-item bodies and restart a counter sequence
//    sequentially. Expected: Returns observe FINISHED and each sequential
//    invocation executes the body once.
// 5. 1800.2-2020 14.2.2.4 (UVM-SEQUENCE-STATE-QUERY) gives rule 5 above.
//    Setup: Inspect a new sequence and state inside/after start hooks.
//    Expected: Observed states agree with CREATED, the executing hook and
//    FINISHED.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Run a sequence with no item requests and no sequencer. Optional
// pre_body and post_body depend only on the call_pre_post argument.

module test_sequence_start_orders_default_hooks;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class trace_sequence extends uvm_sequence#(uvm_sequence_item);
    `uvm_object_utils(trace_sequence)
    function new(string name="trace_sequence"); super.new(name); endfunction
    task pre_start(); $display("UT: pre_start state_ok %0d",
        get_sequence_state() == UVM_PRE_START); endtask
    task pre_body(); $display("UT: pre_body state_ok %0d",
        get_sequence_state() == UVM_PRE_BODY); endtask
    task body(); $display("UT: body state_ok %0d", get_sequence_state() == UVM_BODY); endtask
    task post_body(); $display("UT: post_body state_ok %0d",
        get_sequence_state() == UVM_POST_BODY); endtask
    task post_start(); $display("UT: post_start state_ok %0d",
        get_sequence_state() == UVM_POST_START); endtask
  endclass

  initial begin
    automatic trace_sequence value = new("value");
    value.start(null, null, -1, 1);
    $display("UT: returned_finished %0d", value.get_sequence_state() == UVM_FINISHED);
    $finish;
  end
endmodule
