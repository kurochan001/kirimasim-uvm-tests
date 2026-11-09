/*
:name: test_command_severity_override_changes_the_selected_report_and_preserves_controls
:description: command severity override changes the selected report and preserves controls (IEEE 1800.2-2020 Section G.2.5)
:tags: uG uvm
:type: simulation
:lrm: 1800.2-2020 G.2.5 6.3.7 6.6.3.2 6.6.5 B.2.1.3 1800-2023 6.21
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
:args: +uvm_set_severity=uvm_test_top.leaf,picked,UVM_ERROR,UVM_WARNING
:expected_stdout: @test_command_severity_override_changes_the_selected_report_and_preserves_controls.expected
*/
// What it checks:
// 1. The command-line severity option changes the selected original severity.
// 2. A scoped severity option preserves unmatched reports.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 G.2.5 (UVM-CMDLINE-SEVERITY-SETTING) gives rule 1 above.
//    Setup: One leaf/picked ERROR is configured to WARNING. Expected: The
//    catcher receives the selected report as WARNING.
// 2. 1800.2-2020 G.2.5 (UVM-CMDLINE-SEVERITY-ISOLATION) gives rule 2 above.
//    Setup: Another ID and a peer emit ERROR controls. Expected: Both controls
//    reach the catcher as ERROR.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// An original catcher observes severity after override and suppresses output.
// No server formatting, ALL keyword or multiple-override ordering is inferred.
module test_command_severity_override_changes_the_selected_report_and_preserves_controls;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class capture extends uvm_report_catcher;
    uvm_severity seen[$];
    function new(); super.new("capture"); endfunction
    virtual function action_e catch(); seen.push_back(get_severity()); return CAUGHT; endfunction
  endclass
  class node extends uvm_component;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    node leaf, peer;
    capture probe;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase); leaf = new("leaf", this); peer = new("peer", this);
      probe = new(); uvm_report_cb::add(leaf, probe); uvm_report_cb::add(peer, probe);
    endfunction
    task run_phase(uvm_phase phase);
      leaf.uvm_report_error("picked", "payload", UVM_NONE);
      leaf.uvm_report_error("other", "payload", UVM_NONE);
      peer.uvm_report_error("picked", "payload", UVM_NONE);
      $display("UT: severity count %0d selected %0d other_id %0d peer %0d", probe.seen.size(),
               probe.seen[0] == UVM_WARNING, probe.seen[1] == UVM_ERROR,
               probe.seen[2] == UVM_ERROR);
    endtask
  endclass
  initial run_test("t");
endmodule
