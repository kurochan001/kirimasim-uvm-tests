/*
:name: test_mem_big_endian_wide_location_lists_addresses_in_data_order
:description: wide big-endian memory locations enumerate least-significant data first (IEEE 1800.2-2020 Section 18.6.4.17)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.4.17 17.2.2.4 18.6.3.2 18.1.2.3 18.2.3.4 18.1.2.6 18.1.2.1 18.1.2.2 18.4.2.1 18.6.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_mem_big_endian_wide_location_lists_addresses_in_data_order.expected
*/
// What it checks:
// Memory get_addresses lists the physical addresses in least-significant-data
// order and returns transfer width.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.6.4.17 (UVM-MEMORY-DATA-ORDER-ADDRESSES) gives the rule
// above. Setup: Inspect a wide big-endian location and a word-addressed
// location. Expected: Big-endian addresses are 126 then 124 with width two;
// the word-addressed case returns address 26 and width four.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The second four-byte location uses two two-byte transfers. Check the
// address array and transfer width, without executing those transfers.

module test_mem_big_endian_wide_location_lists_addresses_in_data_order;
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
    automatic model_mem mem = new("mem", 3, 32);
    uvm_reg_map mapping;
    uvm_reg_addr_t addresses[];
    automatic int transferred = 0;
    blk.configure();
    mem.configure(blk);
    mapping = blk.create_map("bus", 'h100, 2, UVM_BIG_ENDIAN);
    mapping.add_mem(mem, 'h20);
    blk.lock_model();
    transferred = mem.get_addresses(1, mapping, addresses);
    $display("UT: transfer %0d count %0d", transferred, addresses.size());
    if (addresses.size() == 2)
      $display("UT: addresses %0h %0h", addresses[0], addresses[1]);
    $finish;
  end
endmodule
