/*
:name: test_port_binding_resolution_checks_lower_and_upper_cardinality_bounds
:description: resolved cardinality checks detect both insufficient and excessive bindings (5.5.2.15)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.5.2.15 5.5.2.12 12.2.6.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_port_binding_resolution_checks_lower_and_upper_cardinality_bounds.expected
*/
module test_port_binding_resolution_checks_lower_and_upper_cardinality_bounds;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class report_probe extends uvm_report_catcher;
    int reports = 0;
    function new(); super.new("probe"); endfunction
    function action_e catch();
      if (get_severity() inside {UVM_WARNING, UVM_ERROR}) begin
        reports++;
        return CAUGHT;
      end
      return THROW;
    endfunction
  endclass
  class sink extends uvm_component;
    uvm_blocking_put_imp#(int, sink) imp;
    function new(string name, uvm_component parent);
      super.new(name, parent); imp = new("imp", this);
    endfunction
    task put(int value); endtask
  endclass
  // Resolve each port separately to associate its diagnostic with the call.
  // No diagnostic client, count, ID, text, severity or index order is fixed.
  initial begin
    automatic sink owner = new("owner", null);
    automatic sink left = new("left", owner);
    automatic sink right = new("right", owner);
    automatic uvm_blocking_put_export#(int) low = new("low", owner, 1, 1);
    automatic uvm_blocking_put_export#(int) high = new("high", owner, 0, 1);
    automatic uvm_blocking_put_export#(int) valid = new("valid", owner, 1, 2);
    automatic report_probe probe = new();
    automatic int lower_reports, upper_reports, valid_reports;
    high.connect(left.imp); high.connect(right.imp);
    valid.connect(left.imp); valid.connect(right.imp);
    uvm_report_cb::add(null, probe);
    low.resolve_bindings(); lower_reports = probe.reports;
    probe.reports = 0;
    high.resolve_bindings(); upper_reports = probe.reports;
    probe.reports = 0;
    valid.resolve_bindings(); valid_reports = probe.reports;
    $display(
      "UT: resolved sizes %0d %0d %0d lower_reported %0d upper_reported %0d valid_clean %0d",
      low.size(), high.size(), valid.size(),
      lower_reports > 0, upper_reports > 0, valid_reports == 0);
    uvm_report_cb::delete(null, probe);
    $finish;
  end
endmodule
