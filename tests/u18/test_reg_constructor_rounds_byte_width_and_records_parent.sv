/*
:name: test_reg_constructor_rounds_byte_width_and_records_parent
:description: a twelve-bit register rounds its byte width upward and reports its parent (IEEE 1800.2-2020 Section 18.4.3.8)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.3.8 18.4.3.9 18.4.3.1 18.1.2.1 18.1.2.2 18.4.2.1 18.4.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_constructor_rounds_byte_width_and_records_parent.expected
*/
// What it checks:
// 1. Register get_n_bits returns its configured bit width.
// 2. Register get_n_bytes rounds up to complete bytes.
// 3. Register get_parent returns its configured block.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.4.3.8 (UVM-REGISTER-BIT-WIDTH-QUERY) gives rule 1 above.
//    Setup: Construct a twelve-bit register. Expected: The returned bit width
//    is twelve.
// 2. 1800.2-2020 18.4.3.9 (UVM-REGISTER-BYTE-WIDTH-ROUNDING) gives rule 2
//    above. Setup: Inspect a twelve-bit register. Expected: The returned byte
//    width is two.
// 3. 1800.2-2020 18.4.3.1 (UVM-REGISTER-PARENT-QUERY) gives rule 3 above.
//    Setup: Configure one register in a block. Expected: The returned handle
//    equals that block.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The physical width need not be a whole number of bytes.

module test_reg_constructor_rounds_byte_width_and_records_parent;
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
    automatic model_reg rg = new("r", 12);
    blk.configure();
    rg.configure(blk);
    $display("UT: bits %0d bytes %0d parent %0d", rg.get_n_bits(), rg.get_n_bytes(),
             rg.get_parent() == blk);
    $finish;
  end
endmodule
