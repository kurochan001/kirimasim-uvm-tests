/*
:name: test_queue_empty_pop_front_warns_returns_default_and_allows_refill
:description: empty queue removal warns and returns the two-state default before a successful refill (IEEE 1800.2-2020 Section 11.3.2.8)
:tags: u11 uvm
:type: simulation
:lrm: 1800.2-2020 11.3.2.8 11.3.2.5 11.3.2.10 11.3.2.11 6.6.3.2 6.6.5 D.4.4 1800-2023 6.11.2 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_queue_empty_pop_front_warns_returns_default_and_allows_refill.expected
*/
// What it checks:
// Popping an empty queue at the front warns and returns the element type
// default.
//
// How the expected output follows from the standard:
// 1800.2-2020 11.3.2.8 (UVM-QUEUE-EMPTY-POP-FRONT) gives the rule above.
// Setup: Pop an initially empty two-state queue, refill/drain it, and pop
// again. Expected: Both empty calls return zero and each warns; successful
// removals retain front/back order.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The pinned library omits the required warning on native empty pops.
module test_queue_empty_pop_front_warns_returns_default_and_allows_refill;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  typedef bit [31:0] word_t;
  class warning_probe extends uvm_report_catcher;
    int warnings = 0;
    function new(); super.new("probe"); endfunction
    virtual function action_e catch();
      if (get_severity() == UVM_WARNING) begin warnings++; return CAUGHT; end
      return THROW;
    endfunction
  endclass

  initial begin
    automatic uvm_queue#(word_t) queue_value = new("queue_value");
    automatic warning_probe probe = new();
    word_t value;
    uvm_report_cb::add(null, probe);
    value = queue_value.pop_front();
    $display("UT: empty default %0d warnings %0d size %0d", value, probe.warnings,
        queue_value.size());
    queue_value.push_back(42); queue_value.push_front(17);
    value = queue_value.pop_front();
    $display("UT: refilled value %0d warnings %0d remaining %0d", value, probe.warnings,
        queue_value.size());
    value = queue_value.pop_front();
    $display("UT: drained value %0d size %0d", value, queue_value.size());
    value = queue_value.pop_front();
    $display("UT: empty_again default %0d warnings %0d size %0d", value, probe.warnings,
        queue_value.size());
    uvm_report_cb::delete(null, probe);
    $finish;
  end

endmodule
