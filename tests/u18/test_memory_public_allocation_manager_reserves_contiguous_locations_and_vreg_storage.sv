/*
:name: test_memory_public_allocation_manager_reserves_contiguous_locations_and_vreg_storage
:description: The public memory allocation manager owns contiguous reservations and the implemented virtual-register range
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.2 18.6.3.2 18.12.5.1 18.12.6.2 18.12.6.3 18.12.7.2.1 18.12.7.2.2 18.12.7.2.3 18.12.7.2.6 18.9.1.1.3 18.9.1.1.5 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_public_allocation_manager_reserves_contiguous_locations_and_vreg_storage.expected
*/
// What it checks:
// 1. The public mam manages the memory corresponding to the abstraction
//    instance.
// 2. The memory manager can reserve a selected consecutive memory region.
// 3. The associated allocation manager owns the implemented virtual-register
//    range.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.6.2 (UVM-MEMORY-AUDIT-PUBLIC-MANAGER) gives rule 1 above.
//    Setup: A configured 32-location, 16-bit memory uses its public mam
//    directly; six bytes are reserved at word offset three and a two-element
//    32-bit vreg is implemented at offset ten. Expected: mam is nonnull and
//    its memory identity is the configured memory.
// 2. 1800.2-2020 18.6.2 (UVM-MEMORY-AUDIT-CONTIGUOUS-REGION) gives rule 2
//    above. Setup: A configured 32-location, 16-bit memory uses its public mam
//    directly; six bytes are reserved at word offset three and a two-element
//    32-bit vreg is implemented at offset ten. Expected: Six bytes at offset
//    three span locations three through five; an overlapping reservation
//    returns null.
// 3. 1800.2-2020 18.6.2 (UVM-MEMORY-AUDIT-VREG-REGION) gives rule 3 above.
//    Setup: A configured 32-location, 16-bit memory uses its public mam
//    directly; six bytes are reserved at word offset three and a two-element
//    32-bit vreg is implemented at offset ten. Expected: Implementation
//    succeeds and its region retains the memory and offsets ten through
//    thirteen.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_memory_public_allocation_manager_reserves_contiguous_locations_and_vreg_storage;
  import uvm_pkg::*;

  class block_type extends uvm_reg_block;
    function new(string name="owner56"); super.new(name,UVM_NO_COVERAGE); endfunction
  endclass

  class quiet_probe extends uvm_report_catcher;
    virtual function action_e catch();
      if (get_severity() inside {UVM_WARNING,UVM_ERROR}) return CAUGHT;
      return THROW;
    endfunction
  endclass

  initial begin
    automatic block_type owner=new();
    automatic uvm_mem memory=new("memory56",32,16);
    automatic uvm_vreg array_reg=new("array56",32);
    automatic quiet_probe quiet=new();
    uvm_mem_region reserved,overlap,implementation;
    bit ok;
    uvm_report_cb::add(null,quiet);
    owner.configure(); memory.configure(owner); array_reg.configure(owner);
    if (memory.mam==null) $fatal(1,"missing memory allocation manager");
    reserved=memory.mam.reserve_region(3,6);
    if (reserved==null) $fatal(1,"missing contiguous reservation");
    overlap=memory.mam.reserve_region(4,2);
    ok=array_reg.implement(2,memory,10,2); implementation=array_reg.get_region();
    $display("UT: public_manager memory %0d contiguous %0d overlap_rejected %0d",
      memory.mam.get_memory()==memory,
      reserved.get_start_offset()==3 && reserved.get_end_offset()==5 &&
      reserved.get_len()==3 && reserved.get_memory()==memory,overlap==null);
    $display("UT: vreg_reservation success %0d manager %0d region %0d",
      ok,implementation!=null && implementation.get_memory()==memory,
      implementation!=null && implementation.get_start_offset()==10 &&
      implementation.get_end_offset()==13);
    $finish;
  end
endmodule
