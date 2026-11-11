/*
:name: test_tlm_fifo_blocking_put_waits_until_space
:description: a blocking FIFO put waits until a get releases bounded capacity (IEEE 1800.2-2020 Section 12.2.4.2.1)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.4.2.1 12.2.4.2.2 12.2.8.2 12.2.8.2.3 12.2.8.2.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_fifo_blocking_put_waits_until_space.expected
*/
// What it checks:
// Blocking put waits until storage can accept its transaction.
//
// How the expected output follows from the standard:
// 1800.2-2020 12.2.4.2.1 (UVM-FIFO-BLOCKING-PUT) gives the rule above. Setup:
// Fill a one-entry FIFO, issue put, then remove the old entry after a delay.
// Expected: Put stays blocked while full and completes with the new value
// stored after space is freed.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Fill the FIFO before forking. A consumer waits a positive delay,
// observes the blocked writer, then removes the original entry.

module test_tlm_fifo_blocking_put_waits_until_space;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_tlm_fifo#(int) fifo;
    int removed = 0;
    int final_value = 0;
    bit returned = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      fifo = new("fifo", this, 1);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      fifo.put(3);
      fork
        begin fifo.put(9); returned = 1; end
        begin
          #1;
          $display("UT: waiting returned %0d used %0d full %0d", returned, fifo.used(),
              fifo.is_full());
          fifo.get(removed);
        end
      join
      fifo.get(final_value);
      $display("UT: completed returned %0d removed %0d final %0d empty %0d", returned,
          removed, final_value, fifo.is_empty());
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #30;
    $fatal(1, "test watchdog expired");
  end
endmodule
