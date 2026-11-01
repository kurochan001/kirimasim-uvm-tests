/*
:name: test_vreg_post_write_orders_registered_callbacks_before_their_methods
:description: vreg post write orders registered callbacks before their methods (IEEE 1800.2-2020 Section 18.9.2.2.2)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.2.2.2 18.9.1.4.2 18.10.6.2.2 18.10.5.2 18.9.1.3.1 18.9.1.1.1 18.9.1.1.2 18.10.2.1 18.10.2.2 D.4.5.9 D.4.5.11 10.7.2.3.1 18.6.3.1 18.6.3.2 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.4 18.2.3.6 19.2.1.2.5 19.2.1.2.6 15.5.2.5 14.1.2.4 1800-2023 6.21 8.19
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_post_write_orders_registered_callbacks_before_their_methods.expected
*/
// Virtual-register post-write work precedes virtual-field post-write work. On
// each object registered callbacks precede the inherited method.

module test_vreg_post_write_orders_registered_callbacks_before_their_methods;
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



  string trace = "";
  class model_vreg extends uvm_vreg;
    function new(); super.new("vr", 16); endfunction
    virtual task post_write(longint unsigned idx, uvm_reg_data_t wdat, uvm_door_e path,
        uvm_reg_map map, ref uvm_status_e status); trace = {trace, "R"}; endtask
  endclass
  class model_vfield extends uvm_vreg_field;
    `uvm_object_utils(model_vfield)
    function new(string name="field"); super.new(name); endfunction
    virtual task post_write(longint unsigned idx, uvm_reg_data_t wdat, uvm_door_e path,
        uvm_reg_map map, ref uvm_status_e status); trace = {trace, "F"}; endtask
  endclass
  class register_watch extends uvm_vreg_cbs;
    int calls = 0;
    function new(); super.new("register_watch"); endfunction
    virtual task post_write(uvm_vreg rg, longint unsigned idx, uvm_reg_data_t wdat,
        uvm_door_e path, uvm_reg_map map, ref uvm_status_e status); trace = {trace, "r"}; endtask
  endclass
  class field_watch extends uvm_vreg_field_cbs;
    int calls = 0;
    function new(); super.new("field_watch"); endfunction
    virtual task post_write(uvm_vreg_field field, longint unsigned idx,
        uvm_reg_data_t wdat, uvm_door_e path, uvm_reg_map map,
            ref uvm_status_e status); trace = {trace, "f"}; endtask
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    model_block blk;
    uvm_mem mem;
    model_vreg vr;
    model_vfield field;
    register_watch reg_cb;
    field_watch field_cb;
    uvm_reg_map mapping;
    word_adapter adapter;
    uvm_sequencer#(packet) sequencer;
    bus_driver driver;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      blk = new();
      blk.configure();
      mem = new("mem", 64, 8, "RW", UVM_NO_COVERAGE);
      mem.configure(blk);
      vr = new();
      vr.configure(blk, mem, 3, 2, 2);
      field = model_vfield::type_id::create("field");
      field.configure(vr, 4, 4);
      reg_cb = new();
      field_cb = new();
      uvm_vreg_cb::add(vr, reg_cb);
      uvm_vreg_field_cb::add(field, field_cb);
      mapping = blk.create_map("bus", 0, 1, UVM_LITTLE_ENDIAN);
      mapping.add_mem(mem, 'h20);
      sequencer = new("sequencer", this);
      adapter = new();
      driver = new("driver", this);
      mapping.set_sequencer(sequencer, adapter);
      blk.lock_model();
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    task run_phase(uvm_phase phase);
      uvm_status_e status;
      uvm_reg_data_t value;
      phase.raise_objection(this);
      vr.write(1, status, 'h3344, UVM_FRONTDOOR, mapping);
      $display("UT: ok %0d order %s", status == UVM_IS_OK, trace);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "virtual callback watchdog expired"); end
endmodule
