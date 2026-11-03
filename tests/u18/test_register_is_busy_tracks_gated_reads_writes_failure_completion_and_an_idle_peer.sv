/*
:name: test_register_is_busy_tracks_gated_reads_writes_failure_completion_and_an_idle_peer
:description: register is busy tracks gated reads writes failure completion and an idle peer
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.4.16 18.4.4.9 18.4.4.10 18.1.2.6 18.2.3.6 18.2.3.3 18.1.2.3 18.4.2.2 18.5.3.2 18.1.2.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_register_is_busy_tracks_gated_reads_writes_failure_completion_and_an_idle_peer.expected
*/
module test_register_is_busy_tracks_gated_reads_writes_failure_completion_and_an_idle_peer;
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
    bit gated=1;
    int entered=0;
    bit separate_response = 0;
    uvm_status_e next_status = UVM_IS_OK;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase);
      packet request;
      packet response;
      forever begin
        seq_item_port.get_next_item(request);
        entered++;wait(!gated);#2;
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
    model_block owner;
    model_reg chosen,peer;
    uvm_reg_field chosen_bits,peer_bits;
    uvm_reg_map mapping;
    word_adapter adapter;
    uvm_sequencer#(packet) seq;
    bus_driver driver;
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);owner=new();owner.configure();
      chosen=new("chosen52",32);peer=new("peer52",32);
      chosen.configure(owner);peer.configure(owner);
      chosen_bits=uvm_reg_field::type_id::create("chosen_bits52");
      peer_bits=uvm_reg_field::type_id::create("peer_bits52");
      chosen_bits.configure(chosen,32,0,"RW",0,0,1,0,0);
      peer_bits.configure(peer,32,0,"RW",0,0,1,0,0);
      mapping=owner.create_map("bus52",'h100,4,UVM_LITTLE_ENDIAN);
      mapping.add_reg(chosen,'h20);mapping.add_reg(peer,'h24);
      adapter=new();seq=new("seq52",this);driver=new("driver52",this);
      mapping.set_sequencer(seq,adapter);mapping.set_auto_predict(1);owner.lock_model();
    endfunction
    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);driver.seq_item_port.connect(seq.seq_item_export);
    endfunction
    virtual task run_phase(uvm_phase phase);
      uvm_status_e status;
      uvm_reg_data_t value;
      phase.raise_objection(this);
      $display("UT: register_busy initial_idle %0d peer_idle %0d",
        !chosen.is_busy(),!peer.is_busy());
      fork
        chosen.write(status,'h52A5,UVM_FRONTDOOR,mapping);
        begin
          wait(driver.entered==1);
          $display("UT: register_busy during_write %0d peer_idle %0d",
            chosen.is_busy(),!peer.is_busy());
          driver.gated=0;
        end
      join
      $display("UT: register_busy write_complete %0d idle %0d",
        status==UVM_IS_OK,!chosen.is_busy());
      driver.gated=1;driver.next_status=UVM_NOT_OK;
      fork
        chosen.read(status,value,UVM_FRONTDOOR,mapping);
        begin
          wait(driver.entered==2);
          $display("UT: register_busy during_read %0d peer_idle %0d",
            chosen.is_busy(),!peer.is_busy());
          driver.gated=0;
        end
      join
      $display("UT: register_busy failed_return %0d idle %0d",status==UVM_NOT_OK,!chosen.is_busy());
      driver.next_status=UVM_IS_OK;chosen.read(status,value,UVM_FRONTDOOR,mapping);
      $display("UT: register_busy retry %0d value %0h idle %0d peer_idle %0d",
        status==UVM_IS_OK,value,!chosen.is_busy(),!peer.is_busy());
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #200;$fatal(1,"register busy watchdog");end
endmodule
