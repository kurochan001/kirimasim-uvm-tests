/*
:name: test_map_sequencer_replacement_redirects_nested_frontdoor_access_and_preserves_old_storage
:description: map sequencer replacement redirects nested frontdoor access and preserves old storage
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.3.6 18.2.4.8 18.2.4.9 18.2.3.5 18.4.4.9 18.4.4.10 18.1.2.6 18.1.2.2 18.1.2.3 18.2.3.3 18.4.2.2 18.5.3.2 19.2.1.2.5 19.2.1.2.6 15.5.2.5 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_map_sequencer_replacement_redirects_nested_frontdoor_access_and_preserves_old_storage.expected
*/
// What it checks:
// 1. set_sequencer associates the selected sequencer and adapter pair with the
//    map.
// 2. Replacing a root map sequencer/adapter redirects the selected later
//    child-map transfers and preserves the old driver storage.
// 3. Adding the selected child map composes its register address with the
//    parent map base and submap offset.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.2.3.6 (UVM-MAP-SCOPE-SET-SEQUENCER-ADAPTER) gives rule 1
//    above. Setup: Use the selected getter-only map settings or the separate
//    original four-byte adapter/sequencer/driver path to a 32-bit RW child-map
//    register. In the real path both root sequencers connect to distinct live
//    original drivers, and replacement follows a completed write/read pair.
//    Adapter context and original stores independently observe selection.
//    Expected: set_sequencer associates the selected sequencer and adapter
//    pair with the map.
// 2. 1800.2-2020 18.2.3.6 (UVM-MAP-SCOPE-SET-REPLACEMENT) gives rule 2 above.
//    Setup: Use the selected getter-only map settings or the separate original
//    four-byte adapter/sequencer/driver path to a 32-bit RW child-map
//    register. In the real path both root sequencers connect to distinct live
//    original drivers, and replacement follows a completed write/read pair.
//    Adapter context and original stores independently observe selection.
//    Expected: Replacing a root map sequencer/adapter redirects the selected
//    later child-map transfers and preserves the old driver storage.
// 3. 1800.2-2020 18.2.3.5 (UVM-MAP-SCOPE-SUBMAP-COMPOSITION) gives rule 3
//    above. Setup: Use the selected getter-only map settings or the separate
//    original four-byte adapter/sequencer/driver path to a 32-bit RW child-map
//    register. In the real path both root sequencers connect to distinct live
//    original drivers, and replacement follows a completed write/read pair.
//    Adapter context and original stores independently observe selection.
//    Expected: Adding the selected child map composes its register address
//    with the parent map base and submap offset.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_map_sequencer_replacement_redirects_nested_frontdoor_access_and_preserves_old_storage;
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
    function new(string name); super.new(name,UVM_NO_COVERAGE); endfunction
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
    model_block root,child;
    model_reg rg;
    uvm_reg_field field_value;
    uvm_reg_map outer,inner;
    word_adapter first_adapter,next_adapter;
    uvm_sequencer#(packet) first_seq,next_seq;
    bus_driver first_driver,next_driver;
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);root=new("root51");child=new("child51");
      root.configure();child.configure(root);
      rg=new("selected51",32);rg.configure(child);field_value=new("bits51");
      field_value.configure(rg,32,0,"RW",0,0,1,0,0);
      outer=root.create_map("outer51",'h100,4,UVM_LITTLE_ENDIAN);
      inner=child.create_map("inner51",0,4,UVM_LITTLE_ENDIAN);
      inner.add_reg(rg,'h20);outer.add_submap(inner,'h40);
      first_adapter=new("first_adapter");next_adapter=new("next_adapter");
      first_seq=new("first_seq",this);next_seq=new("next_seq",this);
      first_driver=new("first_driver",this);next_driver=new("next_driver",this);
      outer.set_sequencer(first_seq,first_adapter);inner.set_auto_predict(1);
      outer.set_auto_predict(1);root.lock_model();
    endfunction
    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      first_driver.seq_item_port.connect(first_seq.seq_item_export);
      next_driver.seq_item_port.connect(next_seq.seq_item_export);
    endfunction
    virtual task run_phase(uvm_phase phase);
      uvm_status_e status;
      uvm_reg_data_t value;
      bit ok;
      int old_count;
      phase.raise_objection(this);
      rg.write(status,'h5111,UVM_FRONTDOOR,inner);ok=status==UVM_IS_OK;
      rg.read(status,value,UVM_FRONTDOOR,inner);
      $display("UT: map_redirect first %0d value %0h address %0d next_unused %0d",
        ok && status==UVM_IS_OK,value,first_driver.addresses[$]=='h160,
        next_driver.addresses.size()==0);
      old_count=first_driver.addresses.size();outer.set_sequencer(next_seq,next_adapter);
      rg.write(status,'h5122,UVM_FRONTDOOR,inner);ok=status==UVM_IS_OK;
      rg.read(status,value,UVM_FRONTDOOR,inner);
      $display("UT: map_redirect next %0d value %0h address %0d old_idle %0d old_value %0h",
        ok && status==UVM_IS_OK,value,next_driver.addresses[$]=='h160,
        first_driver.addresses.size()==old_count,first_driver.storage['h160]);
      $display("UT: map_redirect adapters %0d selected_element %0d selected_map %0d mirror %0d",
        first_adapter.context_seen && next_adapter.context_seen,
        next_adapter.seen_element==rg,next_adapter.seen_map==inner,
        rg.get_mirrored_value()=='h5122);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #200;$fatal(1,"map sequencer replacement watchdog");end
endmodule
