/*
:name: test_reg_order_policy_clearing_stops_hook_calls_without_losing_bus_bytes
:description: clearing a map policy stops its dispatch while retaining complete transfers (IEEE 1800.2-2020 Section 18.2.5.5)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.5.5 18.4.2.4 18.2.5.4 18.2.4.16 18.4.4.9 18.4.4.10 18.2.5.2 18.4.4.3 19.1.2.1 19.1.2.3 19.1.2.4 19.2.1.2.5 19.2.1.2.6 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_order_policy_clearing_stops_hook_calls_without_losing_bus_bytes.expected
*/
// Reorder complete bus-operation structs for one 32-bit register on an
// 8-bit bus. The driver stores bytes by address after a positive delay.
// No partial-width, burst-memory, concurrency or HDL/DPI semantics are claimed.
module test_reg_order_policy_clearing_stops_hook_calls_without_losing_bus_bytes;
  import uvm_pkg::*;

  `include "uvm_macros.svh"
  class address_order extends uvm_reg_transaction_order_policy;
    bit descending = 1;
    int calls = 0;
    int last_size = 0;
    bit widths_match = 1;
    bit kinds_match = 1;
    uvm_access_e expected_kind = UVM_WRITE;
    function new(string name="order"); super.new(name); endfunction
    virtual function void order(ref uvm_reg_bus_op q[$]);
      uvm_reg_bus_op temporary;
      calls++; last_size = q.size();
      foreach (q[i]) begin
        widths_match &= q[i].n_bits == 8;
        kinds_match &= q[i].kind == expected_kind;
      end
      for (int i=0; i<q.size(); i++) begin
        for (int j=i+1; j<q.size(); j++) begin
          if (descending ? q[i].addr < q[j].addr : q[i].addr > q[j].addr) begin
            temporary = q[i]; q[i] = q[j]; q[j] = temporary;
          end
        end
      end
    endfunction
  endclass
  class model_block extends uvm_reg_block;
    function new(); super.new("blk", UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    uvm_reg_field field;
    function new(); super.new("r", 32, UVM_NO_COVERAGE); endfunction
    function void build();
      field = new("value"); field.configure(this, 32, 0, "RW", 0, 0, 1, 0, 1);
    endfunction
  endclass

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    uvm_access_e kind;
    uvm_reg_addr_t address;
    uvm_reg_data_t data;
    int bits;
    function new(string name="packet"); super.new(name); endfunction
  endclass
  class adapter_type extends uvm_reg_adapter;
    function new(); super.new("adapter"); endfunction
    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
      packet item = new(); item.kind = rw.kind; item.address = rw.addr;
      item.data = rw.data; item.bits = rw.n_bits; return item;
    endfunction
    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
      packet item;
      if (!$cast(item, bus_item)) $fatal(1, "wrong packet type");
      rw.kind = item.kind; rw.addr = item.address; rw.data = item.data;
      rw.n_bits = item.bits; rw.status = UVM_IS_OK;
    endfunction
  endclass
  class bus_driver extends uvm_driver#(packet);
    uvm_reg_data_t storage[uvm_reg_addr_t];
    uvm_reg_addr_t addresses[$];
    uvm_reg_data_t data_seen[$];
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase);
      packet request;
      forever begin
        seq_item_port.get_next_item(request); #2;
        if (request.kind == UVM_WRITE) storage[request.address] = request.data & 'hff;
        else request.data = storage.exists(request.address) ? storage[request.address] : 0;
        addresses.push_back(request.address); data_seen.push_back(request.data & 'hff);
        seq_item_port.item_done();
      end
    endtask
    function int occurrences(uvm_reg_addr_t address);
      int count = 0;
      foreach (addresses[i]) if (addresses[i] == address) count++;
      return count;
    endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    model_block blk;
    model_reg rg;
    uvm_reg_map mapping;
    uvm_reg_map alternate;
    address_order first;
    address_order second;
    adapter_type adapter;
    uvm_sequencer#(packet) sequencer;
    bus_driver driver;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      blk = new(); blk.configure(); rg = new(); rg.configure(blk); rg.build();
      mapping = blk.create_map("bus", 0, 1, UVM_LITTLE_ENDIAN);
      alternate = blk.create_map("alternate", 0, 1, UVM_LITTLE_ENDIAN);
      mapping.add_reg(rg, 'h20); alternate.add_reg(rg, 'h40);
      first = new("first"); second = new("second"); second.descending = 0;
      first.descending = 1;
      mapping.set_transaction_order_policy(first);
      sequencer = new("sequencer", this); driver = new("driver", this); adapter = new();
      mapping.set_sequencer(sequencer, adapter); mapping.set_auto_predict(1);
      alternate.set_sequencer(sequencer, adapter); alternate.set_auto_predict(1);
      for (int i=0; i<4; i++) driver.storage['h20+i] = ('h12345678 >> (i*8)) & 'hff;
      blk.lock_model(); blk.reset();
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    task run_phase(uvm_phase phase);
      uvm_status_e status;
      uvm_reg_data_t value;
      int saved_calls;
      phase.raise_objection(this);

      rg.write(status, 'h12345678, UVM_FRONTDOOR, mapping); saved_calls = first.calls;
      mapping.set_transaction_order_policy(null);
      rg.write(status, 'ha1b2c3d4, UVM_FRONTDOOR, mapping);
      $display("UT: cleared no_new_call %0d total_bus_operations %0d", first.calls == saved_calls,
      driver.addresses.size());
      $display("UT: membership %0d %0d %0d %0d", driver.occurrences('h20),
      driver.occurrences('h21), driver.occurrences('h22), driver.occurrences('h23));
      $display("UT: storage %0h %0h %0h %0h mirror %0h", driver.storage['h20],
      driver.storage['h21], driver.storage['h22], driver.storage['h23], rg.get_mirrored_value());

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #200; $fatal(1, "order-policy watchdog expired"); end

endmodule
