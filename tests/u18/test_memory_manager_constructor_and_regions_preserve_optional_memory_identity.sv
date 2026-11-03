/*
:name: test_memory_manager_constructor_and_regions_preserve_optional_memory_identity
:description: memory manager constructor and regions preserve optional memory identity
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.4.1 18.12.6.3 18.12.7.2.6 18.12.7.2.7 18.12.1 18.12.7.1 18.12.9.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_manager_constructor_and_regions_preserve_optional_memory_identity.expected
*/
module test_memory_manager_constructor_and_regions_preserve_optional_memory_identity;
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
    automatic uvm_mem memory=new("memory",64,32);
    automatic uvm_mem_mam attached=new("attached",cfg,memory);
    automatic uvm_mem_mam detached=new("detached",cfg);
    uvm_mem_region a,b;
    a=attached.reserve_region(9,8); b=detached.reserve_region(9,8);
    if (a==null || b==null) $fatal(1,"missing original regions");
    $display("UT: manager_memory attached %0d detached %0d independent %0d",
             attached.get_memory()==memory,detached.get_memory()==null,a!=b);
    $display("UT: region_memory attached %0d detached %0d virtual_a %0d virtual_b %0d",
             a.get_memory()==memory,b.get_memory()==null,
             a.get_virtual_registers()==null,b.get_virtual_registers()==null);
    $finish;
  end
endmodule
