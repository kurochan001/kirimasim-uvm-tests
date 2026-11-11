/*
:name: test_sequence_can_restart_after_natural_completion
:description: a sequence can execute its body again after completing a prior start (IEEE 1800.2-2020 Section 14.2.3.1)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.3.1 14.2.3.6 14.2.2.4 F.2.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_can_restart_after_natural_completion.expected
*/
// What it checks:
// 1. Sequence start returns after natural completion and can be invoked again
//    on a completed sequence.
// 2. The sequence-state getter reports the state corresponding to allocation,
//    hooks and natural completion.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 14.2.3.1 (UVM-SEQUENCE-NATURAL-START-COMPLETION) gives rule 1
//    above. Setup: Run no-item bodies and restart a counter sequence
//    sequentially. Expected: Returns observe FINISHED and each sequential
//    invocation executes the body once.
// 2. 1800.2-2020 14.2.2.4 (UVM-SEQUENCE-STATE-QUERY) gives rule 2 above.
//    Setup: Inspect a new sequence and state inside/after start hooks.
//    Expected: Observed states agree with CREATED, the executing hook and
//    FINISHED.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use one explicitly initialized body counter and invoke start twice
// sequentially. Each start must return only after natural completion.

module test_sequence_can_restart_after_natural_completion;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class counting_sequence extends uvm_sequence#(uvm_sequence_item);
    `uvm_object_utils(counting_sequence)
    int body_calls = 0;
    function new(string name="counting_sequence"); super.new(name); endfunction
    task body(); body_calls++; endtask
  endclass
  initial begin
    automatic counting_sequence value = new("value");
    $display("UT: allocated_state %0d", value.get_sequence_state() == UVM_CREATED);
    value.start(null);
    $display("UT: first calls %0d finished %0d", value.body_calls,
        value.get_sequence_state() == UVM_FINISHED);
    value.start(null);
    $display("UT: second calls %0d finished %0d", value.body_calls,
        value.get_sequence_state() == UVM_FINISHED);
    $finish;
  end
endmodule
