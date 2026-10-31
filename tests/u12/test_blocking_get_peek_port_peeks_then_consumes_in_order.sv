/*
:name: test_blocking_get_peek_port_peeks_then_consumes_in_order
:description: combined blocking get-peek port returns the same head before consuming it (IEEE 1800.2-2020 Section 12.2.5.1)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.5.1 12.2.8.1.4 12.2.4.2.2 12.2.4.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_blocking_get_peek_port_peeks_then_consumes_in_order.expected
*/
// Provide both entries before the blocking calls. Two peeks retain
// the head and occupancy; successive gets consume both entries.

module test_blocking_get_peek_port_peeks_then_consumes_in_order;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_blocking_get_peek_port#(int) rx;
    uvm_tlm_fifo#(int) fifo;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      rx = new("rx", this);
      fifo = new("fifo", this, 2);
    endfunction
    function void connect_phase(uvm_phase phase); rx.connect(fifo.get_peek_export); endfunction
    task run_phase(uvm_phase phase);
      int first;
      int second;
      phase.raise_objection(this);
      fifo.put(11);
      fifo.put(22);
      rx.peek(first);
      rx.peek(second);
      $display("UT: peeks %0d %0d used %0d", first, second, fifo.used());
      rx.get(first);
      rx.get(second);
      $display("UT: gets %0d %0d empty %0d", first, second, fifo.is_empty());
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #30;
    $fatal(1, "test watchdog expired");
  end
endmodule
