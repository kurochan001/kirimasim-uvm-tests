/*
:name: test_tlm_fifo_flush_releases_capacity_to_an_already_blocked_producer
:description: flushing a full bounded FIFO lets an existing blocking writer enqueue its value (IEEE 1800.2-2020 Section 12.2.8.2.6)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.8.2.6 12.2.4.2.1 12.2.4.2.2 12.2.8.2.1 12.2.8.2.3 12.2.8.2.4 12.2.8.2.5
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_fifo_flush_releases_capacity_to_an_already_blocked_producer.expected
*/
// Positive delays establish waiting/completion states. No winner or fairness
// is required between simultaneous consumers or observers.
module test_tlm_fifo_flush_releases_capacity_to_an_already_blocked_producer;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_tlm_fifo#(int) fifo;
    bit returned = 0;
    int value = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      fifo = new("fifo", this, 1);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);

      fifo.put(17);
      fork
        begin fifo.put(42); returned = 1; end
        begin
          #1;
          $display("UT: before_flush blocked %0d full %0d used %0d",
               !returned, fifo.is_full(),
              fifo.used());
          fifo.flush();
        end
      join
      $display("UT: resumed %0d full %0d used %0d", returned, fifo.is_full(), fifo.used());
      fifo.get(value);
      $display("UT: value %0d empty %0d", value, fifo.is_empty());
      fifo.put(73); fifo.get(value);
      $display("UT: reusable value %0d empty %0d", value, fifo.is_empty());

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #40; $fatal(1, "FIFO concurrency watchdog expired"); end
endmodule
