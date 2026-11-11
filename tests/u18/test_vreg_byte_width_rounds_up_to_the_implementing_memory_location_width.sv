/*
:name: test_vreg_byte_width_rounds_up_to_the_implementing_memory_location_width
:description: vreg byte width rounds up to the implementing memory location width (IEEE 1800.2-2020 Section 18.9.1.2.9)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.1.2.9 18.9.1.2.10 18.9.1.2.11 18.9.1.1.1 18.9.1.1.2 18.1.2.1 18.1.2.2 18.6.3.1 18.6.3.2 18.1.2.3 18.1.2.6 18.2.3.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_byte_width_rounds_up_to_the_implementing_memory_location_width.expected
*/
// What it checks:
// Virtual-register byte width rounds up to whole implementing-memory
// locations.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.9.1.2.9 (UVM-VREG-BYTE-WIDTH-MEMORY-ROUNDING) gives the rule
// above. Setup: Implement a 16-bit register over a 32-bit memory. Expected:
// Width is four bytes, one location and increment one.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A 16-bit virtual register implemented in 32-bit memory occupies one whole
// four-byte memory location; its reported byte width follows that allocation
// unit.

module test_vreg_byte_width_rounds_up_to_the_implementing_memory_location_width;
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
    automatic uvm_mem mem = new("mem", 64, 32, "RW", UVM_NO_COVERAGE);
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
    $display("UT: bytes %0d locations %0d increment %0d", vr.get_n_bytes(),
             vr.get_n_memlocs(), vr.get_incr());
    $finish;
  end
endmodule
