/*
:name: test_tlm_fifo_blocking_peek_publishes_each_observation_without_consuming
:description: blocking FIFO peek publishes every observed transaction without removing it (IEEE 1800.2-2020 Section 12.2.8.1.6)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.8.1.6 12.2.4.2.3 12.2.4.2.2 12.2.8.1.3 12.2.8.1.4 12.2.8.2.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_fifo_blocking_peek_publishes_each_observation_without_consuming.expected
*/
// Peek twice at one queued value and inspect get_ap before consuming it.
// The standard includes peek notifications; the pinned library omits them.
// Retain both required notifications as a spec-only expectation.

module test_tlm_fifo_blocking_peek_publishes_each_observation_without_consuming;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class observer extends uvm_subscriber#(int);
    `uvm_component_utils(observer)
    int values[$];
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void write(int t); values.push_back(t); endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_tlm_fifo#(int) fifo;
    uvm_put_port#(int) writer;
    uvm_get_peek_port#(int) reader;
    observer put_first;
    observer put_second;
    observer get_first;
    observer get_second;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      fifo = new("fifo", this, 2);
      writer = new("writer", this);
      reader = new("reader", this);
      put_first = new("put_first", this);
      put_second = new("put_second", this);
      get_first = new("get_first", this);
      get_second = new("get_second", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      writer.connect(fifo.put_export);
      reader.connect(fifo.get_peek_export);
      fifo.put_ap.connect(put_first.analysis_export);
      fifo.put_ap.connect(put_second.analysis_export);
      fifo.get_ap.connect(get_first.analysis_export);
      fifo.get_ap.connect(get_second.analysis_export);
    endfunction
    task run_phase(uvm_phase phase);
      int first_value;
      int second_value;
      int removed_value;
      bit first_ok;
      bit second_ok;
      bit third_ok;
      bit fourth_ok;
      phase.raise_objection(this);
      writer.put(61);
      reader.peek(first_value);
      reader.peek(second_value);
      $display("UT: peeked %0d %0d used %0d notifications %0d %0d", first_value, second_value,
               fifo.used(), get_first.values.size(), get_second.values.size());
      reader.get(removed_value);
      $display("UT: removed %0d total_notifications %0d %0d", removed_value,
               get_first.values.size(), get_second.values.size());
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
