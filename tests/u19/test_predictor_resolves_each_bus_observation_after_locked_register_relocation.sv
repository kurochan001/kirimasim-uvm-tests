/*
:name: test_predictor_resolves_each_bus_observation_after_locked_register_relocation
:description: Observed transactions follow a runtime address move, ignore the old address and retain peer identity (IEEE 1800.2-2020 Section 19.3.2.1)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.3.2.1 19.3.2.2 19.3.2.3 19.2.2.2.2 18.4.2.3 18.4.4.15 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_predictor_resolves_each_bus_observation_after_locked_register_relocation.expected
*/
// Configure a predictor, its generic-payload adapter and the analysis
// connection before run. A completed write is published for the original
// register. Relocate it in the same locked map. A stale-address write must
// leave both mirrors and the publication FIFO unchanged. A peer write and a
// read from the new address must publish their own element, direction and
// value, in order.

module test_predictor_resolves_each_bus_observation_after_locked_register_relocation;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class block_model extends uvm_reg_block;
    function new(); super.new("model", UVM_NO_COVERAGE); endfunction
  endclass
  class byte_reg extends uvm_reg;
    function new(string name, block_model model);
      uvm_reg_field data_field;
      super.new(name, 8, UVM_NO_COVERAGE);
      configure(model);
      data_field = new("data_field");
      data_field.configure(this, 8, 0, "RW", 0, 0, 1, 0, 1);
    endfunction
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    block_model model;
    byte_reg moving, peer;
    uvm_reg_map mapping;
    uvm_reg_predictor #(uvm_tlm_gp) predictor;
    uvm_tlm_analysis_fifo #(uvm_reg_item) observed;
    uvm_analysis_port #(uvm_tlm_gp) monitor;

    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      uvm_reg_tlm_adapter adapter;
      super.build_phase(phase);
      model = new();
      model.configure();
      moving = new("moving", model);
      peer = new("peer", model);
      mapping = model.create_map("bus", 0, 1, UVM_LITTLE_ENDIAN);
      mapping.add_reg(moving, 'h10);
      mapping.add_reg(peer, 'h20);
      model.lock_model();
      model.reset();
      predictor = new("predictor", this);
      adapter = new("adapter");
      predictor.map = mapping;
      predictor.adapter = adapter;
      monitor = new("monitor", this);
      observed = new("observed", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      monitor.connect(predictor.bus_in);
      predictor.reg_ap.connect(observed.analysis_export);
    endfunction
    function void send(uvm_reg_addr_t address, byte unsigned value, uvm_tlm_command_e command);
      uvm_tlm_gp payload = new("payload");
      byte unsigned data[] = '{value};
      byte unsigned enables[] = '{8'hff};
      payload.set_command(command);
      payload.set_address(address);
      payload.set_data(data);
      payload.set_data_length(1);
      payload.set_byte_enable(enables);
      payload.set_byte_enable_length(1);
      payload.set_streaming_width(1);
      payload.set_response_status(UVM_TLM_OK_RESPONSE);
      monitor.write(payload);
    endfunction
    function uvm_reg_item take();
      uvm_reg_item item;
      if (!observed.try_get(item) || item == null) $fatal(1, "missing predicted register item");
      return item;
    endfunction
    task run_phase(uvm_phase phase);
      uvm_reg_item item;
      phase.raise_objection(this);
      send('h10, 'h12, UVM_TLM_WRITE_COMMAND);
      item = take();
      $display("UT: initial element %0d kind %0d data %0h mirrors %0h %0h",
               item.get_element() == moving, item.get_kind() == UVM_WRITE, item.get_value(0),
               moving.get_mirrored_value(), peer.get_mirrored_value());
      moving.set_offset(mapping, 'h30);
      send('h10, 'hee, UVM_TLM_WRITE_COMMAND);
      $display("UT: stale publications %0d mirrors %0h %0h", observed.used(),
               moving.get_mirrored_value(), peer.get_mirrored_value());
      send('h20, 'h34, UVM_TLM_WRITE_COMMAND);
      send('h30, 'h56, UVM_TLM_READ_COMMAND);
      item = take();
      $display("UT: peer element %0d kind %0d data %0h",
               item.get_element() == peer, item.get_kind() == UVM_WRITE, item.get_value(0));
      item = take();
      $display("UT: moved element %0d kind %0d data %0h",
               item.get_element() == moving, item.get_kind() == UVM_READ, item.get_value(0));
      $display("UT: final pending %0d mirrors %0h %0h",
               observed.used(), moving.get_mirrored_value(), peer.get_mirrored_value());
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
endmodule
