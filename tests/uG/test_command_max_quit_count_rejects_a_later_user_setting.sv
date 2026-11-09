/*
:name: test_command_max_quit_count_rejects_a_later_user_setting
:description: command max quit count rejects a later user setting (IEEE 1800.2-2020 Section G.2.6)
:tags: uG uvm
:type: simulation
:lrm: 1800.2-2020 G.2.6 6.5.1.2.2 6.5.1.2.3 6.5.1.2.18 6.6.3.2 6.6.5 B.2.1.3 1800-2023 6.21
:uvm: 2020.3.1
:uvm_dpi: yes
:uvm_cmdline_backend: vpi
:uvm_defines: UVM_HDL_NO_DPI
:dpi_c: @../../tools/cmdline_backend/uvm_cmdline_vpi.cpp
:files: ../../tools/cmdline_backend/uvm_cmdline_regex.cpp ../../tools/cmdline_backend/malloc.h
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:args: +UVM_MAX_QUIT_COUNT=7,NO
:expected_stdout: @test_command_max_quit_count_rejects_a_later_user_setting.expected
*/
// What it checks:
// 1. The quit-count option sets the report-server maximum before user changes.
// 2. The NO overridable choice controls later procedural maximum changes.
// 3. A user change rejected by the NO option issues a warning.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 G.2.6 (UVM-CMDLINE-QUIT-NO-INITIAL) gives rule 1 above.
//    Setup: The invocation supplies count 7 and overridable=NO. Expected: The
//    initial public maximum query returns 7.
// 2. 1800.2-2020 G.2.6 (UVM-CMDLINE-QUIT-NO-USER-CHANGE) gives rule 2 above.
//    Setup: After command-line setup, user code attempts to set the maximum to
//    9. Expected: The maximum after the attempt is 7.
// 3. 1800.2-2020 G.2.6 (UVM-CMDLINE-QUIT-NO-WARNING) gives rule 3 above.
//    Setup: User code attempts to change a non-overridable maximum. Expected:
//    The original catcher sees a warning without fixing its diagnostic text.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The command line controls later procedural changes. Capture only whether a
// warning occurs; no warning text, report counts or quit termination is fixed.
module test_command_max_quit_count_rejects_a_later_user_setting;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class capture extends uvm_report_catcher;
    int warnings = 0;
    function new(); super.new("capture"); endfunction
    virtual function action_e catch();
      if (get_severity() == UVM_WARNING) begin warnings++; return CAUGHT; end
      return THROW;
    endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase);
      automatic uvm_report_server server = uvm_report_server::get_server();
      automatic capture probe = new();
      uvm_report_cb::add(null, probe);
      $display("UT: quit initial %0d", server.get_max_quit_count());
      server.set_max_quit_count(9);
      $display("UT: quit after %0d warning %0d", server.get_max_quit_count(),
               probe.warnings > 0);
      uvm_report_cb::delete(null, probe);
    endtask
  endclass
  initial run_test("t");
endmodule
