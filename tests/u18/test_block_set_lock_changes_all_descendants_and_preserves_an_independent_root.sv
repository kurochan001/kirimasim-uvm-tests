/*
:name: test_block_set_lock_changes_all_descendants_and_preserves_an_independent_root
:description: set_lock propagates both lock values through descendants while preserving another root (18.1.2.8)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.2.8 18.1.2.10 18.1.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_set_lock_changes_all_descendants_and_preserves_an_independent_root.expected
*/
// What it checks:
// set_lock propagates the supplied mode to the block and every descendant
// without changing an independent root.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.1.2.8 (UVM-BLOCK-SET-LOCK-BOTH-VALUES) gives the rule above.
// Setup: Set a three-level hierarchy to one and then zero while a peer remains
// locked. Expected: All three hierarchy flags follow both values; the peer
// stays one.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_block_set_lock_changes_all_descendants_and_preserves_an_independent_root;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class block_type extends uvm_reg_block;
    function new(string name); super.new(name, UVM_NO_COVERAGE); endfunction
  endclass
  class reg_type extends uvm_reg;
    function new(string name); super.new(name, 8, UVM_NO_COVERAGE); endfunction
  endclass
  function automatic reg_type add_reg(block_type owner, uvm_reg_map map_value,
                                     string name, uvm_reg_addr_t offset);
    reg_type value = new(name);
    uvm_reg_field field_value = new("value");
    value.configure(owner);
    field_value.configure(value, 8, 0, "RW", 0, 0, 1, 0, 1);
    map_value.add_reg(value, offset, "RW");
    return value;
  endfunction
  initial begin
    automatic block_type root_block = new("root");
    automatic block_type child = new("child");
    automatic block_type deep = new("deep");
    automatic block_type peer = new("peer");
    root_block.configure(); child.configure(root_block); deep.configure(child); peer.configure();
    peer.set_lock(1); root_block.set_lock(1);
    $display("UT: enabled %0d %0d %0d peer %0d", root_block.is_locked(), child.is_locked(),
             deep.is_locked(), peer.is_locked());
    root_block.set_lock(0);
    $display("UT: disabled %0d %0d %0d peer %0d", root_block.is_locked(), child.is_locked(),
             deep.is_locked(), peer.is_locked());
    $finish;
  end
endmodule
