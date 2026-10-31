/*
:name: test_reg_field_deleted_reset_kind_preserves_state_and_other_reset
:description: deleting one reset kind leaves that reset inert and preserves the hard reset (IEEE 1800.2-2020 Section 18.5.5.5)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.5.5 18.5.5.7 18.5.5.4 18.5.5.1 18.5.5.3 18.5.3.1 18.5.3.2 18.1.2.1 18.1.2.2 18.4.2.1 18.4.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_field_deleted_reset_kind_preserves_state_and_other_reset.expected
*/
// Observe the deletion result once, then the absence and unchanged model state.

module test_reg_field_deleted_reset_kind_preserves_state_and_other_reset;
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
    automatic bit removed = 0;

    blk.configure();
    rg.configure(blk);
    field.configure(rg, 8, 4, "RW", 0, 8'h35, 1, 0, 0);
    field.reset();
    field.set_reset(8'h92, "SOFT");
    removed = field.has_reset("SOFT", 1);
    field.set(8'h61);
    field.reset("SOFT");
    $display("UT: removed %0d soft_present %0d hard_present %0d desired %0h mirror %0h",
             removed, field.has_reset("SOFT"), field.has_reset(), field.get(),
             field.get_mirrored_value());
    field.reset();
    $display("UT: hard desired %0h mirror %0h", field.get(), field.get_mirrored_value());
    $finish;
  end
endmodule
