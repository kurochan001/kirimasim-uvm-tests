/*
:name: test_reg_predictor_interleaved_little_endian_registers_keep_partial_values_independent
:description: interleaved wide-register observations maintain independent incomplete values (IEEE 1800.2-2020 Section 19.3.2.1)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.3.2.1 19.1.2.5 18.5.5.17 19.3.2.2 19.3.2.3 19.3.2.4 19.1.1.2.4 18.4.4.15 18.5.4.6 19.2.1.2.5 19.2.1.2.6 19.1.2 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.3 18.4.2.1 18.4.2.2 18.5.3.2 1800-2023 6.21 8.19
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_predictor_interleaved_little_endian_registers_keep_partial_values_independent.expected
*/
// Observe only mirrors and public analysis publications. The fixture does
// not inspect the predictor's private pending map or use active prediction.

module test_reg_predictor_interleaved_little_endian_registers_keep_partial_values_independent;
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

  class observation_sink extends uvm_subscriber#(uvm_reg_item);
    int calls = 0;
    uvm_reg_data_t value = 0;
    uvm_object element;
    uvm_reg_map mapping;
    uvm_access_e kind;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    virtual function void write(uvm_reg_item t);
      calls++;
      value = t.get_value();
      element = t.get_element();
      mapping = t.get_map();
      kind = t.get_kind();
    endfunction
  endclass


  class t extends uvm_test;
    `uvm_component_utils(t)
    model_block blk;
    model_reg rg;
    model_reg peer;
    uvm_reg_field high_field;
    uvm_reg_field field;
    uvm_reg_map mapping;
    word_adapter adapter;
    uvm_reg_predictor#(packet) predictor;
    observation_sink sink;
    uvm_analysis_port#(packet) monitor;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      blk = new();
      blk.configure();
      rg = new("r", 32);
      rg.configure(blk);
      field = new("value");
      field.configure(rg, 32, 0, "RW", 0, 'h0, 1, 0, 1);
      peer = new("peer", 32);
      peer.configure(blk);
      high_field = new("value");
      high_field.configure(peer, 32, 0, "RW", 0, 0, 1, 0, 1);
      mapping = blk.create_map("bus", 0, 2, UVM_LITTLE_ENDIAN);
      mapping.add_reg(rg, 'h20);
      mapping.add_reg(peer, 'h40);
      adapter = new();
      predictor = new("predictor", this);
      sink = new("sink", this);
      monitor = new("monitor", this);
      mapping.set_auto_predict(0);
      blk.lock_model();
      blk.reset();
      predictor.map = mapping;
      predictor.adapter = adapter;
    endfunction
    function void connect_phase(uvm_phase phase);
      monitor.connect(predictor.bus_in);
      predictor.reg_ap.connect(sink.analysis_export);
    endfunction
    function void observe(uvm_reg_addr_t address, uvm_reg_data_t data, uvm_access_e kind,
                          uvm_reg_byte_en_t enables='1);
      packet item = new("observed");
      item.kind = kind;
      item.address = address;
      item.data = data;
      item.bits = 16;
      item.enables = enables;
      monitor.write(item);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      observe('h20, 'h3344, UVM_WRITE);
      observe('h40, 'h7788, UVM_WRITE);
      $display("UT: partial mirrors %0h %0h calls %0d", rg.get_mirrored_value(),
               peer.get_mirrored_value(), sink.calls);
      observe('h22, 'h1122, UVM_WRITE);
      $display("UT: first_complete mirrors %0h %0h calls %0d target %0d value %0h",
               rg.get_mirrored_value(), peer.get_mirrored_value(), sink.calls,
               sink.element == rg, sink.value);
      observe('h42, 'h5566, UVM_WRITE);
      $display("UT: second_complete mirrors %0h %0h calls %0d target %0d value %0h",
               rg.get_mirrored_value(), peer.get_mirrored_value(), sink.calls,
               sink.element == peer, sink.value);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "predictor watchdog expired"); end
endmodule
