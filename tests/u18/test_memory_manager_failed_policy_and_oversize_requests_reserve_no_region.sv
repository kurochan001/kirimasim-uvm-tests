/*
:name: test_memory_manager_failed_policy_and_oversize_requests_reserve_no_region
:description: memory manager failed policy and oversize requests reserve no region
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.5.2 18.12.6.2 18.12.8 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_manager_failed_policy_and_oversize_requests_reserve_no_region.expected
*/
// What it checks:
// Contradictory or oversized allocation requests return null and reserve no
// region, leaving a valid reservation control possible.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.12.5.2 (UVM-MAM-AUDIT-FAILED-REQUEST-NULL) gives the rule
// above. Setup: Use the linked original fixtures and the explicit sizes,
// location offsets, handles and observations they declare. Allocation inputs
// are configured explicitly rather than relying on unspecified initial
// defaults. Expected: Contradictory or oversized allocation requests return
// null and reserve no region, leaving a valid reservation control possible.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_memory_manager_failed_policy_and_oversize_requests_reserve_no_region;
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
  class impossible_policy extends uvm_mem_mam_policy;
    constraint impossible {start_offset<min_offset;}
  endclass
  initial begin
    automatic uvm_mem_mam_cfg cfg=make_cfg(1,5,8);
    automatic uvm_mem_mam manager=new("manager",cfg);
    automatic impossible_policy policy=new();
    automatic error_probe probe=new();
    uvm_mem_region contradiction,oversize,control;
    uvm_report_cb::add(null,probe);
    contradiction=manager.request_region(1,policy);
    $display("UT: failed_request contradiction %0d empty %0d",
             contradiction==null,count_regions(manager)==0);
    oversize=manager.request_region(5);
    $display("UT: failed_request oversize %0d empty %0d",oversize==null,count_regions(manager)==0);
    control=manager.reserve_region(5,4);
    $display("UT: failed_request valid_control %0d",control!=null);
    uvm_report_cb::delete(null,probe); $finish;
  end
endmodule
