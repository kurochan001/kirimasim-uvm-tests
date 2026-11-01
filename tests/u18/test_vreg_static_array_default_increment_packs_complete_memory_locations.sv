/*
:name: test_vreg_static_array_default_increment_packs_complete_memory_locations
:description: vreg static array default increment packs complete memory locations (IEEE 1800.2-2020 Section 18.9.1.1.2)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.1.1.2 18.9.1.2.8 18.9.1.2.10 18.9.1.2.11 18.9.1.2.14 18.9.1.1.1 18.1.2.1 18.1.2.2 18.6.3.1 18.6.3.2 18.1.2.3 18.1.2.6 18.2.3.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_static_array_default_increment_packs_complete_memory_locations.expected
*/
// A 16-bit virtual register needs two byte-wide memory locations. Zero
// increment selects the closest nonoverlapping packing.

module test_vreg_static_array_default_increment_packs_complete_memory_locations;
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
    vr.configure(blk, mem, 3, 2, 0);

    blk.lock_model();
    $display("UT: memory %0d size %0d locations %0d increment %0d offsets %0d %0d %0d",
             vr.get_memory() == mem, vr.get_size(), vr.get_n_memlocs(), vr.get_incr(),
             vr.get_offset_in_memory(0), vr.get_offset_in_memory(1), vr.get_offset_in_memory(2));
    $finish;
  end
endmodule
