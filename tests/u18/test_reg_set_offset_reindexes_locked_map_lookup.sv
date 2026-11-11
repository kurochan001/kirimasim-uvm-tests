/*
:name: test_reg_set_offset_reindexes_locked_map_lookup
:description: register relocation updates physical addresses and locked map lookup (IEEE 1800.2-2020 Section 18.4.2.3)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.2.3 18.4.3.13 18.4.3.14 18.2.4.17 18.4.2.2 18.5.3.2 18.1.2.3 18.2.3.3 18.1.2.6 18.1.2.1 18.1.2.2 18.4.2.1 18.6.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_set_offset_reindexes_locked_map_lookup.expected
*/
// What it checks:
// Register set_offset moves its placement in the selected map and updates
// locked lookup.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.4.2.3 (UVM-REGISTER-OFFSET-RELOCATION) gives the rule above.
// Setup: Move a locked register from offset 10 to 30. Expected: The old lookup
// is empty, the new lookup returns the register and the address is 30.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Keep the root base at zero to make local and external lookup addresses
// agree. Observe disappearance of the old mapping and the new register handle.

module test_reg_set_offset_reindexes_locked_map_lookup;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class model_block extends uvm_reg_block;
    function new(string name="blk"); super.new(name, UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(string name="r", int unsigned width=8);
      super.new(name, width, UVM_NO_COVERAGE);
    endfunction
  endclass
  class model_mem extends uvm_mem;
    function new(string name="mem", longint unsigned size=4,
                 int unsigned width=16, string access="RW");
      super.new(name, size, width, access, UVM_NO_COVERAGE);
    endfunction
  endclass

  initial begin
    automatic model_block blk = new("blk");
    automatic model_reg rg = new("r", 8);
    automatic uvm_reg_field field = new("value");
    uvm_reg_map mapping;

    blk.configure();
    rg.configure(blk);
    field.configure(rg, 8, 0, "RW", 0, 8'h12, 1, 0, 1);
    mapping = blk.create_map("bus", 0, 1, UVM_LITTLE_ENDIAN);
    mapping.add_reg(rg, 'h10);
    blk.lock_model();
    $display("UT: before %0h lookup %0d", rg.get_address(mapping),
             mapping.get_reg_by_offset('h10) == rg);
    rg.set_offset(mapping, 'h30);
    $display("UT: offset %0h address %0h old_missing %0d new_lookup %0d",
             rg.get_offset(mapping), rg.get_address(mapping),
             mapping.get_reg_by_offset('h10) == null, mapping.get_reg_by_offset('h30) == rg);
    $finish;
  end
endmodule
