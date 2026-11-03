/*
:name: test_memory_manager_iterator_handles_empty_exhausted_reset_and_release_all_states
:description: memory manager iterator handles empty exhausted reset and release all states
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.6.2 18.12.5.4 18.12.5.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_manager_iterator_handles_empty_exhausted_reset_and_release_all_states.expected
*/
module test_memory_manager_iterator_handles_empty_exhausted_reset_and_release_all_states;
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
    uvm_mem_region a,b,value;
    int seen_a,seen_b,visits;
    $display("UT: iterator_empty reset %0d next %0d",
             manager.for_each(1)==null,manager.for_each()==null);
    a=manager.reserve_region(9,4); b=manager.reserve_region(15,4);
    if (a==null || b==null) $fatal(1,"missing regions");
    seen_a=0; seen_b=0; visits=0; value=manager.for_each(1);
    while (value!=null && visits<100) begin
      seen_a+=value==a; seen_b+=value==b; visits++; value=manager.for_each();
    end
    $display("UT: iterator_members visits %0d a %0d b %0d exhausted %0d",visits,
             seen_a,seen_b,value==null);
    value=manager.for_each(1);
    $display("UT: iterator_restart member %0d",value==a || value==b);
    manager.release_all_regions();
    $display("UT: iterator_released empty %0d",manager.for_each(1)==null);
    $finish;
  end
endmodule
