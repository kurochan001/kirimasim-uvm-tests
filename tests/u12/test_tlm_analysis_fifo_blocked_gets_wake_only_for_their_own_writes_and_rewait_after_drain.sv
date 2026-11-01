/*
:name: test_tlm_analysis_fifo_blocked_gets_wake_only_for_their_own_writes_and_rewait_after_drain
:description: analysis FIFO write wakes its pending reader and an empty drained FIFO blocks again (IEEE 1800.2-2020 Section 12.2.8.3.2)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.8.3.2 12.2.4.2.2 12.2.8.2.3 12.2.8.2.4 12.2.8.3
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_analysis_fifo_blocked_gets_wake_only_for_their_own_writes_and_rewait_after_drain.expected
*/
// Positive delays establish waiting/completion states. No winner or fairness
// is required between simultaneous consumers or observers.
module test_tlm_analysis_fifo_blocked_gets_wake_only_for_their_own_writes_and_rewait_after_drain;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_tlm_analysis_fifo#(int) first_fifo;
    uvm_tlm_analysis_fifo#(int) second_fifo;
    int first = 0;
    int second = 0;
    bit first_done = 0;
    bit second_done = 0;
    bit fresh_done = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      first_fifo = new("first_fifo", this); second_fifo = new("second_fifo", this);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);

      fork
        begin first_fifo.get(first); first_done = 1; end
        begin second_fifo.get(second); second_done = 1; end
        begin
          #1;
          $display("UT: both_waiting %0d", !first_done && !second_done);
          first_fifo.write(17);
          #1;
          $display("UT: first_only %0d second_waiting %0d", first_done && first == 17,
              !second_done);
          second_fifo.write(42);
        end
      join
      $display("UT: both_done %0d second_value %0d both_empty %0d", first_done && second_done,
               second, first_fifo.is_empty() && second_fifo.is_empty());
      fork
        begin first_fifo.get(first); fresh_done = 1; end
        begin #1; $display("UT: rewait %0d", !fresh_done); first_fifo.write(73); end
      join
      $display("UT: fresh_value %0d empty %0d", first, first_fifo.is_empty());

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #40; $fatal(1, "FIFO concurrency watchdog expired"); end
endmodule
