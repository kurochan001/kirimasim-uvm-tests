/*
:name: test_command_testname_creates_the_first_registered_test_and_warns_for_duplicates
:description: command testname creates the first registered test and warns for duplicates (IEEE 1800.2-2020 Section G.2.1)
:tags: uG uvm
:type: simulation
:lrm: 1800.2-2020 G.2.1 F.7.3.1 B.2.1.3 6.6.5 6.6.3.2 1800-2023 6.21
:uvm: 2020.3.1
:uvm_dpi: yes
:uvm_cmdline_backend: vpi
:uvm_cmdline_oracle: verilator@5.052
:uvm_defines: UVM_HDL_NO_DPI
:dpi_c: @../../tools/cmdline_backend/uvm_cmdline_vpi.cpp
:files: ../../tools/cmdline_backend/uvm_cmdline_regex.cpp ../../tools/cmdline_backend/malloc.h
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:args: +UVM_TESTNAME=selected_test +UVM_TESTNAME=other_test
:expected_stdout: @test_command_testname_creates_the_first_registered_test_and_warns_for_duplicates.expected
*/
// What it checks:
// 1. The first testname option selects the factory-created UVM test.
// 2. Additional testname settings produce a warning while the first remains
//    selected.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 G.2.1 (UVM-CMDLINE-TESTNAME-FIRST-SELECTION) gives rule 1
//    above. Setup: Two registered test names are supplied, with selected_test
//    first and no procedural test name. Expected: Only selected_test runs its
//    observation.
// 2. 1800.2-2020 G.2.1 (UVM-CMDLINE-TESTNAME-DUPLICATE-WARNING) gives rule 2
//    above. Setup: The invocation supplies a second different registered
//    testname. Expected: A warning is counted without fixing its text or ID.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Select the test through real command-line factory lookup. Warning text and
// IDs are not fixed; only a warning is required for the duplicate option.
// The final block observes the server count after run_test terminates.
module test_command_testname_creates_the_first_registered_test_and_warns_for_duplicates;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class warning_probe extends uvm_report_catcher;
    int warnings = 0;
    function new(); super.new("probe"); endfunction
    virtual function action_e catch();
      if (get_severity() == UVM_WARNING) warnings++;
      return THROW;
    endfunction
  endclass
  class selected_test extends uvm_test;
    `uvm_component_utils(selected_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase); $display("UT: selected_test 1"); endtask
  endclass
  class other_test extends uvm_test;
    `uvm_component_utils(other_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase); $display("UT: selected_test 0"); endtask
  endclass
  initial begin
    automatic warning_probe probe = new();
    uvm_report_cb::add(null, probe);
    run_test();
  end
  final begin
    automatic uvm_report_server server = uvm_report_server::get_server();
    $display("UT: duplicate_warning %0d", server.get_severity_count(UVM_WARNING) > 0);
  end
endmodule
