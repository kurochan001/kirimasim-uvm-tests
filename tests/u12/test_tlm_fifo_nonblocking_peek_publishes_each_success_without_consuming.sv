/*
:name: test_tlm_fifo_nonblocking_peek_publishes_each_success_without_consuming
:description: successful nonblocking FIFO peek publishes each observation while retaining the item (IEEE 1800.2-2020 Section 12.2.8.1.6)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.8.1.6 12.2.4.2.8 12.2.4.2.6 12.2.8.1.3 12.2.8.1.4 12.2.8.2.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_fifo_nonblocking_peek_publishes_each_success_without_consuming.expected
*/
// Use two successful try_peek calls before a consuming try_get. The pinned
// library omits the required peek notifications; preserve the standard count
// without converting observations into removals.

module test_tlm_fifo_nonblocking_peek_publishes_each_success_without_consuming;
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
      writer.put(71);
      first_ok = reader.try_peek(first_value);
      second_ok = reader.try_peek(second_value);
      $display("UT: success %0d %0d peeked %0d %0d used %0d notifications %0d %0d", first_ok,
               second_ok, first_value, second_value, fifo.used(), get_first.values.size(),
               get_second.values.size());
      third_ok = reader.try_get(removed_value);
      $display("UT: removed_ok %0d value %0d total_notifications %0d %0d", third_ok,
               removed_value, get_first.values.size(), get_second.values.size());
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
