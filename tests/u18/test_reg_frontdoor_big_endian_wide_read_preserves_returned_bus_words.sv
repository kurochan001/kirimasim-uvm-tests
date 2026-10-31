/*
:name: test_reg_frontdoor_big_endian_wide_read_preserves_returned_bus_words
:description: big-endian frontdoor read through the standard TLM adapter preserves returned bytes (IEEE 1800.2-2020 Section 18.4.4.10)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.4.10 19.1.2.3 19.2.2.2.1 19.2.2.2.2 18.2.3.6 18.2.5.2 18.4.4.3 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.3 18.4.2.1 18.4.2.2 18.5.3.2 12.3.4.2.15 1800-2023 6.21 8.19
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_frontdoor_big_endian_wide_read_preserves_returned_bus_words.expected
*/
// Use the standard TLM adapter and identical bytes in every returned lane.
// This checks value reconstruction without a custom numeric-word encoding.

module test_reg_frontdoor_big_endian_wide_read_preserves_returned_bus_words;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class model_block extends uvm_reg_block;
    function new(); super.new("blk", UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(); super.new("r", 32, UVM_NO_COVERAGE); endfunction
  endclass
  class payload_driver extends uvm_driver#(uvm_tlm_gp);
    int calls = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase);
      uvm_tlm_gp request;
      byte unsigned bytes[];
      forever begin
        seq_item_port.get_next_item(request);
        #2;
        bytes = new[request.get_data_length()];
        foreach (bytes[i]) bytes[i] = 'h3c;
        request.set_data(bytes);
        request.set_response_status(UVM_TLM_OK_RESPONSE);
        calls++;
        seq_item_port.item_done();
      end
    endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    model_block blk;
    model_reg rg;
    uvm_reg_field field;
    uvm_reg_map mapping;
    uvm_reg_tlm_adapter adapter;
    uvm_sequencer#(uvm_tlm_gp) sequencer;
    payload_driver driver;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      blk = new();
      blk.configure();
      rg = new();
      rg.configure(blk);
      field = new("value");
      field.configure(rg, 32, 0, "RW", 0, 'h11, 1, 0, 1);
      mapping = blk.create_map("bus", 0, 2, UVM_BIG_ENDIAN);
      mapping.add_reg(rg, 'h20);
      sequencer = new("sequencer", this);
      adapter = new("adapter");
      driver = new("driver", this);
      mapping.set_sequencer(sequencer, adapter);
      mapping.set_auto_predict(1);
      blk.lock_model();
      blk.reset();
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    task run_phase(uvm_phase phase);
      uvm_status_e status;
      uvm_reg_data_t value;
      phase.raise_objection(this);
      rg.read(status, value, UVM_FRONTDOOR, mapping);
      $display("UT: ok %0d count %0d value %0h mirror %0h", status == UVM_IS_OK,
               driver.calls, value, rg.get_mirrored_value());
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "frontdoor watchdog expired"); end
endmodule
