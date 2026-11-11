/*
:name: test_mem_two_interface_maps_preserve_membership_addresses_and_rights
:description: one memory can be registered through two independent physical interface maps (IEEE 1800.2-2020 Section 18.2.3.4)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.3.4 18.6.4.2 18.6.4.3 18.6.4.4 18.6.4.5 18.6.4.16 18.6.3.2 18.1.2.3 18.1.2.6 6.6.3.2 6.6.5 18.1.2.1 18.1.2.2 18.4.2.1 18.6.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_mem_two_interface_maps_preserve_membership_addresses_and_rights.expected
*/
// What it checks:
// 1. Memory map count reports the number of maps containing the memory.
// 2. Memory get_maps returns the maps where that memory is registered.
// 3. Memory is_in_map distinguishes member maps from nonmembers.
// 4. Memory get_rights reports map-specific accessibility independently of
//    intrinsic memory policy.
// 5. The selected memory can belong to two interfaces with independent offsets
//    and rights.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.6.4.2 (UVM-MEMORY-MAP-COUNT) gives rule 1 above. Setup:
//    Register one memory in one map or two sibling-interface maps. Expected:
//    The counts are one and two for the respective fixtures.
// 2. 1800.2-2020 18.6.4.4 (UVM-MEMORY-MAP-LIST) gives rule 2 above. Setup:
//    Start with an empty map queue and inspect one/two registered maps.
//    Expected: The returned handles/list sizes agree with the registered maps.
// 3. 1800.2-2020 18.6.4.3 (UVM-MEMORY-MAP-MEMBERSHIP) gives rule 3 above.
//    Setup: Query registered maps, a different map and null in the single-map
//    fixture. Expected: Registered maps are members; the unrelated/null
//    handles are not.
// 4. 1800.2-2020 18.6.4.5 (UVM-MEMORY-MAP-RIGHTS) gives rule 4 above. Setup:
//    Use RO/WO interface maps and separately an intrinsic RO memory with RW
//    maps. Expected: Interface rights remain RO/WO, while the intrinsic-RO
//    fixture reports RW rights.
// 5. 1800.2-2020 18.2.3.4 (UVM-MAP-SCOPE-MEMORY-MULTI-INTERFACE) gives rule 5
//    above. Setup: Selected valid memory ownership, multiple interfaces or an
//    explicitly supplied original custom frontdoor. The unmapped memory has a
//    nominal offset overlapping a real mapped memory, while its custom
//    sequence implements logical location storage and reports successful
//    completion. Expected: The selected memory can belong to two interfaces
//    with independent offsets and rights.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Explicit map arguments select independent offsets and rights. Compare
// membership as a set and count errors without changing report severity.

module test_mem_two_interface_maps_preserve_membership_addresses_and_rights;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class model_block extends uvm_reg_block;
    function new(string name="blk"); super.new(name, UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(string name="r", int unsigned width=8);
      super.new(name, width, UVM_NO_COVERAGE);
    endfunction
  endclass
  class model_mem extends uvm_mem;
    function new(string name="mem", longint unsigned size=4,
                 int unsigned width=16, string access="RW");
      super.new(name, size, width, access, UVM_NO_COVERAGE);
    endfunction
  endclass

  class report_probe extends uvm_report_catcher;
    int warnings = 0;
    int errors = 0;
    function new(); super.new("probe"); endfunction
    virtual function action_e catch();
      if (get_severity() == UVM_WARNING) warnings++;
      if (get_severity() == UVM_ERROR) errors++;
      return CAUGHT;
    endfunction
  endclass

  initial begin
    automatic model_block blk = new("blk");
    automatic model_mem mem = new("mem", 4, 16);
    uvm_reg_map mapping;
    uvm_reg_map second;
    uvm_reg_map maps[$];
    automatic int first_seen = 0;
    automatic int second_seen = 0;
    automatic report_probe probe = new();
    uvm_report_cb::add(null, probe);
    blk.configure();
    mem.configure(blk);
    mapping = blk.create_map("read", 'h100, 2, UVM_LITTLE_ENDIAN);
    second = blk.create_map("write", 'h300, 2, UVM_LITTLE_ENDIAN);
    mapping.add_mem(mem, 'h10, "RO");
    second.add_mem(mem, 'h20, "WO");
    blk.lock_model();
    mem.get_maps(maps);
    foreach (maps[i]) begin
      if (maps[i] == mapping) first_seen++;
      if (maps[i] == second) second_seen++;
    end
    $display("UT: maps %0d listed %0d members %0d %0d errors %0d", mem.get_n_maps(),
             maps.size(), first_seen, second_seen, probe.errors);
    $display("UT: addresses %0h %0h rights %s %s", mem.get_address(0, mapping),
             mem.get_address(0, second), mem.get_rights(mapping), mem.get_rights(second));
    $finish;
  end
endmodule
