/*
:name: test_reg_item_category_setters_preserve_latest_values_per_instance
:description: register item category setters retain most recent enum values per instance (IEEE 1800.2-2020 Section 19.1.1.2.3)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.1.1.2.3 19.1.1.2.1 19.1.1.2.6 19.1.1.2.9 19.1.1.3.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_item_category_setters_preserve_latest_values_per_instance.expected
*/
// Exercise the descriptor public API directly, without bus or DUT access.
// Undefined initial enum/data values are never observed. UVM_HAS_X here is
// an explicitly assigned status enum, not a four-state data observation.
module test_reg_item_category_setters_preserve_latest_values_per_instance;
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


    peer.set_element_kind(UVM_MEM); peer.set_kind(UVM_BURST_READ); peer.set_status(UVM_NOT_OK);
    peer.set_door(UVM_BACKDOOR);
    first.set_element_kind(UVM_REG); first.set_kind(UVM_READ); first.set_status(UVM_IS_OK);
    first.set_door(UVM_FRONTDOOR);
    $display("UT: first_initial element %0d kind %0d status %0d door %0d",
    first.get_element_kind() == UVM_REG, first.get_kind() == UVM_READ,
    first.get_status() == UVM_IS_OK, first.get_door() == UVM_FRONTDOOR);
    first.set_element_kind(UVM_FIELD); first.set_kind(UVM_BURST_WRITE);
    first.set_status(UVM_HAS_X); first.set_door(UVM_DEFAULT_DOOR);
    $display("UT: first_latest element %0d kind %0d status %0d door %0d",
    first.get_element_kind() == UVM_FIELD, first.get_kind() == UVM_BURST_WRITE,
    first.get_status() == UVM_HAS_X, first.get_door() == UVM_DEFAULT_DOOR);
    $display("UT: peer_retained element %0d kind %0d status %0d door %0d",
    peer.get_element_kind() == UVM_MEM, peer.get_kind() == UVM_BURST_READ,
    peer.get_status() == UVM_NOT_OK, peer.get_door() == UVM_BACKDOOR);

    $finish;
  end

endmodule
