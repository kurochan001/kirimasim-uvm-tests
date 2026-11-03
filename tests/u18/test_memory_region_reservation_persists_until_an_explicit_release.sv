/*
:name: test_memory_region_reservation_persists_until_an_explicit_release
:description: memory region reservation persists until an explicit release
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12 18.12.5.1 18.12.5.3 18.12.6.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_region_reservation_persists_until_an_explicit_release.expected
*/
module test_memory_region_reservation_persists_until_an_explicit_release;
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
    automatic uvm_mem_mam_cfg cfg=make_cfg(1,5,8);
    automatic uvm_mem_mam manager=new("manager",cfg);
    automatic error_probe probe=new();
    uvm_mem_region original,blocked,again;
    original=manager.reserve_region(5,4);
    if (original==null) $fatal(1,"initial reservation missing");
    uvm_report_cb::add(null,probe);
    for (int i=0;i<3;i++) begin
      blocked=manager.reserve_region(5,4);
      $display("UT: retained_region %0d blocked %0d original %0d",i,
               blocked==null,count_regions(manager)==1);
    end
    manager.release_region(original); again=manager.reserve_region(5,4);
    $display("UT: explicit_release_available %0d",again!=null);
    uvm_report_cb::delete(null,probe); $finish;
  end
endmodule
