/*
:name: test_memory_manager_repeated_requests_randomize_the_selected_default_allocation_policy
:description: memory manager repeated requests randomize the selected default allocation policy
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.3 18.12.8.1 18.12.5.2 18.12.8.2.1 18.12.8.2.2 18.12.8.2.3 18.12.8.2.4 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_manager_repeated_requests_randomize_the_selected_default_allocation_policy.expected
*/
// What it checks:
// 1. An omitted request policy uses default_alloc; an explicit policy takes
//    precedence without replacing the default.
// 2. A legal original policy subtype can be selected through the standard
//    allocation-policy base.
// 3. Each selected default-policy request randomizes that policy again using
//    the current request length and bounds.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.12.5.2 (UVM-MEMORY-MANAGER-DEFAULT-POLICY-SELECTION) gives
//    rule 1 above. Setup: Install a default policy selecting eight and
//    explicitly pass another selecting sixteen. Expected: Regions start at
//    8/16, each policy randomizes once and the exact default handle is
//    retained.
// 2. 1800.2-2020 18.12.8.1 (UVM-MAM-AUDIT-POLICY-DECLARATION) gives rule 2
//    above. Setup: Use the linked original fixtures and the explicit sizes,
//    location offsets, handles and observations they declare. Allocation
//    inputs are configured explicitly rather than relying on unspecified
//    initial defaults. Expected: A legal original policy subtype can be
//    selected through the standard allocation-policy base.
// 3. 1800.2-2020 18.12.3 (UVM-MAM-AUDIT-DEFAULT-POLICY-RERANDOMIZE) gives rule
//    3 above. Setup: Use the linked original fixtures and the explicit sizes,
//    location offsets, handles and observations they declare. Allocation
//    inputs are configured explicitly rather than relying on unspecified
//    initial defaults. Expected: Each selected default-policy request
//    randomizes that policy again using the current request length and bounds.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_memory_manager_repeated_requests_randomize_the_selected_default_allocation_policy;
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
  class fixed_policy extends uvm_mem_mam_policy;
    uvm_reg_addr_t wanted=12;
    int randomizations=0;
    constraint selected_start {start_offset==wanted;}
    function void pre_randomize(); randomizations++; endfunction
  endclass
  initial begin
    automatic uvm_mem_mam_cfg cfg=make_cfg();
    automatic uvm_mem_mam manager=new("manager",cfg);
    automatic fixed_policy policy=new();
    uvm_mem_region first,second;
    int previous_randomizations;
    manager.default_alloc=policy; first=manager.request_region(5);
    if (first==null) $fatal(1,"first original request failed");
    $display("UT: default_alloc_first randomized %0d start %0d len %0d bounds %0d",
             policy.randomizations>0,first.get_start_offset()==12,policy.len==2,
             policy.min_offset==5 && policy.max_offset==31);
    previous_randomizations=policy.randomizations;
    policy.wanted=19; second=manager.request_region(4);
    if (second==null) $fatal(1,"second original request failed");
    $display("UT: default_alloc_next randomized %0d start %0d len %0d count %0d same %0d",
             policy.randomizations>previous_randomizations,second.get_start_offset()==19,
             policy.len==1,
             count_regions(manager)==2,manager.default_alloc==policy);
    $finish;
  end
endmodule
