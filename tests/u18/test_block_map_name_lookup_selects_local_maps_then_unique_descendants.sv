/*
:name: test_block_map_name_lookup_selects_local_maps_then_unique_descendants
:description: get_map_by_name selects local maps first and searches descendants without ancestors or peers (18.1.3.13)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.3.13 18.1.2.6 18.1.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_map_name_lookup_selects_local_maps_then_unique_descendants.expected
*/
// What it checks:
// 1. The address map name query prefers a local match over a descendant.
// 2. The address map name query finds unambiguous descendant matches.
// 3. The address map name query returns null for missing, ancestor-only or
//    independent-root names.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.1.3.13 (UVM-BLOCK-MAP-NAME-LOCAL-PRECEDENCE) gives rule 1
//    above. Setup: Use the same simple name in the root and child. Expected:
//    Root and child queries return their own exact handles.
// 2. 1800.2-2020 18.1.3.13 (UVM-BLOCK-MAP-NAME-DESCENDANT-SEARCH) gives rule 2
//    above. Setup: Search unique names below the local block. Expected: The
//    expected descendant handles are returned exactly.
// 3. 1800.2-2020 18.1.3.13 (UVM-BLOCK-MAP-NAME-MISSING-AND-OUTSIDE-SCOPE)
//    gives rule 3 above. Setup: Query three out-of-scope or absent names.
//    Expected: All three results are null.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The pinned map-name query finds local maps but misses child-block maps.
// Preserve the required recursive search even on the locked model.
module test_block_map_name_lookup_selects_local_maps_then_unique_descendants;
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
    build_model();
    $display("UT: local root %0d child %0d", root_block.get_map_by_name("shared_map") == root_map,
             child.get_map_by_name("shared_map") == child_map);
    $display("UT: descendants child %0d deep %0d",
             root_block.get_map_by_name("child_map") == child_aux,
             root_block.get_map_by_name("deep_map") == deep_map);
    $display("UT: missing %0d ancestor_excluded %0d peer_excluded %0d",
             root_block.get_map_by_name("missing") == null,
             child.get_map_by_name("root_map") == null,
             root_block.get_map_by_name("peer_map") == null);
    $finish;
  end
endmodule
