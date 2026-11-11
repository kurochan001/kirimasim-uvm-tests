/*
:name: test_reg_custom_frontdoor_read_returns_value_and_updates_mirror
:description: reg custom frontdoor read returns value and updates mirror (IEEE 1800.2-2020 Section 19.4.2.2.1)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.4.2.2.1 18.4.4.10 19.4.2.1 19.4.2.2.2 19.4.2.3 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.6 18.2.5.2 19.1.1.2.1 19.1.1.2.8 19.1.1.2.9 19.1.1.2.2 19.1.1.2.3 19.1.1.2.4 19.1.1.2.5 19.1.1.2.6 18.4.2.1 18.4.2.2 18.5.3.2 18.2.3.3 1800-2023 6.21 8.19
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_custom_frontdoor_read_returns_value_and_updates_mirror.expected
*/
// What it checks:
// Custom register frontdoors receive the operation data through rw_info.
//
// How the expected output follows from the standard:
// 1800.2-2020 19.4.2.2.1 (UVM-REGISTER-CUSTOM-FRONTDOOR-DESCRIPTOR) gives the
// rule above. Setup: Run the explicitly selected custom-frontdoor fixture with
// controlled descriptor fields and storage. Expected: The sequence consumes
// the requested write value or supplies the returned read value.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The custom sequence returns the stored value through rw_info. Auto-prediction
// updates the register mirror after the sequence completes.

module test_reg_custom_frontdoor_read_returns_value_and_updates_mirror;
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
    model_reg rg;
    uvm_reg_field field;
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
      rg = new();
      rg.configure(blk);
      field = new("value");
      field.configure(rg, 8, 0, "RW", 0, 'h11, 1, 0, 1);
      mapping = blk.create_map("bus", 0, 1, UVM_LITTLE_ENDIAN);
      fd = new();
      replacement = new("replacement");
      extension = new();
      mapping.add_reg(rg, 'h20, "RW", 0, fd);
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
      fd.storage[0] = 'hbc;
      rg.read(status, value, UVM_FRONTDOOR, mapping);
      $display("UT: ok %0d calls %0d value %0h mirror %0h", status == UVM_IS_OK,
               fd.calls, value, rg.get_mirrored_value());
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "custom frontdoor watchdog expired"); end
endmodule
