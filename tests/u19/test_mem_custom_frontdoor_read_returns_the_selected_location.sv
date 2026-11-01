/*
:name: test_mem_custom_frontdoor_read_returns_the_selected_location
:description: mem custom frontdoor read returns the selected location (IEEE 1800.2-2020 Section 19.4.2.2.1)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.4.2.2.1 18.6.5.2 19.1.1.2.6 19.4.2.1 19.4.2.2.2 19.4.2.3 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.6 18.2.5.2 19.1.1.2.1 19.1.1.2.8 19.1.1.2.9 19.1.1.2.2 19.1.1.2.3 19.1.1.2.4 19.1.1.2.5 18.6.3.1 18.6.3.2 18.2.3.4 1800-2023 6.21 8.19
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_mem_custom_frontdoor_read_returns_the_selected_location.expected
*/
// Distinct neighboring storage values distinguish the requested memory location
// from an adjacent one.

module test_mem_custom_frontdoor_read_returns_the_selected_location;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class model_block extends uvm_reg_block;
    function new(); super.new("blk", UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(); super.new("r", 8, UVM_NO_COVERAGE); endfunction
  endclass

  class token extends uvm_sequence_item;
    function new(); super.new("token"); endfunction
  endclass
  class storage_frontdoor extends uvm_reg_frontdoor;
    uvm_reg_data_t storage[uvm_reg_addr_t];
    int calls = 0;
    uvm_status_e response_status = UVM_IS_OK;
    uvm_object seen_element;
    uvm_object seen_extension;
    uvm_reg_map seen_map;
    bit seen_frontdoor;
    bit seen_register;
    bit seen_memory;
    bit seen_write;
    bit sequencer_matches;
    uvm_reg_addr_t seen_offset;
    function new(string name="fd"); super.new(name); endfunction
    virtual task body();
      uvm_reg_addr_t location;
      if (rw_info == null) $fatal(1, "missing frontdoor operation");
      calls++;
      seen_element = rw_info.get_element();
      seen_extension = rw_info.get_extension();
      seen_map = rw_info.get_map();
      seen_frontdoor = rw_info.get_door() == UVM_FRONTDOOR;
      seen_register = rw_info.get_element_kind() == UVM_REG;
      seen_memory = rw_info.get_element_kind() == UVM_MEM;
      seen_write = rw_info.get_kind() == UVM_WRITE;
      seen_offset = rw_info.get_offset();
      sequencer_matches = get_sequencer() == sequencer;
      location = seen_memory ? seen_offset : 0;
      #2;
      if (response_status == UVM_IS_OK) begin
        if (seen_write) storage[location] = rw_info.get_value(0);
        else rw_info.set_value(storage.exists(location) ? storage[location] : 0);
      end
      rw_info.set_status(response_status);
    endtask
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    model_block blk;
    uvm_mem mem;
    uvm_reg_map mapping;
    storage_frontdoor fd;
    storage_frontdoor replacement;
    token extension;
    uvm_sequencer#(uvm_sequence_item) sequencer;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      blk = new();
      blk.configure();
      mem = new("mem", 16, 8, "RW", UVM_NO_COVERAGE);
      mem.configure(blk);
      mapping = blk.create_map("bus", 0, 1, UVM_LITTLE_ENDIAN);
      fd = new();
      replacement = new("replacement");
      extension = new();
      mapping.add_mem(mem, 'h20, "RW", 0, fd);
      sequencer = new("sequencer", this);
      mapping.set_sequencer(sequencer);
      mapping.set_auto_predict(1);
      blk.lock_model();
      blk.reset();
    endfunction
    task run_phase(uvm_phase phase);
      uvm_status_e status;
      uvm_reg_data_t value;
      phase.raise_objection(this);
      fd.storage[4] = 'h33;
      fd.storage[5] = 'hbc;
      mem.read(status, 5, value, UVM_FRONTDOOR, mapping);
      $display("UT: ok %0d calls %0d offset %0d value %0h", status == UVM_IS_OK,
               fd.calls, fd.seen_offset, value);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "custom frontdoor watchdog expired"); end
endmodule
