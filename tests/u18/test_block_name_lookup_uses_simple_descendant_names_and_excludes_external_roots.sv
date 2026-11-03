/*
:name: test_block_name_lookup_uses_simple_descendant_names_and_excludes_external_roots
:description: get_block_by_name searches simple descendant names and returns null beyond that subtree (18.1.3.12)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.3.12 18.1.2.6 18.1.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_name_lookup_uses_simple_descendant_names_and_excludes_external_roots.expected
*/
// The pinned block-name query finds direct children but misses deeper ones.
// Preserve the simple-name descendant search required by the standard.
module test_block_name_lookup_uses_simple_descendant_names_and_excludes_external_roots;
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
    $display("UT: descendants child %0d deep %0d nested %0d",
             root_block.get_block_by_name("child") == child,
             root_block.get_block_by_name("deep") == deep, child.get_block_by_name("deep") == deep);
    $display("UT: missing %0d ancestor_excluded %0d peer_excluded %0d",
             root_block.get_block_by_name("missing") == null,
             child.get_block_by_name("root") == null,
             root_block.get_block_by_name("peer") == null);
    $finish;
  end
endmodule
