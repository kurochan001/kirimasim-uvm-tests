/*
:name: test_field_access_little_endian_respects_layout_and_physical_bus_width
:description: field access uses layout eligibility and physical byte ordering (IEEE 1800.2-2020 Section 18.5.5.10)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.5.10 18.5.5.16 18.5.5.9 18.5.3.2 18.5.4.2 18.5.4.3 18.5.5.3 18.2.5.2 18.2.3.2 17.2.2.4 18.2.3.3 19.2.1.2.2 19.2.1.2.5 19.2.1.2.6 18.4.2.1 18.4.2.2 18.1.2.1 18.1.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_field_access_little_endian_respects_layout_and_physical_bus_width.expected
*/
// What it checks:
// 1. Byte-isolated fields fit a one-byte bus and remain individually
//    accessible for either selected endian.
// 2. A selected high-byte write preserves the unselected low-byte bus storage.
// 3. A selected low-byte read returns the low field value.
// 4. Successful individual operations predict their selected fields
//    independently.
// 5. The little-endian high byte is written at its ordered physical address.
// 6. The configured little-endian map selects the low field physical byte.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.5.5.16
//    (UVM-FIELD-LAYOUT-NARROW-BUS-INDIVIDUAL-ELIGIBILITY) gives rule 1 above.
//    Setup: Two eight-bit fields occupy a sixteen-bit register on a supported
//    one-byte interface. Expected: Low and high queries return true in both
//    configurations.
// 2. 1800.2-2020 18.5.5.9 (UVM-FIELD-LAYOUT-NARROW-WRITE-PRESERVES-LIVE-PEER)
//    gives rule 2 above. Setup: The high/low physical bytes initially contain
//    0xab/0xcd in each endian layout. Expected: High becomes 0x6c while low
//    remains 0xcd.
// 3. 1800.2-2020 18.5.5.10
//    (UVM-FIELD-LAYOUT-NARROW-READ-RETURNS-SELECTED-VALUE) gives rule 3 above.
//    Setup: The low physical byte contains 0xcd after a high-field write.
//    Expected: Low returns 0xcd using one enabled lane.
// 4. 1800.2-2020 18.2.5.2 (UVM-FIELD-LAYOUT-NARROW-SELECTED-PREDICTION) gives
//    rule 4 above. Setup: A high write follows reset 0x1234, then a low read
//    observes 0xcd. Expected: Mirrors become 0x6c34 then 0x6ccd.
// 5. 1800.2-2020 17.2.2.4 (UVM-FIELD-LITTLE-ENDIAN-HIGH-WRITE-ADDRESS) gives
//    rule 5 above. Setup: A byte-addressed register starts at 0x20 on a
//    one-byte bus. Expected: The selected high write uses 0x21.
// 6. 1800.2-2020 18.2.3.2 (UVM-FIELD-LITTLE-ENDIAN-LOW-READ-ADDRESS) gives
//    rule 6 above. Setup: Byte addressing and one-byte bus width apply to a
//    two-byte register at 0x20. Expected: The selected low read uses 0x20.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original masked bus storage is distinct from the model mirror.
// RW fields have no side effects. Byte addresses and selected lanes are
// explicit; unused write-data lanes and warning text are not constrained.
module test_field_access_little_endian_respects_layout_and_physical_bus_width;
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
    function new(); super.new("adapter"); supports_byte_enable = 1; endfunction
    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
      automatic packet item = new();
      item.kind = rw.kind; item.address = rw.addr; item.data = rw.data;
      item.enables = rw.byte_en; item.bits = rw.n_bits; return item;
    endfunction
    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
      packet item;
      if (!$cast(item, bus_item) || item == null) $fatal(1, "unexpected packet");
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
    uvm_reg_data_t storage[uvm_reg_addr_t];
    uvm_reg_byte_en_t masks[$];
    uvm_reg_addr_t addresses[$];
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase);
      packet item;
      forever begin
        seq_item_port.get_next_item(item); #2;
        masks.push_back(item.enables & 'h1); addresses.push_back(item.address);
        if (item.kind == UVM_WRITE) begin
          for (int lane = 0; lane < 1; lane++)
            if (item.enables[lane])
              storage[item.address][lane*8 +: 8] = item.data[lane*8 +: 8];
        end else item.data = storage[item.address];
        seq_item_port.item_done();
      end
    endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    model_block blk;
    model_reg rg;
    uvm_reg_field low_field, high_field, target;
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
      mapping = blk.create_map("bus", 0, 1, UVM_LITTLE_ENDIAN);
      mapping.add_reg(rg, 'h20); adapter = new(); sequencer = new("sequencer", this);
      driver = new("driver", this);
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
      driver.storage['h21] = 'hab; driver.storage['h20] = 'hcd;
      $display("UT: individual low %0d high %0d", low_field.is_indv_accessible(
               UVM_FRONTDOOR, mapping), high_field.is_indv_accessible(UVM_FRONTDOOR, mapping));
      high_field.write(status, 'h6c, UVM_FRONTDOOR, mapping);
      $display("UT: high_write ok %0d address %0h mask %0h live_high %0h live_low %0h mirror %0h",
               status == UVM_IS_OK, driver.addresses[0], driver.masks[0],
               driver.storage['h21], driver.storage['h20], rg.get_mirrored_value());
      low_field.read(status, value, UVM_FRONTDOOR, mapping);
      $display("UT: low_read ok %0d address %0h mask %0h value %0h mirror %0h requests %0d",
               status == UVM_IS_OK, driver.addresses[1], driver.masks[1], value,
               rg.get_mirrored_value(), driver.addresses.size());
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "field-access watchdog expired"); end
endmodule
