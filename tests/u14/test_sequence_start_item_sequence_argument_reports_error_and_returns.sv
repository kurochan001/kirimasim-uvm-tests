/*
:name: test_sequence_start_item_sequence_argument_reports_error_and_returns
:description: start_item rejects a child sequence argument with ERROR and returns (IEEE 1800.2-2020 Section 14.2.6.2)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.6.2 6.6.3.2 6.6.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_start_item_sequence_argument_reports_error_and_returns.expected
*/
// Pass a sequence whose is_item query returns zero. The convenience API
// must reject it before selecting a sequencer or invoking pre_do.
// Count the original severity without changing it. Catch reports only so
// the early return can be observed. The pinned library uses FATAL instead
// of the required ERROR; keep the normative expectation as spec-only.

module test_sequence_start_item_sequence_argument_reports_error_and_returns;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    function new(string name="packet"); super.new(name); endfunction
  endclass
  class child_sequence extends uvm_sequence#(packet);
    `uvm_object_utils(child_sequence)
    function new(string name="child_sequence"); super.new(name); endfunction
    task body(); endtask
  endclass
  class severity_probe extends uvm_report_catcher;
    int errors = 0;
    int fatals = 0;
    function new(string name="severity_probe"); super.new(name); endfunction
    function action_e catch();
      if (get_severity() == UVM_ERROR) begin errors++; return CAUGHT; end
      if (get_severity() == UVM_FATAL) begin fatals++; return CAUGHT; end
      return THROW;
    endfunction
  endclass
  class producer extends uvm_sequence#(packet);
    `uvm_object_utils(producer)
    int pre_calls = 0;
    bit returned = 0;
    function new(string name="producer"); super.new(name); endfunction
    task pre_do(bit is_item); pre_calls++; endtask
    task body();
      packet item = new("item");
      child_sequence child = new("child");
      start_item(child);
      returned = 1;
    endtask
  endclass
  initial begin
    automatic producer value = new("value");
    automatic severity_probe probe = new;
    uvm_report_cb::add(null, probe);
    value.start(null);
    $display("UT: returned %0d pre_calls %0d errors %0d fatals %0d", value.returned,
             value.pre_calls, probe.errors, probe.fatals);
    $finish;
  end
  initial begin
    #40;
    $fatal(1, "test watchdog expired");
  end
endmodule
