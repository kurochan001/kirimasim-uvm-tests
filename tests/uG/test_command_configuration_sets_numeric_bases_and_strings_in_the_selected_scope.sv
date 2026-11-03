/*
:name: test_command_configuration_sets_numeric_bases_and_strings_in_the_selected_scope
:description: command configuration sets numeric bases and strings in the selected scope (IEEE 1800.2-2020 Section G.2.8)
:tags: uG uvm
:type: simulation
:lrm: 1800.2-2020 G.2.8 C.4.2.3.1 C.4.2.3.2 C.4.2.3.3 B.2.1.3 1800-2023 6.21
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
:args: +uvm_set_config_int=uvm_test_top.leaf,hex_value,0x2d +uvm_set_config_int=uvm_test_top.leaf,binary_value,0b10110 +uvm_set_config_int=uvm_test_top.leaf,octal_value,'o17 +uvm_set_config_string=uvm_test_top.leaf,label,selected
:expected_stdout: @test_command_configuration_sets_numeric_bases_and_strings_in_the_selected_scope.expected
*/
// Use explicit hex, binary and octal spellings plus a string. Observe through
// public config queries; failed output values and unrelated syntax are open.
module test_command_configuration_sets_numeric_bases_and_strings_in_the_selected_scope;
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
      uvm_bitstream_t hex_value, binary_value, octal_value, ignored;
      string label;
      bit hex_ok, binary_ok, octal_ok, string_ok;
      hex_ok = uvm_config_db#(uvm_bitstream_t)::get(leaf, "", "hex_value", hex_value);
      binary_ok = uvm_config_db#(uvm_bitstream_t)::get(leaf, "", "binary_value", binary_value);
      octal_ok = uvm_config_db#(uvm_bitstream_t)::get(leaf, "", "octal_value", octal_value);
      string_ok = uvm_config_db#(string)::get(leaf, "", "label", label);
      $display("UT: config hex %0d binary %0d octal %0d string %0d peer_absent %0d",
               hex_ok && hex_value == 45, binary_ok && binary_value == 22,
               octal_ok && octal_value == 15, string_ok && label == "selected",
               !uvm_config_db#(uvm_bitstream_t)::get(peer, "", "hex_value", ignored));
    endtask
  endclass
  initial run_test("t");
endmodule
