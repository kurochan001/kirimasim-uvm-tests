/*
:name: test_field_byte_enable_fallback_selects_individual_or_whole_register_access
:description: byte-enable capability selects field-only or whole-register frontdoor access (IEEE 1800.2-2020 Section 18.5.5.16)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.5.16 18.5.5.9 18.5.5.10 19.2.1.2.2 18.5.3.2 18.2.5.2 18.5.5.3 18.2.3.3 18.2.3.6 19.2.1.2.5 19.2.1.2.6 18.4.2.1 18.4.2.2 18.1.2.1 18.1.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_field_byte_enable_fallback_selects_individual_or_whole_register_access.expected
*/
// Each field occupies its own byte of one physical word. The original bus
// model applies byte masks; unused write-data lanes are not constrained.
// Live storage changes after the full read to distinguish the peer mirror.
module test_field_byte_enable_fallback_selects_individual_or_whole_register_access;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class packet extends uvm_sequence_item;
    uvm_access_e kind;
    uvm_reg_addr_t address;
    uvm_reg_data_t data;
    uvm_reg_byte_en_t enables;
    int bits;
    function new(); super.new("packet"); endfunction
  endclass
  class adapter_type extends uvm_reg_adapter;
    function new(); super.new("adapter"); endfunction
    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
      automatic packet item = new();
      item.kind = rw.kind; item.address = rw.addr; item.data = rw.data;
      item.enables = rw.byte_en; item.bits = rw.n_bits;
      return item;
    endfunction
    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
      packet item;
      if (!$cast(item, bus_item) || item == null) $fatal(1, "unexpected bus item");
      rw.kind = item.kind; rw.addr = item.address; rw.data = item.data;
      rw.byte_en = item.enables; rw.n_bits = item.bits; rw.status = UVM_IS_OK;
    endfunction
  endclass
  class model_block extends uvm_reg_block;
    function new(); super.new("blk", UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(); super.new("r", 16, UVM_NO_COVERAGE); endfunction
  endclass
  class bus_driver extends uvm_driver#(packet);
    uvm_reg_data_t storage = 'habcd;
    uvm_reg_byte_en_t masks[$];
    uvm_reg_addr_t addresses[$];
    uvm_access_e kinds[$];
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase);
      packet item;
      forever begin
        seq_item_port.get_next_item(item); #2;
        masks.push_back(item.enables & 'h3); addresses.push_back(item.address);
        kinds.push_back(item.kind);
        if (item.kind == UVM_WRITE) begin
          for (int lane = 0; lane < 2; lane++)
            if (item.enables[lane])
              storage[lane*8 +: 8] = item.data[lane*8 +: 8];
        end else item.data = storage;
        seq_item_port.item_done();
      end
    endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    model_block blk;
    model_reg rg;
    uvm_reg_field low_field, high_field;
    uvm_reg_map mapping;
    adapter_type adapter;
    uvm_sequencer#(packet) sequencer;
    bus_driver driver;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      blk = new(); blk.configure(); rg = new(); rg.configure(blk);
      low_field = new("low"); high_field = new("high");
      low_field.configure(rg, 8, 0, "RW", 0, 'h34, 1, 0, 1);
      high_field.configure(rg, 8, 8, "RW", 0, 'h12, 1, 0, 1);
      mapping = blk.create_map("bus", 0, 2, UVM_LITTLE_ENDIAN);
      mapping.add_reg(rg, 'h20);
      adapter = new(); adapter.supports_byte_enable = 0;
      sequencer = new("sequencer", this); driver = new("driver", this);
      mapping.set_sequencer(sequencer, adapter); mapping.set_auto_predict(1);
      blk.lock_model(); blk.reset();
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    task run_phase(uvm_phase phase);
      uvm_status_e status;
      uvm_reg_data_t value;
      phase.raise_objection(this);
      $display("UT: eligible low %0d high %0d",
               low_field.is_indv_accessible(UVM_FRONTDOOR, mapping),
               high_field.is_indv_accessible(UVM_FRONTDOOR, mapping));
      high_field.read(status, value, UVM_FRONTDOOR, mapping);
      $display("UT: full_read ok %0d value %0h mask %0h low %0h high %0h read %0d",
               status == UVM_IS_OK, value, driver.masks[0],
               low_field.get_mirrored_value(), high_field.get_mirrored_value(),
               driver.kinds[0] == UVM_READ);
      driver.storage = 'hefcd;
      low_field.write(status, 'h5a, UVM_FRONTDOOR, mapping);
      $display("UT: full_write ok %0d mask %0h storage %0h low %0h high %0h write %0d",
               status == UVM_IS_OK, driver.masks[1], driver.storage,
               low_field.get_mirrored_value(), high_field.get_mirrored_value(),
               driver.kinds[1] == UVM_WRITE);
      $display("UT: requests %0d first_address %0h second_address %0h",
               driver.masks.size(), driver.addresses[0], driver.addresses[1]);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "field byte-lane watchdog expired"); end
endmodule
