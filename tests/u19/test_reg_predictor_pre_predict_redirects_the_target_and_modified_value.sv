/*
:name: test_reg_predictor_pre_predict_redirects_the_target_and_modified_value
:description: predictor pre predict redirects the target and modified value (IEEE 1800.2-2020 Section 19.3.3.2)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.3.3.2 19.1.1.2.2 19.3.2.1 19.3.2.2 19.3.2.3 19.3.2.4 19.1.1.2.4 18.4.4.15 18.5.4.6 19.2.1.2.5 19.2.1.2.6 19.1.2 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.3 18.4.2.1 18.4.2.2 18.5.3.2 1800-2023 6.21 8.19
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_predictor_pre_predict_redirects_the_target_and_modified_value.expected
*/
// The hook changes the public target handle and value. The original
// register must retain its mirror while the redirected target is predicted.

module test_reg_predictor_pre_predict_redirects_the_target_and_modified_value;
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
  class redirecting_predictor extends uvm_reg_predictor#(packet);
    uvm_reg destination;
    int hook_calls = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    virtual function void pre_predict(uvm_reg_item rw);
      hook_calls++;
      rw.set_element(destination);
      rw.set_value('h77);
    endfunction
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    model_block blk;
    model_reg rg;
    uvm_reg_field field;
    uvm_reg_map mapping;
    word_adapter adapter;
    redirecting_predictor predictor;
    observation_sink sink;
    uvm_analysis_port#(packet) monitor;
    model_reg destination;
    uvm_reg_field destination_field;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      blk = new();
      blk.configure();
      rg = new("r", 8);
      rg.configure(blk);
      field = new("value");
      field.configure(rg, 8, 0, "RW", 0, 'h55, 1, 0, 1);
      mapping = blk.create_map("bus", 0, 1, UVM_LITTLE_ENDIAN);
      mapping.add_reg(rg, 'h20);
      adapter = new();
      predictor = new("predictor", this);
      sink = new("sink", this);
      monitor = new("monitor", this);
      destination = new("destination", 8);
      destination.configure(blk);
      destination_field = new("destination_value");
      destination_field.configure(destination, 8, 0, "RW", 0, 0, 1, 0, 1);
      mapping.add_reg(destination, 'h40);
      predictor.destination = destination;
      blk.lock_model();
      blk.reset();
      predictor.map = mapping;
      predictor.adapter = adapter;
    endfunction
    function void connect_phase(uvm_phase phase);
      monitor.connect(predictor.bus_in);
      predictor.reg_ap.connect(sink.analysis_export);
    endfunction
    function void observe(uvm_reg_addr_t address, uvm_reg_data_t data, uvm_access_e kind);
      packet item = new("observed");
      item.kind = kind;
      item.address = address;
      item.data = data;
      item.bits = 8;
      monitor.write(item);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      observe('h20, 'h23, UVM_WRITE);
      $display("UT: source %0h target %0h hook %0d calls %0d value %0h redirected %0d",
               rg.get_mirrored_value(), destination.get_mirrored_value(), predictor.hook_calls,
               sink.calls, sink.value, sink.element == destination);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "predictor watchdog expired"); end
endmodule
