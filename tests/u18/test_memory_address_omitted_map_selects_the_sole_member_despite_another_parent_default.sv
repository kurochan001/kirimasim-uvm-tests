/*
:name: test_memory_address_omitted_map_selects_the_sole_member_despite_another_parent_default
:description: memory address omitted map selects the sole member despite another parent default
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.4.16 18.6.3.1 18.6.3.2 18.2.3.4 18.1.2.4 18.1.2.5 18.1.2.3 18.1.2.6 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_address_omitted_map_selects_the_sole_member_despite_another_parent_default.expected
*/
// What it checks:
// 1. A selected memory location has the explicit map base physical address.
// 2. An omitted map selects the sole memory member despite another parent
//    default.
// 3. Omitting the memory address location argument selects zero.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.6.4.16 (UVM-MEM-FIFO-AUDIT-MEM-ADDRESS-EXPLICIT) gives
//    rule 1 above. Setup: Construct valid memory maps, configure the parent
//    default explicitly and lock before querying; distinguish sole-member and
//    shared-memory cases. Expected: Location two is 0x124 in the selected
//    2-byte map.
// 2. 1800.2-2020 18.6.4.16 (UVM-MEM-FIFO-AUDIT-MEM-ADDRESS-SOLE-DEFAULT) gives
//    rule 2 above. Setup: Construct valid memory maps, configure the parent
//    default explicitly and lock before querying; distinguish sole-member and
//    shared-memory cases. Expected: The omitted-map location-two query retains
//    0x124.
// 3. 1800.2-2020 18.6.4.16 (UVM-MEM-FIFO-AUDIT-MEM-ADDRESS-OFFSET-DEFAULT)
//    gives rule 3 above. Setup: Construct valid memory maps, configure the
//    parent default explicitly and lock before querying; distinguish
//    sole-member and shared-memory cases. Expected: The fully omitted query
//    returns 0x120 for location zero.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_memory_address_omitted_map_selects_the_sole_member_despite_another_parent_default;
  import uvm_pkg::*;
  class block_type extends uvm_reg_block;
    function new(); super.new("owner63",UVM_NO_COVERAGE); endfunction
  endclass
  class reports extends uvm_report_catcher;
    bit gated=0;
    int warnings=0;
    virtual function action_e catch();
      if (gated && get_severity()==UVM_WARNING) begin warnings++; return CAUGHT; end
      return THROW;
    endfunction
  endclass

  initial begin
    block_type owner;
    uvm_mem memory;
    uvm_reg_map member_map,other_map;
    owner=new(); owner.configure(); memory=new("memory63",4,16); memory.configure(owner);
    member_map=owner.create_map("member63",'h100,2,UVM_LITTLE_ENDIAN);
    other_map=owner.create_map("other63",'h500,2,UVM_LITTLE_ENDIAN);
    member_map.add_mem(memory,'h20); owner.set_default_map(other_map); owner.lock_model();
    $display("UT: memory_sole default_other %0d one_member %0d explicit %0d",
      owner.get_default_map()==other_map,memory.get_n_maps()==1,
      memory.get_address(2,member_map)=='h124);
    $display("UT: memory_sole omitted_location %0d omitted_offset %0d",
      memory.get_address(2)=='h124,memory.get_address()=='h120);
    $finish;
  end
endmodule
