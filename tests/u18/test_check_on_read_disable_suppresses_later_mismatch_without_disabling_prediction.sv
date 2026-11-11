/*
:name: test_check_on_read_disable_suppresses_later_mismatch_without_disabling_prediction
:description: disabling check-on-read suppresses later mismatch reports and preserves prediction (IEEE 1800.2-2020 Section 18.2.5.3)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.5.3 18.2.5.2 18.4.4.10 18.4.4.14 18.4.4.3 18.4.4.5 18.5.5.15 18.5.4.6 18.2.3.5 19.2.1.2.5 19.2.1.2.6 6.6.3.2 6.6.5 10.7.2.5 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_check_on_read_disable_suppresses_later_mismatch_without_disabling_prediction.expected
*/
// What it checks:
// Disabling comparison suppresses later discrepancy reports without disabling
// mirror updates.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.2.5.3 (UVM-MAP-CHECK-READ-DISABLE-RETAINS-PREDICTION) gives
// the rule above. Setup: Read mismatched 5a while enabled, disable checking
// and read 6c. Expected: The first read reports; the second adds no ERROR and
// updates return/mirror to 6c.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Model-only bus storage, a delayed driver and explicit auto-prediction.
// Count required discrepancy reports without prescribing report text or IDs.
// Read-side effects are model prediction, not an RTL storage implementation.
module test_check_on_read_disable_suppresses_later_mismatch_without_disabling_prediction;
  import uvm_pkg::*;

  `include "uvm_macros.svh"
  class error_probe extends uvm_report_catcher;
    int errors = 0;
    function new(); super.new("error_probe"); endfunction
    function action_e catch();
      if (get_severity() == UVM_ERROR) begin errors++; return CAUGHT; end
      return THROW;
    endfunction
  endclass
  class model_block extends uvm_reg_block;
    function new(string name="blk"); super.new(name, UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    uvm_reg_field low;
    uvm_reg_field high;
    function new(string name="r"); super.new(name, 8, UVM_NO_COVERAGE); endfunction
    function void build(bit split=0, string access="RW", uvm_reg_data_t reset_value='h11);
      low = new("low");
      if (split) begin
        low.configure(this, 4, 0, access, 0, reset_value & 'hf, 1, 0, 0);
        high = new("high"); high.configure(this, 4, 4, access, 0, reset_value >> 4, 1, 0, 0);
      end else low.configure(this, 8, 0, access, 0, reset_value, 1, 0, 1);
    endfunction
  endclass
  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    uvm_reg_addr_t address;
    uvm_reg_data_t data;
    function new(string name="packet"); super.new(name); endfunction
  endclass
  class adapter_type extends uvm_reg_adapter;
    function new(); super.new("adapter"); endfunction
    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
      packet item = new(); item.address = rw.addr; item.data = rw.data; return item;
    endfunction
    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
      packet item;
      if (!$cast(item, bus_item)) $fatal(1, "wrong packet type");
      rw.addr = item.address; rw.data = item.data; rw.status = UVM_IS_OK;
    endfunction
  endclass
  class bus_driver extends uvm_driver#(packet);
    uvm_reg_data_t storage[uvm_reg_addr_t];
    int reads = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase);
      packet request;
      forever begin
        seq_item_port.get_next_item(request); #2;
        reads++; request.data = storage.exists(request.address) ? storage[request.address] : 0;
        seq_item_port.item_done();
      end
    endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    model_block blk;
    model_block child;
    model_reg rg;
    model_reg child_reg;
    uvm_reg_map mapping;
    uvm_reg_map alternate;
    uvm_reg_map child_map;
    adapter_type adapter;
    uvm_sequencer#(packet) sequencer;
    bus_driver driver;
    error_probe probe;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      blk = new(); blk.configure(); child = new("child"); child.configure(blk);
      rg = new(); rg.configure(blk); rg.build(0, "RW", 'h11);
      child_reg = new("child_reg"); child_reg.configure(child); child_reg.build();
      mapping = blk.create_map("bus", 0, 1, UVM_LITTLE_ENDIAN);
      alternate = blk.create_map("alternate", 0, 1, UVM_LITTLE_ENDIAN);
      child_map = child.create_map("child_bus", 0, 1, UVM_LITTLE_ENDIAN);
      mapping.add_reg(rg, 'h20); alternate.add_reg(rg, 'h40);
      child_map.add_reg(child_reg, 'h20); mapping.add_submap(child_map, 'h100);
      sequencer = new("sequencer", this); driver = new("driver", this); adapter = new();
      mapping.set_sequencer(sequencer, adapter); mapping.set_auto_predict(1);
      alternate.set_sequencer(sequencer, adapter); alternate.set_auto_predict(1);
      driver.storage['h20] = 'h11; driver.storage['h40] = 'h11; driver.storage['h120] = 'h11;
      blk.lock_model(); blk.reset();
      probe = new();
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    task run_phase(uvm_phase phase);
      uvm_status_e status;
      uvm_reg_data_t value;
      int before_errors;
      phase.raise_objection(this);
      uvm_report_cb::add(null, probe);

      mapping.set_check_on_read(1); driver.storage['h20] = 'h5a;
      rg.read(status, value, UVM_FRONTDOOR, mapping); before_errors = probe.errors;
      $display("UT: first reported %0d mirror %0h", before_errors > 0, rg.get_mirrored_value());
      mapping.set_check_on_read(0); driver.storage['h20] = 'h6c;
      rg.read(status, value, UVM_FRONTDOOR, mapping);
      $display("UT: disabled no_new_error %0d value %0h mirror %0h reads %0d",
      probe.errors == before_errors, value, rg.get_mirrored_value(), driver.reads);

      uvm_report_cb::delete(null, probe);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "check-on-read watchdog expired"); end

endmodule
