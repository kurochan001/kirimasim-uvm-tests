/*
:name: test_vreg_field_configuration_preserves_parent_width_and_bit_position
:description: vreg field configuration preserves parent width and bit position (IEEE 1800.2-2020 Section 18.10.2.1)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.10.2.1 18.10.2.2 18.10.3.1 18.10.3.2 18.10.3.3 18.9.1.1.1 18.9.1.1.2 18.1.2.1 18.1.2.2 18.6.3.1 18.6.3.2 18.1.2.3 18.1.2.6 18.2.3.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_field_configuration_preserves_parent_width_and_bit_position.expected
*/
// The virtual field is created through its factory wrapper, then configured
// inside the parent virtual register.

module test_vreg_field_configuration_preserves_parent_width_and_bit_position;
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
    middle = uvm_vreg_field::type_id::create("middle");
    middle.configure(vr, 5, 7);
    blk.lock_model();
    $display("UT: parent %0d bits %0d lsb %0d", middle.get_parent() == vr,
             middle.get_n_bits(), middle.get_lsb_pos_in_register());
    $finish;
  end
endmodule
