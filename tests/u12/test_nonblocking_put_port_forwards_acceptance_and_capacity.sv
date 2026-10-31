/*
:name: test_nonblocking_put_port_forwards_acceptance_and_capacity
:description: nonblocking put port forwards receiver capacity and acceptance results (IEEE 1800.2-2020 Section 12.2.5.1)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.5.1 12.2.8.1.3 12.2.4.2.4 12.2.4.2.5 12.2.4.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_nonblocking_put_port_forwards_acceptance_and_capacity.expected
*/
// Use a one-entry receiver. A rejected second put must not overwrite
// the accepted transaction, and a get restores availability.

module test_nonblocking_put_port_forwards_acceptance_and_capacity;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_nonblocking_put_port#(int) tx;
    uvm_tlm_fifo#(int) fifo;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      tx = new("tx", this);
      fifo = new("fifo", this, 1);
    endfunction
    function void connect_phase(uvm_phase phase); tx.connect(fifo.put_export); endfunction
    task run_phase(uvm_phase phase);
      bit first_ok;
      bit second_ok;
      bit get_ok;
      int value;
      phase.raise_objection(this);
      $display("UT: initially_available %0d", tx.can_put());
      first_ok = tx.try_put(13);
      second_ok = tx.try_put(29);
      $display("UT: put_results %0d %0d available %0d used %0d", first_ok, second_ok,
          tx.can_put(), fifo.used());
      get_ok = fifo.try_get(value);
      $display("UT: get %0d value %0d available %0d", get_ok, value, tx.can_put());
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #30;
    $fatal(1, "test watchdog expired");
  end
endmodule
