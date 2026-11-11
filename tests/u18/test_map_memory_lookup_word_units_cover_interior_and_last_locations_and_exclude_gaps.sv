/*
:name: test_map_memory_lookup_word_units_cover_interior_and_last_locations_and_exclude_gaps
:description: map memory lookup word units cover interior and last locations and exclude gaps
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.4.18 18.2.3.4 18.2.4.6 18.1.2.3 18.1.2.2 18.1.2.6 18.6.3.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_map_memory_lookup_word_units_cover_interior_and_last_locations_and_exclude_gaps.expected
*/
// What it checks:
// 1. Memory lookup in selected word units returns the same memory for first,
//    interior and last occupied locations.
// 2. Memory lookup in selected word units returns null immediately before and
//    after the occupied range.
// 3. Memory lookup at the same selected word offset is local to each distinct
//    map.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.2.4.18 (UVM-MAP-SCOPE-MEMORY-LOOKUP-WORD-INTERIOR) gives
//    rule 1 above. Setup: Locked zero-base maps avoid conflating the offset
//    contract with external-base wording. Byte addressing uses four 16-bit
//    entries on a one-byte bus; word addressing uses three 64-bit entries on a
//    four-byte bus. A separate map contains a different memory at the same
//    offset. Expected: Memory lookup in selected word units returns the same
//    memory for first, interior and last occupied locations.
// 2. 1800.2-2020 18.2.4.18 (UVM-MAP-SCOPE-MEMORY-LOOKUP-WORD-MISSING) gives
//    rule 2 above. Setup: Locked zero-base maps avoid conflating the offset
//    contract with external-base wording. Byte addressing uses four 16-bit
//    entries on a one-byte bus; word addressing uses three 64-bit entries on a
//    four-byte bus. A separate map contains a different memory at the same
//    offset. Expected: Memory lookup in selected word units returns null
//    immediately before and after the occupied range.
// 3. 1800.2-2020 18.2.4.18 (UVM-MAP-SCOPE-MEMORY-LOOKUP-WORD-MAP-LOCAL) gives
//    rule 3 above. Setup: Locked zero-base maps avoid conflating the offset
//    contract with external-base wording. Byte addressing uses four 16-bit
//    entries on a one-byte bus; word addressing uses three 64-bit entries on a
//    four-byte bus. A separate map contains a different memory at the same
//    offset. Expected: Memory lookup at the same selected word offset is local
//    to each distinct map.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_map_memory_lookup_word_units_cover_interior_and_last_locations_and_exclude_gaps;
  import uvm_pkg::*;
  class block_type extends uvm_reg_block;
    function new(string name); super.new(name,UVM_NO_COVERAGE); endfunction
  endclass

  initial begin
    automatic block_type owner=new("owner51");
    automatic uvm_mem chosen=new("chosen51",3,64,"RW",UVM_NO_COVERAGE);
    automatic uvm_mem peer=new("peer51",3,64,"RW",UVM_NO_COVERAGE);
    uvm_reg_map selected,other;
    owner.configure();chosen.configure(owner);peer.configure(owner);
    selected=owner.create_map("selected51",0,4,UVM_LITTLE_ENDIAN,0);
    other=owner.create_map("other51",0,4,UVM_LITTLE_ENDIAN,0);
    selected.add_mem(chosen,'h10);other.add_mem(peer,'h10);owner.lock_model();
    $display("UT: mem_lookup_word first %0d interior %0d last %0d",
      selected.get_mem_by_offset('h10)==chosen,
      selected.get_mem_by_offset('h13)==chosen,
      selected.get_mem_by_offset('h15)==chosen);
    $display("UT: mem_lookup_word before_null %0d after_null %0d other_map %0d",
      selected.get_mem_by_offset('hf)==null,
      selected.get_mem_by_offset('h16)==null,other.get_mem_by_offset('h10)==peer);
    $finish;
  end
endmodule
