/*
:name: test_report_catcher_verbosity_mutation_reaches_tail_without_leaking_to_next_report
:description: catcher mutation reaches later callbacks and stays local to the current report (IEEE 1800.2-2020 Section 6.6.4.2)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.6.4.2 6.6.3.4 6.6.3.8 6.6.3.9 6.6 D.4.4 6.3.3.3 6.3.4.3 6.3.5.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_catcher_verbosity_mutation_reaches_tail_without_leaking_to_next_report.expected
*/
// Only the first report is changed. The tail catches both before emission.
// Source location and original state guard against stale-message reuse.
module test_report_catcher_verbosity_mutation_reaches_tail_without_leaking_to_next_report;
  import uvm_pkg::*;
  class mutator extends uvm_report_catcher;
    int visits = 0;
    bit original_state = 1;
    function new(); super.new("mutator"); endfunction
    virtual function action_e catch();
      visits++;
      original_state &= get_verbosity() == UVM_LOW;
      if (visits == 1) set_verbosity(UVM_HIGH);
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
      selected_state &= get_verbosity() == (visits == 1 ? UVM_HIGH : UVM_LOW);
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
