/*
:name: test_vreg_static_array_inherits_memory_map_membership_and_external_address
:description: vreg static array inherits memory map membership and external address (IEEE 1800.2-2020 Section 18.9.1.2.3)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.1.2.3 18.9.1.2.4 18.9.1.2.5 18.9.1.2.15 18.6.4.16 18.9.1.1.1 18.9.1.1.2 18.1.2.1 18.1.2.2 18.6.3.1 18.6.3.2 18.1.2.3 18.1.2.6 18.2.3.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_static_array_inherits_memory_map_membership_and_external_address.expected
*/
// What it checks:
// A static virtual array inherits implementing-memory map membership and
// address translation.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.9.1.2.3 (UVM-VREG-STATIC-MAP-EXTERNAL-ADDRESS) gives the rule
// above. Setup: Map memory at offset 20 hex under base 100 hex and use virtual
// base two/increment three. Expected: The exact map is inherited and element
// two has external address 128 hex.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The virtual element offset is in memory words; the external address also
// includes the memory map offset and root base.

module test_vreg_static_array_inherits_memory_map_membership_and_external_address;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class model_block extends uvm_reg_block;
    function new(); super.new("blk", UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(); super.new("r", 8, UVM_NO_COVERAGE); endfunction
  endclass

  initial begin
    automatic model_block blk = new();
    automatic uvm_mem mem = new("mem", 64, 8, "RW", UVM_NO_COVERAGE);
    automatic uvm_vreg vr = new("vr", 16);
    automatic uvm_vreg_field low;
    automatic uvm_vreg_field middle;
    automatic uvm_vreg_field high;
    automatic uvm_vreg_field fields[$];
    automatic uvm_reg_map mapping;
    automatic uvm_reg_map maps[$];
    blk.configure();
    mem.configure(blk);
    mapping = blk.create_map("bus", 'h100, 1, UVM_LITTLE_ENDIAN);
    mapping.add_mem(mem, 'h20);
    vr.configure(blk, mem, 3, 2, 3);

    blk.lock_model();
    vr.get_maps(maps);
    $display("UT: count %0d member %0d maps %0d handle %0d address %0h", vr.get_n_maps(),
             vr.is_in_map(mapping), maps.size(), maps[0] == mapping, vr.get_address(2, mapping));
    $finish;
  end
endmodule
