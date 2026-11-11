/*
:name: test_block_register_name_lookup_prefers_local_scope_and_finds_descendants
:description: register name lookup searches local models before descendants and does not search ancestors or peer roots (IEEE 1800.2-2020 Section 18.1.3.14)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.3.14 18.1.2.6 18.1.2.1 18.1.2.2 18.1.3.1 18.3.2.1 18.3.2.2 18.3.3.1 18.3.3.2 18.4.2.1 18.4.2.2 18.4.3.1 18.4.3.2 18.5.3.2 18.6.3.1 18.6.3.2 17.2.2.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_register_name_lookup_prefers_local_scope_and_finds_descendants.expected
*/
// What it checks:
// Register simple-name search prefers local registers, then searches child
// blocks and returns null when absent.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.1.3.14 (UVM-BLOCK-REGISTER-SIMPLE-NAME-SEARCH) gives the rule
// above. Setup: Use duplicate local/child names, unique deep/regfile names and
// missing/ancestor/peer names before locking; recheck local/deep/regfile
// matches after locking. Expected: Local duplicates win; descendants and
// regfile registers are found; out-of-scope or missing names return null.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Register-model hierarchy only. Queries use fresh result queues and handle
// membership, without a visit order, address maps, RTL transfers or HDL DPI.
module test_block_register_name_lookup_prefers_local_scope_and_finds_descendants;
  import uvm_pkg::*;
  class model_block extends uvm_reg_block;
    function new(string name="blk"); super.new(name, UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(string name="r"); super.new(name, 8, UVM_NO_COVERAGE); endfunction
  endclass
  model_block root_block, child, side, grandchild, peer;
  model_reg root_reg, file_reg, child_reg, deep_reg, peer_reg;
  uvm_reg_file outer_file, inner_file;
  uvm_reg_field root_low, root_high, file_value, child_value, deep_value, peer_value;
  uvm_mem root_mem, child_mem, deep_mem, peer_mem;
  function automatic uvm_reg_field field_for(model_reg rg, string name, int width=8, int lsb=0);
    uvm_reg_field result_value;
    result_value = new(name); result_value.configure(rg, width, lsb, "RW", 0, 0, 1, 0, 1);
    return result_value;
  endfunction
  function automatic void build_model();
    root_block = new("root"); child = new("child"); side = new("side");
    grandchild = new("grandchild"); peer = new("peer");
    root_block.configure(); child.configure(root_block); side.configure(root_block);
    grandchild.configure(child); peer.configure();
    outer_file = new("outer"); outer_file.configure(root_block, null);
    inner_file = new("inner"); inner_file.configure(root_block, outer_file);
    root_reg = new("root_reg"); root_reg.configure(root_block);
    file_reg = new("file_reg"); file_reg.configure(root_block, inner_file);
    child_reg = new("child_reg"); child_reg.configure(child);
    deep_reg = new("deep_reg"); deep_reg.configure(grandchild);
    peer_reg = new("peer_reg"); peer_reg.configure(peer);
    root_low = field_for(root_reg, "root_low", 4, 0);
    root_high = field_for(root_reg, "root_high", 4, 4);
    file_value = field_for(file_reg, "file_value");
    child_value = field_for(child_reg, "child_value");
    deep_value = field_for(deep_reg, "deep_value");
    peer_value = field_for(peer_reg, "peer_value");
    root_mem = new("root_mem", 4, 8, "RW", UVM_NO_COVERAGE); root_mem.configure(root_block);
    child_mem = new("child_mem", 4, 8, "RW", UVM_NO_COVERAGE); child_mem.configure(child);
    deep_mem = new("deep_mem", 4, 8, "RW", UVM_NO_COVERAGE); deep_mem.configure(grandchild);
    peer_mem = new("peer_mem", 4, 8, "RW", UVM_NO_COVERAGE); peer_mem.configure(peer);
  endfunction
  // The pinned library requires a lock for ordinary name lookup and still
  // misses a nested-regfile register afterwards. Keep both required results.
  initial begin
    model_reg local_same; model_reg child_same;
    build_model();

    local_same = new("same"); local_same.configure(root_block);
    child_same = new("same"); child_same.configure(child);
    $display("UT: local_precedence root %0d child %0d",
    root_block.get_reg_by_name("same") == local_same,
             child.get_reg_by_name("same") == child_same);
    $display("UT: descendants child %0d deep %0d regfile %0d",
             root_block.get_reg_by_name("child_reg") == child_reg,
             root_block.get_reg_by_name("deep_reg") == deep_reg,
             root_block.get_reg_by_name("file_reg") == file_reg);
    $display("UT: missing %0d ancestor_excluded %0d peer_excluded %0d",
             root_block.get_reg_by_name("absent") == null,
             child.get_reg_by_name("root_reg") == null,
             root_block.get_reg_by_name("peer_reg") == null);

    root_block.lock_model();
    peer.lock_model();
    $display("UT: locked_local root %0d child %0d",
             root_block.get_reg_by_name("same") == local_same,
             child.get_reg_by_name("same") == child_same);
    $display("UT: locked_descendants child %0d deep %0d regfile %0d",
             root_block.get_reg_by_name("child_reg") == child_reg,
             root_block.get_reg_by_name("deep_reg") == deep_reg,
             root_block.get_reg_by_name("file_reg") == file_reg);
    $finish;
  end
endmodule
