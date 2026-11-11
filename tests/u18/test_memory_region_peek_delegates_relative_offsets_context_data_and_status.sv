/*
:name: test_memory_region_peek_delegates_relative_offsets_context_data_and_status
:description: memory region peek delegates relative offsets context data and status
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.7.2.13 18.12.4.1 18.12.5.1 18.6.5.6 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_region_peek_delegates_relative_offsets_context_data_and_status.expected
*/
// What it checks:
// 1. Region peek converts the selected first/last relative offset to the
//    implementing memory location.
// 2. Region peek preserves selected parent/extension context during
//    delegation.
// 3. Region peek returns both selected successful and failed memory status
//    values.
// 4. Successful region peek returns the original memory response data.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.12.7.2.13 (UVM-MAM-AUDIT-PEEK-OFFSET) gives rule 1 above.
//    Setup: Use the linked original fixtures and the explicit sizes, location
//    offsets, handles and observations they declare. Allocation inputs are
//    configured explicitly rather than relying on unspecified initial
//    defaults. Expected: Region peek converts the selected first/last relative
//    offset to the implementing memory location.
// 2. 1800.2-2020 18.12.7.2.13 (UVM-MAM-AUDIT-PEEK-CONTEXT) gives rule 2 above.
//    Setup: Use the linked original fixtures and the explicit sizes, location
//    offsets, handles and observations they declare. Allocation inputs are
//    configured explicitly rather than relying on unspecified initial
//    defaults. Expected: Region peek preserves selected parent/extension
//    context during delegation.
// 3. 1800.2-2020 18.12.7.2.13 (UVM-MAM-AUDIT-PEEK-STATUS) gives rule 3 above.
//    Setup: Use the linked original fixtures and the explicit sizes, location
//    offsets, handles and observations they declare. Allocation inputs are
//    configured explicitly rather than relying on unspecified initial
//    defaults. Expected: Region peek returns both selected successful and
//    failed memory status values.
// 4. 1800.2-2020 18.12.7.2.13 (UVM-MAM-AUDIT-PEEK-DATA) gives rule 4 above.
//    Setup: Use the linked original fixtures and the explicit sizes, location
//    offsets, handles and observations they declare. Allocation inputs are
//    configured explicitly rather than relying on unspecified initial
//    defaults. Expected: Successful region peek returns the original memory
//    response data.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_memory_region_peek_delegates_relative_offsets_context_data_and_status;
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
    function new(); super.new("memory",64,32); endfunction
    virtual task peek(output uvm_status_e status,input uvm_reg_addr_t offset,
                    output uvm_reg_data_t value,
                    input string kind="",input uvm_sequence_base parent=null,
                    input uvm_object extension=null,
                    input string fname="",input int lineno=0);
      calls++; seen_offset=offset; seen_parent=parent; seen_extension=extension;

      value='hA611;
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
    automatic uvm_mem_mam_cfg cfg=make_cfg();
    automatic memory_probe memory=new();
    automatic uvm_mem_mam manager=new("manager",cfg,memory);
    automatic parent_sequence parent=new();
    automatic extension_token extension=new();
    automatic uvm_reg_map map=new("map");
    uvm_mem_region region;
    uvm_status_e status;
    uvm_reg_data_t value;
    region=manager.reserve_region(12,16);
    if (region==null) $fatal(1,"missing original region");
    for (int i=0;i<2;i++) begin
      memory.response=i==0 ? UVM_IS_OK : UVM_NOT_OK;
      region.peek(.status(status),.offset(i==0 ? 0 : 3),.value(value),
                  .parent(parent),.extension(extension),.fname("debug44.sv"),.lineno(91));
      $display("UT: region_peek %0d calls %0d offset %0d parent %0d extension %0d status %0d",
               i,memory.calls,memory.seen_offset==12+(i==0 ? 0 : 3),
               memory.seen_parent==parent,memory.seen_extension==extension,
               status==(i==0 ? UVM_IS_OK : UVM_NOT_OK));
      if (i==0) $display("UT: region_read_value exact %0d",value=='hA611);

    end
    $finish;
  end
endmodule
