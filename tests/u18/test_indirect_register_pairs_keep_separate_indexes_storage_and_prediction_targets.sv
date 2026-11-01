/*
:name: test_indirect_register_pairs_keep_separate_indexes_storage_and_prediction_targets
:description: indirect register accesses use the configured index and predict only the selected array register (IEEE 1800.2-2020 Section 18.7.2.2)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.7.2.2 18.7.2.1 18.4.4.9 18.4.4.10 18.4.4.3 18.4.3.1 18.4.3.2 18.2.3.6 18.2.5.2 19.1.2.2 19.1.2.3 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.3 18.4.2.1 18.4.2.2 18.5.3.2 18.3.2.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_indirect_register_pairs_keep_separate_indexes_storage_and_prediction_targets.expected
*/
// Equal-width array elements and explicit successful index writes precede
// each data-port access. A testbench driver models two independent banks; no
// RTL, DPI, out-of-range index or automatic array-frontdoor sequence is used.
module test_indirect_register_pairs_keep_separate_indexes_storage_and_prediction_targets;
  import uvm_pkg::*;

  `include "uvm_macros.svh"
  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    uvm_access_e kind;
    uvm_reg_addr_t address;
    uvm_reg_data_t data;
    uvm_status_e status = UVM_IS_OK;
    function new(string name="packet"); super.new(name); endfunction
  endclass
  class adapter_type extends uvm_reg_adapter;
    function new(); super.new("adapter"); endfunction
    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
      packet result_value;
      result_value = new("request"); result_value.kind = rw.kind;
      result_value.address = rw.addr; result_value.data = rw.data;
      return result_value;
    endfunction
    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
      packet result_value;
      if (!$cast(result_value, bus_item)) $fatal(1, "invalid bus item");
      rw.kind = result_value.kind; rw.addr = result_value.address;
      rw.data = result_value.data; rw.status = result_value.status;
    endfunction
  endclass
  class model_block extends uvm_reg_block;
    function new(); super.new("blk", UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(string name="r"); super.new(name, 8, UVM_NO_COVERAGE); endfunction
  endclass
  class indirect_reg extends uvm_reg_indirect_data;
    function new(string name="data"); super.new(name, 8, UVM_NO_COVERAGE); endfunction
  endclass
  class bus_driver extends uvm_driver#(packet);
    uvm_reg_data_t storage[2][3];
    int selected[2];
    uvm_reg_addr_t addresses[$];
    uvm_access_e kinds[$];
    bit fail_write = 0;
    bit fail_read = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase);
      packet request;
      int bank;
      bit data_port;
      forever begin
        seq_item_port.get_next_item(request); #1;
        addresses.push_back(request.address); kinds.push_back(request.kind);
        bank = request.address >= 16 ? 1 : 0;
        data_port = request.address == 1 || request.address == 17;
        if (!(request.address inside {0, 1, 16, 17})) $fatal(1, "unexpected bus address");
        request.status = UVM_IS_OK;
        if (data_port && ((fail_write && request.kind == UVM_WRITE) ||
                          (fail_read && request.kind == UVM_READ))) begin
          request.status = UVM_NOT_OK; fail_write = 0; fail_read = 0;
        end else if (data_port) begin
          if (selected[bank] < 0 || selected[bank] > 2) $fatal(1, "invalid index");
          if (request.kind == UVM_WRITE) storage[bank][selected[bank]] = request.data;
          else request.data = storage[bank][selected[bank]];
        end else begin
          if (request.kind == UVM_WRITE) selected[bank] = int'(request.data);
          else request.data = selected[bank];
        end
        seq_item_port.item_done();
      end
    endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    model_block blk;
    model_reg index0, index1;
    indirect_reg data0, data1;
    uvm_reg array0[3];
    uvm_reg array1[3];
    uvm_reg_file placement;
    uvm_reg_map mapping;
    adapter_type adapter;
    uvm_sequencer#(packet) sequencer;
    bus_driver driver;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      model_reg rg;
      uvm_reg_field value;
      super.build_phase(phase);
      blk = new(); blk.configure();
      index0 = new("index0"); index0.configure(blk);
      value = new("value0"); value.configure(index0, 8, 0, "RW", 0, 0, 1, 0, 1);
      index1 = new("index1"); index1.configure(blk);
      value = new("value1"); value.configure(index1, 8, 0, "RW", 0, 0, 1, 0, 1);
      foreach (array0[i]) begin
        rg = new($sformatf("array0_%0d", i)); rg.configure(blk);
        value = new("value"); value.configure(rg, 8, 0, "RW", 0, 0, 1, 0, 1); array0[i] = rg;
        rg = new($sformatf("array1_%0d", i)); rg.configure(blk);
        value = new("value"); value.configure(rg, 8, 0, "RW", 0, 0, 1, 0, 1); array1[i] = rg;
      end

      mapping = blk.create_map("bus", 0, 1, UVM_LITTLE_ENDIAN);
      mapping.add_reg(index0, 0); mapping.add_reg(index1, 16);
      data0 = new("data0"); data0.configure(index0, array0, blk, placement);
      data1 = new("data1"); data1.configure(index1, array1, blk);
      mapping.add_reg(data0, 1); mapping.add_reg(data1, 17);
      sequencer = new("sequencer", this); adapter = new(); driver = new("driver", this);
      mapping.set_sequencer(sequencer, adapter); mapping.set_auto_predict(1);
      blk.lock_model(); blk.reset();
      foreach (driver.storage[b,i]) driver.storage[b][i] = 'h11 * (i+1) + b * 'h40;
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    task run_phase(uvm_phase phase);
      uvm_status_e status;
      uvm_reg_data_t value;
      bit first_ok;
      phase.raise_objection(this);

      index0.write(status, 1, UVM_FRONTDOOR, mapping); index1.write(status, 2, UVM_FRONTDOOR,
      mapping);
      data0.write(status, 'h5a, UVM_FRONTDOOR, mapping); data1.write(status, 'h42, UVM_FRONTDOOR,
      mapping);
      $display("UT: indexes %0d/%0d storage %0h/%0h mirrors %0h/%0h", driver.selected[0],
      driver.selected[1], driver.storage[0][1], driver.storage[1][2],
      array0[1].get_mirrored_value(), array1[2].get_mirrored_value());
      $display("UT: peers %0h/%0h data_addresses %0h/%0h calls %0d", driver.storage[0][2],
      driver.storage[1][1], driver.addresses[2], driver.addresses[3], driver.addresses.size());
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #400; $fatal(1, "indirect register watchdog expired"); end

endmodule
