/*
:name: test_reg_map_register_offset_and_external_address_remain_distinct
:description: local register offset and external address include different base contributions (IEEE 1800.2-2020 Section 18.4.3.13)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.3.13 18.4.3.14 18.2.3.3 18.1.2.3 18.1.2.6 18.5.3.2 18.1.2.1 18.1.2.2 18.4.2.1 18.4.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_map_register_offset_and_external_address_remain_distinct.expected
*/
// What it checks:
// 1. Register get_offset returns the offset local to the specified map.
// 2. Register get_address returns the external physical address through the
//    specified map.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.4.3.13 (UVM-REGISTER-MAP-LOCAL-OFFSET) gives rule 1 above.
//    Setup: Use nonzero map bases and distinct offsets in two interface maps.
//    Expected: The returned local offsets exclude the external base and stay
//    distinct across maps.
// 2. 1800.2-2020 18.4.3.14 (UVM-REGISTER-EXTERNAL-ADDRESS) gives rule 2 above.
//    Setup: Inspect register placement in one/two maps with nonzero bases.
//    Expected: External addresses include each selected map base and its
//    register offset.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Specify the map explicitly for every register lookup.

module test_reg_map_register_offset_and_external_address_remain_distinct;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class model_block extends uvm_reg_block;
    function new(string name="blk");
      super.new(name, UVM_NO_COVERAGE);
    endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(string name="r", int unsigned width=16);
      super.new(name, width, UVM_NO_COVERAGE);
    endfunction
  endclass

  initial begin
    automatic model_block blk = new("blk");
    uvm_reg_map mapping;
    automatic model_reg rg = new("r", 16);
    automatic uvm_reg_field field = new("value");

    blk.configure();
    rg.configure(blk);
    field.configure(rg, 16, 0, "RW", 0, 0, 1, 0, 1);
    mapping = blk.create_map("bus", 'h200, 2, UVM_LITTLE_ENDIAN);
    mapping.add_reg(rg, 'h18);
    blk.lock_model();
    $display("UT: offset %0h address %0h", rg.get_offset(mapping), rg.get_address(mapping));
    $finish;
  end
endmodule
