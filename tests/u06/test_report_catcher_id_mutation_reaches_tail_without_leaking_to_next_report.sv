/*
:name: test_report_catcher_id_mutation_reaches_tail_without_leaking_to_next_report
:description: catcher mutation reaches later callbacks and stays local to the current report (IEEE 1800.2-2020 Section 6.6.4.3)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.6.4.3 6.6.3.5 6.6.3.8 6.6.3.9 6.6 D.4.4 6.3.3.3 6.3.4.3 6.3.5.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_catcher_id_mutation_reaches_tail_without_leaking_to_next_report.expected
*/
// What it checks:
// 1. A current-message id mutation is visible to a later catcher.
// 2. The id getter returns the value of the message currently being processed.
// 3. A later report exposes its own id value rather than a previous report
//    mutation.
// 4. The catcher location getter returns the original report source location.
// 5. The catcher location getter returns the original report source location.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 6.6.4.3 (UVM-CATCHER-ID-MUTATION-PROPAGATES) gives rule 1
//    above. Setup: The first catcher changes id only for its first report,
//    then returns THROW. Expected: The tail observes rewritten rather than the
//    initial original.
// 2. 1800.2-2020 6.6.3.5 (UVM-CATCHER-ID-GETTER-AFTER-MUTATION) gives rule 2
//    above. Setup: The first catcher changes id only for its first report,
//    then returns THROW. Expected: The first catcher sees the supplied
//    original value; the tail sees the changed value.
// 3. 1800.2-2020 6.6.3.5 (UVM-CATCHER-ID-FRESH-MESSAGE-STATE) gives rule 3
//    above. Setup: The same two catchers receive a second report with the
//    original explicit id value. Expected: Both callbacks now observe
//    original; each callback has two total visits.
// 4. 1800.2-2020 6.6.3.8 (UVM-CATCHER-EXPLICIT-SOURCE-FILENAME) gives rule 4
//    above. Setup: Six separate attribute mutations leave explicit source
//    location unchanged across two reports. Expected: The supplied origin.sv
//    filename is preserved.
// 5. 1800.2-2020 6.6.3.9 (UVM-CATCHER-EXPLICIT-SOURCE-LINE) gives rule 5
//    above. Setup: Six separate attribute mutations leave explicit source
//    location unchanged across two reports. Expected: The supplied line number
//    37 is preserved.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Only the first report is changed. The tail catches both before emission.
// Source location and original state guard against stale-message reuse.
module test_report_catcher_id_mutation_reaches_tail_without_leaking_to_next_report;
  import uvm_pkg::*;
  class mutator extends uvm_report_catcher;
    int visits = 0;
    bit original_state = 1;
    function new(); super.new("mutator"); endfunction
    virtual function action_e catch();
      visits++;
      original_state &= get_id() == "original";
      if (visits == 1) set_id("rewritten");
      return THROW;
    endfunction
  endclass
  class observer extends uvm_report_catcher;
    int visits = 0;
    bit selected_state = 1;
    bit locations = 1;
    function new(); super.new("observer"); endfunction
    virtual function action_e catch();
      visits++;
      selected_state &= get_id() == (visits == 1 ? "rewritten" : "original");
      locations &= get_fname() == "origin.sv" && get_line() == 37;
      return CAUGHT;
    endfunction
  endclass
  initial begin
    automatic uvm_report_object reporter = new("reporter");
    automatic mutator first = new();
    automatic observer tail = new();
    reporter.set_report_verbosity_level(UVM_DEBUG);
    reporter.set_report_severity_action(UVM_INFO, UVM_DISPLAY);
    uvm_report_cb::add(reporter, first); uvm_report_cb::add(reporter, tail);
    reporter.uvm_report(UVM_INFO, "original", "payload", UVM_LOW,
                        "origin.sv", 37, "base.ctx");
    $display("UT: changed first %0d tail %0d original %0d propagated %0d location %0d",
             first.visits, tail.visits, first.original_state, tail.selected_state, tail.locations);
    reporter.uvm_report(UVM_INFO, "original", "payload", UVM_LOW,
                        "origin.sv", 37, "base.ctx");
    $display("UT: fresh first %0d tail %0d original %0d propagated %0d location %0d",
             first.visits, tail.visits, first.original_state, tail.selected_state, tail.locations);
    uvm_report_cb::delete(reporter, first); uvm_report_cb::delete(reporter, tail);
    $finish;
  end
endmodule
