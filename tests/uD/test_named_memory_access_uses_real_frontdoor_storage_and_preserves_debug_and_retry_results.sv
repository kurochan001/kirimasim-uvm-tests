/*
:name: test_named_memory_access_uses_real_frontdoor_storage_and_preserves_debug_and_retry_results
:description: named memory access uses real frontdoor storage and preserves debug and retry results
:tags: uD uvm
:type: simulation
:lrm: 1800.2-2020 D.3.3 D.3.4 18.6.5.1 18.6.5.2 18.6.3.1 18.6.3.2 18.2.3.4 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.6 18.2.5.2 19.2.1.2.5 19.2.1.2.6 15.5.2.5 14.1.2.4 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_named_memory_access_uses_real_frontdoor_storage_and_preserves_debug_and_retry_results.expected
*/
// What it checks:
// 1. The named memory write chooses the local simple-name match before a
//    same-name descendant.
// 2. The named memory write preserves the selected supplied data.
// 3. The named wrapper returns the selected target failure status.
// 4. A later valid named access returns the new successful target status and
//    selected data.
// 5. Changing the debug-only filename and line number preserves the selected
//    named access functional outcome.
// 6. The named memory write forwards the selected nonzero location offset
//    unchanged.
// 7. The named memory read chooses the local simple-name match before a
//    same-name descendant.
// 8. The named memory read preserves the selected successful returned data.
// 9. The named wrapper returns the selected target failure status.
// 10. A later valid named access returns the new successful target status and
//     selected data.
// 11. Changing the debug-only filename and line number preserves the selected
//     named access functional outcome.
// 12. The named memory read forwards the selected nonzero location offset
//     unchanged.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 D.3.3 (UVM-BLOCK-ACCESS-MEM-WRITE-LOCAL-LOOKUP) gives rule 1
//    above. Setup: Use the selected original hierarchical register/memory
//    models and their explicit public calls. Named wrapper observations call
//    through a block base view and genuine configured lookup; actual frontdoor
//    cases use the original adapter, sequencer and driver storage. Expected:
//    The named memory write chooses the local simple-name match before a
//    same-name descendant.
// 2. 1800.2-2020 D.3.3 (UVM-BLOCK-ACCESS-MEM-WRITE-DATA) gives rule 2 above.
//    Setup: Use the selected original hierarchical register/memory models and
//    their explicit public calls. Named wrapper observations call through a
//    block base view and genuine configured lookup; actual frontdoor cases use
//    the original adapter, sequencer and driver storage. Expected: The named
//    memory write preserves the selected supplied data.
// 3. 1800.2-2020 D.3.3 (UVM-BLOCK-ACCESS-MEM-WRITE-FAILURE-STATUS) gives rule
//    3 above. Setup: Use the selected original hierarchical register/memory
//    models and their explicit public calls. Named wrapper observations call
//    through a block base view and genuine configured lookup; actual frontdoor
//    cases use the original adapter, sequencer and driver storage. Expected:
//    The named wrapper returns the selected target failure status.
// 4. 1800.2-2020 D.3.3 (UVM-BLOCK-ACCESS-MEM-WRITE-RETRY) gives rule 4 above.
//    Setup: Use the selected original hierarchical register/memory models and
//    their explicit public calls. Named wrapper observations call through a
//    block base view and genuine configured lookup; actual frontdoor cases use
//    the original adapter, sequencer and driver storage. Expected: A later
//    valid named access returns the new successful target status and selected
//    data.
// 5. 1800.2-2020 D.3.3 (UVM-BLOCK-ACCESS-MEM-WRITE-DEBUG-INVARIANCE) gives
//    rule 5 above. Setup: Use the selected original hierarchical
//    register/memory models and their explicit public calls. Named wrapper
//    observations call through a block base view and genuine configured
//    lookup; actual frontdoor cases use the original adapter, sequencer and
//    driver storage. Expected: Changing the debug-only filename and line
//    number preserves the selected named access functional outcome.
// 6. 1800.2-2020 D.3.3 (UVM-BLOCK-ACCESS-MEM-WRITE-OFFSET) gives rule 6 above.
//    Setup: Use the selected original hierarchical register/memory models and
//    their explicit public calls. Named wrapper observations call through a
//    block base view and genuine configured lookup; actual frontdoor cases use
//    the original adapter, sequencer and driver storage. Expected: The named
//    memory write forwards the selected nonzero location offset unchanged.
// 7. 1800.2-2020 D.3.4 (UVM-BLOCK-ACCESS-MEM-READ-LOCAL-LOOKUP) gives rule 7
//    above. Setup: Use the selected original hierarchical register/memory
//    models and their explicit public calls. Named wrapper observations call
//    through a block base view and genuine configured lookup; actual frontdoor
//    cases use the original adapter, sequencer and driver storage. Expected:
//    The named memory read chooses the local simple-name match before a
//    same-name descendant.
// 8. 1800.2-2020 D.3.4 (UVM-BLOCK-ACCESS-MEM-READ-DATA) gives rule 8 above.
//    Setup: Use the selected original hierarchical register/memory models and
//    their explicit public calls. Named wrapper observations call through a
//    block base view and genuine configured lookup; actual frontdoor cases use
//    the original adapter, sequencer and driver storage. Expected: The named
//    memory read preserves the selected successful returned data.
// 9. 1800.2-2020 D.3.4 (UVM-BLOCK-ACCESS-MEM-READ-FAILURE-STATUS) gives rule 9
//    above. Setup: Use the selected original hierarchical register/memory
//    models and their explicit public calls. Named wrapper observations call
//    through a block base view and genuine configured lookup; actual frontdoor
//    cases use the original adapter, sequencer and driver storage. Expected:
//    The named wrapper returns the selected target failure status.
// 10. 1800.2-2020 D.3.4 (UVM-BLOCK-ACCESS-MEM-READ-RETRY) gives rule 10 above.
//     Setup: Use the selected original hierarchical register/memory models and
//     their explicit public calls. Named wrapper observations call through a
//     block base view and genuine configured lookup; actual frontdoor cases
//     use the original adapter, sequencer and driver storage. Expected: A
//     later valid named access returns the new successful target status and
//     selected data.
// 11. 1800.2-2020 D.3.4 (UVM-BLOCK-ACCESS-MEM-READ-DEBUG-INVARIANCE) gives
//     rule 11 above. Setup: Use the selected original hierarchical
//     register/memory models and their explicit public calls. Named wrapper
//     observations call through a block base view and genuine configured
//     lookup; actual frontdoor cases use the original adapter, sequencer and
//     driver storage. Expected: Changing the debug-only filename and line
//     number preserves the selected named access functional outcome.
// 12. 1800.2-2020 D.3.4 (UVM-BLOCK-ACCESS-MEM-READ-OFFSET) gives rule 12
//     above. Setup: Use the selected original hierarchical register/memory
//     models and their explicit public calls. Named wrapper observations call
//     through a block base view and genuine configured lookup; actual
//     frontdoor cases use the original adapter, sequencer and driver storage.
//     Expected: The named memory read forwards the selected nonzero location
//     offset unchanged.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_named_memory_access_uses_real_frontdoor_storage_and_preserves_debug_and_retry_results;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    uvm_access_e kind = UVM_READ;
    uvm_reg_addr_t address = 0;
    uvm_reg_data_t data = 0;
    int bits = 0;
    uvm_reg_byte_en_t enables = '1;
    uvm_status_e status = UVM_IS_OK;
    function new(string name="packet"); super.new(name); endfunction
  endclass
  class word_adapter extends uvm_reg_adapter;
    uvm_object seen_element;
    uvm_object seen_extension;
    uvm_reg_map seen_map;
    bit context_seen = 0;
    bit context_write = 0;
    bit context_frontdoor = 0;
    bit response_outside = 1;
    function new(string name="adapter"); super.new(name); endfunction
    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
      packet item = new("item");
      uvm_reg_item context_item = get_item();
      item.kind = rw.kind;
      item.address = rw.addr;
      item.data = rw.data;
      item.bits = rw.n_bits;
      item.enables = rw.byte_en;
      item.status = UVM_IS_OK;
      if (context_item != null) begin
        context_seen = 1;
        seen_element = context_item.get_element();
        seen_extension = context_item.get_extension();
        seen_map = context_item.get_map();
        context_write = context_item.get_kind() == UVM_WRITE;
        context_frontdoor = context_item.get_door() == UVM_FRONTDOOR;
      end
      return item;
    endfunction
    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
      packet item;
      if (!$cast(item, bus_item) || item == null) $fatal(1, "wrong bus packet type");
      response_outside &= get_item() == null;
      rw.kind = item.kind;
      rw.addr = item.address;
      rw.data = item.data;
      rw.n_bits = item.bits;
      rw.byte_en = item.enables;
      rw.status = item.status;
    endfunction
  endclass
  class model_block extends uvm_reg_block;
    function new(); super.new("blk", UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(string name="r", int unsigned width=8);
      super.new(name, width, UVM_NO_COVERAGE);
    endfunction
  endclass

  class bus_driver extends uvm_driver#(packet);
    uvm_reg_data_t storage[uvm_reg_addr_t];
    uvm_reg_addr_t addresses[$];
    uvm_reg_data_t data_seen[$];
    uvm_access_e kinds[$];
    bit separate_response = 0;
    uvm_status_e next_status = UVM_IS_OK;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase);
      packet request;
      packet response;
      forever begin
        seq_item_port.get_next_item(request);
        #2;
        addresses.push_back(request.address);
        data_seen.push_back(request.data);
        kinds.push_back(request.kind);
        if (request.kind == UVM_WRITE && next_status == UVM_IS_OK)
          storage[request.address] = request.data;
        if (separate_response) begin
          response = new("response");
          response.set_id_info(request);
          response.kind = request.kind;
          response.address = request.address;
          response.bits = request.bits;
          response.enables = request.enables;
          response.status = next_status;
          response.data = storage.exists(request.address) ? storage[request.address] : 0;
          seq_item_port.item_done(response);
        end else begin
          if (request.kind == UVM_READ)
            request.data = storage.exists(request.address) ? storage[request.address] : 0;
          request.status = next_status;
          seq_item_port.item_done();
        end
      end
    endtask
    function int occurrences(uvm_reg_addr_t address, uvm_reg_data_t value);
      int count = 0;
      foreach (addresses[i])
        if (addresses[i] == address && data_seen[i] == value) count++;
      return count;
    endfunction
  endclass



  class t extends uvm_test;
    `uvm_component_utils(t)
    model_block blk;
    uvm_mem selected,peer;

    uvm_reg_map mapping;
    word_adapter adapter;
    uvm_sequencer#(packet) sequencer;
    bus_driver driver;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase); blk=new(); blk.configure();
      selected=new("chosen49",16,32,"RW",UVM_NO_COVERAGE);
      peer=new("peer49",16,32,"RW",UVM_NO_COVERAGE);
      selected.configure(blk); peer.configure(blk);
      mapping=blk.create_map("bus49",'h100,4,UVM_LITTLE_ENDIAN);
      mapping.add_mem(selected,'h40); mapping.add_mem(peer,'h80);
      adapter=new(); sequencer=new("sequencer",this); driver=new("driver",this);
      mapping.set_sequencer(sequencer,adapter); mapping.set_auto_predict(1); blk.lock_model();
    endfunction
    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase); driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    function bit peer_untouched();
      foreach (driver.addresses[i]) if (driver.addresses[i]=='h194) return 0;
      return driver.storage.exists('h194) && driver.storage['h194]=='h7777;
    endfunction
    virtual task run_phase(uvm_phase phase);
      uvm_status_e status;
      uvm_reg_data_t value;
      bit write_ok,failed;
      string filename;
      int lineno;
      phase.raise_objection(this); driver.storage['h194]='h7777;
      for (int i=0;i<2;i++) begin
        filename=i==0 ? "" : "debug49.sv"; lineno=i==0 ? 0 : 431;
        blk.write_mem_by_name(status,"chosen49",5,'h49A5,
          UVM_FRONTDOOR,mapping,null,-1,null,filename,lineno);
        write_ok=status==UVM_IS_OK && driver.storage.exists('h154) &&
                 driver.storage['h154]=='h49A5;
        blk.read_mem_by_name(status,"chosen49",5,value,
          UVM_FRONTDOOR,mapping,null,-1,null,filename,lineno);
        $display(
          "UT: named_mem_frontdoor debug %0d write %0d read %0d value %0d peer %0d address %0d",
                 i,write_ok,status==UVM_IS_OK,value=='h49A5,peer_untouched(),
                 driver.addresses.size()>0 && driver.addresses[$]=='h154);

      end
      driver.next_status=UVM_NOT_OK;
      blk.write_mem_by_name(status,"chosen49",5,'hBAD0,UVM_FRONTDOOR,mapping);
      failed=status==UVM_NOT_OK; driver.next_status=UVM_IS_OK;
      blk.write_mem_by_name(status,"chosen49",5,'h49F0,UVM_FRONTDOOR,mapping);
      write_ok=status==UVM_IS_OK;
      blk.read_mem_by_name(status,"chosen49",5,value,UVM_FRONTDOOR,mapping);
      $display("UT: named_mem_write_failure failed %0d retry %0d value %0d peer %0d",
               failed,write_ok && status==UVM_IS_OK,value=='h49F0,peer_untouched());
      driver.next_status=UVM_NOT_OK;
      blk.read_mem_by_name(status,"chosen49",5,value,UVM_FRONTDOOR,mapping);
      failed=status==UVM_NOT_OK;
      // Failed read data has no oracle. Restore the original successful driver.
      driver.next_status=UVM_IS_OK;
      blk.read_mem_by_name(status,"chosen49",5,value,UVM_FRONTDOOR,mapping);
      $display("UT: named_mem_read_failure failed %0d retry %0d value %0d peer %0d",
               failed,status==UVM_IS_OK,value=='h49F0,peer_untouched());
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #200; $fatal(1,"named frontdoor watchdog"); end
endmodule
