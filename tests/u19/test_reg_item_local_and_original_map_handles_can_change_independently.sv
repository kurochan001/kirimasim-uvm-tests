/*
:name: test_reg_item_local_and_original_map_handles_can_change_independently
:description: register item original and local map handles are independently selected (IEEE 1800.2-2020 Section 19.1.1.2.7)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.1.1.2.7 19.1.1.2.8 19.1.1.3.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_item_local_and_original_map_handles_can_change_independently.expected
*/
// Exercise the descriptor public API directly, without bus or DUT access.
// Undefined initial enum/data values are never observed. UVM_HAS_X here is
// an explicitly assigned status enum, not a four-state data observation.
module test_reg_item_local_and_original_map_handles_can_change_independently;
  import uvm_pkg::*;

  `include "uvm_macros.svh"
  class block_type extends uvm_reg_block;
    function new(); super.new("blk", UVM_NO_COVERAGE); endfunction
  endclass
  class reg_type extends uvm_reg;
    function new(); super.new("r", 8, UVM_NO_COVERAGE); endfunction
  endclass
  class mem_type extends uvm_mem;
    function new(); super.new("m", 4, 8, "RW", UVM_NO_COVERAGE); endfunction
  endclass
  class sequence_type extends uvm_sequence;
    function new(string name); super.new(name); endfunction
    virtual task body(); endtask
  endclass
  class warning_probe extends uvm_report_catcher;
    int warnings = 0;
    function new(); super.new("warning_probe"); endfunction
    function action_e catch();
      if (get_severity() == UVM_WARNING) begin warnings++; return CAUGHT; end
      return THROW;
    endfunction
  endclass
  initial begin
    automatic uvm_reg_item first = new("first");
    automatic uvm_reg_item peer = new("peer");

    automatic uvm_reg_map alpha = new("alpha");
    automatic uvm_reg_map beta = new("beta");
    automatic uvm_reg_map gamma = new("gamma");


    peer.set_local_map(gamma); peer.set_map(gamma);
    first.set_local_map(alpha); first.set_map(beta);
    $display("UT: selected local %0d original %0d", first.get_local_map() == alpha,
    first.get_map() == beta);
    first.set_local_map(beta);
    $display("UT: local_replaced %0d original_retained %0d", first.get_local_map() == beta,
    first.get_map() == beta);
    first.set_map(alpha); first.set_local_map(null);
    $display("UT: local_cleared %0d original_replaced %0d", first.get_local_map() == null,
    first.get_map() == alpha);
    first.set_map(null);
    $display("UT: original_cleared %0d peer_local %0d peer_original %0d", first.get_map() == null,
    peer.get_local_map() == gamma, peer.get_map() == gamma);

    $finish;
  end

endmodule
