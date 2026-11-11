/*
:name: test_memory_manager_configuration_query_and_compatible_shrink_preserve_active_regions
:description: memory manager configuration query and compatible shrink preserve active regions
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.4.2 18.12.9.2.1 18.12.9.2.2 18.12.9.2.3 18.12.5.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_manager_configuration_query_and_compatible_shrink_preserve_active_regions.expected
*/
// What it checks:
// 1. Compatible reconfiguration returns the previous configuration and retains
//    existing regions.
// 2. Omitted and explicit-null reconfiguration query current configuration
//    without changing existing reservations.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.12.4.2 (UVM-MAM-COMPATIBLE-RECONFIGURATION) gives rule 1
//    above. Setup: Keep the byte width and change bounds from 0..15 to 2..31
//    around region 4..5. Expected: Returned bounds are 0..15, current bounds
//    are 2..31 and the region stays 4..5.
// 2. 1800.2-2020 18.12.4.2 (UVM-MAM-AUDIT-CONFIGURATION-QUERY) gives rule 2
//    above. Setup: Use the linked original fixtures and the explicit sizes,
//    location offsets, handles and observations they declare. Allocation
//    inputs are configured explicitly rather than relying on unspecified
//    initial defaults. Expected: Omitted and explicit-null reconfiguration
//    query current configuration without changing existing reservations.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_memory_manager_configuration_query_and_compatible_shrink_preserve_active_regions;
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
    automatic uvm_mem_mam_cfg replacement=make_cfg(4,12,13);
    automatic uvm_mem_mam manager=new("manager",cfg);
    uvm_mem_mam_cfg omitted,explicit_null,previous,current;
    uvm_mem_region region;
    region=manager.reserve_region(12,8);
    if (region==null) $fatal(1,"missing region");
    omitted=manager.reconfigure(); explicit_null=manager.reconfigure(null);
    $display("UT: config_query omitted %0d explicit_null %0d unchanged %0d",
             omitted.n_bytes==4 && omitted.start_offset==5 && omitted.end_offset==31,
             explicit_null.n_bytes==4 && explicit_null.start_offset==5 &&
             explicit_null.end_offset==31,count_regions(manager)==1);
    previous=manager.reconfigure(replacement); current=manager.reconfigure();
    $display("UT: config_shrink previous %0d current %0d region %0d",
             previous.start_offset==5 && previous.end_offset==31,
             current.start_offset==12 && current.end_offset==13 && current.n_bytes==4,
             region.get_start_offset()==12 && region.get_end_offset()==13);
    $finish;
  end
endmodule
