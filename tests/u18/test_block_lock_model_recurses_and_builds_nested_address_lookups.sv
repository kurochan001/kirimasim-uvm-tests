/*
:name: test_block_lock_model_recurses_and_builds_nested_address_lookups
:description: lock_model recursively locks blocks and constructs nested offset lookup tables (18.1.2.6)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.2.6 18.1.2.10 18.2.4.17 18.2.3.5 18.2.3.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_lock_model_recurses_and_builds_nested_address_lookups.expected
*/
// What it checks:
// 1. lock_model recursively locks the hierarchy and builds address-map offset
//    lookups.
// 2. is_locked reports the current model lock state.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.1.2.6 (UVM-BLOCK-LOCK-MODEL-RECURSIVE-LOOKUPS) gives rule
//    1 above. Setup: Use a root register at zero and a child register at
//    offset two in a submap at sixteen. Expected: Both blocks become locked
//    and root offsets zero/eighteen return the exact local/child registers.
// 2. 1800.2-2020 18.1.2.10 (UVM-BLOCK-LOCK-STATE-QUERY) gives rule 2 above.
//    Setup: Observe a newly configured hierarchy before and after recursive
//    locking. Expected: Root and child report zero before locking and one
//    afterwards.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_block_lock_model_recurses_and_builds_nested_address_lookups;
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
    automatic uvm_reg_map root_map, child_map;
    automatic reg_type local_reg, child_reg;
    root_block.configure(); child.configure(root_block);
    root_map = root_block.create_map("root_map", 0, 1, UVM_LITTLE_ENDIAN);
    child_map = child.create_map("child_map", 0, 1, UVM_LITTLE_ENDIAN);
    local_reg = add_reg(root_block, root_map, "local_reg", 0);
    child_reg = add_reg(child, child_map, "child_reg", 2);
    root_map.add_submap(child_map, 16);
    $display("UT: before root %0d child %0d", root_block.is_locked(), child.is_locked());
    root_block.lock_model();
    $display("UT: locked root %0d child %0d local_lookup %0d nested_lookup %0d",
             root_block.is_locked(), child.is_locked(), root_map.get_reg_by_offset(0) == local_reg,
             root_map.get_reg_by_offset(18) == child_reg);
    $finish;
  end
endmodule
