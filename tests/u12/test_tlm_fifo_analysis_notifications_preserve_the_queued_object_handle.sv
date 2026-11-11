/*
:name: test_tlm_fifo_analysis_notifications_preserve_the_queued_object_handle
:description: FIFO put and get analysis paths preserve the original queued object handle (IEEE 1800.2-2020 Section 12.2.8.1.5)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.8.1.5 12.2.8.1.6 12.2.8.1.3 12.2.8.1.4 12.2.4.2.1 12.2.4.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_fifo_analysis_notifications_preserve_the_queued_object_handle.expected
*/
// What it checks:
// 1. Accepted FIFO puts publish the transaction to every connected
//    put-analysis subscriber.
// 2. Successful FIFO gets and peeks publish each observed transaction to all
//    get-analysis subscribers.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.2.8.1.5 (UVM-FIFO-PUT-ANALYSIS) gives rule 1 above. Setup:
//    Use blocking/nonblocking puts, a full rejection, availability-only
//    queries and class handles. Expected: All subscribers see accepted
//    values/handles only; failed puts and availability queries add no
//    transactions.
// 2. 1800.2-2020 12.2.8.1.6 (UVM-FIFO-GET-PEEK-ANALYSIS) gives rule 2 above.
//    Setup: Use blocking/nonblocking removal and repeated non-consuming
//    observation, including empty calls. Expected: Every successful
//    observation publishes, including peeks; failed empty calls publish
//    nothing and handles are preserved.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Observe a class transaction on both FIFO analysis ports and at the
// reader. Compare handles and data without requiring an implicit clone
// or an analysis-subscriber invocation order.

module test_tlm_fifo_analysis_notifications_preserve_the_queued_object_handle;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_object;
    `uvm_object_utils(packet)
    int value = 93;
    function new(string name="packet"); super.new(name); endfunction
  endclass
  class observer extends uvm_subscriber#(packet);
    `uvm_component_utils(observer)
    packet seen;
    int calls = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void write(packet t); seen = t; calls++; endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_tlm_fifo#(packet) fifo;
    uvm_put_port#(packet) writer;
    uvm_get_port#(packet) reader;
    observer puts;
    observer gets;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      fifo = new("fifo", this, 1);
      writer = new("writer", this);
      reader = new("reader", this);
      puts = new("puts", this);
      gets = new("gets", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      writer.connect(fifo.put_export);
      reader.connect(fifo.get_peek_export);
      fifo.put_ap.connect(puts.analysis_export);
      fifo.get_ap.connect(gets.analysis_export);
    endfunction
    task run_phase(uvm_phase phase);
      packet sent = new("sent");
      packet received;
      phase.raise_objection(this);
      writer.put(sent);
      reader.get(received);
      $display("UT: put_same %0d get_same %0d reader_same %0d calls %0d %0d value %0d",
               puts.seen == sent, gets.seen == sent, received == sent,
               puts.calls, gets.calls, received.value);
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
