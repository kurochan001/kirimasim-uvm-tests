/*
:name: test_reg_field_readonly_set_leaves_desired_and_mirror_unchanged
:description: readonly access policy prevents set from changing desired state (IEEE 1800.2-2020 Section 18.5.5.2)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.5.2 18.5.4.6 18.5.5.1 18.5.5.3 18.5.3.1 18.5.3.2 18.5.5.4 18.1.2.1 18.1.2.2 18.4.2.1 18.4.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_field_readonly_set_leaves_desired_and_mirror_unchanged.expected
*/
// The reset supplies a defined initial state. Set is a model operation.

module test_reg_field_readonly_set_leaves_desired_and_mirror_unchanged;
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
    field.configure(rg, 8, 4, "RO", 0, 8'h35, 1, 0, 0);
    field.reset();
    field.set(8'ha6);
    $display("UT: desired %0h mirror %0h", field.get(), field.get_mirrored_value());
    $finish;
  end
endmodule
