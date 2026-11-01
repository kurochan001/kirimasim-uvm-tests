/*
:name: test_reg_item_element_replacement_and_null_clear_preserve_peer_handle
:description: register item element handles support replacement and null clearing (IEEE 1800.2-2020 Section 19.1.1.2.2)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.1.1.2.2 19.1.1.2.1 19.1.1.3.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_item_element_replacement_and_null_clear_preserve_peer_handle.expected
*/
// Exercise the descriptor public API directly, without bus or DUT access.
// Undefined initial enum/data values are never observed. UVM_HAS_X here is
// an explicitly assigned status enum, not a four-state data observation.
module test_reg_item_element_replacement_and_null_clear_preserve_peer_handle;
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

    automatic block_type blk = new();
    automatic reg_type rg = new();
    automatic mem_type memory = new();
    automatic uvm_reg_field field = new("f");


    blk.configure(); rg.configure(blk); memory.configure(blk);
    field.configure(rg, 8, 0, "RW", 0, 0, 0, 0, 1);
    peer.set_element(memory); peer.set_element_kind(UVM_MEM);
    first.set_element(rg); first.set_element_kind(UVM_REG);
    $display("UT: register exact %0d kind %0d", first.get_element() == rg,
    first.get_element_kind() == UVM_REG);
    first.set_element(field); first.set_element_kind(UVM_FIELD);
    $display("UT: field exact %0d kind %0d", first.get_element() == field,
    first.get_element_kind() == UVM_FIELD);
    first.set_element(null);
    $display("UT: cleared %0d peer_exact %0d peer_kind %0d", first.get_element() == null,
    peer.get_element() == memory, peer.get_element_kind() == UVM_MEM);

    $finish;
  end

endmodule
