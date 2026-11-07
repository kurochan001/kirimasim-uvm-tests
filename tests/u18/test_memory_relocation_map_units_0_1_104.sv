/*
:name: test_memory_relocation_map_units_0_1_104
:description: Memory relocation preserves map address units location offsets and independent interface mappings
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.3.3 18.6.4.15 18.6.4.16 18.6.3.1 18.6.3.2 18.2.3.4 18.2.4.4 18.2.4.6 18.2.4.16 18.2.4.18 18.1.2.3 18.1.2.4 18.1.2.5 18.1.2.6 1800-2023 6.21 8.13 8.16
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers104_relocation/relocation104.svh
:expected_exit: 0
:expected_stdout: @test_memory_relocation_map_units_0_1_104.expected
*/
module test_memory_relocation_map_units_0_1_104;
  import uvm_pkg::*;
  localparam int SHAPE104=0,BUS104=2,WIDTH104=16,SIZE104=3;
  localparam bit BYTEA104=1;
  localparam int STRIDEA104=2;
  localparam uvm_reg_addr_t BASEA104='h100;
  localparam uvm_reg_addr_t BASEB104='h300;
  localparam uvm_reg_addr_t FIRST104='h40;
  localparam uvm_reg_addr_t NEXT104='h100;
  localparam uvm_reg_addr_t LAST104='h200;
  localparam uvm_reg_addr_t HOME104='h400;
  localparam uvm_reg_addr_t ALT104='h600;
  localparam uvm_reg_addr_t ALTHOME104='h800;
  `include "relocation104.svh"
endmodule
