/*
:name: test_command_timed_verbosity_updates_the_selected_id_and_component_only
:description: command timed verbosity updates the selected id and component only (IEEE 1800.2-2020 Section G.2.3)
:tags: uG uvm
:type: simulation
:lrm: 1800.2-2020 G.2.3 6.3.4.1 6.3.4.4 F.2.2.4 B.2.1.3 1800-2023 6.21
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
:args: +uvm_set_verbosity=uvm_test_top.leaf,picked,UVM_HIGH,time,3 +uvm_set_verbosity=uvm_test_top.leaf,picked,UVM_LOW,time,6
:expected_stdout: @test_command_timed_verbosity_updates_the_selected_id_and_component_only.expected
*/
// What it checks:
// 1. A timed verbosity option updates its selected component and ID at the
//    scheduled time.
// 2. A later timed option replaces the earlier verbosity for the same selected
//    key.
// 3. Timed component/ID settings preserve unmatched IDs and components.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 G.2.3 (UVM-CMDLINE-TIMED-VERBOSITY-FIRST-SETTING) gives rule
//    1 above. Setup: HIGH is scheduled at time 3 and observed at time 4.
//    Expected: Before the setting the default remains; afterwards the selected
//    ID is HIGH.
// 2. 1800.2-2020 G.2.3 (UVM-CMDLINE-TIMED-VERBOSITY-LATER-SETTING) gives rule
//    2 above. Setup: LOW is scheduled at time 6 after HIGH at time 3.
//    Expected: The observation at time 7 sees LOW.
// 3. 1800.2-2020 G.2.3 (UVM-CMDLINE-TIMED-VERBOSITY-ISOLATION) gives rule 3
//    above. Setup: Another ID and a peer are queried after both scheduled
//    updates. Expected: Both controls retain default MEDIUM verbosity.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Observe after, rather than exactly at, each scheduled time. Selected
// component/ID changes must preserve another ID and an outside peer.
// Non-run phase settings and equal-time ordering remain separate conditions.
module test_command_timed_verbosity_updates_the_selected_id_and_component_only;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class node extends uvm_component;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    node leaf, peer;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase); leaf = new("leaf", this); peer = new("peer", this);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      #1; $display("UT: timed before %0d",
                  leaf.get_report_verbosity_level(UVM_INFO, "picked") == UVM_MEDIUM);
      #3; $display("UT: timed first %0d other %0d peer %0d",
                  leaf.get_report_verbosity_level(UVM_INFO, "picked") == UVM_HIGH,
                  leaf.get_report_verbosity_level(UVM_INFO, "other") == UVM_MEDIUM,
                  peer.get_report_verbosity_level(UVM_INFO, "picked") == UVM_MEDIUM);
      #3; $display("UT: timed second %0d other %0d peer %0d",
                  leaf.get_report_verbosity_level(UVM_INFO, "picked") == UVM_LOW,
                  leaf.get_report_verbosity_level(UVM_INFO, "other") == UVM_MEDIUM,
                  peer.get_report_verbosity_level(UVM_INFO, "picked") == UVM_MEDIUM);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
endmodule
