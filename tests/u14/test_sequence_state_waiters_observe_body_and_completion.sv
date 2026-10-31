/*
:name: test_sequence_state_waiters_observe_body_and_completion
:description: sequence state waiters observe body execution and return immediately for a matching finished mask (IEEE 1800.2-2020 Section 14.2.2.5)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.2.5 14.2.2.4 14.2.3.1 14.2.3.6 F.2.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_state_waiters_observe_body_and_completion.expected
*/
// The sequence handle has module lifetime for forked access. A
// positive body delay makes BODY observable; a watchdog bounds the wait.

module test_sequence_state_waiters_observe_body_and_completion;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class delayed_sequence extends uvm_sequence#(uvm_sequence_item);
    `uvm_object_utils(delayed_sequence)
    function new(string name="delayed_sequence"); super.new(name); endfunction
    task body(); #2; endtask
  endclass
  delayed_sequence value;
  initial begin
    value = new("value");
    fork
      value.start(null);
      begin
        value.wait_for_sequence_state(UVM_BODY);
        $display("UT: observed_body %0d", value.get_sequence_state() == UVM_BODY);
        value.wait_for_sequence_state(UVM_FINISHED);
        $display("UT: observed_finished %0d", value.get_sequence_state() == UVM_FINISHED);
      end
    join
    value.wait_for_sequence_state(UVM_STOPPED | UVM_FINISHED);
    $display("UT: matching_mask_returned 1");
    $finish;
  end
  initial begin
    #30;
    $fatal(1, "test watchdog expired");
  end
endmodule
