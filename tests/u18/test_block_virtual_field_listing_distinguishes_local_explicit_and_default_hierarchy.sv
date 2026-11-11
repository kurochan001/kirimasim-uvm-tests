/*
:name: test_block_virtual_field_listing_distinguishes_local_explicit_and_default_hierarchy
:description: get_virtual_fields collects exact local or recursive field handles without peer roots (18.1.3.11)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.3.11 18.1.2.6 18.9.1.1.2 18.10.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_virtual_field_listing_distinguishes_local_explicit_and_default_hierarchy.expected
*/
// What it checks:
// 1. get_virtual_fields with UVM_NO_HIER returns only this block virtual
//    fields.
// 2. Explicit UVM_HIER includes fields in nested sub-blocks.
// 3. The default virtual-field hierarchy setting is recursive.
// 4. Virtual-field enumeration excludes fields belonging to an independent
//    root.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.1.3.11 (UVM-BLOCK-VIRTUAL-FIELD-LOCAL-LIST) gives rule 1
//    above. Setup: Use three local fields with fields also configured below
//    the block. Expected: Exactly three local handles are returned with
//    membership mask seven.
// 2. 1800.2-2020 18.1.3.11 (UVM-BLOCK-VIRTUAL-FIELD-EXPLICIT-RECURSION) gives
//    rule 2 above. Setup: Use three levels with six fields in total. Expected:
//    Exactly six expected handles are returned, with mask sixty-three.
// 3. 1800.2-2020 18.1.3.11 (UVM-BLOCK-VIRTUAL-FIELD-DEFAULT-RECURSION) gives
//    rule 3 above. Setup: Omit hier on the same three-level model. Expected:
//    The default queue contains all six exact subtree fields.
// 4. 1800.2-2020 18.1.3.11
//    (UVM-BLOCK-VIRTUAL-FIELD-INDEPENDENT-ROOT-EXCLUSION) gives rule 4 above.
//    Setup: Add a peer field outside the selected hierarchy. Expected: No
//    local, recursive or default membership mask includes the peer bit.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_block_virtual_field_listing_distinguishes_local_explicit_and_default_hierarchy;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class block_type extends uvm_reg_block;
    function new(string name); super.new(name, UVM_NO_COVERAGE); endfunction
  endclass
  class reg_type extends uvm_reg;
    function new(string name); super.new(name, 8, UVM_NO_COVERAGE); endfunction
  endclass
  block_type root_block, child, deep, peer;
  uvm_reg_map root_map, root_aux, child_map, child_aux, deep_map, peer_map;
  uvm_vreg root_vr, root_extra, child_vr, deep_vr, peer_vr;
  uvm_vreg_field r0, r1, r2, c0, c1, d0, p0;
  function automatic void mapped_register(block_type owner, uvm_reg_map map_value);
    reg_type value = new("value");
    uvm_reg_field field_value = uvm_reg_field::type_id::create("field");
    value.configure(owner); field_value.configure(value, 8, 0, "RW", 0, 0, 1, 0, 1);
    map_value.add_reg(value, 0, "RW");
  endfunction
  function automatic uvm_vreg virtual_register(block_type owner, string name);
    uvm_vreg result_value = new(name, 8);
    result_value.configure(owner); return result_value;
  endfunction
  function automatic uvm_vreg_field virtual_field(uvm_vreg owner, string name, int bits, int lsb);
    uvm_vreg_field value = uvm_vreg_field::type_id::create(name);
    value.configure(owner, bits, lsb); return value;
  endfunction
  function automatic void build_model();
    root_block = new("root"); child = new("child"); deep = new("deep"); peer = new("peer");
    root_block.configure(); child.configure(root_block); deep.configure(child); peer.configure();
    root_map = root_block.create_map("shared_map", 0, 1, UVM_LITTLE_ENDIAN);
    root_aux = root_block.create_map("root_map", 16, 1, UVM_LITTLE_ENDIAN);
    child_map = child.create_map("shared_map", 0, 1, UVM_LITTLE_ENDIAN);
    child_aux = child.create_map("child_map", 16, 1, UVM_LITTLE_ENDIAN);
    deep_map = deep.create_map("deep_map", 0, 1, UVM_LITTLE_ENDIAN);
    peer_map = peer.create_map("peer_map", 0, 1, UVM_LITTLE_ENDIAN);
    mapped_register(root_block, root_map); mapped_register(child, child_map);
    mapped_register(deep, deep_map); mapped_register(peer, peer_map);
    root_vr = virtual_register(root_block, "shared_vreg");
    root_extra = virtual_register(root_block, "root_vreg");
    child_vr = virtual_register(child, "shared_vreg");
    deep_vr = virtual_register(deep, "deep_vreg"); peer_vr = virtual_register(peer, "peer_vreg");
    r0 = virtual_field(root_vr, "shared", 4, 0); r1 = virtual_field(root_vr, "root_only", 4, 4);
    r2 = virtual_field(root_extra, "root_extra", 8, 0);
    c0 = virtual_field(child_vr, "shared", 4, 0); c1 = virtual_field(child_vr, "child_only", 4, 4);
    d0 = virtual_field(deep_vr, "deep_only", 8, 0); p0 = virtual_field(peer_vr, "peer_only", 8, 0);
    root_block.lock_model(); peer.lock_model();
  endfunction
  function automatic int field_members(uvm_vreg_field values[$]);
    int members = 0;
    foreach (values[i]) begin
      if (values[i] == r0) members |= 1; if (values[i] == r1) members |= 2;
      if (values[i] == r2) members |= 4; if (values[i] == c0) members |= 8;
      if (values[i] == c1) members |= 16; if (values[i] == d0) members |= 32;
      if (values[i] == p0) members |= 64;
    end
    return members;
  endfunction
  initial begin
    uvm_vreg_field local_fields[$], recursive_fields[$], default_fields[$];
    build_model();
    root_block.get_virtual_fields(local_fields, UVM_NO_HIER);
    root_block.get_virtual_fields(recursive_fields, UVM_HIER);
    root_block.get_virtual_fields(default_fields);
    $display("UT: local count %0d members %0d", local_fields.size(), field_members(local_fields));
    $display("UT: recursive count %0d members %0d", recursive_fields.size(),
             field_members(recursive_fields));
    $display("UT: default count %0d members %0d", default_fields.size(),
             field_members(default_fields));
    $finish;
  end
endmodule
