/*
:name: test_queue_out_of_range_get_warns_returns_a_two_state_default_and_retains_data
:description: out-of-range get warns and returns the two-state type default without removing queued data (11.3.2.4)
:tags: u11 uvm
:type: simulation
:lrm: 1800.2-2020 11.3.2.4 11.3.2.5 11.3.2.11 6.6.3.2 D.4.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_queue_out_of_range_get_warns_returns_a_two_state_default_and_retains_data.expected
*/
// What it checks:
// A get at or above size warns and returns the missing-entry default for the
// element type.
//
// How the expected output follows from the standard:
// 1800.2-2020 11.3.2.4 (UVM-QUEUE-OUT-OF-RANGE-GET-TWO-STATE-DEFAULT) gives
// the rule above. Setup: Read at size and size plus one from a two-entry
// two-state bit-vector queue. Expected: There are two warnings, no errors and
// zero defaults; both original entries remain in order.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_queue_out_of_range_get_warns_returns_a_two_state_default_and_retains_data;
  import uvm_pkg::*;
  class warning_probe extends uvm_report_catcher;
    int warnings = 0;
    int errors = 0;
    function new(); super.new("probe"); endfunction
    virtual function action_e catch();
      if (get_severity() == UVM_WARNING) begin warnings++; return CAUGHT; end
      if (get_severity() == UVM_ERROR) begin errors++; return CAUGHT; end
      return THROW;
    endfunction
  endclass
  initial begin
    automatic uvm_queue#(bit[15:0]) queue = new("queue");
    automatic warning_probe probe = new();
    bit [15:0] at_size, above_size;
    queue.push_back('habcd);
    queue.push_back('hef12);
    uvm_report_cb::add(null, probe);
    at_size = queue.get(2);
    above_size = queue.get(3);
    uvm_report_cb::delete(null, probe);
    $display("UT: warnings %0d errors %0d defaults %0d %0d",
             probe.warnings, probe.errors, at_size == 0, above_size == 0);
    $display("UT: retained size %0d first %0d second %0d", queue.size(),
             queue.get(0) == 'habcd, queue.get(1) == 'hef12);
    $finish;
  end
endmodule
