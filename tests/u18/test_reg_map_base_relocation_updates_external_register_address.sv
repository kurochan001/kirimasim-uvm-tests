/*
:name: test_reg_map_base_relocation_updates_external_register_address
:description: relocating a locked root map changes the external address without changing local offset (IEEE 1800.2-2020 Section 18.2.3.9)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.3.9 18.2.4.4 18.4.3.13 18.4.3.14 18.2.3.3 18.1.2.3 18.1.2.6 18.5.3.2 18.1.2.1 18.1.2.2 18.4.2.1 18.4.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_map_base_relocation_updates_external_register_address.expected
*/
// What it checks:
// Changing the map base relocates the external register address while
// preserving its local offset.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.2.3.9 (UVM-MAP-BASE-RELOCATION) gives the rule above. Setup:
// Change map base from 100 to 400 with register offset 20. Expected: The
// external address changes from 120 to 420 while offset stays 20.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Relocation changes the configured map base. The register remains at its local
// offset.

module test_reg_map_base_relocation_updates_external_register_address;
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
    mapping = blk.create_map("bus", 'h100, 2, UVM_LITTLE_ENDIAN);
    mapping.add_reg(rg, 'h20);
    blk.lock_model();
    $display("UT: before %0h", rg.get_address(mapping));
    mapping.set_base_addr('h400);
    $display("UT: base %0h offset %0h address %0h", mapping.get_base_addr(),
             rg.get_offset(mapping), rg.get_address(mapping));
    $finish;
  end
endmodule
