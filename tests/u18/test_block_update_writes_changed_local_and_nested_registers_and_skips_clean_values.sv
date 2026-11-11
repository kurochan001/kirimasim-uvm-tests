/*
:name: test_block_update_writes_changed_local_and_nested_registers_and_skips_clean_values
:description: block update writes changed local and nested registers and skips clean values
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.5.5 18.1.5.4 18.4.4.13 18.4.4.9 18.2.3.6 18.2.5.2 19.2.1.2.5 19.2.1.2.6 15.5.2.5 14.1.2.4 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.3 18.2.3.10 18.4.2.1 18.4.2.2 18.4.4.1 18.4.4.2 18.4.4.3 18.4.4.4 18.4.4.5 18.5.3.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_update_writes_changed_local_and_nested_registers_and_skips_clean_values.expected
*/
// What it checks:
// 1. Block update writes selected desired values in both the block and its
//    child block.
// 2. The selected two changed full-width RW registers require one write each
//    while the clean peer receives none.
// 3. Calling update on the selected already-clean hierarchy issues no
//    additional writes.
// 4. Changing debug-only source information on a clean block does not cause
//    writes or change stored values.
// 5. The selected block update reports the original single-register bus
//    failure.
// 6. A new desired value can be successfully updated after the original driver
//    recovers.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.1.5.5 (UVM-BLOCK-ACCESS-UPDATE-SUBTREE) gives rule 1
//    above. Setup: Use the selected original hierarchical register/memory
//    models and their explicit public calls. Named wrapper observations call
//    through a block base view and genuine configured lookup; actual frontdoor
//    cases use the original adapter, sequencer and driver storage. Expected:
//    Block update writes selected desired values in both the block and its
//    child block.
// 2. 1800.2-2020 18.1.5.5 (UVM-BLOCK-ACCESS-UPDATE-MINIMUM-WRITES) gives rule
//    2 above. Setup: Use the selected original hierarchical register/memory
//    models and their explicit public calls. Named wrapper observations call
//    through a block base view and genuine configured lookup; actual frontdoor
//    cases use the original adapter, sequencer and driver storage. Expected:
//    The selected two changed full-width RW registers require one write each
//    while the clean peer receives none.
// 3. 1800.2-2020 18.1.5.5 (UVM-BLOCK-ACCESS-UPDATE-CLEAN-NO-WRITES) gives rule
//    3 above. Setup: Use the selected original hierarchical register/memory
//    models and their explicit public calls. Named wrapper observations call
//    through a block base view and genuine configured lookup; actual frontdoor
//    cases use the original adapter, sequencer and driver storage. Expected:
//    Calling update on the selected already-clean hierarchy issues no
//    additional writes.
// 4. 1800.2-2020 18.1.5.5 (UVM-BLOCK-ACCESS-UPDATE-DEBUG-INVARIANCE) gives
//    rule 4 above. Setup: Use the selected original hierarchical
//    register/memory models and their explicit public calls. Named wrapper
//    observations call through a block base view and genuine configured
//    lookup; actual frontdoor cases use the original adapter, sequencer and
//    driver storage. Expected: Changing debug-only source information on a
//    clean block does not cause writes or change stored values.
// 5. 1800.2-2020 18.1.5.5 (UVM-BLOCK-ACCESS-UPDATE-FAILURE-STATUS) gives rule
//    5 above. Setup: Use the selected original hierarchical register/memory
//    models and their explicit public calls. Named wrapper observations call
//    through a block base view and genuine configured lookup; actual frontdoor
//    cases use the original adapter, sequencer and driver storage. Expected:
//    The selected block update reports the original single-register bus
//    failure.
// 6. 1800.2-2020 18.1.5.5 (UVM-BLOCK-ACCESS-UPDATE-NEW-SUCCESS) gives rule 6
//    above. Setup: Use the selected original hierarchical register/memory
//    models and their explicit public calls. Named wrapper observations call
//    through a block base view and genuine configured lookup; actual frontdoor
//    cases use the original adapter, sequencer and driver storage. Expected: A
//    new desired value can be successfully updated after the original driver
//    recovers.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_block_update_writes_changed_local_and_nested_registers_and_skips_clean_values;
  import uvm_pkg::*;
  class aggregate_block extends uvm_reg_block;
    function new(string name); super.new(name,UVM_NO_COVERAGE); endfunction
  endclass
  class aggregate_reg extends uvm_reg;
    function new(string name); super.new(name,32,UVM_NO_COVERAGE); endfunction
  endclass
  function automatic void configure_reg(aggregate_reg value,aggregate_block owner);
    uvm_reg_field field_value;
    value.configure(owner); field_value=new("bits49");
    field_value.configure(value,32,0,"RW",0,0,1,0,0); field_value.set_compare(UVM_CHECK);
  endfunction
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



  class error_probe extends uvm_report_catcher;
    int errors=0;
    virtual function action_e catch();
      if (get_severity() inside {UVM_ERROR,UVM_FATAL}) begin errors++; return CAUGHT; end
      return THROW;
    endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    aggregate_block root,child;
    aggregate_reg selected,peer,deep;
    uvm_reg_map root_map,child_map;
    word_adapter adapter;
    uvm_sequencer#(packet) sequencer;
    bus_driver driver;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase); root=new("root49"); child=new("child49");
      root.configure(); child.configure(root);
      selected=new("selected49"); peer=new("peer49"); deep=new("deep49");
      configure_reg(selected,root); configure_reg(peer,root); configure_reg(deep,child);
      root_map=root.create_map("root_map49",'h100,4,UVM_LITTLE_ENDIAN);
      child_map=child.create_map("child_map49",0,4,UVM_LITTLE_ENDIAN);
      root_map.add_reg(selected,'h20); root_map.add_reg(peer,'h24); child_map.add_reg(deep,0);
      root_map.add_submap(child_map,'h80);
      adapter=new(); sequencer=new("sequencer",this); driver=new("driver",this);
      root_map.set_sequencer(sequencer,adapter);
      root_map.set_auto_predict(1); child_map.set_auto_predict(1);
      root.lock_model(); root.reset();
    endfunction
    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase); driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    function int transfers(uvm_access_e kind,uvm_reg_addr_t address);
      int count=0;
      foreach (driver.addresses[i])
        if (driver.addresses[i]==address && driver.kinds[i]==kind) count++;
      return count;
    endfunction
    function int writes();
      int count=0;
      foreach (driver.kinds[i]) if (driver.kinds[i]==UVM_WRITE) count++;
      return count;
    endfunction
    virtual task run_phase(uvm_phase phase);
      uvm_status_e status;
      int before_writes;
      phase.raise_objection(this);
      driver.storage['h120]=0; driver.storage['h124]='h7777; driver.storage['h180]=0;
      selected.set('h49A0); deep.set('h49C0);
      root.update(status,UVM_FRONTDOOR);
      $display("UT: block_update success %0d local %0d deep %0d peer %0d minimal %0d mirrors %0d",
               status==UVM_IS_OK,driver.storage['h120]=='h49A0,driver.storage['h180]=='h49C0,
               driver.storage['h124]=='h7777 && transfers(UVM_WRITE,'h124)==0,
               transfers(UVM_WRITE,'h120)==1 && transfers(UVM_WRITE,'h180)==1,
               selected.get_mirrored_value()=='h49A0 && deep.get_mirrored_value()=='h49C0);
      before_writes=writes();
      root.update(status,UVM_FRONTDOOR,null,-1,null,"debug49.sv",431);
      $display("UT: block_update clean_no_writes %0d values %0d",
               writes()==before_writes,driver.storage['h120]=='h49A0 &&
               driver.storage['h180]=='h49C0 && driver.storage['h124]=='h7777);
      driver.next_status=UVM_NOT_OK; selected.set('h49E0);
      root.update(status,UVM_FRONTDOOR);
      $display("UT: block_update failed_status %0d",status==UVM_NOT_OK);
      driver.next_status=UVM_IS_OK; selected.set('h49F0);
      root.update(status,UVM_FRONTDOOR);
      $display("UT: block_update retry %0d value %0d peer %0d",status==UVM_IS_OK,
               driver.storage['h120]=='h49F0,driver.storage['h124]=='h7777);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #300; $fatal(1,"block aggregate watchdog"); end
endmodule
