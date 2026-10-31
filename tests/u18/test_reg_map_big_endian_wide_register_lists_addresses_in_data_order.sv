/*
:name: test_reg_map_big_endian_wide_register_lists_addresses_in_data_order
:description: big-endian map lists a wide registers addresses from least-significant data (IEEE 1800.2-2020 Section 18.2.4.16)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.4.16 18.4.3.15 18.2.3.3 18.1.2.3 18.1.2.6 17.2.2.4 18.5.3.2 18.1.2.1 18.1.2.2 18.4.2.1 18.4.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_map_big_endian_wide_register_lists_addresses_in_data_order.expected
*/
// A six-byte register spans three two-byte transfers. The returned array
// is ordered by data significance, rather than sorted numerically.

module test_reg_map_big_endian_wide_register_lists_addresses_in_data_order;
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
    uvm_reg_map mapping;
    automatic model_reg rg = new("wide", 48);
    automatic uvm_reg_field field = new("value");
    uvm_reg_addr_t addresses[];
    automatic int transferred = 0;

    blk.configure();
    rg.configure(blk);
    field.configure(rg, 48, 0, "RW", 0, 0, 1, 0, 0);
    mapping = blk.create_map("bus", 'h100, 2, UVM_BIG_ENDIAN);
    mapping.add_reg(rg, 'h20);
    blk.lock_model();
    transferred = rg.get_addresses(mapping, addresses);
    $display("UT: transfer %0d count %0d", transferred, addresses.size());
    if (addresses.size() == 3)
      $display("UT: addresses %0h %0h %0h", addresses[0], addresses[1], addresses[2]);
    $finish;
  end
endmodule
