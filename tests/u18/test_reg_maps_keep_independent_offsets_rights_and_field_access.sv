/*
:name: test_reg_maps_keep_independent_offsets_rights_and_field_access
:description: one register retains distinct offsets and access rights in two maps (IEEE 1800.2-2020 Section 18.2.3.3)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.3.3 18.4.3.7 18.4.3.13 18.4.3.14 18.4.3.3 18.5.4.5 18.1.2.3 18.1.2.6 18.5.3.2 18.1.2.1 18.1.2.2 18.4.2.1 18.4.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_maps_keep_independent_offsets_rights_and_field_access.expected
*/
// What it checks:
// 1. Register get_offset returns the offset local to the specified map.
// 2. Register get_address returns the external physical address through the
//    specified map.
// 3. Register get_rights returns the accessibility of the selected interface
//    map.
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
// 3. 1800.2-2020 18.4.3.7 (UVM-REGISTER-MAP-RIGHTS-QUERY) gives rule 3 above.
//    Setup: Place one register in read-only and write-only maps. Expected: The
//    respective rights are RO and WO.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// This is register multi-mapping, not the declared memory multi-map deviation.
// Explicit map arguments avoid the separate null-map selection deviation.

module test_reg_maps_keep_independent_offsets_rights_and_field_access;
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
    uvm_reg_map second;

    blk.configure();
    rg.configure(blk);
    field.configure(rg, 16, 0, "RW", 0, 0, 1, 0, 1);
    mapping = blk.create_map("read_bus", 'h100, 2, UVM_LITTLE_ENDIAN);
    second = blk.create_map("write_bus", 'h300, 2, UVM_LITTLE_ENDIAN);
    mapping.add_reg(rg, 'h10, "RO");
    second.add_reg(rg, 'h20, "WO");
    blk.lock_model();
    $display("UT: maps %0d offsets %0h %0h addresses %0h %0h", rg.get_n_maps(),
             rg.get_offset(mapping), rg.get_offset(second), rg.get_address(mapping),
             rg.get_address(second));
    $display("UT: rights %s %s field_access %s %s", rg.get_rights(mapping),
             rg.get_rights(second), field.get_access(mapping), field.get_access(second));
    $finish;
  end
endmodule
