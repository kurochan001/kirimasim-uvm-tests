/*
:name: test_mem_constructor_reports_location_count_rounded_width_and_parent
:description: memory construction records location count and rounds each location width (IEEE 1800.2-2020 Section 18.6.3.1)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.3.1 18.6.3.2 18.6.4.1 18.6.4.7 18.6.4.8 18.6.4.9 18.1.2.1 18.1.2.2 18.4.2.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_mem_constructor_reports_location_count_rounded_width_and_parent.expected
*/
// Five locations of thirteen bits occupy two model bytes each. These are
// introspection results, without reading any memory contents.

module test_mem_constructor_reports_location_count_rounded_width_and_parent;
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
    automatic model_mem mem = new("mem", 5, 13);
    blk.configure();
    mem.configure(blk);
    $display("UT: parent %0d size %0d bits %0d bytes %0d", mem.get_parent() == blk,
             mem.get_size(), mem.get_n_bits(), mem.get_n_bytes());
    $finish;
  end
endmodule
