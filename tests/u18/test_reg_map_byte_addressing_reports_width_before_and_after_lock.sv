/*
:name: test_reg_map_byte_addressing_reports_width_before_and_after_lock
:description: byte-addressed map introspection reports the configured bus properties (IEEE 1800.2-2020 Section 18.2.4.2)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.4.2 18.1.2.6 18.2.4.4 18.2.4.5 18.2.4.6 18.2.4.7 18.2.4.1 18.1.2.3 18.1.2.1 18.1.2.2 18.4.2.1 18.4.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_map_byte_addressing_reports_width_before_and_after_lock.expected
*/
// What it checks:
// A configured map reports its bus width independently of model locking.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.2.4.2 (UVM-REG-MAP-WIDTH-BEFORE-AND-AFTER-LOCK) gives the
// rule above. Setup: Query a little-endian four-byte map before and after
// lock. Expected: Width is four both times; byte address unit and exact
// parent/root handles agree.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The configured bus width is observed before and after locking. The map
// introspection clause gives no lock prerequisite.

module test_reg_map_byte_addressing_reports_width_before_and_after_lock;
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

    blk.configure();
    mapping = blk.create_map("bus", 'h100, 4, UVM_LITTLE_ENDIAN, 1);
    $display("UT: parent %0d root %0d base %0h bytes %0d unit %0d little %0d",
             mapping.get_parent() == blk, mapping.get_root_map() == mapping,
             mapping.get_base_addr(), mapping.get_n_bytes(), mapping.get_addr_unit_bytes(),
             mapping.get_endian() == UVM_LITTLE_ENDIAN);
    blk.lock_model();
    $display("UT: locked bytes %0d", mapping.get_n_bytes());
    $finish;
  end
endmodule
