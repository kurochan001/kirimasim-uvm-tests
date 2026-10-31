/*
:name: test_reg_field_configure_preserves_parent_width_position_and_access
:description: configured field reports its parent, layout, access and volatility (IEEE 1800.2-2020 Section 18.5.3.2)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.3.2 18.5.4.1 18.5.4.2 18.5.4.3 18.5.4.5 18.5.4.9 18.5.4.10 18.5.3.1 18.5.5.4 18.1.2.1 18.1.2.2 18.4.2.1 18.4.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_field_configure_preserves_parent_width_position_and_access.expected
*/
// Use public introspection on an eight-bit field starting at bit four.
// Volatility changes are observed separately from stored values.

module test_reg_field_configure_preserves_parent_width_position_and_access;
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
    automatic model_reg rg = new("r", 16);
    automatic uvm_reg_field field = new("f");

    blk.configure();
    rg.configure(blk);
    field.configure(rg, 8, 4, "RW", 0, 8'h35, 1, 0, 0);
    field.reset();
    $display("UT: parent %0d bits %0d lsb %0d access %s volatile %0d",
             field.get_parent() == rg, field.get_n_bits(), field.get_lsb_pos(),
             field.get_access(), field.is_volatile());
    field.set_volatility(1);
    $display("UT: volatile %0d", field.is_volatile());
    $finish;
  end
endmodule
