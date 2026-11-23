/*
:name: test_rtl_separate_responses_preserve_status_and_data_of_two_outstanding_register_reads
:description: Two outstanding frontdoor reads receive reversed RTL replies, including an error and a successful retry (IEEE 1800.2-2020 Section 19.2.1.2.3)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.2.1.2.3 19.2.1.2.5 19.2.1.2.6 14.1.2.4 15.5.2.9 18.4.4.10 18.2.5.2 1800-2023 9.2.2.4 25.9 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers_reordered_responses/read_bus.sv
:expected_exit: 0
:expected_stdout: @test_rtl_separate_responses_preserve_status_and_data_of_two_outstanding_register_reads.expected
*/
// Hold the first bus read until a second register is read. The slave replies
// to the second request with an error, then completes the first with its
// stored byte. A retry of the second read succeeds. Check the physical
// response order, each caller status, both successful read values and the
// mirror values. The data from the unsuccessful read is deliberately ignored.

module test_rtl_separate_responses_preserve_status_and_data_of_two_outstanding_register_reads;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  bit clk;
  always #5 clk = ~clk;
  tagged_read_bus bus(clk);
  reordered_read_slave dut(bus);

  class read_item extends uvm_sequence_item;
    bit [7:0] addr, data;
    bit failed;
    function new(string name); super.new(name); endfunction
  endclass

  class read_adapter extends uvm_reg_adapter;
    function new();
      super.new("adapter");
      provides_responses = 1;
    endfunction
    function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
      read_item item = new("request");
      if (rw.kind != UVM_READ) $fatal(1, "unexpected write");
      item.addr = rw.addr[7:0];
      return item;
    endfunction
    function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
      read_item item;
      if (!$cast(item, bus_item) || item == null) $fatal(1, "bad bus item");
      rw.kind = UVM_READ;
      rw.addr = item.addr;
      rw.data = item.data;
      rw.n_bits = 8;
      rw.byte_en = 1;
      rw.status = item.failed ? UVM_NOT_OK : UVM_IS_OK;
    endfunction
  endclass

  class read_driver extends uvm_driver #(read_item);
    virtual tagged_read_bus vif;
    read_item pending[bit [7:0]];
    bit [7:0] reply_order[$];
    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    task drive_commands();
      read_item item;
      forever begin
        seq_item_port.get_next_item(item);
        @(negedge vif.clk);
        if (pending.exists(item.addr)) $fatal(1, "tag already in use");
        pending[item.addr] = item;
        vif.addr = item.addr;
        vif.valid = 1;
        @(negedge vif.clk);
        vif.valid = 0;
        seq_item_port.item_done();
      end
    endtask

    task return_responses();
      read_item rsp;
      forever begin
        @(negedge vif.clk);
        if (vif.rsp_valid) begin
          if (!pending.exists(vif.rsp_addr)) $fatal(1, "unknown response tag");
          rsp = new("response");
          rsp.set_id_info(pending[vif.rsp_addr]);
          pending.delete(vif.rsp_addr);
          rsp.addr = vif.rsp_addr;
          rsp.data = vif.rsp_data;
          rsp.failed = vif.rsp_error;
          reply_order.push_back(rsp.addr);
          seq_item_port.put_response(rsp);
        end
      end
    endtask

    task run_phase(uvm_phase phase);
      wait (vif.rst_n);
      fork
        drive_commands();
        return_responses();
      join
    endtask
  endclass

  class reg_model extends uvm_reg_block;
    function new(); super.new("model", UVM_NO_COVERAGE); endfunction
  endclass
  class byte_reg extends uvm_reg;
    function new(string name, reg_model model);
      uvm_reg_field data_field;
      super.new(name, 8, UVM_NO_COVERAGE);
      configure(model);
      data_field = new("data_field");
      data_field.configure(this, 8, 0, "RW", 0, 0, 1, 0, 1);
    endfunction
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    reg_model model;
    byte_reg a, b;
    uvm_reg_map map_value;
    uvm_sequencer #(read_item) sqr;
    read_driver driver;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      read_adapter adapter;
      super.build_phase(phase);
      driver = new("driver", this);
      if (!uvm_config_db #(virtual tagged_read_bus)::get(this, "", "vif", driver.vif))
        $fatal(1, "bus interface missing");
      sqr = new("sqr", this);
      model = new();
      model.configure();
      a = new("A", model);
      b = new("B", model);
      map_value = model.create_map("bus_map", 0, 1, UVM_LITTLE_ENDIAN);
      map_value.add_reg(a, 'h10);
      map_value.add_reg(b, 'h20);
      model.lock_model();
      model.reset();
      adapter = new();
      map_value.set_sequencer(sqr, adapter);
      map_value.set_auto_predict(1);
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sqr.seq_item_export);
    endfunction
    task run_phase(uvm_phase phase);
      uvm_status_e first_status, second_status, retry_status;
      uvm_reg_data_t first_data, failed_data, retry_data;
      phase.raise_objection(this);
      fork
        a.read(first_status, first_data, UVM_FRONTDOOR, map_value);
        begin
          wait (driver.vif.accepted == 1);
          b.read(second_status, failed_data, UVM_FRONTDOOR, map_value);
        end
      join
      if (driver.reply_order.size() != 2) $fatal(1, "missing reply");
      $display("UT: replies %0h %0h rtl %0d %0d", driver.reply_order[0], driver.reply_order[1],
               driver.vif.accepted, driver.vif.completed);
      $display("UT: first ok %0d data %0h second failed %0d mirrors %0h %0h",
               first_status == UVM_IS_OK, first_data, second_status == UVM_NOT_OK,
               a.get_mirrored_value(), b.get_mirrored_value());
      b.read(retry_status, retry_data, UVM_FRONTDOOR, map_value);
      $display("UT: retry ok %0d data %0h mirrors %0h %0h",
               retry_status == UVM_IS_OK, retry_data,
               a.get_mirrored_value(), b.get_mirrored_value());
      $display("UT: final reply %0h rtl %0d %0d pending %0d", driver.reply_order[2],
               driver.vif.accepted, driver.vif.completed, driver.pending.num());
      phase.drop_objection(this);
    endtask
  endclass
  initial begin
    uvm_config_db #(virtual tagged_read_bus)::set(null, "uvm_test_top", "vif", bus);
    run_test("t");
  end
  initial begin
    repeat (2) @(negedge clk);
    bus.rst_n = 1;
  end
  initial begin
    repeat (100) @(posedge clk);
    $fatal(1, "timed out waiting for the paired reads");
  end
endmodule
