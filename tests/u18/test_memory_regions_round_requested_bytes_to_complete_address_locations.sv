/*
:name: test_memory_regions_round_requested_bytes_to_complete_address_locations
:description: memory regions round requested bytes to complete address locations
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.7.2.1 18.12.7.2.2 18.12.7.2.3 18.12.7.2.4 18.12.9.2.1 18.12.5.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_regions_round_requested_bytes_to_complete_address_locations.expected
*/
module test_memory_regions_round_requested_bytes_to_complete_address_locations;
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
    automatic int requests[4]='{1,4,5,13};
    automatic int locations[4]='{1,1,2,4};
    foreach (requests[i]) begin
      automatic uvm_mem_mam_cfg cfg=make_cfg();
      automatic uvm_mem_mam manager=new("manager",cfg);
      uvm_mem_region region;
      region=manager.reserve_region(12,requests[i]);
      if (region==null) $fatal(1,"missing region");
      $display("UT: region_units %0d start %0d end %0d locations %0d bytes %0d",i,
               region.get_start_offset()==12,region.get_end_offset()==11+locations[i],
               region.get_len()==locations[i],region.get_n_bytes()==4*locations[i]);
    end
    $finish;
  end
endmodule
