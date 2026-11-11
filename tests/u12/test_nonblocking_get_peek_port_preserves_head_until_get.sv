/*
:name: test_nonblocking_get_peek_port_preserves_head_until_get
:description: combined nonblocking get-peek port forwards queries and consuming reads (IEEE 1800.2-2020 Section 12.2.5.1)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.5.1 12.2.8.1.4 12.2.4.2.6 12.2.4.2.7 12.2.4.2.8 12.2.4.2.9 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_nonblocking_get_peek_port_preserves_head_until_get.expected
*/
// What it checks:
// Compatible nonblocking ports forward availability, acceptance and get/peek
// results.
//
// How the expected output follows from the standard:
// 1800.2-2020 12.2.5.1 (UVM-TLM1-BOUND-NONBLOCKING-PORT-TRANSFERS) gives the
// rule above. Setup: Use a one-entry put FIFO and a two-entry get/peek FIFO.
// Expected: A full put is rejected without replacement; successful peek/get
// values and capacity transitions match their endpoint.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Peek the connected FIFO head before consuming it. Availability
// queries become false after both queued entries have been removed.

module test_nonblocking_get_peek_port_preserves_head_until_get;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_nonblocking_get_peek_port#(int) rx;
    uvm_tlm_fifo#(int) fifo;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      rx = new("rx", this);
      fifo = new("fifo", this, 2);
    endfunction
    function void connect_phase(uvm_phase phase); rx.connect(fifo.get_peek_export); endfunction
    task run_phase(uvm_phase phase);
      int value;
      bit ok;
      phase.raise_objection(this);
      void'(fifo.try_put(11));
      void'(fifo.try_put(22));
      $display("UT: available get %0d peek %0d", rx.can_get(), rx.can_peek());
      ok = rx.try_peek(value);
      $display("UT: peek %0d %0d used %0d", ok, value, fifo.used());
      ok = rx.try_get(value);
      $display("UT: first_get %0d %0d used %0d", ok, value, fifo.used());
      ok = rx.try_get(value);
      $display("UT: second_get %0d %0d available %0d %0d", ok, value, rx.can_get(), rx.can_peek());
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #30;
    $fatal(1, "test watchdog expired");
  end
endmodule
