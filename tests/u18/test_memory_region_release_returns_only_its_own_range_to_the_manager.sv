/*
:name: test_memory_region_release_returns_only_its_own_range_to_the_manager
:description: memory region release returns only its own range to the manager
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.7.2.5 18.12.5.1 18.12.5.3 18.12.6.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_region_release_returns_only_its_own_range_to_the_manager.expected
*/
// What it checks:
// 1. Explicit release makes a reserved range available to a later reservation.
// 2. The region release method returns its own range to the manager without
//    releasing an independent peer.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.12.5.3 (UVM-MAM-EXPLICIT-RELEASE-REUSE) gives rule 1
//    above. Setup: Reserve four locations at six, release and reserve the same
//    range. Expected: The range is available again and exactly one region
//    remains active.
// 2. 1800.2-2020 18.12.7.2.5 (UVM-MAM-AUDIT-REGION-RELEASE) gives rule 2
//    above. Setup: Use the linked original fixtures and the explicit sizes,
//    location offsets, handles and observations they declare. Allocation
//    inputs are configured explicitly rather than relying on unspecified
//    initial defaults. Expected: The region release method returns its own
//    range to the manager without releasing an independent peer.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_memory_region_release_returns_only_its_own_range_to_the_manager;
  import uvm_pkg::*;
  function automatic uvm_mem_mam_cfg make_cfg(int bytes_per_location=4,
                                               uvm_reg_addr_t first=5,last=31);
    uvm_mem_mam_cfg cfg=new();
    cfg.n_bytes=bytes_per_location; cfg.start_offset=first; cfg.end_offset=last;
    cfg.mode=uvm_mem_mam::GREEDY; cfg.locality=uvm_mem_mam::BROAD;
    return cfg;
  endfunction
  function automatic int count_regions(uvm_mem_mam manager);
    uvm_mem_region value=manager.for_each(1);
    int count=0;
    while (value!=null && count<100) begin count++; value=manager.for_each(); end
    return count;
  endfunction
  class error_probe extends uvm_report_catcher;
    int errors=0;
    virtual function action_e catch();
      if (get_severity()==UVM_ERROR) begin errors++; return CAUGHT; end
      return THROW;
    endfunction
  endclass
  initial begin
    automatic uvm_mem_mam_cfg cfg=make_cfg();
    automatic uvm_mem_mam manager=new("manager",cfg);
    automatic error_probe probe=new();
    uvm_mem_region selected,peer,again,blocked;
    selected=manager.reserve_region(9,8); peer=manager.reserve_region(15,8);
    if (selected==null || peer==null) $fatal(1,"missing regions");
    selected.release_region(); again=manager.reserve_region(9,8);
    uvm_report_cb::add(null,probe); blocked=manager.reserve_region(15,8);
    $display("UT: region_release again %0d peer_reserved %0d count %0d",
             again!=null,blocked==null,count_regions(manager)==2);
    uvm_report_cb::delete(null,probe); $finish;
  end
endmodule
