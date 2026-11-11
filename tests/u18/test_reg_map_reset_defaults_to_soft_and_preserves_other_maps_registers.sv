/*
:name: test_reg_map_reset_defaults_to_soft_and_preserves_other_maps_registers
:description: map reset defaults to soft and affects only its own register membership (IEEE 1800.2-2020 Section 18.2.3.10)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.3.10 18.5.5.7 18.4.4.15 18.4.4.3 18.4.2.2 18.5.3.2 18.1.2.3 18.2.3.3 18.1.2.6 18.1.2.1 18.1.2.2 18.4.2.1 18.6.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_map_reset_defaults_to_soft_and_preserves_other_maps_registers.expected
*/
// What it checks:
// Map reset defaults to SOFT and resets only registers belonging to that map.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.2.3.10 (UVM-MAP-RESET-SOFT-DEFAULT) gives the rule above.
// Setup: Configure distinct HARD/SOFT values and a register in another map,
// then use default/explicit HARD reset. Expected: Default reset yields 78,
// HARD yields 12, and the other-map register retains bb.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Two registers belong to separate maps in one block. Reset one map and
// observe both mirrors; explicitly requesting HARD uses a different value.

module test_reg_map_reset_defaults_to_soft_and_preserves_other_maps_registers;
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
    automatic model_reg other = new("other", 8);
    automatic uvm_reg_field other_field = new("other_value");
    uvm_reg_map second;
    automatic bit accepted = 0;
    blk.configure();
    rg.configure(blk);
    field.configure(rg, 8, 0, "RW", 0, 8'h12, 1, 0, 1);
    other.configure(blk);
    other_field.configure(other, 8, 0, "RW", 0, 8'h34, 1, 0, 1);
    field.set_reset(8'h78, "SOFT");
    mapping = blk.create_map("first", 0, 1, UVM_LITTLE_ENDIAN);
    second = blk.create_map("second", 'h100, 1, UVM_LITTLE_ENDIAN);
    mapping.add_reg(rg, 0);
    second.add_reg(other, 0);
    blk.lock_model();
    accepted = rg.predict(8'haa) && other.predict(8'hbb);
    mapping.reset();
    $display("UT: predicted %0d soft %0h other %0h", accepted,
             rg.get_mirrored_value(), other.get_mirrored_value());
    mapping.reset("HARD");
    $display("UT: hard %0h other %0h", rg.get_mirrored_value(), other.get_mirrored_value());
    $finish;
  end
endmodule
