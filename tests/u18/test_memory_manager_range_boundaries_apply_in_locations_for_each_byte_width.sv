/*
:name: test_memory_manager_range_boundaries_apply_in_locations_for_each_byte_width
:description: memory manager range boundaries apply in locations for each byte width
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.9.2.1 18.12.9.2.2 18.12.9.2.3 18.12.5.1 18.12.7.2.1 18.12.7.2.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_manager_range_boundaries_apply_in_locations_for_each_byte_width.expected
*/
module test_memory_manager_range_boundaries_apply_in_locations_for_each_byte_width;
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
    automatic int widths[4]='{1,2,4,8};
    automatic error_probe probe=new();
    uvm_report_cb::add(null,probe);
    foreach (widths[i]) begin
      automatic uvm_mem_mam_cfg cfg=make_cfg(widths[i]);
      automatic uvm_mem_mam manager=new("manager",cfg);
      uvm_mem_region first,last,below,above,overrun;
      below=manager.reserve_region(4,1); above=manager.reserve_region(32,1);
      overrun=manager.reserve_region(30,3*widths[i]);
      first=manager.reserve_region(5,1); last=manager.reserve_region(31,widths[i]);
      $display("UT: range_units %0d first %0d last %0d below %0d above %0d overrun %0d",i,
               first!=null,last!=null,below==null,above==null,overrun==null);
      if (first==null || last==null) $fatal(1,"valid boundary rejected");
      $display("UT: range_offsets %0d first %0d last %0d count %0d",i,
               first.get_start_offset()==5,last.get_end_offset()==31,count_regions(manager)==2);
    end
    uvm_report_cb::delete(null,probe); $finish;
  end
endmodule
