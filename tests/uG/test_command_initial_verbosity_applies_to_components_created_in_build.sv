/*
:name: test_command_initial_verbosity_applies_to_components_created_in_build
:description: command initial verbosity applies to components created in build (IEEE 1800.2-2020 Section G.2.2)
:tags: uG uvm
:type: simulation
:lrm: 1800.2-2020 G.2.2 6.3.4.1 6.3.4.2 F.2.2.4 B.2.1.3 1800-2023 6.21
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
:args: +UVM_VERBOSITY=UVM_HIGH
:expected_stdout: @test_command_initial_verbosity_applies_to_components_created_in_build.expected
*/
// Observe initial component settings, including components constructed during
// build. This does not test duplicate-option warnings or timed changes.
module test_command_initial_verbosity_applies_to_components_created_in_build;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class node extends uvm_component;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    node first, peer;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase); first = new("first", this); peer = new("peer", this);
    endfunction
    task run_phase(uvm_phase phase);
      $display("UT: initial_verbosity test %0d first %0d peer %0d",
               get_report_max_verbosity_level() == UVM_HIGH,
               first.get_report_max_verbosity_level() == UVM_HIGH,
               peer.get_report_max_verbosity_level() == UVM_HIGH);
    endtask
  endclass
  initial run_test("t");
endmodule
