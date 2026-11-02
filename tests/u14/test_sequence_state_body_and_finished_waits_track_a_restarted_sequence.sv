/*
:name: test_sequence_state_body_and_finished_waits_track_a_restarted_sequence
:description: sequence state waits observe a new execution on a reused sequence handle (IEEE 1800.2-2020 Section 14.2.2.5)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.2.5 14.2.2.4 14.2.3.1 14.2.3.6 14.2.5.11 F.2.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_state_body_and_finished_waits_track_a_restarted_sequence.expected
*/
// Unbound virtual sequences with positive body delays; no driver or phases.
// Only mask/state behavior is asserted, not kill post-hook ordering.
module test_sequence_state_body_and_finished_waits_track_a_restarted_sequence;
  import uvm_pkg::*;

  class delayed_sequence extends uvm_sequence#(uvm_sequence_item);
    int entries = 0;
    int exits = 0;
    function new(string name); super.new(name); endfunction
    virtual task body(); entries++; #4; exits++; endtask
  endclass
  delayed_sequence first;
  delayed_sequence peer;
  bit first_wait_returned = 0;
  bit peer_wait_returned = 0;
  bit start_returned = 0;
  initial begin
    first = new("first"); peer = new("peer");

    first.start(null);
    $display("UT: first_run finished %0d entries %0d exits %0d",
    first.get_sequence_state() == UVM_FINISHED, first.entries, first.exits);
    fork
      first.start(null);
      begin
        first.wait_for_sequence_state(UVM_BODY);
        $display("UT: second_body body %0d exits %0d", first.get_sequence_state() == UVM_BODY,
        first.exits);
        first.wait_for_sequence_state(UVM_FINISHED);
        $display("UT: second_run entries %0d exits %0d", first.entries, first.exits);
      end
    join

    $finish;
  end
  initial begin #80; $fatal(1, "state wait watchdog expired"); end

endmodule
