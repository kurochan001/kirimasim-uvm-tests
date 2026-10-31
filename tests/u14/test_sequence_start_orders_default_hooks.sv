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
