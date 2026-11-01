/*
:name: test_tlm_fifo_two_waiting_consumers_remove_distinct_arrivals_without_assuming_a_winner
:description: each of two pending gets consumes one fresh FIFO arrival without duplication (IEEE 1800.2-2020 Section 12.2.4.2.2)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.4.2.2 12.2.4.2.1 12.2.8.2.1 12.2.8.2.3 12.2.8.2.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_fifo_two_waiting_consumers_remove_distinct_arrivals_without_assuming_a_winner.expected
*/
// Positive delays establish waiting/completion states. No winner or fairness
// is required between simultaneous consumers or observers.
module test_tlm_fifo_two_waiting_consumers_remove_distinct_arrivals_without_assuming_a_winner;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_tlm_fifo#(int) fifo;
    int first = 0;
    int second = 0;
    bit first_done = 0;
    bit second_done = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      fifo = new("fifo", this, 2);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);

      fork
        begin fifo.get(first); first_done = 1; end
        begin fifo.get(second); second_done = 1; end
        begin
          #1;
          $display("UT: initially_waiting %0d empty %0d", !first_done && !second_done,
              fifo.is_empty());
          fifo.put(17);
          #1;
          $display("UT: one_arrival one_done %0d empty %0d", first_done != second_done,
              fifo.is_empty());
          fifo.put(42);
        end
      join
      $display("UT: both_done %0d correct_pair %0d empty %0d", first_done && second_done,
               (first == 17 && second == 42) || (first == 42 && second == 17), fifo.is_empty());

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #40; $fatal(1, "FIFO concurrency watchdog expired"); end
endmodule
