/*
:name: test_blocking_put_port_forwards_values_to_fifo
:description: blocking put port calls deliver values to a connected FIFO in order (IEEE 1800.2-2020 Section 12.2.5.1)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.5.1 12.2.8.1.3 12.2.4.2.1 12.2.4.2.2 5.5.2.12 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_blocking_put_port_forwards_values_to_fifo.expected
*/
// Connect a typed put port to the FIFO export during connect phase.
// The FIFO has enough capacity for both immediate puts.

module test_blocking_put_port_forwards_values_to_fifo;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_blocking_put_port#(int) tx;
    uvm_tlm_fifo#(int) fifo;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      tx = new("tx", this);
      fifo = new("fifo", this, 2);
    endfunction
    function void connect_phase(uvm_phase phase); tx.connect(fifo.put_export); endfunction
    task run_phase(uvm_phase phase);
      int first;
      int second;
      phase.raise_objection(this);
      tx.put(13);
      tx.put(29);
      $display("UT: bindings %0d queued %0d", tx.size(), fifo.used());
      fifo.get(first);
      fifo.get(second);
      $display("UT: received %0d %0d empty %0d", first, second, fifo.is_empty());
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #30;
    $fatal(1, "test watchdog expired");
  end
endmodule
