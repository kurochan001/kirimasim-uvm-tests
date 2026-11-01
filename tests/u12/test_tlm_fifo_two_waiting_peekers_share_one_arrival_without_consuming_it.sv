/*
:name: test_tlm_fifo_two_waiting_peekers_share_one_arrival_without_consuming_it
:description: multiple pending peeks observe the same fresh head while preserving it for get (IEEE 1800.2-2020 Section 12.2.4.2.3)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.4.2.3 12.2.4.2.1 12.2.4.2.2 12.2.8.2.1 12.2.8.2.3 12.2.8.2.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_fifo_two_waiting_peekers_share_one_arrival_without_consuming_it.expected
*/
// Positive delays establish waiting/completion states. No winner or fairness
// is required between simultaneous consumers or observers.
module test_tlm_fifo_two_waiting_peekers_share_one_arrival_without_consuming_it;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_tlm_fifo#(int) fifo;
    int first = 0;
    int second = 0;
    int removed = 0;
    bit first_done = 0;
    bit second_done = 0;
    bit fresh_done = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      fifo = new("fifo", this, 1);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);

      fork
        begin fifo.peek(first); first_done = 1; end
        begin fifo.peek(second); second_done = 1; end
        begin
          #1;
          $display("UT: initially_waiting %0d empty %0d", !first_done && !second_done,
              fifo.is_empty());
          fifo.put(73);
        end
      join
      $display("UT: both_done %0d same_head %0d retained %0d", first_done && second_done,
               first == 73 && second == 73, fifo.used());
      fifo.get(removed);
      $display("UT: consumed value %0d empty %0d", removed, fifo.is_empty());
      fork
        begin fifo.peek(first); fresh_done = 1; end
        begin #1; $display("UT: rewait %0d", !fresh_done); fifo.put(91); end
      join
      $display("UT: fresh_head %0d retained %0d", first, fifo.used());

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #40; $fatal(1, "FIFO concurrency watchdog expired"); end
endmodule
