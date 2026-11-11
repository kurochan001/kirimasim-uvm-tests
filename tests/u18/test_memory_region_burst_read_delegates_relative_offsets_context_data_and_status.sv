/*
:name: test_memory_region_burst_read_delegates_relative_offsets_context_data_and_status
:description: memory region burst read delegates relative offsets context data and status
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.7.2.11 18.12.4.1 18.12.5.1 18.6.5.4 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_region_burst_read_delegates_relative_offsets_context_data_and_status.expected
*/
// What it checks:
// 1. Region burst_read converts the selected first/last relative offset to the
//    implementing memory location.
// 2. Region burst_read preserves selected parent/extension/path/map/priority
//    context during delegation.
// 3. Region burst_read returns both selected successful and failed memory
//    status values.
// 4. Successful region burst_read returns the original memory response data.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.12.7.2.11 (UVM-MAM-AUDIT-BURST-READ-OFFSET) gives rule 1
//    above. Setup: Use the linked original fixtures and the explicit sizes,
//    location offsets, handles and observations they declare. Allocation
//    inputs are configured explicitly rather than relying on unspecified
//    initial defaults. Expected: Region burst_read converts the selected
//    first/last relative offset to the implementing memory location.
// 2. 1800.2-2020 18.12.7.2.11 (UVM-MAM-AUDIT-BURST-READ-CONTEXT) gives rule 2
//    above. Setup: Use the linked original fixtures and the explicit sizes,
//    location offsets, handles and observations they declare. Allocation
//    inputs are configured explicitly rather than relying on unspecified
//    initial defaults. Expected: Region burst_read preserves selected
//    parent/extension/path/map/priority context during delegation.
// 3. 1800.2-2020 18.12.7.2.11 (UVM-MAM-AUDIT-BURST-READ-STATUS) gives rule 3
//    above. Setup: Use the linked original fixtures and the explicit sizes,
//    location offsets, handles and observations they declare. Allocation
//    inputs are configured explicitly rather than relying on unspecified
//    initial defaults. Expected: Region burst_read returns both selected
//    successful and failed memory status values.
// 4. 1800.2-2020 18.12.7.2.11 (UVM-MAM-AUDIT-BURST-READ-DATA) gives rule 4
//    above. Setup: Use the linked original fixtures and the explicit sizes,
//    location offsets, handles and observations they declare. Allocation
//    inputs are configured explicitly rather than relying on unspecified
//    initial defaults. Expected: Successful region burst_read returns the
//    original memory response data.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_memory_region_burst_read_delegates_relative_offsets_context_data_and_status;
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
  class memory_probe extends uvm_mem;
    int calls=0;
    uvm_reg_addr_t seen_offset;
    uvm_sequence_base seen_parent;
    uvm_object seen_extension;
    uvm_door_e seen_path;
    uvm_reg_map seen_map;
    int seen_prior;
    bit payload_ok;
    uvm_status_e response=UVM_IS_OK;
    function new(); super.new("memory",64,$bits(uvm_reg_data_t)); endfunction
    virtual task burst_read(output uvm_status_e status,input uvm_reg_addr_t offset,
                    ref uvm_reg_data_t value[],
                    input uvm_door_e path=UVM_DEFAULT_DOOR,input uvm_reg_map map=null,
                    input uvm_sequence_base parent=null,
                    input int prior=-1,
                    input uvm_object extension=null,
                    input string fname="",input int lineno=0);
      calls++; seen_offset=offset; seen_parent=parent; seen_extension=extension;
      seen_path=path; seen_map=map; seen_prior=prior;
      value=new[2]; value[0]='hA611; value[1]='hB722;
      status=response;
    endtask
  endclass
  class extension_token extends uvm_object;
    function new(); super.new("extension"); endfunction
  endclass
  class parent_sequence extends uvm_sequence#(uvm_sequence_item);
    function new(string name="parent"); super.new(name); endfunction
    virtual task body(); endtask
  endclass
  initial begin
    automatic uvm_mem_mam_cfg cfg=make_cfg(($bits(uvm_reg_data_t)+7)/8);
    automatic memory_probe memory=new();
    automatic uvm_mem_mam manager=new("manager",cfg,memory);
    automatic parent_sequence parent=new();
    automatic extension_token extension=new();
    automatic uvm_reg_map map=new("map");
    uvm_mem_region region;
    uvm_status_e status;
    uvm_reg_data_t value[];

    region=manager.reserve_region(12,4*cfg.n_bytes);
    if (region==null) $fatal(1,"missing original region");
    for (int i=0;i<2;i++) begin
      memory.response=i==0 ? UVM_IS_OK : UVM_NOT_OK;
      if (i==0) value=new[2];
      region.burst_read(status,(i==0 ? 0 : 2),value,UVM_FRONTDOOR,map,parent,7,extension,
                   "debug44.sv",91);
      $display("UT: region_burst_read %0d calls %0d offset %0d parent %0d extension %0d status %0d",
               i,memory.calls,memory.seen_offset==12+(i==0 ? 0 : 2),
               memory.seen_parent==parent,memory.seen_extension==extension,
               status==(i==0 ? UVM_IS_OK : UVM_NOT_OK));
      if (i==0) $display("UT: region_read_value size %0d first %0d second %0d",value.size(),
               value[0]=='hA611,value[1]=='hB722);
      $display("UT: region_path exact %0d map %0d priority %0d",
               memory.seen_path==UVM_FRONTDOOR,memory.seen_map==map,memory.seen_prior==7);
    end
    $finish;
  end
endmodule
