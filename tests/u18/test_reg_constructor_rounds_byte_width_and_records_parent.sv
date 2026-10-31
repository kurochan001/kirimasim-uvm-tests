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
