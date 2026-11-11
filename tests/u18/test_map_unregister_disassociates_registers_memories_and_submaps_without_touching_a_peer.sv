/*
:name: test_map_unregister_disassociates_registers_memories_and_submaps_without_touching_a_peer
:description: map unregister clears local contents and child-map association while preserving another map (18.2.3.11)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.3.11 18.2.4.10 18.2.4.11 18.2.4.13 18.2.3.3 18.2.3.4 18.2.3.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_map_unregister_disassociates_registers_memories_and_submaps_without_touching_a_peer.expected
*/
// What it checks:
// 1. Map unregister disassociates its local register content.
// 2. Map unregister disassociates its local memory content.
// 3. Map unregister disassociates its child-map content.
// 4. Unregistering a map preserves disjoint content of another map.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.2.3.11 (UVM-MAP-UNREGISTER-LOCAL-REGISTERS) gives rule 1
//    above. Setup: Unregister an unlocked map with one local register.
//    Expected: The map local register queue becomes empty.
// 2. 1800.2-2020 18.2.3.11 (UVM-MAP-UNREGISTER-LOCAL-MEMORIES) gives rule 2
//    above. Setup: Unregister a map containing one memory. Expected: The map
//    local memory queue becomes empty.
// 3. 1800.2-2020 18.2.3.11 (UVM-MAP-UNREGISTER-SUBMAP-ASSOCIATION) gives rule
//    3 above. Setup: Unregister a map with one child map. Expected: The submap
//    queue becomes empty.
// 4. 1800.2-2020 18.2.3.11 (UVM-MAP-UNREGISTER-PEER-CONTENT-ISOLATION) gives
//    rule 4 above. Setup: Keep a separate register/memory pair on a second
//    map. Expected: Its exact register and memory remain, one of each.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_map_unregister_disassociates_registers_memories_and_submaps_without_touching_a_peer;
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
    automatic uvm_mem removed_mem = new("removed_mem", 4, 8);
    automatic uvm_mem retained_mem = new("retained_mem", 4, 8);
    automatic uvm_reg retained_register;
    uvm_reg regs[$], retained_regs[$];
    uvm_mem mems[$], retained_mems[$];
    uvm_reg_map submaps[$];
    // Construct a separate unlocked graph; the hierarchy fixture is unused.
    root_block = new("owner"); child = new("child");
    root_block.configure(); child.configure(root_block);
    root_map = root_block.create_map("removed", 0, 1, UVM_LITTLE_ENDIAN);
    root_aux = root_block.create_map("retained", 0, 1, UVM_LITTLE_ENDIAN);
    child_map = child.create_map("child", 0, 1, UVM_LITTLE_ENDIAN);
    mapped_register(root_block, root_map);
    // Use a distinct register name within the same block.
    begin
      automatic reg_type value = new("retained_value");
      automatic uvm_reg_field field_value = uvm_reg_field::type_id::create("field");
      value.configure(root_block); field_value.configure(value, 8, 0, "RW", 0, 0, 1, 0, 1);
      root_aux.add_reg(value, 0, "RW"); retained_register = value;
    end
    mapped_register(child, child_map);
    removed_mem.configure(root_block); retained_mem.configure(root_block);
    root_map.add_mem(removed_mem, 4); root_aux.add_mem(retained_mem, 4);
    root_map.add_submap(child_map, 16);
    root_map.unregister();
    root_map.get_registers(regs, UVM_NO_HIER); root_map.get_memories(mems, UVM_NO_HIER);
    root_map.get_submaps(submaps);
    root_aux.get_registers(retained_regs, UVM_NO_HIER);
    root_aux.get_memories(retained_mems, UVM_NO_HIER);
    $display("UT: removed registers %0d memories %0d submaps %0d",
             regs.size(), mems.size(), submaps.size());
    $display(
      "UT: retained registers %0d exact_register %0d memories %0d exact_memory %0d",
      retained_regs.size(), retained_regs.size() == 1 && retained_regs[0] == retained_register,
      retained_mems.size(), retained_mems.size() == 1 && retained_mems[0] == retained_mem);
    $finish;
  end
endmodule
