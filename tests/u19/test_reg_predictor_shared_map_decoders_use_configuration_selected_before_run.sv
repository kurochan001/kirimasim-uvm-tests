/*
:name: test_reg_predictor_shared_map_decoders_use_configuration_selected_before_run
:description: reg predictor shared map decoders use configuration selected before run (IEEE 1800.2-2020 Section 19.3.2.4)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.3.2.4 19.3.2.1 19.3.2.2 19.3.2.3 19.3.3.1 19.2.1.2.5 19.2.1.2.6 18.4.4.15 18.1.2.1 18.1.2.2 18.1.2.6 18.2.3.3 18.4.2.1 18.4.2.2 18.4.6.2 18.5.3.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_predictor_shared_map_decoders_use_configuration_selected_before_run.expected
*/
// Both public map/adapter configurations precede run. Original XOR-coded
// packets define the fixture bus protocol; actual predictor outputs and
// mirrors
// show which configured scope/decoder is used. This is single-byte RW
// modeling,
// not a physical DUT, live reconfiguration or incomplete-check diagnostic
// oracle.
module test_reg_predictor_shared_map_decoders_use_configuration_selected_before_run;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    uvm_reg_addr_t address;
    uvm_reg_data_t raw;
    function new(string name = "packet"); super.new(name); endfunction
  endclass
  class decoder extends uvm_reg_adapter;
    uvm_reg_data_t mask;
    function new(uvm_reg_data_t selected_mask);
      super.new("decoder"); mask = selected_mask;
    endfunction
    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
      automatic packet item = new(); item.address = rw.addr; item.raw = rw.data ^ mask;
      return item;
    endfunction
    virtual function void bus2reg(uvm_sequence_item item_value, ref uvm_reg_bus_op rw);
      packet item;
      if (!$cast(item,item_value) || item == null) $fatal(1, "wrong original packet");
      rw.kind = UVM_WRITE; rw.addr = item.address; rw.data = item.raw ^ mask;
      rw.n_bits = 8; rw.byte_en = 1; rw.status = UVM_IS_OK;
    endfunction
  endclass
  class model_block extends uvm_reg_block;
    function new(string name); super.new(name, UVM_NO_COVERAGE); endfunction
  endclass
  class model_register extends uvm_reg;
    function new(); super.new("reg_value", 8, UVM_NO_COVERAGE); endfunction
  endclass
  class sink extends uvm_subscriber#(uvm_reg_item);
    int calls = 0;
    uvm_reg_data_t last_value;
    function new(string name, uvm_component parent); super.new(name,parent); endfunction
    function void write(uvm_reg_item rw); calls++; last_value = rw.get_value(0); endfunction
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    model_block left_block, right_block;
    model_register left_value, right_value;
    uvm_reg_field left_field, right_field;
    uvm_reg_map left_map, right_map;
    decoder left_decoder, right_decoder;
    uvm_reg_predictor#(packet) left_predictor, right_predictor;
    sink left_sink, right_sink;
    uvm_analysis_port#(packet) left_monitor, right_monitor;
    function new(string name, uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      left_block = new("left"); left_block.configure(); left_value = new();
      left_value.configure(left_block); left_field = new("field_value");
      left_field.configure(left_value,8,0,"RW",0,0,1,0,1);
      left_map = left_block.create_map("map_value",0,1,UVM_LITTLE_ENDIAN);
      left_map.add_reg(left_value,'h10); left_block.lock_model(); left_block.reset();
      right_map = left_map; right_value = left_value;
      left_decoder = new('h11); right_decoder = new('h22);
      left_predictor = new("left_predictor",this); right_predictor = new("right_predictor",this);
      left_predictor.map = left_map; right_predictor.map = right_map;
      left_predictor.adapter = left_decoder; right_predictor.adapter = right_decoder;
      left_sink = new("left_sink",this); right_sink = new("right_sink",this);
      left_monitor = new("left_monitor",this); right_monitor = new("right_monitor",this);
    endfunction
    function void connect_phase(uvm_phase phase);
      left_monitor.connect(left_predictor.bus_in);
      right_monitor.connect(right_predictor.bus_in);
      left_predictor.reg_ap.connect(left_sink.analysis_export);
      right_predictor.reg_ap.connect(right_sink.analysis_export);
    endfunction
    task run_phase(uvm_phase phase);
      automatic packet observation = new();
      phase.raise_objection(this);
      observation.address = 'h10; observation.raw = 'h3a;
      left_monitor.write(observation);
      $display("UT: first mirror %0h published %0h calls %0d %0d",
               left_value.get_mirrored_value(), left_sink.last_value,
               left_sink.calls, right_sink.calls);
      right_monitor.write(observation);
      $display("UT: second mirror %0h left_snapshot %0h right_snapshot %0h calls %0d %0d",
               left_value.get_mirrored_value(), left_sink.last_value, right_sink.last_value,
               left_sink.calls, right_sink.calls);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
endmodule
