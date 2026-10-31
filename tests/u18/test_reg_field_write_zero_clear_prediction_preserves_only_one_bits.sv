/*
:name: test_reg_field_write_zero_clear_prediction_preserves_only_one_bits
:description: W0C write prediction applies the access rule to both model values (IEEE 1800.2-2020 Section 18.5.5.17)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.5.17 18.5.4.6 18.5.5.1 18.5.5.3 18.5.5.4 18.5.3.2 18.4.2.2 17.2.2.8 18.1.2.1 18.1.2.2 18.4.2.1 18.6.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_field_write_zero_clear_prediction_preserves_only_one_bits.expected
*/
// Selected zero bits clear the mirror; one bits preserve its prior state.
// The input represents an observation, not a physical bus operation.

module test_reg_field_write_zero_clear_prediction_preserves_only_one_bits;
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
    automatic uvm_reg_field field = new("f");
    automatic bit accepted = 0;

    blk.configure();
    rg.configure(blk);
    field.configure(rg, 8, 0, "W0C", 0, 8'hf3, 1, 0, 1);
    field.reset();
    accepted = field.predict(8'hcc, -1, UVM_PREDICT_WRITE);
    $display("UT: step 1 accepted %0d desired %0h mirror %0h", accepted,
             field.get(), field.get_mirrored_value());
    accepted = field.predict(8'h0f, -1, UVM_PREDICT_WRITE);
    $display("UT: step 2 accepted %0d desired %0h mirror %0h", accepted,
             field.get(), field.get_mirrored_value());

    $finish;
  end
endmodule
