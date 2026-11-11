/*
:name: test_map_unmapped_memory_uses_custom_frontdoor_and_ignores_its_nominal_physical_offset
:description: map unmapped memory uses custom frontdoor and ignores its nominal physical offset
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.3.4 18.2.4.18 18.6.5.1 18.6.5.2 19.4.2.2.1 19.4.2.3 19.1.1.2.2 19.1.1.2.4 19.1.1.2.5 19.1.1.2.6 18.2.3.6 18.1.2.2 18.1.2.3 18.1.2.6 18.6.3.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_map_unmapped_memory_uses_custom_frontdoor_and_ignores_its_nominal_physical_offset.expected
*/
// What it checks:
// 1. Omitting add_mem rights gives the selected mapped memory RW rights.
// 2. An unmapped memory does not replace the real physical lookup entry at its
//    ignored nominal offset.
// 3. The explicitly supplied frontdoor accesses the selected unmapped memory
//    logical location.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.2.3.4 (UVM-MAP-SCOPE-MEMORY-DEFAULT-RIGHTS) gives rule 1
//    above. Setup: Selected valid memory ownership, multiple interfaces or an
//    explicitly supplied original custom frontdoor. The unmapped memory has a
//    nominal offset overlapping a real mapped memory, while its custom
//    sequence implements logical location storage and reports successful
//    completion. Expected: Omitting add_mem rights gives the selected mapped
//    memory RW rights.
// 2. 1800.2-2020 18.2.3.4 (UVM-MAP-SCOPE-MEMORY-UNMAPPED-NO-ADDRESS) gives
//    rule 2 above. Setup: Selected valid memory ownership, multiple interfaces
//    or an explicitly supplied original custom frontdoor. The unmapped memory
//    has a nominal offset overlapping a real mapped memory, while its custom
//    sequence implements logical location storage and reports successful
//    completion. Expected: An unmapped memory does not replace the real
//    physical lookup entry at its ignored nominal offset.
// 3. 1800.2-2020 18.2.3.4 (UVM-MAP-SCOPE-MEMORY-UNMAPPED-FRONTDOOR) gives rule
//    3 above. Setup: Selected valid memory ownership, multiple interfaces or
//    an explicitly supplied original custom frontdoor. The unmapped memory has
//    a nominal offset overlapping a real mapped memory, while its custom
//    sequence implements logical location storage and reports successful
//    completion. Expected: The explicitly supplied frontdoor accesses the
//    selected unmapped memory logical location.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_map_unmapped_memory_uses_custom_frontdoor_and_ignores_its_nominal_physical_offset;
  import uvm_pkg::*;
  class block_type extends uvm_reg_block;
    function new(string name); super.new(name,UVM_NO_COVERAGE); endfunction
  endclass

  `include "uvm_macros.svh"
  class logical_frontdoor extends uvm_reg_frontdoor;
    uvm_reg_data_t storage[uvm_reg_addr_t];
    uvm_object seen_element;
    uvm_reg_addr_t seen_offset;
    int calls=0;
    function new();super.new("logical51");endfunction
    virtual task body();
      seen_element=rw_info.get_element();seen_offset=rw_info.get_offset();calls++;
      #2;
      if (rw_info.get_kind()==UVM_WRITE) storage[seen_offset]=rw_info.get_value(0);
      else rw_info.set_value(storage[seen_offset]);
      rw_info.set_status(UVM_IS_OK);
    endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    block_type owner;
    uvm_mem logical_mem,physical_mem;
    uvm_reg_map mapping;
    logical_frontdoor fd;
    uvm_sequencer#(uvm_sequence_item) seq;
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);owner=new("owner51");owner.configure();
      logical_mem=new("logical51",8,32,"RW",UVM_NO_COVERAGE);
      physical_mem=new("physical51",8,32,"RW",UVM_NO_COVERAGE);
      logical_mem.configure(owner);physical_mem.configure(owner);
      mapping=owner.create_map("bus51",0,4,UVM_LITTLE_ENDIAN);fd=new();
      mapping.add_mem(physical_mem,'h80);mapping.add_mem(logical_mem,'h80,"RW",1,fd);
      seq=new("seq51",this);mapping.set_sequencer(seq);owner.lock_model();
    endfunction
    virtual task run_phase(uvm_phase phase);
      uvm_status_e status;
      uvm_reg_data_t value;
      bit ok;
      phase.raise_objection(this);
      logical_mem.write(status,3,'h51A3,UVM_FRONTDOOR,mapping);ok=status==UVM_IS_OK;
      logical_mem.read(status,3,value,UVM_FRONTDOOR,mapping);
      $display("UT: unmapped_memory access %0d value %0h element %0d offset %0d used %0d",
        ok && status==UVM_IS_OK,value,fd.seen_element==logical_mem,fd.seen_offset,fd.calls>0);
      $display("UT: unmapped_memory physical_only %0d after_null %0d default_rights %0d",
        mapping.get_mem_by_offset('h8c)==physical_mem,mapping.get_mem_by_offset('ha0)==null,
        physical_mem.get_rights(mapping)=="RW");
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100;$fatal(1,"unmapped memory watchdog");end
endmodule
