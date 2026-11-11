/*
:name: test_memory_manager_rejects_a_foreign_region_before_an_independent_valid_control
:description: memory manager rejects a foreign region before an independent valid control
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.5.3 18.12.5.1 6.6.5 D.4.4 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_manager_rejects_a_foreign_region_before_an_independent_valid_control.expected
*/
// What it checks:
// Releasing a foreign region or releasing an already released region reports
// an error.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.12.5.3 (UVM-MAM-AUDIT-INVALID-RELEASE-ERROR) gives the rule
// above. Setup: Use the linked original fixtures and the explicit sizes,
// location offsets, handles and observations they declare. Allocation inputs
// are configured explicitly rather than relying on unspecified initial
// defaults. Expected: Releasing a foreign region or releasing an already
// released region reports an error.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_memory_manager_rejects_a_foreign_region_before_an_independent_valid_control;
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
    automatic uvm_mem_mam other=new("other",cfg);
    uvm_mem_region region;
    region=other.reserve_region(9,4);
    if (region==null) $fatal(1,"missing region");
    uvm_report_cb::add(null,probe); manager.release_region(region);
    $display("UT: invalid_release_error %0d",probe.errors>0);
    uvm_report_cb::delete(null,probe);
    // Later checks use a separate valid manager, not the invalid-call state.
    begin
      automatic uvm_mem_mam_cfg valid_cfg=make_cfg();
      automatic uvm_mem_mam control=new("control",valid_cfg);
      uvm_mem_region value;
      value=control.reserve_region(9,4);
      if (value==null) $fatal(1,"control reserve failed");
      control.release_region(value);
      $display("UT: valid_release_control %0d",count_regions(control)==0);
    end
    $finish;
  end
endmodule
