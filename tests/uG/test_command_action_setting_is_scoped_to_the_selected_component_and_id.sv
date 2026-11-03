/*
:name: test_command_action_setting_is_scoped_to_the_selected_component_and_id
:description: command action setting is scoped to the selected component and id (IEEE 1800.2-2020 Section G.2.4)
:tags: uG uvm
:type: simulation
:lrm: 1800.2-2020 G.2.4 6.3.5.1 6.3.5.2 B.2.1.3 1800-2023 6.21
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
:args: +uvm_set_action=uvm_test_top.leaf,picked,UVM_WARNING,UVM_NO_ACTION
:expected_stdout: @test_command_action_setting_is_scoped_to_the_selected_component_and_id.expected
*/
// Observe effective public action settings without formatted output. The
// selected literal component/ID condition does not test ALL or action unions.
module test_command_action_setting_is_scoped_to_the_selected_component_and_id;
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
      $display("UT: action selected %0d other_id %0d peer %0d",
               leaf.get_report_action(UVM_WARNING, "picked") == UVM_NO_ACTION,
               leaf.get_report_action(UVM_WARNING, "other") == UVM_DISPLAY,
               peer.get_report_action(UVM_WARNING, "picked") == UVM_DISPLAY);
    endtask
  endclass
  initial run_test("t");
endmodule
